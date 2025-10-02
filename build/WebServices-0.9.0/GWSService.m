 /** 
   Copyright (C) 2008 Free Software Foundation, Inc.
   
   Written by:  Richard Frith-Macdonald <rfm@gnu.org>
   Date:	January 2008
   
   This file is part of the WebServices Library.

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 3 of the License, or (at your option) any later version.
   
   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.
   
   You should have received a copy of the GNU Lesser General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.

   $Date: 2007-09-24 14:19:12 +0100 (Mon, 24 Sep 2007) $ $Revision: 25500 $
   */ 

#import <Foundation/Foundation.h>
#import "GWSPrivate.h"
#import <Performance/GSThreadPool.h>

static NSRecursiveLock	*queueLock = nil;
static unsigned perHostPool = 20;
static unsigned perHostQMax = 200;
static unsigned	shared = 200;
static unsigned	pool = 200;
static unsigned	qMax = 2000;
static unsigned	activeCount = 0;
static GSThreadPool		*workThreads = nil;
static NSMutableDictionary	*active = nil;
static NSMutableDictionary	*queues = nil;
static NSMutableArray		*queued = nil;
static NSMutableDictionary	*perHostReserve = nil;

#if	defined(GNUSTEP)
#import <GNUstepBase/NSURL+GNUstepBase.h>

static NSLock	                *handleLock = nil;
static NSMutableDictionary      *handles = nil;
static unsigned                 handleCount = 0;
#endif

#define	IOTHREADS	8
static BOOL			useIOThreads = NO;
static NSThread			*ioThreads[IOTHREADS] = { 0 };
static NSUInteger		ioRequests[IOTHREADS] = { 0 };
#if	defined(GNUSTEP)
static BOOL                     requestDebug = NO;
#endif

static inline void
threadAdd(NSThread **t)
{
  unsigned	index = IOTHREADS;
  NSUInteger	offset = NSNotFound;
  NSUInteger	count = NSNotFound;
  NSThread	*best = nil;

  while (index-- > 0)
    {
      if (ioRequests[index] < count)
	{
	  best = ioThreads[index];
	  count = ioRequests[index];
	  offset = index;
	}
    }
  ioRequests[offset]++;		// Record that we have added to this thread.
  *t = best;
}

static inline void
threadRem(NSThread **t)
{
  unsigned	index = IOTHREADS;

  while (index-- > 0)
    {
      if (ioThreads[index] == *t)
	{
	  ioRequests[index]--;	// Record that we have removed from this thread.
	}
    }
  *t = nil;
}

/* Return YES if there is an available slot to send a request to the
 * specified host, NO otherwise.
 * The global lock must be locked before this is called.
 */
static BOOL
available(NSString *host)
{
  if (activeCount >= pool)
    {
      return NO;
    }
  if (nil != host)
    {
      unsigned	inUse = [[active objectForKey: host] count];

      if (activeCount < shared)
	{
	  /* There are shared connections available ... we can have one
	   * as long as the number of connections for this host has not
	   * been reached.
	   */
	  if (inUse < perHostPool)
	    {
	      return YES;
	    }
	}
      else if (0 == inUse && [[perHostReserve objectForKey: host] intValue] > 0)
	{
	  /* No shared connections, but we can use the one reserved for
	   * this host because there are none in use.
	   */
	  return YES;
	}
    }
  return NO;
}

/* To support client side SSL certificate authentication we use the old
 * NSURLHandle stuff with GNUstep extensions.  We use the _connection
 * ivar to hold the handle in this case.
 */
#define	handle	((NSURLHandle*)_connection)

#if	defined(GNUSTEP)
@interface	NSURLHandle (Debug)
- (int) setDebug: (int)flag;
- (void) setReturnAll: (BOOL)flag;
@end
@interface	NSURLRequest (Debug)
- (int) setDebug: (int)flag;
@end
#endif

@implementation	GWSService (Private)

+ (void) _never: (NSTimer*)t
{
  return;
}

+ (void) _run: (NSString*)host
{
  NSMutableArray	*a = nil;
  NSUInteger		index;
  NSUInteger		count;

  [queueLock lock];
  if (activeCount < pool && [queued count] > 0)
    {
      if (available(host) == YES)
	{
	  NSArray	*q = [queues objectForKey: host];

	  count = [q count];
	  for (index = 0; index < count; index++)
	    {
	      GWSService	*svc = [q objectAtIndex: index];

	      if (svc->_request != nil)
		{
		  /* Found a service which is ready to send ...
		   */
		  [svc _activate];
		  if (nil == a)
		    {
		      a = [[NSMutableArray alloc] initWithCapacity: 100];
		    }
		  [a addObject: svc];
		  break;
		}
	    }
	}
      for (index = 0; activeCount < pool && index < [queued count]; index++)
	{
	  GWSService	*svc = [queued objectAtIndex: index];

	  if (svc->_request != nil)
	    {
	      if (available([svc->_connectionURL host]) == YES)
		{
		  [svc _activate];
		  if (nil == a)
		    {
		      a = [[NSMutableArray alloc] initWithCapacity: 100];
		    }
		  [a addObject: svc];
		}
	    }
	}
    }
  [queueLock unlock];
  count = [a count];
  if (count > 0)
    {
      for (index = 0; index < count; index++)
	{
	  GWSService	*svc = [a objectAtIndex: index];
	
	  if (YES == useIOThreads)
	    {
	      threadAdd(&svc->_ioThread);
	    }
	  else
	    {
	      svc->_ioThread = svc->_queueThread;
	    }
	  [svc performSelector: @selector(_start)
		      onThread: svc->_ioThread
		    withObject: nil
		 waitUntilDone: NO];
	}
    }
  [a release];
}

+ (void) _runThread
{
  NSAutoreleasePool	*pool = [NSAutoreleasePool new];
  NSDate		*forever = [NSDate distantFuture];

  [NSTimer scheduledTimerWithTimeInterval: [forever timeIntervalSinceNow]
				   target: self
				 selector: @selector(_never:)
				 userInfo: nil
				  repeats: NO];
  [[NSRunLoop currentRunLoop] run];
  [pool release];
}

/* NB. This must be called with the global lock already locked.
 */
- (void) _activate
{
  NSString		*host;
  NSMutableArray	*hostQueue;

  /* Add self to active list.
   * Keep the count of active requests up to date.
   */
  host = [_connectionURL host];
  hostQueue = [active objectForKey: host];
  if (hostQueue == nil)
    {
      hostQueue = [NSMutableArray new];
      [active setObject: hostQueue forKey: host];
      [hostQueue release];
    }
  [hostQueue addObject: self];
  activeCount++;

  /* The next two lines will do nothing if the receiver was not
   * queued before activation.  We need them for the case where
   * we were queued and are now being activated.
   * Removal from the queue is done *after* addition to the
   * active list to ensure that the receiver is not deallocated.
   */
  [[queues objectForKey: host] removeObjectIdenticalTo: self];
  [queued removeObjectIdenticalTo: self];
}

- (BOOL) _beginMethod: (NSString*)method 
            operation: (NSString**)operation
	         port: (GWSPort**)port
{
  /* Perhaps the values are being set directly ... if so, we trust them
   */
  if (operation && *operation && port && *port)
    {
      NSString	*o = [*operation retain];
      GWSPort	*p = [*port retain];

      [_operation release];
      _operation = o;
      [_port release];
      _port = p;
      return YES;
    }

  if (nil != _operation)
    {
      [_operation autorelease];
      _operation = nil;
    }
  if (nil != _port)
    {
      [_port autorelease];
      _port = nil;
    }

  if (nil == _document)
    {
      _operation = [method retain];
    }
  else
    {
      NSRange		r;
      NSString		*portName;
      NSEnumerator	*enumerator;
      GWSElement	*elem;
      GWSPortType	*portType;
      GWSBinding	*binding;
      GWSPort		*found;

      /* As this is not a standalone service, we must set up information from
       * the parsed WSDL document.
       */

      /* Look through the ports declared in this service for one with an
       * operation uniquely matching the method.  Get details by looking up
       * bindings, since we can't actually use a port/operation if there
       * is no binding for it.
       */
      found = nil;
      portName = nil;
      enumerator = [_ports objectEnumerator];
      while ((_port = [enumerator nextObject]) != nil)
	{
	  binding = [_port binding];
	  portType = [binding type];
	  if (portType != nil)
	    {
	      elem = [[portType operations] objectForKey: method];
	      if (elem != nil)
		{
		  if (nil == portName)
		    {
		      portName = [portType name];	// matched
		      found = _port;
		    }
		  else
		    {
		      found = nil;			// not unique
		      _port = nil;
		      break;
		    }
		}
	    }
	}

      if (nil != found)
	{
	  _operation = [method copy];
	  _port = [found retain];
	}
      else if (1 == (r = [method rangeOfString: @"."]).length)
	{
	  /* No unique operation ... but our method name uses dot
	   * syntax to specify port and operation.
	   */
	  portName = [method substringToIndex: r.location];
	  _operation = [method substringFromIndex: NSMaxRange(r)];
	  [_operation retain];

	  /* Look through the ports declared in this service for one matching
	   * the port name and operation name.  Get details by looking up
	   * bindings, since we can't actually use a port/operation if there
	   * is no binding for it.
	   */
	  enumerator = [_ports objectEnumerator];
	  while ((_port = [enumerator nextObject]) != nil)
	    {
	      binding = [_port binding];
	      portType = [binding type];
	      if (portType != nil)
		{
		  elem = [[portType operations] objectForKey: _operation];
		  if (elem != nil && [portName isEqual: [portType name]])
		    {
		      break;	// matched
		    }
		}
	    }
	  [_port retain];
	}

      if (nil == _port)
	{
	  [self _clean];
	  [self _setProblem: [NSString stringWithFormat:
	    @"Unable to find unique operation or port.operation matching '%@'",
	    method]];
	  return NO;
	}
    }
  if (operation != 0)
    {
      *operation = _operation;
    }
  if (port != 0)
    {
      *port = _port;
    }
  return YES;
}

- (void) _clean
{
  [_timeout release];
  _timeout = nil;
  [_prepMethod release];
  _prepMethod = nil;
  [_prepParameters release];
  _prepParameters = nil;
  [_prepOrder release];
  _prepOrder = nil;
  [_queueThread release];
  _queueThread = nil;
  [_operation release];
  _operation = nil;
  [_parameters release];
  _parameters = nil;
  [_port release];
  _port = nil;
  [_request release];
  _request = nil;
}

- (void) _clearConnection
{
  if (_connection)
    {
      id        obj = _connection;

      _connection = nil;
#if	defined(GNUSTEP)
      if ([obj isKindOfClass: [NSURLHandle class]])
        {
          [handleLock lock];
          if (handleCount < pool + 16)
            {
              NSString  *k = [_connectionURL cacheKey];

              if (k)
                {
                  NSMutableArray        *a = [handles objectForKey: k];

                  if (nil == a)
                    {
                      a = [NSMutableArray array];
                      [handles setObject: a forKey: k];
                    }
                  [a addObject: obj];
                  handleCount++;
                }
            }
          [handleLock unlock];
        }
#endif
      [obj release];
    }
}

- (void) _completed
{
  /* We can safely call this more than once, since we do nothing unless
   * a request is actually in progress.
   */
  if (nil == _queueThread)
    {
      return;
    }

  /* Check that this is running in the thread which queued it.
   */
  if ([NSThread currentThread] != _queueThread)
    {
      [self performSelector: @selector(_completed)
		   onThread: _queueThread
		 withObject: nil
	      waitUntilDone: NO];
    }
  else
    {
      NSString		*host;
      NSMutableArray	*a;
      NSUInteger	index;

      [_timer invalidate];
      _timer = nil;
      if ([self debug] == YES)
	{
	  if (_request != nil)
	    {
	      [_result setObject: _request forKey: GWSRequestDataKey];
	    }
	  if (_response != nil)
	    {
	      [_result setObject: _response forKey: GWSResponseDataKey];
	    }
	}
      [self _clean];

      /* Retain self and host in case the delegate changes the URL
       * or releases us (or removing self from active list would
       * cause deallocation).
       */
      [[self retain] autorelease];
      host = [[[_connectionURL host] retain] autorelease];

      /* Now make sure the receiver is no longer active.
       * This must be done before informing the delegate of
       * completion, in case the delegate wants to schedule
       * another request to the same host.
       */
      [queueLock lock];
      a = [active objectForKey: host];
      index = [a indexOfObjectIdenticalTo: self];
      if (index == NSNotFound)
	{
	  /* Must have timed out while still in local queue.
	   */
	  [[queues objectForKey: host] removeObjectIdenticalTo: self];
	  [queued removeObjectIdenticalTo: self];
	}
      else
	{
	  [a removeObjectAtIndex: index];
	  activeCount--;
	}
      [queueLock unlock];
      [GWSService _run: host];	// start any queued requests for host

      if ([_delegate respondsToSelector: @selector(completedRPC:)])
	{
	  [_delegate completedRPC: self];
	}
    }
}

- (void) _completedIO
{
  /* Must be called in locked region and when _ioThread is not nil!
   * Once I/O has been completed, we can't time out ... the RPC has
   * either failed or succeeded. 
   */
  _completedIO = YES;
  threadRem(&_ioThread);
  [_timer invalidate];
  _timer = nil;
}

- (BOOL) _enqueue
{
  NSString	*host = [_connectionURL host];
  BOOL		result = NO;

  if (nil != host)
    {
      NSMutableArray	*hostQueue;
      NSInteger		used;

      [queueLock lock];
      result = YES;
      hostQueue = [queues objectForKey: host];
      used = (NSInteger)[hostQueue count];
      if ([queued count] >= qMax)
	{
	  result = NO;	// Too many queued in total.
	}
      else if (used >= (NSInteger)perHostQMax)
	{
	  result = NO;	// Too many queued for an individual host.
	}
      if (NO == result && used < [[perHostReserve objectForKey: host] intValue])
	{
	  result = YES;	// Reserved space for this host was not filled.
	}
      if (YES == result)
	{
	  if (hostQueue == nil)
	    {
	      hostQueue = [NSMutableArray new];
	      [queues setObject: hostQueue forKey: host];
	      [hostQueue release];
	    }
	  if (YES == _prioritised)
	    {
	      unsigned	count;
	      unsigned	index;

	      count = [hostQueue count];
	      for (index = 0; index < count; index++)
		{
		  GWSService	*tmp = [hostQueue objectAtIndex: index];

		  if (tmp->_prioritised == NO)
		    {
		      break;
		    }
		}
	      [hostQueue insertObject: self atIndex: index];

	      count = [queued count];
	      for (index = 0; index < count; index++)
		{
		  GWSService	*tmp = [queued objectAtIndex: index];

		  if (tmp->_prioritised == NO)
		    {
		      break;
		    }
		}
	      [queued insertObject: self atIndex: index];
	    }
	  else
	    {
	      [hostQueue addObject: self];
	      [queued addObject: self];
	    }
	  _stage = RPCQueued;
	}
      [queueLock unlock];
    }
  return result;
}

- (id) _initWithName: (NSString*)name document: (GWSDocument*)document
{
  if ((self = [super init]) != nil)
    {
      GWSElement        *elem;

      _lock = [NSRecursiveLock new];
#if	!defined(GNUSTEP)
      _newAPI = YES;
#endif
      _SOAPAction = @"\"\"";
      _debug = [[NSUserDefaults standardUserDefaults] boolForKey: @"GWSDebug"];
      _name = [name copy];
      _document = document;
      elem = [_document initializing];
      elem = [elem firstChild];
      if ([[elem name] isEqualToString: @"documentation"] == YES)
        {
          _documentation = [elem retain];
          elem = [elem sibling];
          [_documentation remove];
        }
      while (elem != nil && [[elem name] isEqualToString: @"port"] == YES)
        {
          GWSElement    *used = nil;
          NSString      *name;
          NSString      *binding;

          name = [[elem attributes] objectForKey: @"name"];
          binding = [[elem attributes] objectForKey: @"binding"];
          if (name == nil)
            {
              NSLog(@"Port without a name in WSDL!");
            }
          else if (binding == nil)
            {
              NSLog(@"Port named '%@' without a binding in WSDL!", name);
            }
          else if ([_document bindingWithName: binding create: NO] == nil)
	    {
              NSLog(@"Port named '%@' with binding '%@' in service but "
		@"not in bindings", name, binding);
	    }
	  else
            {
              GWSPort	*port;

              port = [[GWSPort alloc] _initWithName: name
					   document: _document
					       from: elem];
              if (_ports == nil)
                {
                  _ports = [NSMutableDictionary new];
                }
              if (port != nil)
                {
                  [_ports setObject: port forKey: [port name]];
                  [port release];
                }
              used = elem;
            }
          elem = [elem sibling];
          [used remove];
        }
      while (elem != nil)
        {
	  NSString	*problem;

	  problem = [_document _validate: elem in: self];
	  if (problem != nil)
	    {
	      NSLog(@"Bad service extensibility: %@", problem);
	    }
          if (_extensibility == nil)
            {
              _extensibility = [NSMutableArray new];
            }
          [_extensibility addObject: elem];
          elem = [elem sibling];
          [[_extensibility lastObject] remove];
        }
    }
  return self;
}

/* Method to be run from thread pool in order to prepare request data
 * to be sent.
 */
- (void) _prepare
{
  static NSData		*empty = nil;
  int                   stage;
  NSData		*req;
  NSString              *pm;
  NSDictionary          *pp;
  NSArray               *po;

  if (nil == empty)
    {
      empty = [NSData new];
    }

  [_lock lock];
  stage = _stage;
  _stage = RPCPreparing;
  pm = _prepMethod;
  _prepMethod = nil;
  pp = _prepParameters;
  _prepParameters = nil;
  po = _prepOrder;
  _prepOrder = nil;
  NS_DURING
    {
      if (_parameters != nil)
        {
          NSLog(@"Problem preparing RPC for %@: Earlier operation"
            @" still in progress", self);
          req = nil;
        }
      else
        {
          if ([_delegate respondsToSelector:
            @selector(webService:buildRequest:parameters:order:)] == YES)
            {
              req = [_delegate webService: self
                             buildRequest: pm
                               parameters: pp
                                    order: po];
            }
          else
            {
              req = nil;
            }
          if (nil == req)
            {
              req = [self buildRequest: pm
                            parameters: pp
                                 order: po];
            }
          if ([_delegate respondsToSelector:
            @selector(webService:willSendRequest:)] == YES)
            {
              req = [_delegate webService: self willSendRequest: req];
            }
        }
    }
  NS_HANDLER
    {
      NSLog(@"Problem preparing RPC for %@: %@", self, localException);
      req = nil;
    }
  NS_ENDHANDLER
  [_lock unlock];

  [pm release];
  [pp release];
  [po release];
  /* We can't send a nil request ... so we use an empty data object
   * instead if necessary.
   */
  if (nil == req)
    {
      req = empty;
    }
  /* We must use a lock around the changes we actually make so that a
   * call to _run: in another thread won't pick this one up prematurely.
   */
  [queueLock lock];
  _request = [req retain];
  _stage = stage;
  [queueLock unlock];
}

- (void) _prepareAndRun
{
  [self _prepare];

  /* Make sure that this is de-queued and run if possible.
   */
  [GWSService _run: [_connectionURL host]];
}

- (void) _received
{
  if (_result != nil && [_result objectForKey: GWSErrorKey] != nil)
    {
      return;   // Already failed (eg timeout part way through reading).
    }

  if (_code != 200 && [_coder isKindOfClass: [GWSXMLRPCCoder class]] == YES)
    {
      NSString	*str;

      str = [NSString stringWithFormat: @"HTTP status %03d", _code];
      [self _setProblem: str];
    }
  else if (_code != 204 && [_response length] == 0)
    {
      NSString	*str;

      /* Unless we got a 204 response, we expect to have a body to parse.
       */
      if (_code == 200)
	{
          str = [NSString stringWithFormat: @"HTTP status 200 but no body"];
	}
      else
	{
          str = [NSString stringWithFormat: @"HTTP status %03d", _code];
	}
      [self _setProblem: str];
    }
  else
    {
      /* OK ... parse the body ... which should contain some sort of data
       * unless we had a 204 response (some services may accept an empty
       * response, even though xmlrpc and soap do not).
       */
      NS_DURING
	{
          NSMutableDictionary   *res = nil;

	  if ([_delegate respondsToSelector:
	    @selector(webService:handleResponse:)] == YES)
            {
              res = [_delegate webService: self handleResponse: _response];
            }
          if (nil == res)
            {
              if ([_delegate respondsToSelector:
                @selector(webService:willHandleResponse:)] == YES)
                {
                  NSData	*data;

                  data = [_delegate webService: self
                            willHandleResponse: _response];
                  if (data != _response)
                    {
                      [_response release];
                      _response = [data mutableCopy];
                    }
                }
              res = [_coder parseMessage: _response];
            }
          _result = [res retain];
	}
      NS_HANDLER
	{
	  id	reason = [localException reason];
	  id	keys[1];

	  keys[0] = GWSFaultKey;
	  _result = [[NSMutableDictionary alloc] initWithObjects: &reason
						         forKeys: keys
							   count: 1];
	}
      NS_ENDHANDLER
    }

  [self _completed];
}

- (void) _remove
{
  _document = nil;
}

- (void) _setProblem: (NSString*)s
{
  if (_result == nil)
    {
      _result = [NSMutableDictionary new];
    }
  [_result setObject: s forKey: GWSErrorKey];
}

- (NSString*) _setupFrom: (GWSElement*)element in: (id)section
{
  NSString	*n;

  n = [element namespace];
  if ([n length] == 0)
    {
      /* No namespace recorded directly in the element ... 
       * See if the document has a namespace for the element's prefix.
       */
      n = [element prefix];
      if (n == nil)
	{
	  n = @"";
	}
      n = [_document namespaceForPrefix: n];
    }
  if (n != nil)
    {
      GWSExtensibility	*e = [_document extensibilityForNamespace: n];

      if (e != nil)
	{
	  return [e validate: element for: _document in: section setup: self];
	}
    }
  return nil;
}

- (void) _start
{
  NSData        *toSend;
  NSString      *method;

  [_lock lock];
  if (YES == _cancelled)
    {
      threadRem(&_ioThread);
      [_lock unlock];
      [self _completed];
      return;
    }
  _stage = RPCActive;
  toSend = [_request retain];
  if (nil == (method = [_HTTPMethod retain]))
    {
      method = @"POST";
    }
  [_lock unlock];

  /* Now we initiate the asynchronous I/O process.
   */
  _code = 0;
  if (YES == _newAPI && nil == _clientCertificate 
#if	defined(GNUSTEP)
/* GNUstep has better debugging with NSURLHandle than NSURLConnection
 */
&& [self debug] == NO
#endif
    )
    {
      NSMutableURLRequest   *request;

      request = [NSMutableURLRequest alloc];
      request = [request initWithURL: _connectionURL];
      [request setCachePolicy: NSURLRequestReloadIgnoringCacheData];
      [request setHTTPMethod: method];  
      [request setValue: @"GWSService/0.1.0" forHTTPHeaderField: @"User-Agent"];
      if (nil == _contentType)
        {
          [request setValue: @"text/xml" forHTTPHeaderField: @"Content-Type"];
        }
      else
        {
          [request setValue: _contentType forHTTPHeaderField: @"Content-Type"];
        }
      if (_SOAPAction != nil)
	{
	  [request setValue: _SOAPAction forHTTPHeaderField: @"SOAPAction"];
	}
      if ([_headers count] > 0)
	{
	  NSEnumerator	*e = [_headers keyEnumerator];
	  NSString	*k;

	  while ((k = [e nextObject]) != nil)
	    {
	      NSString	*v = [_headers objectForKey: k];

	      [request setValue: v forHTTPHeaderField: k];
	    }
	}
      [request setHTTPBody: toSend];
#if	defined(GNUSTEP)
      if (YES == requestDebug)
        {
          if ([self debug])
            {
              [request setDebug: YES];
              [request setDebugLogDelegate: self];
            }
          else
            {
              [request setDebug: NO];
              [request setDebugLogDelegate: nil];
            }
        }
#endif
      [self _clearConnection];
      _connection = [NSURLConnection alloc];
      _response = [[NSMutableData alloc] init];
      _connection = [_connection initWithRequest: request delegate: self];
      [request release];
    }
  else
    {
#if	defined(GNUSTEP)
      if (_connection == nil)
	{
          NSString      *k;

          [handleLock lock];
          if ((k = [_connectionURL cacheKey]) != nil)
            {
              NSMutableArray    *a = [handles objectForKey: k];

              if ([a count])
                {
                  _connection = RETAIN([a firstObject]);
                  [a removeObjectAtIndex: 0];
                  if (0 == [a count])
                    {
                      [handles removeObjectForKey: k];
                    }
                  handleCount--;
                }
            }
          [handleLock unlock];
          NS_DURING
            {
              /* If a cached handle was found, we have to adjust its URL
               * to be the one we are using.  This can raise an exception
               * if the handle is in use, which should never happen.
               */
              [handle setURL: _connectionURL];
            }
          NS_HANDLER
            {
              DESTROY(_connection);
              NSLog(@"[%@-%@] problem with handle cache: %@",
                NSStringFromClass([self class]), NSStringFromSelector(_cmd),
                localException);
            }
          NS_ENDHANDLER
        }
          
      if (_connection == nil)
	{
          _connection = (NSURLConnection*)[[_connectionURL
	    URLHandleUsingCache: NO] retain];
	}
      if ([self debug])
        {
          [handle setDebug: YES];
          [(id)handle setDebugLogDelegate: self];
        }
      else
        {
          [handle setDebug: NO];
          [(id)handle setDebugLogDelegate: nil];
        }
      [handle setReturnAll: YES];
      if (_clientCertificate != nil)
	{
	  [handle writeProperty: _clientCertificate 
			 forKey: GSHTTPPropertyCertificateFileKey];
	}
      if (_clientKey != nil)
	{
	  [handle writeProperty: _clientKey forKey: GSHTTPPropertyKeyFileKey];
	}
      if (_clientPassword != nil)
	{
	  [handle writeProperty: _clientPassword
			 forKey: GSHTTPPropertyPasswordKey];
	}
      if (_SOAPAction != nil)
	{
	  [handle writeProperty: _SOAPAction forKey: @"SOAPAction"];
	}
      [handle addClient: (id<NSURLHandleClient>)self];
      [handle writeProperty: method forKey: GSHTTPPropertyMethodKey];
      [handle writeProperty: @"GWSService/0.1.0" forKey: @"User-Agent"];
      if (nil == _contentType)
        {
          [handle writeProperty: @"text/xml" forKey: @"Content-Type"];
        }
      else
        {
          [handle writeProperty: _contentType forKey: @"Content-Type"];
        }
      if ([_headers count] > 0)
	{
	  NSEnumerator	*e = [_headers keyEnumerator];
	  NSString	*k;

	  while ((k = [e nextObject]) != nil)
	    {
	      NSString	*v = [_headers objectForKey: k];

	      [handle writeProperty: v forKey: k];
	    }
	}
      [handle writeData: toSend];
      [handle loadInBackground];
#endif
    }
  NSAssert(nil != toSend, NSInternalInconsistencyException);
  [method release];
  [toSend release];
}

@end


@implementation	GWSService

+ (void) initialize
{
  if (self == [GWSService class])
    {
#if	defined(GNUSTEP)
      requestDebug = [[NSMutableURLRequest class]
        instancesRespondToSelector: @selector(setDebug:)];
      handleLock = [NSLock new];
      handles = [NSMutableDictionary new];
#endif
      queueLock = [NSRecursiveLock new];
      active = [NSMutableDictionary new];
      queues = [NSMutableDictionary new];
      queued = [NSMutableArray new];
      perHostReserve = [NSMutableDictionary new];
      workThreads = [GSThreadPool new];
      [workThreads setThreads: 0];
      [workThreads setOperations: pool * 2];
    }
}

+ (NSString*) description
{
  NSString	*result;

  [queueLock lock];
  if (0 == [workThreads maxThreads])
    {
      result = [NSString stringWithFormat: @"GWSService async request status..."
        @" Pool: %u (per host: %u) Active: %@ Queues: %@\n",
        pool, perHostPool, active, queues];
    }
  else
    {
      result = [NSString stringWithFormat: @"GWSService async request status..."
        @" Pool: %u (per host: %u) Active: %@ Queues: %@\nWorkers: %@\n",
        pool, perHostPool, active, queues, workThreads];
    }
  if (YES == useIOThreads)
    {
      unsigned	i;

      for (i = 0; i < IOTHREADS; i++)
	{
	  if (ioRequests[i] > 0)
	    {
	      result = [result stringByAppendingFormat:
		@"  Thread %u ... %u current.\n", i, (unsigned)ioRequests[i]];
	    }
	}
    }
  [queueLock unlock];
  return result;
}

+ (void) flushConnections: (NSURL*)url
{
  ENTER_POOL
  NSString      *key = [url cacheKey];

  /* The connections removed are retained and autoreleased so that
   * they get released when the pool is emptied outside the locked
   * region.  Any exception during their destruction should not
   * mess up the locking.
   */
  [handleLock lock];
  if (key)
    {
      NSArray   *a = AUTORELEASE(RETAIN([handles objectForKey: key]));

      handleCount -= [a count];
      [handles removeObjectForKey: key];
    }
  else
    {
      [handles allValues];      // preserve the objects
      handleCount = 0;
      [handles removeAllObjects];
    }
  [handleLock unlock];
  LEAVE_POOL
}

+ (void) setPerHostPool: (unsigned)max
{
  [queueLock lock];
  if (max < 1)
    {
      max = 1;
    }
  if (max != perHostPool)
    {
      if (max > pool)
	{
	  max = pool;
	}
      perHostPool = max;
    }
  [queueLock unlock];
}

+ (void) setPerHostQMax: (unsigned)max
{
  perHostQMax = max;
}

+ (void) setPool: (unsigned)max
{
  [queueLock lock];
  if (max < [perHostReserve count] + 1)
    {
      max = [perHostReserve count] + 1;
    }
  if (max != pool)
    {
      if (max > perHostPool)
	{
	  perHostPool = max;
	}
      pool = max;
    }
  shared = pool - [perHostReserve count];
  [workThreads setOperations: pool * 2];
  [queueLock unlock];
}

+ (void) setQMax: (unsigned)max
{
  qMax = max;
}

+ (void) setReserve: (unsigned)reserve forHost: (NSString*)host
{
  [queueLock lock];
  if (0 == reserve)
    {
      [perHostReserve removeObjectForKey: host];
    }
  else
    {
      // is there a better way to maintain backward compatibility?
#if !defined(GNUSTEP) && (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_4)
      [perHostReserve setObject: [NSNumber numberWithInt: reserve]
			 forKey: host];
#else
      [perHostReserve setObject: [NSNumber numberWithInteger: reserve]
			 forKey: host];
#endif
    }
  if (pool <= [perHostReserve count])
    {
      pool = [perHostReserve count] + 1;
    }
  shared = pool - [perHostReserve count];
  [queueLock unlock];
}

+ (void) setUseIOThreads: (BOOL)aFlag
{
  [queueLock lock];
  if (aFlag != useIOThreads)
    {
      if (YES == aFlag && nil == ioThreads[0])
	{
	  unsigned	i;

	  for (i = 0; i < IOTHREADS; i++)
	    {
	      ioThreads[i] = [[NSThread alloc] initWithTarget: self
		selector: @selector(_runThread) object: nil];
	      [ioThreads[i] start];
	    }
	}
      useIOThreads = aFlag;
    }
  [queueLock unlock];
}

+ (void) setWorkThreads: (NSUInteger)count
{
  [workThreads setThreads: count];
}

- (NSData*) buildRequest: (NSString*)method 
              parameters: (NSDictionary*)parameters
                   order: (NSArray*)order
{
  NSData        *req;

  if (_parameters != nil)
    {
      [_parameters autorelease];
      _parameters = nil;
    }

  if ([self _beginMethod: method operation: 0 port: 0] == NO)
    {
      return nil;
    }

  /* Take a mutable copy of the parameters so that we can add keys to it
   * to control encoding options.
   * If there was no parameters dictionary, create an empty one to use.
   */
  _parameters = [parameters mutableCopy];
  if (_parameters == nil)
    {
      _parameters = [NSMutableDictionary new];
    }
  if (order != nil)
    {
      /* Store the ordering so that extensions can find it.
       */
      [_parameters setObject: order forKey: GWSOrderKey];
    }

  /* If this is not a standalone service, we must set up information from
   * the parsed WSDL document.  Otherwise we just use whatever has been
   * set via the API.
   */
  if (_port != nil)
    {
      NSEnumerator	*enumerator;
      GWSElement	*elem;
      GWSElement	*operation;
      GWSBinding	*binding;
      GWSPortType	*portType;
      NSString		*problem;
      NSArray		*order;

      /* Handle extensibility for port ...
       * With SOAP this supplies the URL that we should send to.
       */
      enumerator = [[_port extensibility] objectEnumerator];
      while ((elem = [enumerator nextObject]) != nil)
	{
	  problem = [self _setupFrom: elem in: _port];
	  if (problem != nil)
	    {
	      [self _clean];
	      [self _setProblem: problem];
	      return nil;
	    }
	}

      /* Handle SOAP binding ... this supplies the encoding style and
       * transport that we should used.
       */
      binding = [_port binding];
      enumerator = [[binding extensibility] objectEnumerator];
      while ((elem = [enumerator nextObject]) != nil)
	{
	  problem = [self _setupFrom: elem in: binding];
	  if (problem != nil)
	    {
	      [self _clean];
	      [self _setProblem: problem];
	      return nil;
	    }
	}

      /* Now look at operation specific parameter ordering defined in
       * the abstract operation in the portType. 
       */
      portType = [binding type];
      operation = [[portType operations] objectForKey: _operation];
      order = [[[operation attributes] objectForKey: @"parameterOrder"]
	componentsSeparatedByString: @" "];
      if ([order count] > 0)
	{
	  NSMutableArray	*m = [order mutableCopy];
	  unsigned		c = [m count];

	  while (c-- > 0)
	    {
	      NSString	*s = [order objectAtIndex: c];

	      if ([_parameters objectForKey: s] == nil)
		{
		  /* Item is not present in parameters dictionary so
		   * presumably it' an output parameter rather than
		   * an input parameter ad we can ignore it.
		   */
		  [m removeObjectAtIndex: c];
		}
	    }
	  if ([m count] > 0)
	    {
	      /* Add the ordering information to the parameters dictionary
	       * so that the coder will be able to use it.
	       */
	      [_parameters setObject: m forKey: GWSOrderKey];
	    }
	  [m release];
	}

      /* Next we can examine the specific operation binding information.
       */
      elem = [binding operationWithName: _operation create: NO];
      elem = [elem firstChild];
      while (elem != nil
	&& [[elem name] isEqualToString: @"input"] == NO
	&& [[elem name] isEqualToString: @"output"] == NO)
	{
	  problem = [self _setupFrom: elem in: binding];
	  if (problem != nil)
	    {
	      [self _clean];
	      [self _setProblem: problem];
	      return nil;
	    }
	  elem = [elem sibling];
	}
      if ([[elem name] isEqualToString: @"input"] == YES)
	{
	  elem = [elem firstChild];
	  while (elem != nil)
	    {
	      problem = [self _setupFrom: elem in: binding];
	      if (problem != nil)
		{
		  [self _clean];
		  [self _setProblem: problem];
		  return nil;
		}
	      elem = [elem sibling];
	    }
	}
    }

  if (_coder == nil)
    {
      [self _clean];
      [self _setProblem: @"no coder set  (use -setCoder:)"];
      return nil;
    }
  [_coder setDebug: [self debug]];
  req = [_coder buildRequest: method parameters: _parameters order: order];
  return req;
}

- (GWSCoder*) coder
{
  return _coder;
}

- (GWSElement*) coder: (GWSSOAPCoder*)coder didEncode: (GWSElement*)element
{
  if ([_delegate respondsToSelector: @selector(webService:didEncode:)] == YES)
    {
      element = [_delegate webService: self didEncode: element];
    }
  return element;
}

- (GWSElement*) coder: (GWSSOAPCoder*)coder willDecode: (GWSElement*)element
{
  if ([_delegate respondsToSelector: @selector(webService:willDecode:)] == YES)
    {
      element = [_delegate webService: self willDecode: element];
    }
  return element;
}

- (GWSElement*) coder: (GWSSOAPCoder*)coder willEncode: (GWSElement*)element
{
  if ([_delegate respondsToSelector: @selector(webService:willEncode:)] == YES)
    {
      element = [_delegate webService: self willEncode: element];
    }
  return element;
}

- (BOOL) compact
{
  return _compact;
}

- (void) dealloc
{
  NSAssert(nil == _timer, NSInternalInconsistencyException);
  [self _clean];
  [_coder release];
  _coder = nil;
  [_tz release];
  [_result release];
  [self _clearConnection];
  [_response release];
  [_connectionURL release];
  [_documentation release];
  [_extensibility release];
  [_SOAPAction release];
  [_HTTPMethod release];
  [_ports release];
  [_name release];
  [_headers release];
  [_extra release];
  [_lock release];
  [super dealloc];
}

- (BOOL) debug
{
  return _debug;
}

- (id) delegate
{
  return _delegate;
}

- (GWSElement*) documentation
{
  return _documentation;
}

/* Method called as debug logging delegate for GNUstep APIs
 */
- (BOOL) getBytes: (const uint8_t*)bytes
         ofLength: (NSUInteger)length
         byHandle: (NSObject*)anObject
{
  if ([_delegate respondsToSelector: _cmd])
    {
      return [_delegate getBytes: bytes ofLength: length byHandle: self];
    }
  return NO;	// Use default logging
}

- (NSDictionary*) headers
{
  return _headers;
}

- (id) init
{
  return [self _initWithName: nil document: nil];
}

- (NSMutableDictionary*) invokeMethod: (NSString*)method 
                           parameters: (NSDictionary*)parameters
                                order: (NSArray*)order
                              timeout: (int)seconds
{
  if (_result != nil)
    {
      [_result release];
      _result = nil;
    }
  NS_DURING
    {
      if ([self sendRequest: method
                 parameters: parameters
                      order: order
                    timeout: seconds] == YES)
	{
	  NSDate	*when = [[[_timer fireDate] retain] autorelease];

	  while (_timeout != nil)
	    {
	      [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode
				       beforeDate: when];
	    }
	}
    }
  NS_HANDLER
    {
      [self _setProblem: [localException description]];
    }
  NS_ENDHANDLER

  return _result;  
}

- (NSString*) name
{
  return _name;
}

- (id) objectForKey: (NSString*)aKey
{
  return [_extra objectForKey: aKey];
}

/* Method called as debug logging delegate for GNUstep APIs
 */
- (BOOL) putBytes: (const uint8_t*)bytes
         ofLength: (NSUInteger)length
         byHandle: (NSObject*)anObject
{
  if ([_delegate respondsToSelector: _cmd])
    {
      return [_delegate putBytes: bytes ofLength: length byHandle: self];
    }
  return NO;	// Use default logging
}
- (NSMutableDictionary*) result
{
  if (_timer == nil)
    {
      return _result;
    }
  else
    {
      return nil;
    }
}

- (BOOL) sendRequest: (NSString*)method 
          parameters: (NSDictionary*)parameters
               order: (NSArray*)order
             timeout: (int)seconds
{
  return [self sendRequest: method
	        parameters: parameters
		     order: order
		   timeout: seconds
	       prioritised: NO];
}

- (BOOL) sendRequest: (NSString*)method 
          parameters: (NSDictionary*)parameters
               order: (NSArray*)order
             timeout: (int)seconds
	 prioritised: (BOOL)urgent
{
  if (nil != _timeout)
    {
      NSLog(@"[%@-%@] request already in progress",
        NSStringFromClass([self class]), NSStringFromSelector(_cmd));
      return NO;
    }
  if (_result != nil)
    {
      [_result release];
      _result = nil;
    }
  if (_response != nil)
    {
      [_response release];
      _response = nil;
    }
  _prioritised = urgent;

  _cancelled = NO;
  _completedIO = NO;
  _stage = RPCIdle;
  if (seconds < 1)
    {
      seconds = 1;
    }
  _timeout = [[NSDate alloc] initWithTimeIntervalSinceNow: seconds];

  /* Make a note of which thread queued the request.
   */
  _queueThread = [[NSThread currentThread] retain];

  /* The timer runs in the thread which queued the request ...
   * so the loop for that thread needs to be run in order to
   * deal with timeouts of queued operations.
   */
  _timer = [NSTimer
    scheduledTimerWithTimeInterval: [_timeout timeIntervalSinceNow]
    target: self
    selector: @selector(timeout:)
    userInfo: nil
    repeats: NO];

  _prepMethod = [method copy]; 
  _prepParameters = [parameters copy]; 
  _prepOrder = [order copy]; 
  
  if (nil == _connectionURL)
    {
      /* We have nowhere to connect to ... so try building the request in
       * case the build process is also going to set the connection URL.
       * We have to do that now since we can't queue the request until we
       * know where it's going.
       */
      [self _prepare];
    }

  if (NO == [self _enqueue])
    {
      _stage = RPCIdle;
      [_timer invalidate];
      _timer = nil;
      [self _clean];
      return NO;        // Too many enqueued requests in process
    }

  if (nil == _request)
    {
      /* Get the request data built ... either asynchronously in another
       * thread or synchronously in this one if threading is not enabled.
       * At the end of the -_prepareAndRun method the sending of the request
       * is automatically started if possible.
       */
      [workThreads scheduleSelector: @selector(_prepareAndRun)
			 onReceiver: self
			 withObject: nil];
    }
  else
    {
      /* Make sure that this is de-queued and run if possible.
       */
      [GWSService _run: [_connectionURL host]];
    }
  return YES;
}

- (void) setCoder: (GWSCoder*)aCoder
{
  if (aCoder != _coder)
    {
      GWSCoder   *old = _coder;

      if ([aCoder delegate] != nil)
	{
	  [NSException raise: NSInvalidArgumentException
		      format: @"Coder already had a delegate"];
	}
      _coder = nil;
      if ([old delegate] == (id)self)
	{
          [old setDelegate: nil];
	}
      _coder = [aCoder retain];
      [old release];
      [_coder setDelegate: self];
    }
}

- (void) setCompact: (BOOL)flag
{
  _compact = flag;
}

- (void) setContentType: (NSString*)cType
{
  if ([cType length] == 0)
    {
      cType = nil;
    }
  if (NO == [_contentType isEqual: cType])
    {
      NSString	*old = _contentType;

      _contentType = [cType copy];
      [old release];
    }
}

/* Much software uses integer settings for debub levels, so to selector
 * type conflicts we use the same convention even though we are using it
 * as a boolean.
 */
- (int) setDebug: (int)flag
{
  BOOL  old = _debug;

  _debug = flag ? YES : NO;
  return old;
}

- (void) setDelegate: (id)aDelegate
{
  _delegate = aDelegate;
}

- (void) setDocumentation: (GWSElement*)documentation
{
  if (documentation != _documentation)
    {
      id        o = _documentation;

      _documentation = [documentation retain];
      [o release];
      [_documentation remove];
    }
}

- (void) setHeaders: (NSDictionary*)headers
{
  NSDictionary	*tmp = [headers copy];

  [_headers release];
  _headers = tmp;
}

- (void) setHTTPMethod: (NSString*)method
{
  if (0 == [method length]) method = @"POST";
  if (NO == [_HTTPMethod isEqual: method])
    {
      NSString	*old = _HTTPMethod;

      _HTTPMethod = [method copy];
      [old release];
    }
}

- (BOOL) setNewAPI: (BOOL)aFlag
{
  BOOL	old = _newAPI;

  _newAPI = (aFlag ? YES : NO);
  return old;
}

- (void) setObject: (id)anObject forKey: (NSString*)aKey
{
  if (anObject == nil)
    {
      [_extra removeObjectForKey: aKey];
    }
  else
    {
      if (_extra == nil)
	{
	  _extra = [NSMutableDictionary new];
	}
      [_extra setObject: anObject forKey: aKey];
    }
}

- (void) setSOAPAction: (NSString*)action
{
  if (NO == [_SOAPAction isEqual: action])
    {
      NSString	*old = _SOAPAction;

      _SOAPAction = [action copy];
      [old release];
    }
}

- (void) setTimeZone: (NSTimeZone*)timeZone
{
  if (_tz != timeZone)
    {
      NSTimeZone        *old = _tz;

      _tz = [timeZone retain];
      [old release];
    }
}

- (void) setURL: (id)url
{
  [self setURL: url certificate: nil privateKey: nil password: nil];
}

- (void) setURL: (id)url
    certificate: (NSString*)cert
     privateKey: (NSString*)pKey
       password: (NSString*)pwd
{
  id	old;

#if	!defined(GNUSTEP)
  if (cert != nil)
    {
      [NSException raise: NSInvalidArgumentException
	          format: @"Client certificates not supported on MacOS-X"];
    }
#endif
  if ([url isKindOfClass: [NSURL class]] == NO)
    {
      NSURL	*u = [NSURL URLWithString: url];
      NSString	*s = [u scheme];

      if (u == nil || [u host] == nil
	|| ([s isEqual: @"http"] == NO && [s isEqual: @"https"] == NO))
	{
	  NSLog(@"[%@-%@] Bad URL (%@) ignored",
	    NSStringFromClass([self class]), NSStringFromSelector(_cmd), url);
	  return;
	}
      url = u;
    }
  [self _clearConnection];
  old = _connectionURL;
  _connectionURL = [url copy];
  [old release];
  old = _clientCertificate;
  _clientCertificate = [cert copy];
  [old release];
  old = _clientKey;
  _clientKey = [pKey copy];
  [old release];
  old = _clientPassword;
  _clientPassword = [pwd copy];
  [old release];
  [_response release];
  _response = nil;
}

/* This must be performed on the I/O thread.
 */
- (void) _cancel
{
  if (nil != _ioThread)
    {
#if	defined(GNUSTEP)
      if (NO == [_connection isKindOfClass: [NSURLConnection class]])
	{
          /* For an NSURLHandle, we can just cancel the operation and
           * the callback from that will do all the work.
           */
	  [handle cancelLoadInBackground];
          return;
	}
#endif
      [_lock lock];
      if (nil != _ioThread)
        {
          [self _completedIO];
          [_connection cancel];
        }
      [_lock unlock];
      [self _completed];
    }
}

- (void) timeout: (NSTimer*)t
{
  NSThread	*cancelThread = nil;
  BOOL          notYetActive;
  NSUInteger    index;

  /* First we check to see if the timeout occurred while the request was
   * still in the queue (not yet active) and remove it from the queue if
   * it did.
   */ 
  [queueLock lock];
  index = [queued indexOfObjectIdenticalTo: self];
  if (NSNotFound == index)
    {
      notYetActive = YES;
    }
  else
    {
      NSString	*host = [_connectionURL host];

      notYetActive = NO;
      [queued removeObjectAtIndex: index];
      [[queues objectForKey: host] removeObjectIdenticalTo: self];
    }
  [queueLock unlock];

  /* Now we clean up the timer, set the request status, and initiate
   * the cancellation of the request I/O if necessary.
   */
  [_lock lock];
  if (NO == _cancelled && NO == _completedIO)
    {
      if (t == _timer)
        {
          [self _setProblem: @"timed out"];
        }
    }
  else
    {
      [self _setProblem: @"cancelled"];
    }
  /* We invalidate the timer: otherwise we could get a timeout just after
   * cancelling ... which would change our problem report from 'cancelled'
   */
  [_timer invalidate];
  _timer = nil;

  if (NO == notYetActive)
    {
      if (NO == _cancelled && NO == _completedIO)
        {
          _cancelled = YES;
          cancelThread = _ioThread;
        }
      if (nil != cancelThread)
        {
          [self performSelector: @selector(_cancel)
                       onThread: cancelThread
                     withObject: nil
                  waitUntilDone: NO];
        }
    }
  [_lock unlock];

  /* Finally, if no cancellation is in progress (the request was never
   * started or the cancellation already finished) we can handle completion.
   */
  if (nil == cancelThread)
    {
      [self _completed];
    }
}

- (NSTimeZone*) timeZone
{
  if (_tz == nil)
    {
      _tz = [[NSTimeZone timeZoneForSecondsFromGMT: 0] retain];
    }
  return _tz;
}

- (GWSElement*) tree
{
  GWSElement    *tree;
  GWSElement    *elem;
  GWSPort	*port;
  NSEnumerator  *enumerator;
  NSString	*q;

  q = (_document == nil) ? (id)@"service" : (id)[_document qualify: @"service"];
  tree = [[GWSElement alloc] initWithName: @"service"
                                namespace: nil
                                qualified: q
                               attributes: nil];
  [tree setAttribute: _name forKey: @"name"];
  if (_documentation != nil)
    {
      elem = [_documentation mutableCopy];
      [tree addChild: elem];
      [elem release];
    }
  enumerator = [_ports objectEnumerator];
  while ((port = [enumerator nextObject]) != nil)
    {
      [tree addChild: [port tree]];
    }
  enumerator = [_extensibility objectEnumerator];
  while ((elem = [enumerator nextObject]) != nil)
    {
      elem = [elem mutableCopy];
      [tree addChild: elem];
      [elem release];
    }
  return [tree autorelease];
}

- (void) connection: (NSURLConnection*)connection
didCancelAuthenticationChallenge: (NSURLAuthenticationChallenge*)challenge
{
  /* DO NOTHING */
}

- (void) connection: (NSURLConnection*)connection
   didFailWithError: (NSError*)error
{
  [_lock lock];
  [self _completedIO];
  if (NO == _cancelled)
    {
      [self _setProblem: [error localizedDescription]];
    }
  [_lock unlock];
  [self _completed];
}

- (void) connection: (NSURLConnection*)connection
didReceiveAuthenticationChallenge: (NSURLAuthenticationChallenge*)challenge 
{
}

- (void) connection: (NSURLConnection*)connection didReceiveData: (NSData*)data 
{
  [_response appendData: data];
}

- (void) connection: (NSURLConnection*)connection
 didReceiveResponse: (NSURLResponse*)response 
{
  _code = [(NSHTTPURLResponse*)response statusCode];
}

- (NSCachedURLResponse*) connection: (NSURLConnection*)connection
		  willCacheResponse: (NSCachedURLResponse*)cachedResponse
{
  return nil;
}

- (NSURLRequest*) connection: (NSURLConnection*)connection
	     willSendRequest: (NSURLRequest*)request
	    redirectResponse: (NSURLResponse*)redirectResponse 
{
  /* This is a request to allow a redirect ...
   * If redirectResponse is nil then it's internal rewriting of the
   * request (canonicalisation) by  NSURLConnection itself, so it is
   * safe (and necessary) to permit it.
   */
  if (nil == redirectResponse)
    {
      return request;
    }

  /* Real redirects are not supported ... if we wanted to allow that we
   * would also have to devise some mechanism to prevent an infinite loop.
   * NB. Some versions of OSX have a bug and don't handle a nil return
   * properly (they don't use the callbacks to tell us the connection
   * has failed).  So we do the cleanup here:
   */
  [_lock lock];
  [self _completedIO];
  if (NO == _cancelled)
    {
      [self _setProblem: @"remote host attempted redirect"];
    }
  [_lock unlock];
  [self _completed];

  return nil;
}

- (void) connectionDidFinishLoading: (NSURLConnection*)connection 
{
  [_lock lock];
  [self _completedIO];
  _stage = RPCParsing;
  [_lock unlock];

  if ([_response length] == 0)	// No response received
    {
      [_response release];
      _response = nil;
    }
  if ([workThreads maxThreads] == 0
    && [NSThread currentThread] != _queueThread)
    {
      [self performSelector: @selector(_received)
		   onThread: _queueThread
		 withObject: nil
	      waitUntilDone: NO];
    }
  else
    {
      [workThreads scheduleSelector: @selector(_received)
			 onReceiver: self
			 withObject: nil];
    }
}

- (NSString*) webServiceOperation
{
  return _operation;
}

- (NSMutableDictionary*) webServiceParameters
{
  return _parameters;
}

- (GWSPort*) webServicePort
{
  return _port;
}

@end

@implementation	GWSService (Delegate)
- (void) completedRPC: (GWSService*)sender
{
}
- (NSData*) webService: (GWSService*)service
          buildRequest: (NSString*)method
            parameters: (NSDictionary*)parameters
                 order: (NSArray*)order
{
  return nil;
}
- (GWSElement*) webService: (GWSService*)service
		 didEncode: (GWSElement*)element
{
  return element;
}
- (NSMutableDictionary*) webService: (GWSService*)service
                     handleResponse: (NSData*)response
{
  return nil;
}
- (GWSElement*) webService: (GWSService*)service
		willDecode: (GWSElement*)element
{
  return element;
}
- (GWSElement*) webService: (GWSService*)service
		willEncode: (GWSElement*)element
{
  return element;
}
- (NSData*) webService: (GWSService*)sender willHandleResponse: (NSData*)data
{
  return data;
}
- (NSData*) webService: (GWSService*)sender willSendRequest: (NSData*)data
{
  return data;
}
@end

#if	defined(GNUSTEP)
@implementation	GWSService (NSURLHandle)

- (void) URLHandle: (NSURLHandle*)sender
  resourceDataDidBecomeAvailable: (NSData*)newData
{
  return;	// Not interesting
}

- (void) URLHandle: (NSURLHandle*)sender
  resourceDidFailLoadingWithReason: (NSString*)reason
{
  /* Retain self during this process ... since removing self as a
   * client of the handle could cause the receiver to be deallocated
   */ 
  [[self retain] autorelease];
  [_lock lock];
  [self _completedIO];
  [handle removeClient: (id<NSURLHandleClient>)self];
  if (NO == _cancelled)
    {
      [self _setProblem: reason];
    }
  [_lock unlock];
  [self _completed];
}

- (void) URLHandleResourceDidBeginLoading: (NSURLHandle*)sender
{
  return;	// Not interesting
}

- (void) URLHandleResourceDidCancelLoading: (NSURLHandle*)sender
{
  /* Retain self during this process ... since removing self as a
   * client of the handle could cause the receiver to be deallocated
   */ 
  [[self retain] autorelease];
  [_lock lock];
  [self _completedIO];
  [handle removeClient: (id<NSURLHandleClient>)self];
  if (NO == _cancelled)
    {
      NSString	*str;

      str = [handle propertyForKeyIfAvailable: NSHTTPPropertyStatusCodeKey];
      if (str == nil)
        {
          str = @"timeout";
        }
      else
        {
          str = [NSString stringWithFormat: @"HTTP status %@", str];
        }
      [self _setProblem: str];
    }
  [_lock unlock];
  [self _completed];
}

- (void) URLHandleResourceDidFinishLoading: (NSURLHandle*)sender
{
  /* Retain self during this process ... since removing self as a
   * client of the handle could cause the receiver to be deallocated
   */ 
  [[self retain] autorelease];
  [_lock lock];
  [self _completedIO];
  _stage = RPCParsing;
  [handle removeClient: (id<NSURLHandleClient>)self];
  [_response release];
  _response = [[handle availableResourceData] mutableCopy];
  _code = [[handle propertyForKey: NSHTTPPropertyStatusCodeKey] intValue];
  [_lock unlock];
  if ([workThreads maxThreads] == 0
    && [NSThread currentThread] != _queueThread)
    {
      [self performSelector: @selector(_received)
		   onThread: _queueThread
		 withObject: nil
	      waitUntilDone: NO];
    }
  else
    {
      [workThreads scheduleSelector: @selector(_received)
			 onReceiver: self
			 withObject: nil];
    }
}
@end
#endif

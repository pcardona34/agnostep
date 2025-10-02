/*
**  MessageComposition.m
**
**  Copyright (c) 2001, 2002, 2003 Ujwal S. Sathyam
**                2019 Riccardo Mottola
**
**  Author: Ujwal S. Sathyam
**
**  Description: Scriptable class that works with an EditWindowController
**               and a Message.
**
**  This program is free software; you can redistribute it and/or modify
**  it under the terms of the GNU General Public License as published by
**  the Free Software Foundation; either version 2 of the License, or
**  (at your option) any later version.
**
**  This program is distributed in the hope that it will be useful,
**  but WITHOUT ANY WARRANTY; without even the implied warranty of
**  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
**  GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#import "MessageComposition.h"
#import "Constants.h"
#import "GNUMail.h"
#import "EditWindowController.h"
#import "ExtendedTextView.h"
#import "Utilities.h"

#import <Pantomime/CWConstants.h>
#import <Pantomime/CWInternetAddress.h>
#import <Pantomime/CWMessage.h>

NSString *NSOperationNotSupportedForKeyException = @"NSOperationNotSupportedForKeyException";

//
//
//
@implementation MessageComposition

- (id) init
{
  self = [super init];
  
  if (self != nil)
    {
      _recipients = [[NSMutableArray allocWithZone:[self zone]] init];
      _attachments = [[NSMutableArray allocWithZone:[self zone]] init];
    }
  
  // NSLog(@"Initialized message 0x%x", self);
  return self;
}


//
//
//
- (void) dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [_author release];
  [_content release];
  [_subject release];
  [_recipients release];
  [_attachments release];
  [_account release];
  
  [super dealloc];
}


//
//
//
- (NSArray *) recipientsWithClass: (Class) theClass
{
  NSArray *recipients = [self recipients];
  NSMutableArray *result = [NSMutableArray array];
  unsigned i, c = [recipients count];
  id curRecipient;
  
  for (i=0; i<c; i++)
    {
      curRecipient = [recipients objectAtIndex:i];
      if ([curRecipient isKindOfClass:theClass])
	{
	  [result addObject:curRecipient];
	}
    }
  return result;
}


//
//
//
- (void) send
{
  // NSLog(@"Sending message composition 0x%x", self);
  
  [self _loadMessage];
  // Send the message!
  [_editWindowController sendMessage: nil];
}


//
//
//
- (void) addAttachment: (NSString *) aFileName
{
  if (aFileName)
    {
      NSString *theFile = [aFileName copy];
      [_attachments addObject: theFile];
      RELEASE(theFile);
    }
}


//
// accessors for attributes: 
//
- (NSString *) author
{
  return _author;
}


//
//
//
- (void) setAuthor: (NSString *) author
{
  if ( ![author isEqual: _author] )
    { 
      NSString *temp = [author copy];
      [_author release];
      _author = temp;
    }
}


//
//
///
- (NSTextStorage *) content
{
  return _content;
}


//
//
//
- (void) setContent: (NSTextStorage *) content
{
  if ( ![content isEqual: _content] )
    { 
      NSTextStorage *temp = [content copy];
      [_content release];
      _content = temp;
    }
}


//
//
//
- (int) signaturePosition
{
  return _signaturePosition;
}


//
//
//
- (void) setSignaturePosition: (int) signaturePosition
{
  if ( signaturePosition != _signaturePosition )
    { 
      _signaturePosition = signaturePosition;
    }
}


//
//
//
- (BOOL) hasSignature
{
  return _hasSignature;
}


//
//
//
- (void) setHasSignature: (BOOL) hasSignature
{
  if ( hasSignature != _hasSignature )
    { 
      _hasSignature = hasSignature;
    }
}


//
//
//
- (NSString*) subject
{
  return _subject;
}


//
//
//
-(void) setSubject: (NSString *) subject
{
  if ( ![subject isEqual: _subject] )
    { 
      NSString *temp = [subject copy];
      [_subject release];
      _subject = temp;
    }
}


//
//
//
- (void) show: (BOOL) flag
{
  if (flag)
    {
      [self _loadMessage];
      [[_editWindowController window] makeKeyAndOrderFront: nil];
    }
  else
    {
      [[_editWindowController window] close];
    }
}


//
//
//
- (NSArray *) attachments
{
  return (_attachments);
}


//
//
//
- (void) setAttachments: (NSArray *) attachments
{
  // We won't allow wholesale setting of these subset keys.
  [NSException raise: NSOperationNotSupportedForKeyException  format: @"Setting 'attachments' key is not supported."];
}


//
//
//
- (NSString *) account
{
  if (_account != nil)
    {
      return (_account);
    }
  
  // grab the default account
  return ([Utilities defaultAccountName]);
}


//
//
//
- (void) setAccount: (NSString *) accountName
{
  if (_account != nil)
    {
      RELEASE(_account);
      _account = nil;
    }
  if (accountName != nil)
    {
      RETAIN(accountName);
      _account = accountName;
    }
}


//
// accessors for to-many relationships: 
//
- (NSArray *) recipients
{
  return _recipients;
}


//
//
//
- (void) setRecipients: (NSArray *) recipients
{
  // NSLog(@"MessageComposition: setRecipients");
  [_recipients setArray: recipients];
}


//
//
//
- (NSArray *) ccRecipients
{
  return [self recipientsWithClass: [CcRecipient class]];
}


//
//
//
- (void) setCcRecipients: (NSArray *) ccRecipients
{
  // We won't allow wholesale setting of these subset keys.
  [NSException raise: NSOperationNotSupportedForKeyException  format: @"Setting 'cc recipients' key is not supported."];
}


//
//
//
- (NSArray *) bccRecipients
{
  return [self recipientsWithClass: [BccRecipient class]];
}


//
//
//
- (void) setBccRecipients: (NSArray *) bccRecipients
{
  // We won't allow wholesale setting of these subset keys.
  [NSException raise: NSOperationNotSupportedForKeyException  format: @"Setting 'bcc recipients' key is not supported."];
}


//
//
//
- (NSArray *) toRecipients
{
  return [self recipientsWithClass: [ToRecipient class]];
}


//
//
//
- (void) setToRecipients: (NSArray *) toRecipients
{
  // We won't allow wholesale setting of these subset keys.
  [NSException raise: NSOperationNotSupportedForKeyException  format: @"Setting 'to recipients' key is not supported."];
}

@end


//
//
//
@implementation MessageComposition (KeyValueCoding)

- (id) valueInRecipientsAtIndex: (NSUInteger) theIndex
{
  // NSLog(@"MessageComposition: valueInRecipientsAtIndex %d", theIndex);
  return ([[self recipients] objectAtIndex: theIndex]);
}


//
//
//
- (void) replaceInRecipients: (CWInternetAddress *) object
		     atIndex: (NSUInteger) theIndex
{
  [self removeFromRecipientsAtIndex:theIndex];
  [self insertInRecipients:object atIndex:theIndex];
}


//
//
//
- (void) insertInRecipients: (CWInternetAddress *) object
{
  // NSLog(@"MessageComposition: insertInRecipients 0x%x", object);
  if ([object type] == 0)
    {
      [object setType: PantomimeToRecipient];
    }
  
  [self insertInRecipients: object atIndex: [[self recipients] count]];
}


//
//
//
- (void) insertInRecipients: (CWInternetAddress *) object 
		    atIndex: (NSUInteger) theIndex
{
  // NSLog(@"MessageComposition: insertInRecipients %@ atIndex %d", [object description], theIndex);
  [_recipients insertObject:object atIndex:theIndex];
  [object setContainer: self];
}


//
//
//
- (void) removeFromRecipientsAtIndex: (NSUInteger) theIndex
{
  // NSLog(@"MessageComposition: removeFromRecipientsAtIndex %d", theIndex);
  [_recipients removeObjectAtIndex:theIndex];
}


//
//
//
- (id) valueInCcRecipientsAtIndex: (NSUInteger) theIndex
{
  return ([[self ccRecipients] objectAtIndex: theIndex]);
}


//
//
//
- (void) replaceInCcRecipients: (CcRecipient *) object
		       atIndex: (NSUInteger) theIndex
{
  NSArray *ccRcpts = [self ccRecipients];
  NSArray *recipients = [self recipients];
  NSUInteger newIndex = [recipients indexOfObjectIdenticalTo: [ccRcpts objectAtIndex:theIndex]];
  
  if (newIndex != NSNotFound)
    {
      [self removeFromRecipientsAtIndex: newIndex];
      [self insertInRecipients:object atIndex: newIndex];
    } 
  else 
    {
      // Shouldn't happen.
      [NSException raise: NSRangeException  format: @"Could not find the given 'cc recipient' in the recipients."];
    }
}


//
//
//
- (void) insertInCcRecipients: (CcRecipient *) object
{
  [self insertInCcRecipients: object atIndex: [[self ccRecipients] count]];
}


//
//
//
- (void) insertInCcRecipients: (CcRecipient *) object 
		      atIndex: (NSUInteger) theIndex
{
  NSArray *ccRcpts = [self ccRecipients];
  
  if (theIndex == [ccRcpts count])
    {
      [self insertInRecipients:object atIndex: theIndex];
    } 
  else 
    {
      NSArray *recipients = [self recipients];
      NSUInteger newIndex = [recipients indexOfObjectIdenticalTo: [ccRcpts objectAtIndex: theIndex]];
      if (newIndex != NSNotFound)
	{
	  [self insertInRecipients:object atIndex: newIndex];
        } 
      else 
	{
	  // Shouldn't happen.
	  [NSException raise: NSRangeException  format: @"Could not find the given 'cc recipients' in the recipients."];
        }
    }
}


//
//
//
- (void) removeFromCcRecipientsAtIndex: (NSUInteger) theIndex
{
  NSArray *ccRcpts = [self ccRecipients];
  NSArray *recipients = [self recipients];
  NSUInteger newIndex = [recipients indexOfObjectIdenticalTo: [ccRcpts objectAtIndex: theIndex]];
  
  if (newIndex != NSNotFound)
    {
      [self removeFromRecipientsAtIndex: newIndex];
    } 
  else
    {
      // Shouldn't happen.
      [NSException raise: NSRangeException  format: @"Could not find the given 'cc recipients' in the recipients."];
    }
}


//
//
//
- (id) valueInBccRecipientsAtIndex: (NSUInteger) theIndex
{
  return ([[self bccRecipients] objectAtIndex: theIndex]);
}


//
//
//
- (void) replaceInBccRecipients: (BccRecipient *) object
			atIndex: (NSUInteger) theIndex
{
  NSArray *bccRcpts = [self bccRecipients];
  NSArray *recipients = [self recipients];
  NSUInteger newIndex = [recipients indexOfObjectIdenticalTo: [bccRcpts objectAtIndex:theIndex]];
  
  if (newIndex != NSNotFound)
    {
      [self removeFromRecipientsAtIndex: newIndex];
      [self insertInRecipients: object  atIndex: newIndex];
    } 
  else 
    {
      // Shouldn't happen.
      [NSException raise: NSRangeException  format: @"Could not find the given 'bcc recipient' in the recipients."];
    }
}


//
//
//
- (void) insertInBccRecipients: (BccRecipient *) object
{
  [self insertInBccRecipients: object  atIndex: [[self bccRecipients] count]];
}


//
//
//
- (void) insertInBccRecipients: (BccRecipient *) object 
		       atIndex: (NSUInteger) theIndex
{
  // implement your method here:
  NSArray *bccRcpts = [self bccRecipients];
  if (theIndex == [bccRcpts count])
    {
      [self insertInRecipients:object atIndex: theIndex];
    } 
  else 
    {
      NSArray *recipients = [self recipients];
      NSUInteger newIndex = [recipients indexOfObjectIdenticalTo: [bccRcpts objectAtIndex: theIndex]];
      if (newIndex != NSNotFound)
	{
	  [self insertInRecipients: object  atIndex: newIndex];
	} 
      else
	{
	  // Shouldn't happen.
	  [NSException raise: NSRangeException  format: @"Could not find the given 'bcc recipients' in the recipients."];
        }
    }
}


//
//
//
- (void) removeFromBccRecipientsAtIndex: (NSUInteger) theIndex
{
  NSArray *bccRcpts = [self bccRecipients];
  NSArray *recipients = [self recipients];
  NSUInteger newIndex = [recipients indexOfObjectIdenticalTo:[bccRcpts objectAtIndex:theIndex]];
  
  if (newIndex != NSNotFound)
    {
      [self removeFromRecipientsAtIndex:newIndex];
    } 
  else 
    {
      // Shouldn't happen.
      [NSException raise:NSRangeException format:@"Could not find the given 'bcc recipients' in the recipients."];
    }
}


//
//
//
- (id) valueInToRecipientsAtIndex: (NSUInteger) theIndex
{
  return ([[self toRecipients] objectAtIndex: theIndex]);
}


//
//
//
- (void) replaceInToRecipients: (ToRecipient *) object
		       atIndex: (NSUInteger) theIndex
{
  // NSLog(@"MessageComposition: replaceInToRecipients 0x%x at index %d", object, index);
  NSArray *toRcpts = [self toRecipients];
  NSArray *recipients = [self recipients];
  NSUInteger newIndex = [recipients indexOfObjectIdenticalTo:[toRcpts objectAtIndex:theIndex]];
  
  if (newIndex != NSNotFound)
    {
      [self removeFromRecipientsAtIndex:newIndex];
      [self insertInRecipients:object atIndex:newIndex];
    } 
  else
    {
      // Shouldn't happen.
      [NSException raise:NSRangeException format:@"Could not find the given 'to recipient' in the recipients."];
    }
}


//
//
//
- (void) insertInToRecipients: (ToRecipient *) object
{
  [self insertInToRecipients: object atIndex: [[self toRecipients] count]];
}


//
//
//
- (void) insertInToRecipients: (ToRecipient *) object
		      atIndex: (NSUInteger) theIndex
{
  // NSLog(@"MessageComposition: insertInToRecipients 0x%x at index %d", object, index);
  
  NSArray *toRcpts = [self toRecipients];
  if (theIndex == [toRcpts count])
    {
      [self insertInRecipients:object atIndex: theIndex];
    } 
  else 
    {
      NSArray *recipients = [self recipients];
      NSUInteger newIndex = [recipients indexOfObjectIdenticalTo:[toRcpts objectAtIndex:theIndex]];
      if (newIndex != NSNotFound)
	{
	  [self insertInRecipients:object atIndex:newIndex];
	} 
      else 
	{
	  // Shouldn't happen.
	  [NSException raise:NSRangeException format:@"Could not find the given 'to recipients' in the recipients."];
        }
    }
}


//
//
//
- (void)removeFromToRecipientsAtIndex: (NSUInteger) theIndex
{
  NSArray *toRcpts = [self toRecipients];
  NSArray *recipients = [self recipients];
  NSUInteger newIndex = [recipients indexOfObjectIdenticalTo:[toRcpts objectAtIndex:theIndex]];
  
  if (newIndex != NSNotFound)
    {
      [self removeFromRecipientsAtIndex:newIndex];
    } 
  else 
    {
      // Shouldn't happen.
      [NSException raise:NSRangeException format:@"Could not find the given 'to recipients' in the recipients."];
    }
}

@end


//
//
//
@implementation MessageComposition (Private)

- (void) _loadMessage
{
  // NSLog(@"MessageComposer: loading message 0x%x", self);
  CWInternetAddress *aRecipient;
  NSEnumerator *anEnumerator;
  CWMessage *aMessage;
  NSString *aFileName;
  
  // We create a new message
  aMessage = [[CWMessage alloc] init];

  //  We set the recipients
  anEnumerator = [[self recipients] objectEnumerator];
  while ((aRecipient = [anEnumerator nextObject]) != nil)
    {
      [aMessage addRecipient: aRecipient];
      // NSLog(@"MessageComposition: -send: Added recipient %@", [aRecipient description]);
    }
  
  // Set the subject
  if ([self subject])
    {
      [aMessage setSubject: [self subject]];
      // NSLog(@"MessageComposition: -send: Set subject: %@", [self subject]);
    }
  
  // Set the content
  if ([self content])
    {
      [aMessage setContent: [[self content] string]];
      // NSLog(@"MessageComposition: -send: Set content: %@", [[self content] string]);
    }
  
  // We create our controller, but we do not show the window
  if (_editWindowController != nil)
    {
      [[_editWindowController window] close];
    }

  _editWindowController = [[EditWindowController alloc] initWithWindowNibName: @"EditWindow"];
  
  if ( _editWindowController )
    {
      [[_editWindowController window] setTitle: _(@"New message...")];
      
      // set the source account
      [_editWindowController setAccountName: [self account]];
      
      // Set the message
      [_editWindowController setMessage: aMessage];
      [_editWindowController setShowCc: YES];
      [_editWindowController setShowBcc: YES];
      
      // Add any attachments
      anEnumerator = [[self attachments] objectEnumerator];
      while ((aFileName = [anEnumerator nextObject]) != nil)
	{
	  [(ExtendedTextView *)[_editWindowController textView] insertFile: aFileName];
	}
    }
  
  RELEASE(aMessage);
}

@end


#ifdef MACOSX
//
//
//
@implementation MessageComposition (ScriptingSupport)

- (NSScriptObjectSpecifier *) objectSpecifier
{
  NSUInteger tmpIndex = 0;
  id classDescription = nil;

  NSScriptObjectSpecifier *containerRef;
  
  NSArray *messageCompositions = [[NSApp delegate] messageCompositions];
  tmpIndex = [messageCompositions indexOfObjectIdenticalTo:self];
  
  if (tmpIndex != NSNotFound)
    {
      containerRef     = [NSApp objectSpecifier];
      classDescription = [NSClassDescription classDescriptionForClass:[NSApp class]];
      //create and return the specifier
      return [[[NSIndexSpecifier allocWithZone:[self zone]]
		initWithContainerClassDescription: classDescription
		containerSpecifier: containerRef
		key: @"messageCompositions"
		index: tmpIndex] autorelease];
    } 
  else 
    {
      return nil;
    }
}


//
// Handlers for supported commands:
//
- (void) handleSendMessageScriptCommand: (NSScriptCommand *) command
{
  [self send];
  return;
}


//
//
//
- (void) handleShowMessageScriptCommand: (NSScriptCommand *) command
{
  [self show: YES];
}


//
//
//
- (void) handleAttachScriptCommand: (NSScriptCommand *) command
{
  // Get the command's arguments:
  NSDictionary *args = [command evaluatedArguments];
  NSString *file = [args objectForKey:@"file"];
  
  [self addAttachment: file];
  
  return;
}

@end


//
//
//
@implementation CWInternetAddress (ScriptingSupport)

- (NSScriptObjectSpecifier *) objectSpecifier
{
  NSUInteger rcpIndex = 0;
  id classDescription = nil;
  
  NSScriptObjectSpecifier *containerRef = nil;
  
  NSArray *recipients = [[self container] recipients];
  rcpIndex = [recipients indexOfObjectIdenticalTo:self];
  
  if (rcpIndex != NSNotFound)
    {
      containerRef     = [[self container] objectSpecifier];
      classDescription = [containerRef keyClassDescription];
      //create and return the specifier
      return [[[NSIndexSpecifier allocWithZone:[self zone]]
		initWithContainerClassDescription: classDescription
		containerSpecifier: containerRef
		key: @"recipients"
		index: rcpIndex] autorelease];
    } 
  else 
    {
      // NSLog(@"recipient not found!");
      return nil;
    }
}

@end

#endif


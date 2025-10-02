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

NSString * const GWSErrorKey = @"GWSCoderError";
NSString * const GWSFaultKey = @"GWSCoderFault";
NSString * const GWSMethodKey = @"GWSCoderMethod";
NSString * const GWSOrderKey = @"GWSCoderOrder";
NSString * const GWSParametersKey = @"GWSCoderParameters";
NSString * const GWSRequestDataKey = @"GWSCoderRequestData";
NSString * const GWSResponseDataKey = @"GWSCoderResponseData";
NSString * const GWSRPCIDKey = @"GWSCoderRPCID";
NSString * const GWSRPCVersionKey = @"GWSCoderRPCVersion";

@implementation GWSType

- (void) dealloc
{
  if (_document != nil)
    {
      _document = nil;
      [_document removeTypeNamed: _name];
      return;
    }
  [_name release];
  [_properties release];
  [super dealloc];
}

- (id) init
{
  /* The initWithName:nameSpace: must be used */
  [self release];
  return nil;
}

- (id) _initWithName: (NSString*)name document: (GWSDocument*)document
{
  if ((self = [super init]) != 0)
    {
      _name = [name copy];
      _document = document;
    }
  return self;
}

- (NSString*) name
{
  return _name;
}

- (NSString*) nameSpace
{
  return _nameSpace;
}

- (id) propertyForKey: (NSString*)key
{
  return [_properties objectForKey: key];
}

- (void) setProperty: (id)property forKey: (NSString*)key
{
  if (property == nil)
    {
      [_properties removeObjectForKey: key];
    }
  else
    {
      if (_properties == nil)
        {
          _properties = [NSMutableDictionary new];
        }
      [_properties setObject: property forKey: key];
    }
}

- (GWSElement*) tree
{
  // FIXME ... not implemented
  NSLog(@"FIXME .. type tree not implemented");
  return nil;
}
@end




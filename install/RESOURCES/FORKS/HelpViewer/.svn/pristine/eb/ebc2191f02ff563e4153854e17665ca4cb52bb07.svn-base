/*
    This file is part of HelpViewer (http://gap.nongnu.org/helpviewer/)
    Copyright (C) 2003 Nicolas Roard <nicolas@roard.com>
                  2025 Riccardo Mottola <rm@gnu.org>

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the
    Free Software Foundation, Inc.  
    31 Milk Street #960789 Boston, MA 02196 USA
*/

#ifndef __PARSER_H__
#define __PARSER_H__

#import <Foundation/Foundation.h>
#import "GNUstep.h"

@protocol SAXHandler
- (void) startElement: (NSString*) elementName attributes: (NSMutableDictionary*) elementAttributes;
- (void) endElement: (NSString*) elementName;
- (void) characters: (NSString*) name;
@end

@interface Parser : NSObject 
{
  id<SAXHandler> _handler;
  NSData *_data;
}

+ (instancetype) parserWithSAXHandler : (id<SAXHandler>) handler withData: (NSData*) data;

- (instancetype) initWithSAXHandler : (id<SAXHandler>) handler withData: (NSData*) data;


- (BOOL) parse;
@end

NSString *charFromEntity(char *entityName);

#endif

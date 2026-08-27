/*
    This file is part of HelpViewer (http://gap.nongnu.org/helpviewer/)
    Copyright (C) 2003 Nicolas Roard <nicolas@roard.com>
                  2026 Riccardo Mottola <rm@gnu.org>

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

#ifndef __SECTION_H__
#define __SECTION_H__

#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>
#include "GNUstep.h"
#include "TextFormatter.h"
#include "HandlerStructure.h"

#define SECTION_TYPE_NORMAL 0
#define SECTION_TYPE_CHAPTER 1
#define SECTION_TYPE_PART 2
#define SECTION_TYPE_PLAIN 3

@interface Section : NSObject
{
    NSMutableAttributedString* text;
    NSString* header;
    NSRange range;
    NSMutableArray* subs;
    Section* parent;
    int type;
    BOOL rendered;
    BOOL loaded;
    NSString* path;
} 
- (id) initWithHeader: (NSString*) header;
- (NSMutableAttributedString*) text;
- (void) setType: (int) t;
- (int) type;
- (NSString*) header;
- (NSRange) range;
- (void) setRange: (NSRange) range;
- (void) addSubsection: (Section*) sub;
- (BOOL) hasSubsections;
- (NSMutableArray*) subsections;
- (Section*) parent;
- (void) setParent: (Section*) par;
- (void) print;
- (void) setPath: (NSString*) src;
- (void) setLoaded: (BOOL) load;
- (BOOL) loaded;
- (void) load;
- (NSMutableAttributedString*) contentWithLevel: (int) level ;
+ (void) setTextFormatter: (id) obj;
+ (void) setBundle: (NSBundle*) obj;
@end

#endif

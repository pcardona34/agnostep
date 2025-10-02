/*
    HKTextPattern.h

    Declarations of data structures and functions for text pattern
    manipulation for the HighlighterKit framework.

    Copyright (C) 2005, 2006, 2007, 2008  Saso Kiselkov

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
*/

#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>

#ifndef IN_TEXT_PATTERN_M
/**
 * An opaque handle to a text pattern. This type is always used as a pointer.
 */
typedef void HKTextPattern;
#endif

HKTextPattern *HKCompileTextPattern (NSString * string);

void HKFreeTextPattern (HKTextPattern * pattern);

BOOL HKTextPatternsEqual (HKTextPattern * pattern1, HKTextPattern * pattern2);

unsigned int
HKCheckTextPatternPresenceInString (HKTextPattern * pattern,
                                    unichar * string,
                                    unsigned int stringLength,
                                    unsigned int index);

unichar *HKPermissibleCharactersAtPatternBeginning (HKTextPattern * pattern);

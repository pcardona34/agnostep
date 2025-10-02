/*
**  NSUserDefaults+Extensions.h
**
**  Copyright (C) 2002-2005 Ludovic Marcotte
**
**  Author: Ludovic Marcotte <ludovic@Sophos.ca>     
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

#ifndef _GNUMail_H_NSUserDefaults_Extensions
#define _GNUMail_H_NSUserDefaults_Extensions

#import <AppKit/AppKit.h>

@interface NSUserDefaults (GNUMailColorExtensions)

- (NSColor *) colorForKey: (NSString *) theKey;
- (void) setColor: (NSColor *) theColor
           forKey: (NSString *) theKey;

- (int) integerForKey: (NSString *) theKey
              default: (int) theValue;

@end

#endif // _GNUMail_H_NSUserDefaults_Extensions

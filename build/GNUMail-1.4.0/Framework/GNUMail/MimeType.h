/*
**  MimeType.h
**
**  Copyright (c) 2001-2007 Ludovic Marcotte
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

#ifndef _GNUMail_H_MimeType
#define _GNUMail_H_MimeType

#import <AppKit/AppKit.h>

#define DISPLAY_IF_POSSIBLE 0
#define DISPLAY_AS_ICON     1

#define PROMPT_SAVE_PANEL          0
#define OPEN_WITH_WORKSPACE        1
#define OPEN_WITH_EXTERNAL_PROGRAM 2

@interface MimeType: NSObject <NSCoding>
{
  NSString *mimeType;
  NSString *fileExtensions;
  NSString *description;
  int view, action;
  NSString *dataHandlerCommand;
  NSImage *icon;
}

- (void) encodeWithCoder: (NSCoder *) theCoder;
- (id) initWithCoder: (NSCoder *) theCoder;


//
// class methods
//

//
// access/mutation methods
//

- (NSString *) mimeType;
- (void) setMimeType: (NSString *) theMimeType;

- (NSString *) primaryType;
- (void) setPrimaryType: (NSString *) thePrimaryType;

- (NSString *) subType;
- (void) setSubType: (NSString *) theSubType;

- (NSEnumerator *) fileExtensions;
- (NSString *) stringValueOfFileExtensions;
- (void) setFileExtensions: (NSString *) theFileExtensions;

- (int) view;
- (void) setView: (int) theView;

- (int) action;
- (void) setAction: (int) theAction;

- (NSString *) dataHandlerCommand;
- (void) setDataHandlerCommand: (NSString *) theDataHandlerCommand;

- (NSImage *) icon;
- (void) setIcon: (NSImage *) theIcon;

- (NSString *) description;
- (void) setDescription: (NSString *) theDescription;

@end

#endif // _GNUMail_H_MimeType

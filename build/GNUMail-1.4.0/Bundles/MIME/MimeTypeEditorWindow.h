/*
**  MimeTypeEditorWindow.h
**
**  Copyright (c) 2001, 2002, 2003 Ludovic Marcotte
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
**  You should have received a copy of the GNU General Public License
**  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef _GNUMail_H_MimeTypeEditorWindow
#define _GNUMail_H_MimeTypeEditorWindow

#import <AppKit/AppKit.h>

@interface MimeTypeEditorWindow : NSWindow
{
  NSTextField *mimeTypeField, *fileExtensionsField, *descriptionField, *dataHandlerCommandField;
  NSButton *dataHandlerCommandButton, *iconButton;
  NSMatrix *viewMatrix, *actionMatrix;
}

- (void) layoutWindow;
- (void) dealloc;

//
// access/mutation methods
//
- (NSTextField *) mimeTypeField;
- (NSTextField *) fileExtensionsField;
- (NSTextField *) descriptionField;
- (NSTextField *) dataHandlerCommandField;

- (NSButton *) dataHandlerCommandButton;
- (NSButton *) iconButton;

- (NSMatrix *) viewMatrix;
- (NSMatrix *) actionMatrix;

@end

#endif // _GNUMail_H_MimeTypeEditorWindow

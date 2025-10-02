/*
**  MailboxManager.h
**
**  Copyright (c) 2001, 2002, 2003, 2004 Ludovic Marcotte
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

#ifndef _GNUMail_H_MailboxManager
#define _GNUMail_H_MailboxManager

#import <AppKit/AppKit.h>

@class ExtendedOutlineView;

@interface MailboxManager : NSPanel
{
  @public
    NSTableColumn *mailboxColumn, *messagesColumn;
    ExtendedOutlineView *outlineView;
    NSScrollView *scrollView;
}

- (void) layoutWindow;
- (void) dealloc;

@end

#endif // _GNUMail_H_MailboxManager

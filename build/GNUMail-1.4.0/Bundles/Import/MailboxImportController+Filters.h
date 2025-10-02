/*
**  MailboxImportController+Filters.h
**
**  Copyright (c) 2003-2004 Ludovic Marcotte
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

#ifndef _GNUMail_H_MailboxImportController_Filters
#define _GNUMail_H_MailboxImportController_Filters

#include "MailboxImportController.h"

@class CWStore;

@interface MailboxImportController (Filters)
     
- (void) importFromEntourage;
- (void) importFromMbox;

- (NSString *) uniqueMailboxNameFromName: (NSString *) theName
                                   store: (CWStore *) theStore
                                   index: (int) theIndex
                            proposedName: (NSString *) theProposedName;

@end

#endif // _GNUMail_H_MailboxImportController_Filters

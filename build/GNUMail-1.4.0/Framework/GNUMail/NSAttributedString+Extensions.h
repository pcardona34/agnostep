/*
**  NSAttributedString+Extensions.h
**
**  Copyright (c) 2004-2005 Ludovic Marcotte
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

#ifndef _GNUMail_H_NSAttributedString_Extensions
#define _GNUMail_H_NSAttributedString_Extensions

#import <AppKit/AppKit.h>

@class CWMessage;
@class CWMIMEMultipart;
@class CWPart;

@interface NSAttributedString (GNUMailAttributedStringExtensions)

+ (NSAttributedString *) attributedStringFromContentForPart: (CWPart *) thePart
                                                 controller: (id) theController;
+ (NSAttributedString *) attributedStringFromHeadersForMessage: (CWMessage *) theMessage
                                                showAllHeaders: (BOOL) showAllHeader
                                             useMailHeaderCell: (BOOL) useMailHeaderCell;
+ (NSAttributedString *) attributedStringFromMultipartAlternative: (CWMIMEMultipart *) theMimeMultipart
                                                       controller: (id) theController;
+ (NSAttributedString *) attributedStringFromMultipartAppleDouble: (CWMIMEMultipart *) theMimeMultipart
                                                       controller: (id) theController;
+ (NSAttributedString *) attributedStringFromTextPart: (CWPart *) thePart;
+ (NSAttributedString *) attributedStringWithString: (NSString *) theString
                                         attributes: (NSDictionary *) theAttributes;

- (NSSize) sizeInRect: (NSRect) theRect;

@end

@interface NSMutableAttributedString (GNUMailMutableAttributedStringExtensions)

- (void) format;
- (void) highlightAndActivateURL;
- (void) quote;

@end
#endif // _GNUMail_H_NSAttributedString_Extensions

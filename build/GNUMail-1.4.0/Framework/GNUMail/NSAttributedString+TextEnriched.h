/*
**  NSAttributedString+TextEnriched.h
**
**  Copyright (c) 2001-2004 Ludovic Marcotte
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

#ifndef _GNUMail_H_NSAttributedString_TextEnriched
#define _GNUMail_H_NSAttributedString_TextEnriched

#import <AppKit/AppKit.h>

@interface NSAttributedString (TextEnriched)

+ (NSAttributedString *) attributedStringFromTextEnrichedString: (NSString *) theString;

+ (void) _alterAttributedString: (NSMutableAttributedString *) theMutableAttributedString
		    withScanner: (NSScanner *) theScanner
		    fontManager: (NSFontManager *) theFontManager
		       startCmd: (NSString *) theStartCmd
			 endCmd: (NSString *) theEndCmd
                          trait: (int) theTrait;

+ (void) _removeCommandsFromAttributedString: (NSMutableAttributedString *) theMutableAttributedString;

+ (void) _unfoldAttributedString: (NSMutableAttributedString *) theMutableAttributedString;

@end

#endif // _NSAttributedString_TextEnriched

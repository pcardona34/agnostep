/*
 **  AutoCompletingTextField.h
 **
 **  Copyright (c) 2003 Ken Ferry
 **  Copyright (C) 2023 Riccardo Mottola
 **
 **  Author: Ken Ferry <kenferry@mac.com>
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

#ifndef _GNUMail_H_AutoCompletingTextField
#define _GNUMail_H_AutoCompletingTextField

#import <AppKit/AppKit.h>

@interface NSObject ( CompletionsDataSource )

// should return nil if there is no valid completion
- (NSString *)completionForPrefix:(NSString *)prefix;
- (NSArray *)allCompletionsForPrefix:(NSString *)prefix;
- (BOOL)isACompletion:(NSString *)candidate;

@end

@interface AutoCompletingTextField : NSTextField
{
  NSRange _componentRange;
  NSRange _prefixRange;
  NSArray *_cachedCompletions;
  float _completionDelay;
  NSUInteger _maximumDropDownRows;
  BOOL _commaDelimited;
  BOOL _dropDownIsDown;

  BOOL _justDeleted;
  BOOL _shouldShowDropDown;
  BOOL _textViewDoCommandBySelectorResponse;
  
  id _dataSource;
}

- (void)complete:(id)sender;
- (NSRange)currentComponentRange;

- (BOOL)dropDownIsDown;
- (void)setDropDownIsDown:(BOOL)flag;

- (id)dataSource;
- (void)setDataSource:(id)dataSource;
- (BOOL)commaDelimited;
- (void)setCommaDelimited:(BOOL)commaDelimited;
- (float)completionDelay;
- (void)setCompletionDelay:(float)completionDelay;
- (NSUInteger)maximumDropDownRows;
- (void)setMaximumDropDownRows:(NSUInteger)maxRows;

@end

#endif // _GNUMail_H_AutoCompletingTextField

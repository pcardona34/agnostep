/*
**  FilterEditorWindow.h
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
**  You should have received a copy of the GNU General Public License
**  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef _GNUMail_H_FilterEditorWindow
#define _GNUMail_H_FilterEditorWindow

#import <AppKit/AppKit.h>

@interface FilterEditorWindow : NSWindow
{
  @public
    NSTextField *descriptionField;
    NSButton *activeButton;
  
    NSMatrix *filterTypeMatrix;
  
    // External program
    NSButton *externalProgramButton;
    NSTextField *externalProgramField;
    NSPopUpButton *externalProgramPopUpButton;

    NSBox *criteriaBox;
  
    // First criteria
    NSPopUpButton *criteriaSourcePopUpButtonA;
    NSPopUpButton *criteriaFindOperationPopUpButtonA;
    NSTextField *criteriaStringFieldA;
    NSPopUpButton *criteriaPopUpButtonA;
  
    // Second criteria
    NSPopUpButton *criteriaConditionPopUpButtonB;
    NSPopUpButton *criteriaSourcePopUpButtonB;
    NSPopUpButton *criteriaFindOperationPopUpButtonB;
    NSTextField *criteriaStringFieldB;
    NSPopUpButton *criteriaPopUpButtonB;

    // Third criteria
    NSPopUpButton *criteriaConditionPopUpButtonC;
    NSPopUpButton *criteriaSourcePopUpButtonC;
    NSPopUpButton *criteriaFindOperationPopUpButtonC;
    NSTextField *criteriaStringFieldC;
    NSPopUpButton *criteriaPopUpButtonC;

    // Other UI elements
    NSMatrix *matrix;
    NSColorWell *actionColorWell;
    NSPopUpButton *actionFolderNamePopUpButton;
    NSPopUpButton *actionEMailStringPopUpButton;
    NSTextField *actionEMailStringField;
    NSButton *actionEMailStringButton;
  
    NSTextField *pathToSoundField;
    NSButton *chooseFileButton;
}

- (void) layoutWindow;

@end

#endif // _GNUMail_H_FilterEditorWindow

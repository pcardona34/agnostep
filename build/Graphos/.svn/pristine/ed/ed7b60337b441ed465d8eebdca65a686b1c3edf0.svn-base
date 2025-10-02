/*
 Project: Graphos
 GRObjectEditor.h

 Copyright (C) 2008-2013 GNUstep Application Project

 Author: Ing. Riccardo Mottola

 Created: 2008-02-25

 This application is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public
 License as published by the Free Software Foundation; either
 version 2 of the License, or (at your option) any later version.

 This application is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 Library General Public License for more details.

 You should have received a copy of the GNU General Public
 License along with this library; if not, write to the Free
 Software Foundation, Inc., 31 Milk Street #960789 Boston, MA 02196 USA.
 */


#import <Foundation/Foundation.h>
#import "GRDrawableObject.h"

/**
 * This abstract class is the companion of the GRDrawableObject class.
 * It defines the most generic behaviour of an object editor.
 */
@interface GRObjectEditor : NSObject <NSCopying>
{
  GRDrawableObject *object;
  BOOL groupSelected;
  BOOL editSelected;
  BOOL isValid;
  BOOL isDone;
}

- (id)initEditor:(GRDrawableObject *)anObject;
- (void)setObject:(GRDrawableObject *)anObject;
- (void)select;
- (void)selectAsGroup;
- (void)selectForEditing;
- (BOOL)isSelected;
- (BOOL)isGroupSelected;
- (void)unselect;
- (BOOL)isEditSelected;
- (BOOL)isDone;
- (void)setIsDone:(BOOL)status;
- (void)setIsValid:(BOOL)value;
- (BOOL)isValid;
- (void)draw;

@end

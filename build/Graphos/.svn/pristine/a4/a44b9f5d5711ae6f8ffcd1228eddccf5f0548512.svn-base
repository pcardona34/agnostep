/*
 Project: Graphos
 GRObjectEditor.m

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


#import "GRObjectEditor.h"
#import "GRDocView.h"

@implementation GRObjectEditor

- (id)initEditor:(GRDrawableObject *)anObject
{
    self = [super init];
    if(self != nil)
    {
        object = anObject;
        groupSelected = NO;
        editSelected = NO;
        isDone = NO;
        isValid = NO;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    GRObjectEditor *objCopy;

    objCopy = [[[self class] allocWithZone:zone] init];
    objCopy->groupSelected = groupSelected;
    objCopy->editSelected = editSelected;
    objCopy->isDone = isDone;
    objCopy->isValid = isValid;

    objCopy->object = nil;
    
    return objCopy;
}


- (void)setObject:(GRDrawableObject *)anObject
{
    object = anObject;
}

- (void)select
{
    [self selectAsGroup];
}

- (void)selectAsGroup
{
    if([object locked])
        return;
    
    if(!groupSelected)
    {
        groupSelected = YES;
        editSelected = NO;
        isValid = NO;
        
	[[object view] unselectOtherObjects: (GRDrawableObject *)object];
    }
}

- (void)selectForEditing
{
    if([object locked])
        return;
    editSelected = YES;
    groupSelected = NO;
    isValid = NO;
    isDone = NO;
    [[object view] unselectOtherObjects: (GRDrawableObject *)object];
}


- (void)unselect
{
    groupSelected = NO;
    editSelected = NO;
    isValid = YES;
    isDone = YES;
}

- (BOOL)isSelected
{
    if(editSelected || groupSelected)
        return YES;
    return NO;
}

- (BOOL)isGroupSelected
{
    return groupSelected;
}

- (BOOL)isEditSelected
{
    return editSelected;
}

- (BOOL)isDone
{
  return isDone;
}

- (void)setIsDone:(BOOL)status
{
  isDone = status;
}


- (void)setIsValid:(BOOL)value
{
  isValid = value;
}

- (BOOL)isValid
{
  return isValid;
}

- (void)draw
{
}

@end

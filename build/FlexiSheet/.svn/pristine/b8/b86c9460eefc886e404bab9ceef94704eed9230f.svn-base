//  $Id: FSValue.m,v 1.1 2008/10/14 15:04:24 hns Exp $
//
//  FSValue.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 29-JAN-2001.
//
//  Copyright (c) 2001-2004, Stefan Leuker.        All rights reserved.
//  
//  Redistribution and use in source and binary forms,  with or without
//  modification,  are permitted provided that the following conditions
//  are met:
//  
//  *  Redistributions of source code must retain the above copyright
//     notice,  this list of conditions and the following disclaimer.
//  
//  *  Redistributions  in  binary  form  must  reproduce  the  above
//     copyright notice,  this  list of conditions  and the following
//     disclaimer  in  the  documentation  and / or  other  materials
//     provided with the distribution.
//  
//  *  Neither the name  "FlexiSheet"  nor the names of its copyright
//     holders  or  contributors  may  be used  to endorse or promote
//     products  derived  from  this software  without specific prior
//     written permission.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
//  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,  INCLUDING,  BUT NOT
//  LIMITED TO,  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND  FITNESS
//  FOR  A PARTICULAR PURPOSE  ARE  DISCLAIMED.  IN NO EVENT  SHALL THE
//  COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
//  INCIDENTAL, SPECIAL, EXEMPLARY OR CONSEQUENTIAL DAMAGES (INCLUDING,
//  BUT NOT LIMITED TO,  PROCUREMENT  OF  SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE,  DATA,  OR PROFITS;  OR BUSINESS INTERRUPTION) HOWEVER
//  CAUSED AND ON ANY THEORY OF LIABILITY,  WHETHER IN CONTRACT, STRICT
//  LIABILITY, OR TORT  (INCLUDING NEGLIGENCE OR OTHERWISE)  ARISING IN
//  ANY WAY  OUT  OF  THE USE OF THIS SOFTWARE,  EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//  

#import <FSCore/FoundationExtentions.h>
#import <FSCore/FSParserFunctions.h>
#import <FSCore/FSCore.h>

@implementation FSValue
/*" FSValue represents one value in a spread sheet. "*/


- (id)init
/*" Calls #initWithValue: with an empty string value. "*/
{
    return [self initWithValue:nil forKeys:nil];
}


- (id)initWithValue:(id)aValue
/*" Calls #initWithValue:forKeys: with an empty NSKeySet. "*/
{
    return [self initWithValue:aValue forKeys:nil];
}


- (id)initWithValue:(id)aValue forKeys:(FSKeySet*)keys
/*" Designated initialzier.  "*/
{
    self = [super init];
    if (self != nil) {
        // initialize the FSkeyset structure.
        _keyset.keys = NULL;
        _keyset.count = 0;
        _keyset.hashcodeChars =  NULL;
        if (keys) [self setKeys:keys];

        _value = @"";
        if (aValue) [self setValue:aValue postNotification:NO];

        _cachedUM = nil;
        TEST_DBG [FSLog logDebug:@"FSValue allocated."];
    }
    return self;
}


- (void)dealloc
{
    [_cachedUM removeAllActionsWithTarget:self];
    [_cachedUM release];
    [_value release];
    [_valueFormula release];
    [_type release];
    [_possibleValues release];
    TEST_DBG [FSLog logDebug:@"FSValue deallocated."];
    [super dealloc];
}


- (NSString*)type
{
    return _type;
}


- (void)_setType:(NSString*)aType
{
    [aType retain];
    [_type release];
    _type = aType;
}


BOOL simpleNumericCheck(NSString* strg)
{
    static NSCharacterSet *numChars = nil;
    
    if ([strg length] == 0) return NO;

    if (numChars == nil) {
        NSString *num = @"+-01234567890.eE ";
        numChars = [[NSCharacterSet characterSetWithCharactersInString:num] retain];
    }

    return ([numChars characterIsMember:[strg characterAtIndex:0]]);
}


- (void)_setValue:(id)newValue
{
    if (newValue == _value) return;

    if ([newValue isKindOfClass:[NSString class]]) {
        //NSScanner *scanner;
        double     numeric;

        if (FSScanDoubleFromString((NSString*)newValue, &numeric)) {
            newValue = [NSNumber numberWithDouble:numeric];
        }
    }

    if (NO == [newValue isMemberOfClass:[_value class]]) {
        if ([newValue isKindOfClass:[NSNumber class]]) {
            [self _setType:@"NSNumber"];
        } else if ([newValue isKindOfClass:[NSDate class]]) {
            [self _setType:@"NSDate"];
        } else if ([newValue isKindOfClass:[NSString class]]) {
            [self _setType:@"NSString"];
        } else {
            [self _setType:[newValue className]];
        }
    } else {
        if ([newValue isEqual:_value]) return;
    }
    [newValue retain];
    [_value release];
    _value = newValue;
}


- (id)value
/*" Returns the value object.  Note that this can be any kind of NSObject subclass!"*/
{
    if ((_value == nil) && (_valueFormula)) {
        //[FSLog logInfo:@"Calculating new value for %@.", [_keys description]];
        [self _setValue:@""]; // so we don't loop forever
        [self _setValue:[_valueFormula formulaValueForKeySet:[FSKeySet keySet:&_keyset]]];
        //[FSLog logInfo:@"Calculation done for %@.", [_keys description]];
    }
    return _value;
}


- (double)doubleValue
{
    return [[self value] doubleValue];
}


- (int)intValue
{
    return [[self value] intValue];
}


- (NSString*)stringValue
/*" Returns the value as a string.  Formatting is considered for numbers, dates, etc. "*/
{
    if ([self value] == nil) return @"";
    return [[self value] description];
}


- (void)setValue:(id)newValue
{
    [self setValue:newValue postNotification:YES];
}


- (void)setValue:(id)newValue postNotification:(BOOL)flag
{
    if ([newValue isKindOfClass:[FSFormula class]]) {
        _value = nil;
        _valueFormula = [newValue retain];
    } else {
        if (_value) {
            NSUndoManager *um = [_table undoManager];
            if ([um isUndoRegistrationEnabled]) {
                [um registerUndoWithTarget:self selector:@selector(setValue:) object:_value];
            }
        }
        [self _setValue:newValue];
        [_valueFormula release];
        _valueFormula = nil;
    }
    if (flag) {
        [[_table notificationCenter] postNotificationName:FSValueDidChangeNotification object:_table];
    }
}


- (void)setKeys:(FSKeySet*)newKeys
/*" Sets the key set.  Keys can not be modified separately, however it is possible to add single keys to the key set. "*/
{
    if (newKeys) {
        FSkeysetCopyKeys(&_keyset, &(newKeys->_data));
        _table = [newKeys table];
   }
}


- (void)addKey:(FSKey*)newKey
/*" Adds a key to the current key set. "*/
{
    FSkeysetAddKey(&_keyset, newKey);
}


- (void)revalidateKeys
/*" Calls FSkeysetRevalidate and updates the hashcode. "*/
{
    FSkeysetRevalidate(&_keyset);
}


- (FSKeySet*)keySet
{
    return [FSKeySet keySet:&_keyset];
}


- (FSHashKey)hashcode
/*" Returns the hashcode for this value.  

The hashcode is a unique identifier that remains the same as long as the key set does not change. "*/
{
    if (!_keyset.hashcodeChars) {
        FSkeysetGenerateHashcode(&_keyset);
    }
    return _keyset.hashcodeChars;
}


- (BOOL)hasCompleteKeys
{
    FSTable       *theTable = nil;
    NSArray       *headers;
    FSKey         *aKey;
    int            index = _keyset.count;
    
    if (_keyset.keys == NULL) return NO;

    // First key not set?  Not complete.
    aKey = _keyset.keys[0];
    if (aKey == nil) return NO;

    // We have the table all keys must belong to.
    theTable = [aKey table];
    headers = [theTable headers];

    if ([headers count] != _keyset.count) {
        FSkeysetRevalidate(&_keyset);
        index = _keyset.count;
    }

    while (index-- > 0) {
        if (theTable != [_keyset.keys[index] table]) return NO;
    }
    return YES;
}


- (BOOL)hashcodeEqualTo:(FSHashKey)hc
{
    if (!hc) return NO;
    return (strcmp(hc, [self hashcode]) == 0);
}


- (NSString*)description
{
    return [_value description];
}


- (id)copyWithZone:(NSZone*)zone
{
    return [self retain];
}


- (FSFormula*)calculatedByFormula
{
    return _valueFormula;
}

//
// Sorting
//

- (NSComparisonResult)smartCompare:(FSValue*)otherObject
{
    return [[self stringValue] compare:[otherObject stringValue] options:NSCaseInsensitiveSearch];
}

- (NSComparisonResult)smartCompareReverse:(FSValue*)otherObject
{
    return -[self smartCompare:otherObject];
}

@end

@implementation FSValue (Archiving)

- (NSDictionary*)dictionaryForArchiving
{
    NSMutableDictionary  *dict = nil;
    NSString             *strg = [self stringValue];
    
    //[dict setObject:@"FSValue" forKey:@"Class"];
    if ([strg length] > 0) {
        dict = [NSMutableDictionary dictionary];
        [dict setObject:[self type] forKey:@"Type"];
        [dict setObject:strg forKey:@"Value"];
        [dict setObject:[[FSKeySet keySet:&_keyset] dictionaryForArchiving] forKey:@"KeySet"];
    }
    
    return dict;
}

@end

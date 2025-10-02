//
//  FSGraffleExport.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 06-MAY-2002.
//  Copyright (c) 2001-2003 Stefan Leuker. All rights reserved.
//
//  $Id: FSGraffleExport.m,v 1.1 2008/10/14 15:03:45 hns Exp $

#import "FSGraffleExport.h"


@implementation FSGraffleExport

+ (FSGraffleExport*)graffleDocument
{
    return [[[self alloc] init] autorelease];
}


- (id)init
{
    self = [super init];
    if (self) {
        graffleDocument = [[NSMutableDictionary alloc] init];
        [graffleDocument setObject:[NSNumber numberWithInt:2] forKey:@"GraphDocumentVersion"];
        [graffleDocument setObject:[NSNumber numberWithInt:0] forKey:@"ColumnAlign"];
        [graffleDocument setObject:[NSNumber numberWithInt:1] forKey:@"VPages"];
    }
    return self;
}


- (void)dealloc
{
    [graffleDocument release];
    [super dealloc];
}


- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile
{
    return [graffleDocument writeToFile:path atomically:useAuxiliaryFile];
}

@end

/*
 **  GetURLScriptCommand.h
 **
 **  Copyright (c) 2003 Ujwal S. Sathyam
 **
 **  Author: Ujwal S. Sathyam
 **
 **  Project: GNUMail
 **
 **  Description: Header file for Applescript support for GNUMail.
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

#ifndef _GNUMail_H_GetURLScriptCommand
#define _GNUMail_H_GetURLScriptCommand

#import <Foundation/Foundation.h>

@interface GetURLScriptCommand : NSScriptCommand {

}

- (id)scriptError:(int)errorNumber description:(NSString *)description;
- (id)performDefaultImplementation;

@end

#endif // _GNUMail_H_GetURLScriptCommand

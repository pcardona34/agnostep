/*
**  MessageComposition.h
**
**  Copyright (c) 2001-2004 Ujwal S. Sathyam
**
**  Author: Ujwal S. Sathyam
**
**  Description: Header file for scriptable MessageComposition class.
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

#ifndef _GNUMail_H_MessageComposition
#define _GNUMail_H_MessageComposition

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@class CWInternetAddress;
@class ToRecipient;
@class CcRecipient;
@class BccRecipient;
@class EditWindowController;

@interface MessageComposition : NSObject 
{
  // instance variables for attributes: 
  NSString *_author;
  NSTextStorage *_content;
  int _signaturePosition;
  BOOL _hasSignature;
  NSString *_subject;
  NSMutableArray *_attachments;
  NSString *_account;
  
  // instance variables for to-many relationships: 
  NSMutableArray *_recipients;
  
  @private
    EditWindowController *_editWindowController;
}

- (void) send;
- (void) show: (BOOL) flag;
- (void) addAttachment: (NSString *) aFileName;

//
// accessors for attributes:
// 
- (NSString *) author;
- (void) setAuthor: (NSString *)author;
- (NSTextStorage *) content;
- (void) setContent: (NSTextStorage *)content;
- (int) signaturePosition;
- (void) setSignaturePosition: (int) signaturePosition;
- (BOOL) hasSignature;
- (void) setHasSignature: (BOOL) hasSignature;
- (NSString *) subject;
- (void) setSubject: (NSString *) subject;
- (NSArray *) attachments;
- (void) setAttachments: (NSArray *) attachments;
- (NSString *) account;
- (void) setAccount: (NSString *) accountName;

//
// accessors for to-many relationships:
// 
- (NSArray *)recipients;
- (void) setRecipients: (NSArray *) recipients;
- (NSArray *)ccRecipients;
- (void) setCcRecipients: (NSArray *) ccRecipients;
- (NSArray *)bccRecipients;
- (void) setBccRecipients: (NSArray *) bccRecipients;
- (NSArray *)toRecipients;
- (void) setToRecipients: (NSArray *) toRecipients;

@end


//
//
//
@interface MessageComposition (KeyValueCoding)

- (void) insertInRecipients: (CWInternetAddress *) object;
- (void) insertInRecipients: (CWInternetAddress *) object  atIndex: (NSUInteger) theIndex;
- (void) removeFromRecipientsAtIndex: (NSUInteger) theIndex;
- (void) replaceInRecipients: (CWInternetAddress *) object  atIndex: (NSUInteger) theIndex;
- (id) valueInRecipientsAtIndex: (NSUInteger) index;
- (void) insertInToRecipients: (ToRecipient *) object;
- (void) insertInToRecipients: (ToRecipient *) object  atIndex: (NSUInteger) theIndex;
- (void) removeFromToRecipientsAtIndex: (NSUInteger) theIndex;
- (void) replaceInToRecipients: (ToRecipient *) object  atIndex: (NSUInteger) theIndex;
- (id) valueInToRecipientsAtIndex: (NSUInteger) theIndex;
- (void) insertInCcRecipients: (CcRecipient *) object;
- (void) insertInCcRecipients: (CcRecipient *) object  atIndex: (NSUInteger) theIndex;
- (void) removeFromCcRecipientsAtIndex: (NSUInteger) theIndex;
- (void) replaceInCcRecipients: (CcRecipient *) object  atIndex: (NSUInteger) theIndex;
- (id) valueInCcRecipientsAtIndex: (NSUInteger) theIndex;
- (void) insertInBccRecipients: (BccRecipient *) object;
- (void) insertInBccRecipients: (BccRecipient *) object  atIndex: (NSUInteger) theIndex;
- (void) removeFromBccRecipientsAtIndex: (NSUInteger) theIndex;
- (void) replaceInBccRecipients: (BccRecipient *) object  atIndex: (NSUInteger) theIndex;
- (id) valueInBccRecipientsAtIndex: (NSUInteger) theIndex;

@end

@interface MessageComposition (Private)

- (void) _loadMessage;

@end

#ifdef MACOSX
@interface MessageComposition (ScriptingSupport)

//
// Object specifier
//
- (NSScriptObjectSpecifier *)objectSpecifier;

//
// Handlers for supported commands:
//
- (void) handleSendMessageScriptCommand: (NSScriptCommand *) command;
- (void) handleShowMessageScriptCommand: (NSScriptCommand *) command;
- (void) handleAttachScriptCommand: (NSScriptCommand *) command;

@end

#endif

#endif // _GNUMail_H_MessageComposition

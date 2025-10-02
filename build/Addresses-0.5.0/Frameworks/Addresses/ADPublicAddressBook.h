// ADPublicAddressBook.h (this is -*- ObjC -*-)
// 
// Author: Bj�rn Giesler <giesler@ira.uka.de>
// 
// Address Book Framework for GNUstep
// 

#import <Addresses/ADAddressBook.h>

@interface ADPublicAddressBook: ADAddressBook
{
  BOOL _readOnly;
  ADAddressBook *_book;
}

- (instancetype)initWithAddressBook: (ADAddressBook*) book
			   readOnly: (BOOL) ro;
@end

@protocol ADSimpleAddressBookServing
- (ADAddressBook*) addressBookForReadOnlyAccessWithAuth: (id) auth;
- (ADAddressBook*) addressBookForReadWriteAccessWithAuth: (id) auth;
@end


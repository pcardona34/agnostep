// ADEnvelopeAddressBook.h (this is -*- ObjC -*-)
// 
// Author: Björn Giesler <giesler@ira.uka.de>
// 
// Address Book Framework for GNUstep
// 

#import <Addresses/ADAddressBook.h>


@interface ADEnvelopeAddressBook: ADAddressBook
{
  NSMutableArray *_books;
  ADAddressBook *_primary;
  BOOL _merge;
}
  
+ (ADAddressBook*) sharedAddressBook;

- (instancetype) initWithPrimaryAddressBook: (ADAddressBook*) book;

- (BOOL) addAddressBook: (ADAddressBook*) book;
- (BOOL) removeAddressBook: (ADAddressBook*) book;

- (void) setPrimaryAddressBook: (ADAddressBook*) book;
- (ADAddressBook*) primaryAddressBook;
- (NSEnumerator*) addressBooksEnumerator;

- (void) setMergesAddressBooks: (BOOL) merge;
- (BOOL) mergesAddressBooks;
@end

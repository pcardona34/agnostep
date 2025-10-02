// ADSinglePropertyView.h (this is -*- ObjC -*-)
// 
// \author: Bj�rn Giesler <giesler@ira.uka.de>
// 
// Address View Framework for GNUstep

#import <AppKit/AppKit.h>
#import <Addresses/Addresses.h>


@class ADSinglePropertyView;

@interface NSObject (ADSinglePropertyViewDelegate)
- (void) doubleClickOnName: (NSString*) name
		     value: (NSString*) value
		    inView: (ADSinglePropertyView*) aView;
@end

typedef enum {
  ADAutoselectNone       = 0,
  ADAutoselectAll        = 1,
  ADAutoselectFirstValue = 2
} ADAutoselectMode;

@interface ADSinglePropertyView: NSView
{
  NSString *_property, *_prefLabel;
  ADAutoselectMode _autosel;
  
  NSMutableArray *_names, *_namesUnthinned, *_values, *_people;
  ADGroup *_selectedGroup;
  ADAddressBook *_book;
  NSSplitView *_splitView;
  NSBrowser *_groupsBrowser;
  NSTableView *_peopleTable;
  NSScrollView *_ptScrollView;
  NSTableColumn *_nameColumn;
  NSTableColumn *_propertyColumn;
  id _delegate;
}

- (instancetype) initWithFrame: (NSRect) frame;

- (void) setDelegate: (id) delegate;
- (id) delegate;

- (void) setDisplayedProperty: (NSString*) property;
- (NSString*) displayedProperty;

// This value, if non-nil, narrows down the display of multi-values
// somewhat. The algorithm is as follows:
//     foreach ADPerson p in [group members] or [book people]:
//          if [[person valueForProperty: displayedProperty]
//                  hasValueWithLabel: preferredLabel]:
//              insert all values with the matching label
//          else:
//              insert all values for the property
// Has no effect on non-multivalues. nil by default.
- (void) setPreferredLabel: (NSString*) preferredLabel;
- (NSString*) preferredLabel;

// This value toggles whether the view should autoselect everything,
// if it deems it sensible. If set, all addresses will be autoselected
// on:
//         o selecting a group (but not "All")
//         o setting a new preferredLabel
// ADAutoselectNone by default.
- (void) setAutoselectMode: (ADAutoselectMode) mode;
- (ADAutoselectMode) autoselectMode;
- (void) autoselectAccordingToMode: (ADAutoselectMode) mode;

// Return an array of two-string arrays (Name, Value)
- (NSArray*) selectedNamesAndValues;
// Return an array of arrays (person[ADPerson*], Value[NSString*],
//                            Index[NSNumber]).
- (NSArray*) selectedPeopleAndValues;
// Return an array of strings
- (NSArray*) selectedValues;

- (ADGroup*) selectedGroup;
- (NSArray*) selectedPeople;
@end

#ifndef FUNCTIONS_H
#define FUNCTIONS_H

@class NSString;
@protocol NSMenuItem;

id <NSMenuItem> addItemToMenu(NSMenu *menu, NSString *str, 
														NSString *comm, NSString *sel, NSString *key);

#endif

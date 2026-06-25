/* 
####################################################
### A G N o S t e p  -  Desktop - by Patrick Cardona
### (c) 2026 - pcardona34 @ Github
### Author: Patrick Cardona
###
### Thanks for the GNUstep Developers Community.
### This application is free software.
### Read complete License in the root directory.
####################################################

####################################################
### Pass.app
### Interface: ListController.h
####################################################
*/

#import <AppKit/AppKit.h>

@interface ListController : NSObject

{    
  
  NSButton *closeButton; 
  NSWindow *listWindow;
  NSScrollView *scrollView;
  NSTextView *textView;
  NSButton *passButton;
  NSButton *editButton;
  
}

- (instancetype) init;
- (IBAction) showList: (id)sender;
- (IBAction) closeWindow:(id)sender;
- (IBAction) pass:(id) sender;
- (IBAction) edit:(id) sender;
- (void) loadDataSynchronously;

@end
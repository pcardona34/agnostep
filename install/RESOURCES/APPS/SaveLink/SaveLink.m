/* 
####################################################
### A G N o S t e p  -  Desktop - by Patrick Cardona
### (c) 2026 - pcardona34 @ Github
###
### Thanks for the GNUstep Developers Community
### This is Free and Open Source software.
### Read License in the root directory.
####################################################

####################################################
### SaveLink: an Internet Shortcuts Manager
### SaveLink.m: Implementation
####################################################
*/

#import "SaveLink.h"

@implementation SaveLink

- (instancetype) init
{

if (( self = [super init] )){
  manager = [NSFileManager defaultManager];
  }
return self;
}

- (BOOL) checkDirectory: (NSString *) dir
{
  BOOL isDirectory;
  BOOL exists = [manager fileExistsAtPath: dir
                         isDirectory: &isDirectory];
  if (exists && isDirectory) {
    return YES;
  }else{
    return NO;
  }
}

- (NSString *) favPath
{
 // Retrieving UserName of the current User and then his homeDirectory
  NSString *userName = NSUserName();
  NSString *homeDir = NSHomeDirectoryForUser(userName);
  
  // LANG prefix?
  NSArray *languages = [[NSUserDefaults standardUserDefaults]   
              stringArrayForKey:@"NSLanguages"];  
  NSString *firstLanguage = [languages firstObject];  
  NSString *languagePrefix = [[firstLanguage substringToIndex: 2] lowercaseString];
  
  // Favorites Folder Name?
  NSString *favFolder;
  NSArray *items;
  items = [NSArray arrayWithObjects: @"fr", @"en", nil];
  NSInteger item = [items indexOfObject: languagePrefix];
  switch (item) {
    case 0:
       favFolder = @"/Favoris/";
       break;
    case 1:
       favFolder = @"/Favorites/";
       break;
    default:
       favFolder = @"/Favorites/";
   }
   NSString *favPath = [homeDir stringByAppendingString: favFolder];
   return favPath;
}

- (void) awakeFromNib
{
  // Register for notifications
  [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textDidChange:)
                                                 name:NSControlTextDidChangeNotification
                                               object:name];
                                               
   [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textDidChange:)
                                                 name:NSControlTextDidChangeNotification
                                               object:link];
  
  NSArray *arguments = [[NSProcessInfo processInfo] arguments];
  // Check if there are any arguments passed
    if ([arguments count] > 1) 
      {
        NSString *filePath = [arguments lastObject]; // The last argument is the file path
        [self openWithPath: filePath];
      }
}

- (void) applicationDidFinishLaunching: (NSNotification *)aNotif
{
  
}

- (IBAction) save: (id)sender
{
  NSLog(@"We enter in Save Link method...");
  // We retrieve values from textFileds outlets
  // Also We trim spaces in the nameLink:
  NSString *nameLink = [[name stringValue] stringByReplacingOccurrencesOfString:@" " withString:@""];
  NSString *urlLink = [link stringValue];
  
  // Setting filePath
  NSString *ext = @".url";
  NSString *favPath = [self favPath];
  NSLog(@"FavPath is: %@", favPath);
   
  // We check Favorites path
  if ([self checkDirectory: favPath]) {
            NSString *filePath = [[favPath 
            stringByAppendingString: nameLink] stringByAppendingString: ext];
      
  // Preparing the content to write
  NSString *content = [NSString stringWithFormat: @"[InternetShortcut]\nURL=%@\n", urlLink];
  // Writing to File Name.url
  NSError *error;
  BOOL success;

  success = [content writeToFile:filePath
                         atomically:YES
                           encoding:NSUTF8StringEncoding
                              error:&error];

  if (!success) {
    NSLog(@"Failed to write file: %@", [error localizedDescription]);
    [NSApp terminate: self];                   
   }

 NSLog(@"End of save action");
 }
 else
 {
   NSLog(@"Path of Favorites not found!");
   NSAlert *alert = [[[NSAlert alloc] init] autorelease];
   [alert setMessageText: _(@"Path of Favorites not found!")];
   [alert setInformativeText: _(@"You should have a Favorites folder in your Home Directory.")];
   [alert runModal];
   [NSApp terminate:nil];
 }
}

- (IBAction) reset: (id)sender
{
  [link setStringValue:@""];
  [name setStringValue:@""];
  [name becomeFirstResponder];
}

- (IBAction) open:  (id)sender
{
  // Filter: we want only .url files to open
  NSArray *fileTypes;
  fileTypes = [NSArray arrayWithObjects: @"url", nil];
  // Open Panel
  NSOpenPanel *openPanel;
  openPanel = [[[NSOpenPanel alloc] init] autorelease];
  [openPanel runModalForTypes: fileTypes];
  NSArray *selection;
  selection = [openPanel filenames];
  NSString *openPath = [selection firstObject];
  
  // Getting the Name of the Link
  NSString *nameLink = [[openPath lastPathComponent] stringByDeletingPathExtension];
  [name setStringValue: nameLink];
  
  // Getting the Link value
  NSString *content;
  content = [NSString stringWithContentsOfFile: openPath];
  NSString *url =  [content substringFromIndex: 23];
  [link setStringValue: url];
  [savebutton setEnabled:YES];
}

- (void) openWithPath: (NSString *)pathFile;
{
  // Get Name of the Link
  NSString *fileName = [[pathFile lastPathComponent] stringByDeletingPathExtension];
  [name setStringValue: fileName];
  
  // Get Link value
  NSString *content;
  content = [NSString stringWithContentsOfFile: pathFile];
  NSString *url =  [content substringFromIndex: 23];
  [link setStringValue: url];
  [savebutton setEnabled:YES];
}

- (void)textDidChange:(NSNotification *)notification
{
  // We retrieve values from textFileds outlets
  // NSLog(@"textDidChange called.");
  NSString *nameLink = [name stringValue];
  NSString *urlLink = [link stringValue];
  [savebutton setEnabled:([nameLink length] && [urlLink hasPrefix: @"http"])];
}

@end

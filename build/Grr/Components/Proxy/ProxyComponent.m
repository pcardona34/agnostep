/*
   Grr RSS Reader
   
   Copyright (C) 2006, 2007 Guenther Noack <guenther@unix-ag.uni-kl.de>
   Copyright (C) 2009  GNUstep Application Team
                       Riccardo Mottola

   This application is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public
   License as published by the Free Software Foundation; either
   version 3 of the License, or (at your option) any later version.
 
   This application is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.
 
   You should have received a copy of the GNU General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 31 Milk Street #960789 Boston, MA 02196 USA. 
*/


#import "ProxyComponent.h"

#ifdef __APPLE__
#import "GNUstep.h"
#endif

@implementation ProxyComponent

// ---------------------------------------
//    init and dealloc
// ---------------------------------------

-(id) init
{
    if ((self = [super init]) != nil) {
        RETAIN(hostnameControl);
        RETAIN(portControl);
        RETAIN(proxyUseButton);
        
        ASSIGN(defaults, [NSUserDefaults standardUserDefaults]);
        
        [self updateGUI];
    }
    
    return self;
}

-(void) dealloc
{
    DESTROY(hostnameControl);
    DESTROY(portControl);
    DESTROY(proxyUseButton);
    DESTROY(defaults);
    [super dealloc];
}

// ---------------------------------------
//    Overriding stuff from the superclass
// ---------------------------------------

-(NSString*) prefPaneName
{
    return @"Proxy";
}

-(NSImage*) prefPaneIcon
{
    return [NSImage imageNamed: @"WebProxy"];
}

// ---------------------------------------
//    Handles actions invoked from the GUI and sets user defaults
// ---------------------------------------

-(void) hostnameChanged: (id)sender
{
    NSString* hostStr = [hostnameControl stringValue];
    
    [defaults setObject: hostStr forKey: @"ProxyHostname"];
    
    [self updateGUI];
}

-(void) portChanged: (id)sender
{
    int num = [[portControl stringValue] intValue];
    
    if (num == 0) {
        num = 3128;
    }
    
    [defaults setInteger: num forKey: @"ProxyPort"];
    [self updateGUI];
}

-(void) proxyUseButtonChanged: (id)sender
{
    BOOL enabled;
    int state = [proxyUseButton state];
    
    NSAssert1(state == NSOnState || state == NSOffState, @"Bad button state %d", state);
    
    if (state == NSOnState) {
        enabled = YES;
    } else { // NSOffState
        enabled = NO;
    }
    
    [defaults setBool: enabled forKey: @"ProxyEnabled"];
    [self updateGUI];
}

// ---------------------------------------
//    Updates the GUI from the user defaults
// ---------------------------------------

-(void) updateGUI
{
  NSString *hostName;
  
  hostName = [defaults stringForKey: @"ProxyHostname"];
  if(hostName != nil) // FIXME: this is a hack for MacOS 
      [hostnameControl setStringValue: hostName];
  
  [portControl setIntValue: [defaults integerForKey: @"ProxyPort"]];
  [proxyUseButton setIntValue: [defaults boolForKey: @"ProxyEnabled"]];
}

@end

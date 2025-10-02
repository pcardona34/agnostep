/*
   Grr RSS Reader
   
   Copyright (C) 2006, 2007 Guenther Noack <guenther@unix-ag.uni-kl.de>
   Copyright (C) 2009-2014  GNUstep Application Team
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

#ifndef _PLUGINCONTROLLER_H_
#define _PLUGINCONTROLLER_H_

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#import "PipeType.h"
#import "GNUstep.h"

extern NSString* ComponentDidUpdateNotification;

/**
 * Components conforming to this protocol send a ComponentDidUpdateNotification
 * with themselves as notification object whenever their output changes. Listeners can
 * then retrieve the output using the output providing component's -objectsForPipeType method.
 */
@protocol OutputProvidingComponent
/**
 * Returns the set of objects handled by this component that is
 * given out through the "pipe" with the given pipe type.
 */
-(NSSet*) objectsForPipeType: (id<PipeType>)aPipeType;
@end

/**
 * Components conforming to this protocol can be sent notifications to the
 * componentDidUpdateSet: method with an OutputProvidingComponent being the
 * notification object. They can then retrieve their input using the
 * OutputProvidingComponent's -objectsForPipeType method.
 *
 * @see OutputProvidingComponent
 */
@protocol InputAcceptingComponent
/**
 * Notifications sent to this method with an OutputPlugin being the notification object
 * tell the InputPlugin that an updated set of objects can be retrieved from the OutputPlugin.
 */
-(void)componentDidUpdateSet: (NSNotification*) aNotification;
@end


/**
 * This convenience protocol serves the sole purpose to release programmers
 * from writing OutputProvidingComponent,InputAcceptingComponent.
 */
@protocol FilterComponent <OutputProvidingComponent,InputAcceptingComponent>
@end


/**
 * Components conforming to this interface can return an NSView instance using their
 * -view method. The returned NSView reference must always refer to the same instance for
 * each instance of the ViewProvidingComponent.
 */
@protocol ViewProvidingComponent
/**
 * Returns the view belonging to this component.
 */
-(NSView*) view;
@end


/**
 * A class with a _view field that implements ViewProvidingComponent. Inherit from this class
 * for easy view providing component creation. The steps to do are:
 *
 * <ul>
 * <li>Create a subclass of this class</li>
 * <li>Create a Gorm file named like your subclass
 *    <ul>
 *    <li>Model this class and your subclass into the Gorm file. Don't forget the fields
 *        for your class and this classes' _view field.</li>
 *    <li>Connect this classes' _view outlet with the view you wish to use as component view.</li>
 *    </ul>
 * <li>Done. When your class is instantiated, the Gorm file will automatically be loaded and
 *     it will automatically return that view.</li>
 * </li>
 * </ul>
 */
@interface ViewProvidingComponent : NSObject <ViewProvidingComponent>
{
    IBOutlet NSView* _view;
}

-(NSView*) view;

/**
 * Small convenience method that can be used in almost every output providing component.
 */
-(void) notifyChanges;

@end

#endif // _PLUGINCONTROLLER_H_


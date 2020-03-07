//
//  AppDelegate.h
//  NewBezelServices
//
//  Created by Kelian on 05/07/2015.
//  Copyright © 2015 MLforAll. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HUDWindowController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSXPCListenerDelegate>
{
    HUDWindowController *_hudCtrl;
    NSXPCListener *_listener;
}

@end

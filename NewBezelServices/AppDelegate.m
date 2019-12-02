//
//  AppDelegate.m
//  NewBezelServices
//
//  Created by Kelian on 05/07/2015.
//  Copyright © 2015 OSXHackers. All rights reserved.
//

#import "AppDelegate.h"
#import "NSAppSubclass.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    hudCtrl = [[HUDWindowController alloc] initWithWindowNibName:@"HUDWindow"];
    [hudCtrl loadWindow];
    [(NSAppSubclass *)NSApp setHudCtrl:hudCtrl];
}

@end

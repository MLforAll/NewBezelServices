//
//  AppDelegate.m
//  NewBezelServices
//
//  Created by Kelian on 05/07/2015.
//  Copyright © 2015 MLforAll. All rights reserved.
//

#import "AppDelegate.h"
#import "NSAppSubclass.h"
#import "OSDUIHelper.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    _hudCtrl = [[HUDWindowController alloc] initWithWindowNibName:@"HUDWindow"];
    [_hudCtrl loadWindow];
    
#ifdef DEBUG
    [(NSAppSubclass *)NSApp setHudCtrl:_hudCtrl];
#else
    _listener = [[NSXPCListener alloc] initWithMachServiceName:@"com.apple.OSDUIHelper"];
    [_listener setDelegate:self];
    [_listener resume];
#endif
}

#pragma mark - XPC Delegate

#ifndef DEBUG

- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)newConnection
{
#pragma unused(listener)

    [newConnection setExportedInterface:[NSXPCInterface interfaceWithProtocol:@protocol(OSDUIHelperProtocol)]];
    [newConnection setExportedObject:self];

    [newConnection resume];

    return YES;
}

#pragma mark - OSDUIHelper Protocol

- (void)showImage:(long long)img onDisplayID:(CGDirectDisplayID)did priority:(unsigned int)prio msecUntilFade:(unsigned int)msec filledChiclets:(unsigned int)filled totalChiclets:(unsigned int)total locked:(int8_t)locked
{
#pragma unused(did, prio, msec)

    bezel_action_t action = kBezelActionUndef;
    switch (img)
    {
        case 4:
            action = kBezelActionMute;
            break ;
        case 5:
        case 23:
            action = kBezelActionVolume;
            break ;
        case 1:
            action = kBezelActionBrightness;
            break ;
        case 25:
            action = kBezelActionKeyBrightness;
            break ;
        case 26:
            action = kBezelActionKeyBrightnessOff;
            break ;
    }
    if (action == kBezelActionUndef)
        return ;

    dispatch_async(dispatch_get_main_queue(), ^{
        [self->_hudCtrl showHUDForAction:action sliderFilled:filled sliderMax:locked ? 0.0f : total textStringValue:nil];
    });
}

#endif

@end

//
//  NSAppSubclass.m
//  NewBezelServices
//
//  Created by Kelian on 07/07/2015.
//  Copyright © 2015 OSXHackers. All rights reserved.
//

#import "NSAppSubclass.h"
#import <IOKit/hidsystem/ev_keymap.h>
#import "HUDWindowController.h"

@implementation NSAppSubclass

- (void)mediaKeyEvent:(int)key state:(BOOL)state
{
    short keyTypeInt = 0;
    BOOL eslider = YES;
    NSString *textStringVal = @"...";
    switch (key) {
        case NX_KEYTYPE_SOUND_UP:
        case NX_KEYTYPE_SOUND_DOWN:
        case NX_KEYTYPE_MUTE:
            keyTypeInt = 1;
            break;
        case NX_KEYTYPE_BRIGHTNESS_UP:
        case NX_KEYTYPE_BRIGHTNESS_DOWN:
            keyTypeInt = 2;
            break;
        case NX_KEYTYPE_EJECT:
            keyTypeInt = 3;
            eslider = NO;
            textStringVal = @"Ejecting...";
            break;
    }
    if (keyTypeInt > 0) {
        /*usleep(200);
        [apd updateProgressWithType:types[keyTypeInt-1]];
        [apd updateImageWithType:types[keyTypeInt-1]];
        if (state) [apd showHUDwithType:types[keyTypeInt-1] enableSlider:eslider textStringValue:textStringVal];*/
        [_hudCtrl showWindow:nil];
    }
}

- (void)sendEvent:(NSEvent *)event
{
    // Catch media key events
    if ([event type] == NSEventTypeSystemDefined && [event subtype] == 8)
    {
        int keyCode = (([event data1] & 0xFFFF0000) >> 16);
        int keyFlags = ([event data1] & 0x0000FFFF);
        int keyState = (((keyFlags & 0xFF00) >> 8)) == 0xA;

        // Process the media key event and return
        if (event.modifierFlags == 0 || keyCode != NX_KEYTYPE_EJECT)
            [self mediaKeyEvent:keyCode state:keyState];
        return ;
    }

    // Continue on to super
    [super sendEvent:event];
}

@end

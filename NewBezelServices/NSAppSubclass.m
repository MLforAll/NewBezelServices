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
    bezel_action_t keyAction = kBezelActionUndef;
    BOOL eslider = YES;
    NSString *textStringVal = nil;

    switch (key)
    {
        case NX_KEYTYPE_SOUND_UP:
        case NX_KEYTYPE_SOUND_DOWN:
        case NX_KEYTYPE_MUTE:
            keyAction = kBezelActionVolume;
            break;
        case NX_KEYTYPE_BRIGHTNESS_UP:
        case NX_KEYTYPE_BRIGHTNESS_DOWN:
            keyAction = kBezelActionBrightness;
            break;
        case NX_KEYTYPE_EJECT:
            keyAction = kBezelActionEject;
            eslider = NO;
            textStringVal = @"Ejecting...";
            break;
        default:
            break ;
    }
    if (keyAction == kBezelActionUndef)
        return ;

    //usleep(100);
    [_hudCtrl showHUDForAction:keyAction enableSlider:eslider textStringValue:textStringVal];
}

- (void)sendEvent:(NSEvent *)event
{
    // Catch media key events
    if (event.type == NSEventTypeSystemDefined && event.subtype == NSEventSubtypeScreenChanged)
    {
        int keyCode = (([event data1] & 0xFFFF0000) >> 16);
        int keyFlags = ([event data1] & 0x0000FFFF);
        BOOL keyState = (((keyFlags & 0xFF00) >> 8)) == 0xA;

        // Process the media key event and return
        if (event.modifierFlags == 0 || keyCode != NX_KEYTYPE_EJECT)
            [self mediaKeyEvent:keyCode state:keyState];
        return ;
    }

    // Continue on to super
    [super sendEvent:event];
}

@end

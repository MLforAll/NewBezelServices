//
//  NSAppSubclass.m
//  NewBezelServices
//
//  Created by Kelian on 07/07/2015.
//  Copyright © 2015 MLforAll. All rights reserved.
//

#import "NSAppSubclass.h"

#import "VolumeControl.h"
#import "BrightnessControl.h"
#import "HUDWindowController.h"

#import <IOKit/hidsystem/ev_keymap.h>

@implementation NSAppSubclass

#ifdef DEBUG

- (void)mediaKeyEvent:(int)key state:(BOOL)state
{
    bezel_action_t keyAction = kBezelActionUndef;
    double filled = 0;

    switch (key)
    {
        case NX_KEYTYPE_SOUND_UP:
        case NX_KEYTYPE_SOUND_DOWN:
        case NX_KEYTYPE_MUTE:
        {
            BOOL muted = VolumeControl.muted;
            keyAction = muted ? kBezelActionMute : kBezelActionVolume;
            filled = muted ? 0 : VolumeControl.volumeLevel;
            break;
        }
        case NX_KEYTYPE_BRIGHTNESS_UP:
        case NX_KEYTYPE_BRIGHTNESS_DOWN:
            keyAction = kBezelActionBrightness;
            filled = BrightnessControl.brightnessLevel;
            break;
        case NX_KEYTYPE_EJECT:
            keyAction = kBezelActionEject;
            break;
        default:
            break ;
    }

    if (keyAction == kBezelActionUndef)
        return ;
    [_hudCtrl showHUDForAction:keyAction sliderFilled:filled sliderMax:1.0f textStringValue:nil];
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

#endif

@end

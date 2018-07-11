//
//  NSAppSubclass.m
//  NewBezelServices
//
//  Created by Kelian on 07/07/2015.
//  Copyright © 2015 OSXHackers. All rights reserved.
//

#import "AppDelegate.h"
#import "NSAppSubclass.h"
#import <IOKit/hidsystem/ev_keymap.h>
#import <DiskArbitration/DiskArbitration.h>
#import "BrightnessControl.h"

@implementation NSAppSubclass

- (void)sendEvent:(NSEvent *)event {
    // Catch media key events
    if ([event type] == NSSystemDefined && [event subtype] == 8) {
        
        int keyCode = (([event data1] & 0xFFFF0000) >> 16);
        int keyFlags = ([event data1] & 0x0000FFFF);
        int keyState = (((keyFlags & 0xFF00) >> 8)) == 0xA;
        
        // Is there a modifier key pressed (or a combination of those) ?
        int mflags = [event modifierFlags];
        BOOL modPressed = [self doesModPressedWithMFlags:mflags];
        
        // Process the media key event and return
        if (!modPressed || keyCode != NX_KEYTYPE_EJECT) [self mediaKeyEvent:keyCode state:keyState];
        return;
    }
    // Continue on to super
    [super sendEvent:event];
}

- (BOOL)doesModPressedWithMFlags:(int)mflags {
    
    int mainModsFlags[5] = {0, 262145, 524576, 1048584, 131330};
    short mainModsFlagsCount = sizeof(mainModsFlags)/sizeof(int);
    short numberOfOperations = (mainModsFlagsCount-2)*(mainModsFlagsCount-1);
    int additionalModsFlags[numberOfOperations];
    for (short i = 1; i < numberOfOperations+1; i++) {
        short mID = 0;
        short sID = 1;
        if (i < 5) mID = 1; else if (i < 8) mID = 2; else if (i < 11) mID = 3; else if (i < 14) mID = 4;
        if (i < 5) sID = 1; else if (i < 8) sID = 5; else if (i < 11) sID = 8; else if (i < 14) sID = 11;
        if (mID != i-sID+1) additionalModsFlags[i-1] = mainModsFlags[mID]+mainModsFlags[i-sID+1];
    }
    for (short i = 0; i < mainModsFlagsCount+numberOfOperations+1; i++) {
        int modFlagToTest = mainModsFlags[i];
        if (i > 4) modFlagToTest = additionalModsFlags[i-mainModsFlagsCount-1];
        if (mflags == modFlagToTest) return YES;
    }
    
    return NO;
}

/*- (BOOL)canShowEjectHUD {
    DADiskRef opticalDrive = DADiskCreateFromBSDName
    return YES;
}*/

- (void)mediaKeyEvent:(int)key state:(BOOL)state {
    AppDelegate *apd = (AppDelegate *)[self delegate];
    BrightnessControl *brightc = [[BrightnessControl alloc] init];
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
    if (keyTypeInt == 0 && round(2.0f * ([brightc getBrightnessLevel]*100) / 2.0f) != currBrightLevel) {
        NSLog(@"brightness change detected when pressing a non-brightness control bt!");
        NSLog(@"getBrightness = %f", [self getBrightnessLevel]);
        NSLog(@"currBrightLevel = %f", currBrightLevel);
        keyTypeInt = 2;
    }
    if (keyTypeInt > 0) {
        usleep(200);
        [apd updateProgressWithType:types[keyTypeInt-1]];
        [apd updateImageWithType:types[keyTypeInt-1]];
        if (state) [apd showHUDwithType:types[keyTypeInt-1] enableSlider:eslider textStringValue:textStringVal];
    }
}

- (float)getBrightnessLevel {
    BrightnessControl *brightc = [[BrightnessControl alloc] init];
    float brightLevel = [brightc getBrightnessLevel];
    return brightLevel;
}

@end

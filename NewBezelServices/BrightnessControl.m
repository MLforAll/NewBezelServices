//
//  BrightnessControl.m
//  NewBezelServices
//
//  Created by Kelian on 04/11/2016.
//  Copyright © 2016 OSXHackers. All rights reserved.
//

// Almost completely from: http://mattdanger.net/2008/12/adjust-mac-os-x-display-brightness-from-the-terminal

#import "BrightnessControl.h"

@implementation BrightnessControl

const int kMaxDisplays = 16;
const CFStringRef kDisplayBrightness = CFSTR(kIODisplayBrightnessKey);

- (float)getBrightnessLevel {
    CGDirectDisplayID display[kMaxDisplays];
    CGDisplayCount numDisplays;
    CGDisplayErr err;
    err = CGGetActiveDisplayList(kMaxDisplays, display, &numDisplays);
    
    if (err != CGDisplayNoErr)
        NSLog(@"Cannot get list of displays (error %d)\n",err);
    
    for (CGDisplayCount i = 0; i < numDisplays; ++i) {
        
        CGDirectDisplayID dspy = display[i];
        CFDictionaryRef originalMode = CGDisplayCurrentMode(dspy);
        if (originalMode == NULL)
            continue;
        io_service_t service = CGDisplayIOServicePort(dspy);
        
        float brightness;
        err = IODisplayGetFloatParameter(service, kNilOptions, kDisplayBrightness,
                                        &brightness);
        if (err != kIOReturnSuccess) {
            NSLog(@"Failed to get brightness of display 0x%x (error %d)",
                  (unsigned int)dspy, err);
            continue;
        }
        return brightness;
    }
    NSLog(@"[ERR] Couldn't get brightness for any display!");
    return -1.0; //couldn't get brightness for any display
}

- (void)setBrightnessLevel:(float)level {
    CGDirectDisplayID display[kMaxDisplays];
    CGDisplayCount numDisplays;
    CGDisplayErr err;
    err = CGGetActiveDisplayList(kMaxDisplays, display, &numDisplays);
    
    if (err != CGDisplayNoErr)
        NSLog(@"Cannot get list of displays (error %d)\n",err);
    
    for (CGDisplayCount i = 0; i < numDisplays; ++i) {
        
        CGDirectDisplayID dspy = display[i];
        CFDictionaryRef originalMode = CGDisplayCurrentMode(dspy);
        if (originalMode == NULL)
            continue;
        io_service_t service = CGDisplayIOServicePort(dspy);
        
        float brightness;
        err= IODisplayGetFloatParameter(service, kNilOptions, kDisplayBrightness,
                                        &brightness);
        if (err != kIOReturnSuccess) {
            NSLog(@"Failed to get brightness of display 0x%x (error %d)",
                  (unsigned int)dspy, err);
            continue;
        }
        
        err = IODisplaySetFloatParameter(service, kNilOptions, kDisplayBrightness,
                                         level);
        if (err != kIOReturnSuccess) {
            NSLog(@"Failed to set brightness of display 0x%x (error %d)",
                  (unsigned int)dspy, err);
            continue;
        }
    }
}

@end

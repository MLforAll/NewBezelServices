//
//  VolumeControl.m
//  NewBezelServices
//
//  Created by Kelian on 04/11/2016.
//  Copyright © 2016 OSXHackers. All rights reserved.
//

#import "VolumeControl.h"
#import "AppDelegate.h"
#import <AppKit/NSEvent.h>
#import <AudioToolbox/AudioServices.h>

@implementation VolumeControl

+ (AudioDeviceID)defaultOutputDeviceID {
    
    AudioDeviceID outputDeviceID = kAudioObjectUnknown;
    
    // get output device device
    UInt32 propertySize = 0;
    OSStatus status = noErr;
    AudioObjectPropertyAddress propertyAOPA;
    propertyAOPA.mScope = kAudioObjectPropertyScopeGlobal;
    propertyAOPA.mElement = kAudioObjectPropertyElementMaster;
    propertyAOPA.mSelector = kAudioHardwarePropertyDefaultOutputDevice;
    
    if (!AudioHardwareServiceHasProperty(kAudioObjectSystemObject, &propertyAOPA)) {
        NSLog(@"Cannot find default output device!");
        return outputDeviceID;
    }
    
    propertySize = sizeof(AudioDeviceID);
    
    status = AudioHardwareServiceGetPropertyData(kAudioObjectSystemObject, &propertyAOPA, 0, NULL, &propertySize, &outputDeviceID);
    
    if (status)
        NSLog(@"Cannot find default output device!");
    
    return outputDeviceID;
}
+ (float)getVolumeLevel {
    
    Float32 outputVolume;
    
    UInt32 propertySize = 0;
    OSStatus status = noErr;
    AudioObjectPropertyAddress propertyAOPA;
    propertyAOPA.mElement = kAudioObjectPropertyElementMaster;
    propertyAOPA.mSelector = kAudioHardwareServiceDeviceProperty_VirtualMasterVolume;
    propertyAOPA.mScope = kAudioDevicePropertyScopeOutput;
    
    AudioDeviceID outputDeviceID = [self defaultOutputDeviceID];
    
    if (outputDeviceID == kAudioObjectUnknown) {
        NSLog(@"Unknown device");
        return 0.0;
    }
    
    if (!AudioHardwareServiceHasProperty(outputDeviceID, &propertyAOPA)) {
        NSLog(@"No volume returned for device 0x%0x", outputDeviceID);
        return 0.0;
    }
    
    propertySize = sizeof(Float32);
    
    status = AudioHardwareServiceGetPropertyData(outputDeviceID, &propertyAOPA, 0, NULL, &propertySize, &outputVolume);
    
    if (status) {
        NSLog(@"No volume returned for device 0x%0x", outputDeviceID);
        return 0.0;
    }
    
    if (outputVolume < 0.0 || outputVolume > 1.0) return 0.0;
    
    return outputVolume;
}
+ (bool)isAudioMuted {
    UInt32 mute;
    UInt32 propertySize = 0;
    OSStatus status = noErr;
    AudioObjectPropertyAddress propertyAOPA;
    propertyAOPA.mElement = kAudioObjectPropertyElementMaster;
    propertyAOPA.mSelector = kAudioDevicePropertyMute;
    propertyAOPA.mScope = kAudioDevicePropertyScopeOutput;
    AudioDeviceID outputDeviceID = [self defaultOutputDeviceID];
    if (outputDeviceID == kAudioObjectUnknown)
    {
        NSLog(@"Unknown device");
        return 0.0;
    }
    if (!AudioHardwareServiceHasProperty(outputDeviceID, &propertyAOPA))
    {
        NSLog(@"No volume returned for device 0x%0x", outputDeviceID);
        return 0.0;
    }
    propertySize = sizeof(UInt32);
    status = AudioHardwareServiceGetPropertyData(outputDeviceID, &propertyAOPA, 0, NULL, &propertySize, &mute);
    if (status)
    {
        NSLog(@"No volume returned for device 0x%0x", outputDeviceID);
        return 0.0;
    }
    return mute;
}
+ (void)setMuted:(BOOL)state { // Couldn't find a way to do it in ObjC. Ended up embeding AppleScript. Works like a charm!
    NSString *stateCodeStr;
    if (state) stateCodeStr = @"with"; else stateCodeStr = @"without";
    NSAppleScript *asCode = [[NSAppleScript alloc] initWithSource:[NSString stringWithFormat:@"set volume %@ output muted", stateCodeStr]];
    [asCode executeAndReturnError:nil];
}
+ (void)setVolumeLevel:(Float32)level {
    if ([self isAudioMuted] && level > 0) [self setMuted:NO]; else if (![self isAudioMuted] && level == 0) [self setMuted:YES];
    AudioObjectPropertyAddress propertyAddress = {
        kAudioHardwareServiceDeviceProperty_VirtualMasterVolume,
        kAudioDevicePropertyScopeOutput,
        kAudioObjectPropertyElementMaster,
    };
    AudioHardwareServiceSetPropertyData([self.class defaultOutputDeviceID],
                                        &propertyAddress,
                                        0,
                                        NULL,
                                        sizeof(Float32),
                                        &level);
    
    [(AppDelegate *)[[NSApplication sharedApplication] delegate] launchHUDcloseTimerWithTime:2.5];
}

@end

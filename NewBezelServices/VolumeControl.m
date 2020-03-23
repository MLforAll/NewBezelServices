//
//  VolumeControl.m
//  NewBezelServices
//
//  Created by Kelian on 04/11/2016.
//  Copyright © 2016 MLforAll. All rights reserved.
//

#import "VolumeControl.h"
#import <AppKit/NSEvent.h>
#import <AudioToolbox/AudioServices.h>

@implementation VolumeControl

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

+ (AudioDeviceID)defaultOutputDeviceID
{
    AudioDeviceID outputDeviceID = kAudioObjectUnknown;

    // get output device device
    UInt32 propertySize = 0;
    OSStatus status = noErr;
    AudioObjectPropertyAddress propertyAOPA;
    propertyAOPA.mScope = kAudioObjectPropertyScopeGlobal;
    propertyAOPA.mElement = kAudioObjectPropertyElementMaster;
    propertyAOPA.mSelector = kAudioHardwarePropertyDefaultOutputDevice;

    if (!AudioHardwareServiceHasProperty(kAudioObjectSystemObject, &propertyAOPA)) // deprecated
    {
        NSLog(@"[ERR] Cannot find default output device!");
        return outputDeviceID;
    }

    propertySize = sizeof(AudioDeviceID);

    status = AudioHardwareServiceGetPropertyData(kAudioObjectSystemObject, &propertyAOPA, 0, NULL, &propertySize, &outputDeviceID); // deprecated
    if (status)
    {
        NSLog(@"[ERR] Cannot find default output device!");
        return outputDeviceID;
    }

    return outputDeviceID;
}

+ (Float32)getVolumeLevel
{
    Float32 outputVolume;

    UInt32 propertySize = 0;
    OSStatus status = noErr;
    AudioObjectPropertyAddress propertyAOPA;
    propertyAOPA.mElement = kAudioObjectPropertyElementMaster;
    propertyAOPA.mSelector = kAudioHardwareServiceDeviceProperty_VirtualMasterVolume;
    propertyAOPA.mScope = kAudioDevicePropertyScopeOutput;

    AudioDeviceID outputDeviceID = [self defaultOutputDeviceID];

    if (outputDeviceID == kAudioObjectUnknown)
    {
        NSLog(@"[ERR] Unknown device");
        return 0.0f;
    }

    if (!AudioHardwareServiceHasProperty(outputDeviceID, &propertyAOPA)) // deprecated
    {
        NSLog(@"[ERR] No volume returned for device %#0x", outputDeviceID);
        return 0.0f;
    }

    propertySize = sizeof(Float32);

    status = AudioHardwareServiceGetPropertyData(outputDeviceID, &propertyAOPA, 0, NULL, &propertySize, &outputVolume); // deprecated
    if (status)
    {
        NSLog(@"[ERR] No volume returned for device %#0x", outputDeviceID);
        return 0.0;
    }

    return (outputVolume < 0.0f || outputVolume > 1.0f) ? 0.0f : outputVolume;
}

+ (BOOL)isAudioMuted
{
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
        return NO;
    }
    if (!AudioHardwareServiceHasProperty(outputDeviceID, &propertyAOPA)) // deprecated
    {
        NSLog(@"No volume returned for device 0x%0x", outputDeviceID);
        return NO;
    }
    propertySize = sizeof(UInt32);
    status = AudioHardwareServiceGetPropertyData(outputDeviceID, &propertyAOPA, 0, NULL, &propertySize, &mute); // deprecated
    if (status)
    {
        NSLog(@"No volume returned for device 0x%0x", outputDeviceID);
        return NO;
    }
    return mute;
}

// Couldn't find a way to do it in Obj-C. Ended up embeding AppleScript. Works like a charm!
+ (void)setMuted:(BOOL)muted
{
    NSString *stateCodeStr = (muted) ? @"with" : @"without";
    NSAppleScript *asCode = [[NSAppleScript alloc] initWithSource:[NSString stringWithFormat:@"set volume %@ output muted", stateCodeStr]];
    [asCode executeAndReturnError:nil];
}

+ (void)setVolumeLevel:(Float32)level
{
    // TODO: Redesign
    BOOL muted = [self isAudioMuted];
    if (muted && level > 0)
        [self setMuted:NO];
    else if (!muted && level == 0)
        [self setMuted:YES];

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
                                        &level); // deprecated
}

#pragma GCC diagnostic pop

@end

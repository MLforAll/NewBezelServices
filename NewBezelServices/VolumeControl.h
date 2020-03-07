//
//  VolumeControl.h
//  NewBezelServices
//
//  Created by Kelian on 04/11/2016.
//  Copyright © 2016 MLforAll. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kVolumeControlMinValue  0.0f
#define kVolumeControlMaxValue  1.0f

@interface VolumeControl : NSObject

@property (readwrite, class, getter=getVolumeLevel) Float32 volumeLevel;
@property (readwrite, class, getter=isAudioMuted) BOOL muted;

@end

//
//  VolumeControl.h
//  NewBezelServices
//
//  Created by Kelian on 04/11/2016.
//  Copyright © 2016 OSXHackers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VolumeControl : NSObject

@property (readonly, class, getter=getVolumeLevel) float volumeLevel;
@property (readonly, class, getter=isAudioMuted) BOOL muted;

+ (void)setMuted:(BOOL)state;
+ (void)setVolumeLevel:(Float32)level;

@end

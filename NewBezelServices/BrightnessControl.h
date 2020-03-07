//
//  BrightnessControl.h
//  NewBezelServices
//
//  Created by Kelian on 04/11/2016.
//  Copyright © 2016 MLforAll. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kBrightnessControlMinValue  0.0f
#define kBrightnessControlMaxValue  1.0f

@interface BrightnessControl : NSObject

@property (readonly, class, getter=getBrightnessLevel) float brightnessLevel;

+ (void)setBrightnessLevel:(float)level;

@end

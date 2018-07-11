//
//  BrightnessControl.h
//  NewBezelServices
//
//  Created by Kelian on 04/11/2016.
//  Copyright © 2016 OSXHackers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BrightnessControl : NSObject

- (float)getBrightnessLevel;
- (void)setBrightnessLevel:(float)level;

@end

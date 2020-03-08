//
//  HUDWindowController.h
//  NewBezelServices
//
//  Created by Kelian on 29/11/2019.
//  Copyright © 2019 MLforAll. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum : int8_t
{
    kBezelActionUndef = -1,
    kBezelActionVolume,
    kBezelActionMute,
    kBezelActionBrightness,
    kBezelActionKeyBrightness,
    kBezelActionKeyBrightnessOff,
    kBezelActionEject,
    kBezelActionMax
} bezel_action_t;

@interface HUDWindowController : NSWindowController
{
    NSString *_imagesPath;
    NSString *_currImgName;
    NSDictionary *_bezelImages;
    NSSound *_volumeSound;

    NSVisualEffectView *_visualEffectView;
    NSTimer *_closeWindowTimer;
    BOOL _previousThemeState;
}

@property (readwrite, nullable, nonatomic) NSString *volumeSoundPath;

- (void)showHUDForAction:(bezel_action_t)action sliderFilled:(double)filled sliderMax:(double)max textStringValue:(NSString * __nullable)tsval;

@end

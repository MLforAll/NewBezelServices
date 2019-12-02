//
//  HUDWindowController.h
//  NewBezelServices
//
//  Created by Kelian on 29/11/2019.
//  Copyright © 2019 OSXHackers. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : uint8_t
{
    kBezelActionUndef,
    kBezelActionVolume,
    kBezelActionBrightness,
    kBezelActionEject
} bezel_action_t;

@interface HUDWindowController : NSWindowController
{
    NSString *imagesPath;
    NSSound *volumeSound;
    NSTimer *closeWindowTimer;
    NSString *currImgName;
    NSDictionary *bezelImages;
    BOOL previousThemeState;
}

@property (weak) NSVisualEffectView *visualEffectView;
@property (weak) IBOutlet NSTabView *tabView;
@property (weak) IBOutlet NSSlider *slider;
@property (weak) IBOutlet NSTextField *text;
@property (weak) IBOutlet NSImageView *image;

@property (readwrite, nullable, nonatomic) NSString *volumeSoundPath;

- (void)showHUDForAction:(bezel_action_t)action enableSlider:(BOOL)eslider textStringValue:(NSString * __nullable)tsval;

@end

NS_ASSUME_NONNULL_END

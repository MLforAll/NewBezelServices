//
//  AppDelegate.h
//  NewBezelServices
//
//  Created by Kelian on 05/07/2015.
//  Copyright © 2015 OSXHackers. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HUDWindowController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    HUDWindowController *hudCtrl;
}

@property (assign) IBOutlet NSPanel *window;
@property (unsafe_unretained) IBOutlet NSTabView *tabView;
@property (assign) IBOutlet NSSlider *slider;
@property (unsafe_unretained) IBOutlet NSTextField *text;
@property (assign) IBOutlet NSImageView *image;

- (void)showHUDwithType:(NSString *)type enableSlider:(BOOL)eslider textStringValue:(NSString *)tsval;
- (void)launchHUDcloseTimerWithTime:(float)time;
- (void)updateProgressWithType:(NSString *)type;
- (void)updateImageWithType:(NSString *)type;

extern NSString *types[3];
extern NSTimer *closeWindowTimer;
extern NSString *volumeSoundPath;
extern NSString *imagesPath;

extern NSTimer *closeWindowTimer;

@end

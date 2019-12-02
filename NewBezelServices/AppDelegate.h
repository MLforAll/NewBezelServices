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

@end

//
//  HUDWindowController.h
//  NewBezelServices
//
//  Created by Kelian on 29/11/2019.
//  Copyright © 2019 OSXHackers. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface HUDWindowController : NSWindowController
{
    NSSound *volumeSound;
}

@property (weak) IBOutlet NSTabView *tabView;
@property (weak) IBOutlet NSSlider *slider;
@property (weak) IBOutlet NSTextField *text;
@property (weak) IBOutlet NSImageView *image;

@property (readwrite, nullable, nonatomic) NSString *volumeSoundPath;

@end

NS_ASSUME_NONNULL_END

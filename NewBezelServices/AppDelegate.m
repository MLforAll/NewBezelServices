//
//  AppDelegate.m
//  NewBezelServices
//
//  Created by Kelian on 05/07/2015.
//  Copyright © 2015 OSXHackers. All rights reserved.
//

#import "AppDelegate.h"
#import "NSAppSubclass.h"
#import "VolumeControl.h"
#import "BrightnessControl.h"
#import <CoreImage/CoreImage.h>
#import "NSStatusBarWindow.h"

@implementation AppDelegate

float heightDiffWindow = 45;

NSString *types[3];
NSTimer *closeWindowTimer;

NSString *volumeSoundPath = @"/System/Library/LoginPlugins/BezelServices.loginPlugin/Contents/Resources/volume.aiff";
NSString *imagesPath;

NSDictionary *bezelImages = nil;
BOOL previousThemeState;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    types[0] = @"volume";
    types[1] = @"brightness";
    types[2] = @"eject";
    
    NSString *elcap_earlier_imagespath = @"/System/Library/LoginPlugins/BezelServices.loginPlugin/Contents/Resources/BezelUI/HiDPI";
    NSString *sierra_later_imagespath = @"/System/Library/CoreServices/OSDUIHelper.app/Contents/Resources";
    if ([[NSFileManager defaultManager] fileExistsAtPath:elcap_earlier_imagespath])
        imagesPath = elcap_earlier_imagespath;
    else
        imagesPath = sierra_later_imagespath;
        
    hudCtrl = [[HUDWindowController alloc] initWithWindowNibName:@"HUDWindow"];
    [hudCtrl loadWindow];
    [(NSAppSubclass *)NSApp setHudCtrl:hudCtrl];
}

- (BOOL)isDarkModeEnabled {
    NSDictionary *udsDict = [[NSUserDefaults standardUserDefaults] persistentDomainForName:NSGlobalDomain];
    id style = [udsDict valueForKey:@"AppleInterfaceStyle"];
    return (style && [[style lowercaseString] isEqualToString:@"dark"]);
}

- (void)adaptUI {
    BOOL themeState = [self isDarkModeEnabled];
    if (bezelImages == nil || themeState != previousThemeState) {
        previousThemeState = themeState;
        NSAppearanceName vappn;
        if (themeState)
            vappn = NSAppearanceNameVibrantDark;
        else
            vappn = NSAppearanceNameVibrantLight;
        for (NSView *view in [[_window contentView] subviews]) {
            if ([[view className] isEqualToString:@"NSVisualEffectView"]) {
                [view setAppearance:[NSAppearance appearanceNamed:vappn]];
            }
        }
        NSMutableArray *dictNSImages = [NSMutableArray new];
        NSArray *imagePathContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:imagesPath error:nil];
        NSMutableArray *hudImages = [NSMutableArray new];
        for (short i = 0; i < imagePathContents.count; i++) {
            if ([imagePathContents[i] hasSuffix:@".pdf"])
                [hudImages addObject:imagePathContents[i]];
        }
        for (short i = 0; i < hudImages.count; i++) {
            NSImage *hudImg = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", imagesPath, hudImages[i]]];
            if (themeState) {
                [_text setTextColor:[NSColor whiteColor]];
                [dictNSImages addObject:[self invertNSImage:hudImg]];
            } else {
                [_text setTextColor:[NSColor blackColor]];
                [dictNSImages addObject:hudImg];
            }
        }
        bezelImages = [NSDictionary dictionaryWithObjects:dictNSImages forKeys:hudImages];
        [_image setImage:[bezelImages valueForKey:currImgName]];
    }
}

- (NSImage *)invertNSImage:(NSImage *)inputImage {
    CIImage *ciImage = [[CIImage alloc] initWithData:[inputImage TIFFRepresentation]];
    CIFilter *ciFilter = [CIFilter filterWithName:@"CIColorInvert"];
    [ciFilter setDefaults];
    [ciFilter setValue:ciImage forKey:@"inputImage"];
    CIImage *outputImage = [ciFilter valueForKey:@"outputImage"];
    NSImage *output = [[NSImage alloc] initWithSize:[outputImage extent].size];
    NSCIImageRep *rep = [NSCIImageRep imageRepWithCIImage:outputImage];
    [output addRepresentation:rep];
    return output;
}

- (void)setHUDpos {
    NSScreen *mouseScreen;
    NSPoint mouseLoc = [NSEvent mouseLocation];
    for (NSScreen *screen in [NSScreen screens])
        if (NSMouseInRect(mouseLoc, [screen frame], NO)) mouseScreen = screen;
    NSRect mouseScreenRect = [mouseScreen frame];
    NSRect mouseScreenVisibleRect = [mouseScreen visibleFrame];
    
    /*float menuBarHeight = [[NSStatusBar systemStatusBar] thickness];
     float dockHeight = mouseScreenRect.size.height+menuBarHeight-mouseScreenVisibleRect.size.height-49;
     NSLog(@"%f", dockHeight);
     if (mouseScreenVisibleRect.size.height+dockHeight+menuBarHeight+5 < mouseScreenRect.size.height) {
     dockHeight += menuBarHeight;
     heightDiffWindow -= menuBarHeight;
     }*/
    
    [_window setFrameOrigin:NSMakePoint(mouseScreenVisibleRect.origin.x+30, mouseScreen.frame.origin.y+mouseScreenRect.size.height-_window.frame.size.height-heightDiffWindow)];
}

- (void)showHUDwithType:(NSString *)type enableSlider:(BOOL)eslider textStringValue:(NSString *)tsval {
    
    if ([closeWindowTimer isValid]) [closeWindowTimer invalidate];
    
    if (eslider) {
        [_tabView selectFirstTabViewItem:nil];
    } else {
        [_text setStringValue:tsval];
        [_tabView selectLastTabViewItem:nil];
    }
    [_slider setTag:[self getTypeIntForType:type]];
    
    [self setHUDpos];
    if (![_window isVisible]) [_window makeKeyAndOrderFront:nil];
    
    [self launchHUDcloseTimerWithTime:2];
}

- (void)closeHUD {
    [_window close];
}
- (void)launchHUDcloseTimerWithTime:(float)time {
    //closeWindowTimer = [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(closeHUD) userInfo:nil repeats:NO];
    closeWindowTimer = [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(closeHUD) userInfo:nil repeats:NO];
}

- (int)getTypeIntForType:(NSString *)type {
    for (int i = 0; i < (sizeof(types)/sizeof(NSString *))+1; i++) {
        if ([types[i] isEqualToString:type]) return i+1;
    }
    NSLog(@"[ERR] Could not set int value for the specific type str!");
    return 0;
}
NSString *currImgName;
- (void)updateImageWithType:(NSString *)type {
    short typeInt = [self getTypeIntForType:type];
    NSString *imageName;
    switch (typeInt) {
        case 1:
            if (![VolumeControl isAudioMuted]) imageName = @"Volume.pdf"; else imageName = @"Mute.pdf";
            break;
        case 2:
            imageName = @"Brightness.pdf";
            break;
        case 3:
            imageName = @"Eject.pdf";
    }
    if (currImgName != imageName)
        [_image setImage:[bezelImages valueForKey:imageName]];
    currImgName = imageName;
}
- (void)updateProgressWithType:(NSString *)type {
    int typeInt = [self getTypeIntForType:type];
    switch (typeInt) {
        case 1:
            [self updateProgressVolume];
            break;
        case 2:
            [self updateProgressBrightness];
            break;
    }
}
- (void)updateProgressVolume {
    bool muteState = [VolumeControl isAudioMuted];
    float level;
    if (muteState) level = 0; else level = [VolumeControl getVolumeLevel]*100;
    [_slider setDoubleValue:level];
}
- (void)updateProgressBrightness {
    float currLevel = [BrightnessControl getBrightnessLevel]*100;
    [_slider setDoubleValue:currLevel];
}

- (IBAction)sliderAction:(id)sender {
    if ([closeWindowTimer isValid]) [closeWindowTimer invalidate];
    short typeInt = [sender tag];
    NSString *typeStr = types[typeInt-1];
    NSString *selectorName = [NSString stringWithFormat:@"setProgress%@WithSliderDoubleValue:", [typeStr capitalizedString]];
    double sliderdv = [sender doubleValue];
    //[self performSelector:NSSelectorFromString(selectorName) withObject:[NSNumber numberWithDouble:sliderdv]];
    [self arcPerformSelectorFromString:selectorName onTarget:self withObject:[NSNumber numberWithDouble:sliderdv]];
}

- (void)arcPerformSelectorFromString:(NSString *)selName onTarget:(id)target {
    SEL selector = NSSelectorFromString(selName);
    IMP imp = [target methodForSelector:selector];
    void (*func)(id, SEL) = (void*)imp;
    func(target, selector);
}
- (void)arcPerformSelectorFromString:(NSString *)selName onTarget:(id)target withObject:(id)obj {
    SEL selector = NSSelectorFromString(selName);
    IMP imp = [target methodForSelector:selector];
    void (*func)(id, SEL, id) = (void*)imp;
    func(target, selector, obj);
}

- (void)setProgressVolumeWithSliderDoubleValue:(NSNumber *)sdvobj {
    double sdv = [sdvobj doubleValue];
    NSEvent *event = [[NSApplication sharedApplication] currentEvent];
    if (event.type == NSLeftMouseUp) [[[NSSound alloc] initWithContentsOfFile:volumeSoundPath byReference:YES] play];
    
    bool refMuteState = [VolumeControl isAudioMuted];
    
    Float32 currSliderVolumeEquivalent = sdv/100;
    [VolumeControl setVolumeLevel:currSliderVolumeEquivalent];
    if (refMuteState != [VolumeControl isAudioMuted]) [self updateImageWithType:@"volume"];
    
}
- (void)setProgressBrightnessWithSliderDoubleValue:(NSNumber *)sdvobj {
    double sdv = [sdvobj doubleValue];
    [BrightnessControl setBrightnessLevel:sdv/100];
}

@end

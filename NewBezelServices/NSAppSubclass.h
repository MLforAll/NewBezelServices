//
//  NSAppSubclass.h
//  NewBezelServices
//
//  Created by Kelian on 07/07/2015.
//  Copyright © 2015 OSXHackers. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class HUDWindowController;

@interface NSAppSubclass : NSApplication

@property (readwrite) HUDWindowController *hudCtrl;

@end

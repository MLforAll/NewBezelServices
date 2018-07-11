//
//  WindowDelegate.m
//  NewBezelServices
//
//  Created by Kelian on 25/02/2017.
//  Copyright © 2017 OSXHackers. All rights reserved.
//

#import "WindowDelegate.h"

@implementation WindowDelegate

- (void)windowDidResignKey:(NSNotification *)notification {
    [[(AppDelegate *)[AppDelegate alloc] init].window makeKeyAndOrderFront:nil];
}

@end

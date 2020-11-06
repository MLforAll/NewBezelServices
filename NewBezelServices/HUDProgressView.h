//
//  HUDProgressView.h
//  NewBezelServices
//
//  Created by Kelian on 03/11/2020.
//  Copyright © 2020 MLforAll. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface HUDProgressView : NSView
{
    NSView *_foreground, *_background;
    double _delta;

    id _target;
    SEL _action;
}

@property (readwrite) NSInteger tag;
@property (readwrite, nonatomic) BOOL enabled;

@property (readwrite) double minValue;
@property (readwrite) double maxValue;
@property (readwrite, nonatomic) double doubleValue;

- (void)setTarget:(id)target action:(SEL)action;

@end

NS_ASSUME_NONNULL_END

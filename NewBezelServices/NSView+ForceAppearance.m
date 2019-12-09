//
//  NSView+ForceAppearance.m
//  NewBezelServices
//
//  Created by Kelian on 09/12/2019.
//  Copyright © 2019 OSXHackers. All rights reserved.
//

#import "NSView+ForceAppearance.h"

@implementation NSView (ForceAppearance)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

- (void)viewDidChangeEffectiveAppearance
{
    [self setAppearance:self.effectiveAppearance];
}

#pragma clang diagnostic pop

@end

//
//  NSImage+ColorInvert.h
//  NewBezelServices
//
//  Created by Kelian on 02/12/2019.
//  Copyright © 2019 MLforAll. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSImage (ColorInvert)

- (NSImage *)imageByInvertingColors;

@end

NS_ASSUME_NONNULL_END

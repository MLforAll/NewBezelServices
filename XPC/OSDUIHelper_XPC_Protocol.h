@protocol OSDUIHelperProtocol

- (void)showImage:(long long)img onDisplayID:(CGDirectDisplayID)id priority:(unsigned int)prio msecUntilFade:(unsigned int)msec;

- (void)showImage:(long long)img onDisplayID:(CGDirectDisplayID)id priority:(unsigned int)prio msecUntilFade:(unsigned int)msec withText:(NSString *)text;

- (void)showImage:(long long)img onDisplayID:(CGDirectDisplayID)id priority:(unsigned int)prio msecUntilFade:(unsigned int)msec filledChiclets:(uint8_t)filled totalChiclets:(uint8_t)total locked:(uint8_t)locked;

- (void)showImageAtPath:(NSString *)path onDisplayID:(CGDirectDisplayID)id priority:(unsigned int)prio msecUntilFade:(unsigned int)msec withText:(NSString *)text;

- (void)fadeClassicImageOnDisplay:(CGDirectDisplayID)id;

- (void)showFullScreenImage:(long long)img onDisplayID:(CGDirectDisplayID)id priority:(unsigned int)prio msecToAnimate:(unsigned int)msec;

@end

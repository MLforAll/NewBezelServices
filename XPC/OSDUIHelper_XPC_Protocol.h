@protocol OSDUIHelperProtocol

- (void)showImage:(long long)img onDisplayID:(CGDirectDisplayID)did priority:(unsigned int)prio msecUntilFade:(unsigned int)msec;
- (void)showImage:(long long)img onDisplayID:(CGDirectDisplayID)did priority:(unsigned int)prio msecUntilFade:(unsigned int)msec withText:(NSString *)text;
- (void)showImage:(long long)img onDisplayID:(CGDirectDisplayID)did priority:(unsigned int)prio msecUntilFade:(unsigned int)msec filledChiclets:(unsigned int)filled totalChiclets:(unsigned int)total locked:(int8_t)locked;
- (void)showImageAtPath:(NSString *)path onDisplayID:(CGDirectDisplayID)did priority:(unsigned int)prio msecUntilFade:(unsigned int)msec withText:(NSString *)text;
- (void)fadeClassicImageOnDisplay:(CGDirectDisplayID)did;
- (void)showFullScreenImage:(long long)img onDisplayID:(CGDirectDisplayID)did priority:(unsigned int)prio msecToAnimate:(unsigned int)msec;

@end

#import <Foundation/Foundation.h>
#import "../../NewBezelServices/OSDUIHelper.h"

@interface Daemon : NSObject <NSXPCListenerDelegate, OSDUIHelperProtocol>
{
	NSXPCListener *_listener;
}

@end

@implementation Daemon

- (instancetype)init
{
	self = [super init];
	if (self)
	{
		_listener = [[NSXPCListener alloc] initWithMachServiceName:@"com.apple.OSDUIHelper"];
		[_listener setDelegate:self];
		[_listener resume];
		NSLog(@"hello");
	}
	return self;
}

- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)newConnection
{
	// Configure the incoming connection
	[newConnection setExportedInterface:[NSXPCInterface interfaceWithProtocol:@protocol(OSDUIHelperProtocol)]];
	[newConnection setExportedObject:self];
	[newConnection setInvalidationHandler:^{
		NSLog(@"newConnection was invalidated");
	}];

	NSLog(@"%@", newConnection);

	// New connections always start in a suspended state
	[newConnection resume];

	return YES;
}

- (void)showImage:(long long)img onDisplayID:(CGDirectDisplayID)did priority:(unsigned int)prio msecUntilFade:(unsigned int)msec
{
	NSLog(@"showImage1");
}

- (void)showImage:(long long)img onDisplayID:(CGDirectDisplayID)did priority:(unsigned int)prio msecUntilFade:(unsigned int)msec withText:(NSString *)text
{
	NSLog(@"showImage2");
}

- (void)showImage:(long long)img onDisplayID:(CGDirectDisplayID)did priority:(unsigned int)prio msecUntilFade:(unsigned int)msec filledChiclets:(unsigned int)filled totalChiclets:(unsigned int)total locked:(int8_t)locked
{
	NSLog(@"isMainThread: %hhu", (uint8_t)NSThread.isMainThread);
	NSLog(@"showImage:%lli onDisplayID:%u priority:%u msecUntilFade:%u filledChiclets:%u totalChiclets:%u locked:%hhi", img, did, prio, msec, filled, total, locked);
}

- (void)showImageAtPath:(NSString *)path onDisplayID:(CGDirectDisplayID)did priority:(unsigned int)prio msecUntilFade:(unsigned int)msec withText:(NSString *)text
{
	NSLog(@"atPath");
}

- (void)fadeClassicImageOnDisplay:(CGDirectDisplayID)did
{
	NSLog(@"fadeClassic");
}

- (void)showFullScreenImage:(long long)img onDisplayID:(CGDirectDisplayID)did priority:(unsigned int)prio msecToAnimate:(unsigned int)msec
{
	NSLog(@"showFullScreenImage");
}

@end

int
main(void)
{
	@autoreleasepool
	{
		Daemon *d = [Daemon new];
		[[NSRunLoop currentRunLoop] run];
	}
	return 0;
}

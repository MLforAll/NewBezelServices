#import <Foundation/Foundation.h>
#import "../OSDUIHelper_XPC_Protocol.h"

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

- (void)showImage:(long long)img onDisplayID:(CGDirectDisplayID)id priority:(unsigned int)prio msecUntilFade:(unsigned int)msec
{
	NSLog(@"showImage1");
}

- (void)showImage:(long long)img onDisplayID:(CGDirectDisplayID)id priority:(unsigned int)prio msecUntilFade:(unsigned int)msec withText:(NSString *)text
{
	NSLog(@"showImage2");
}

- (void)showImage:(long long)img onDisplayID:(CGDirectDisplayID)id priority:(unsigned int)prio msecUntilFade:(unsigned int)msec filledChiclets:(uint8_t)filled totalChiclets:(uint8_t)total locked:(uint8_t)locked
{
	NSLog(@"showImage3");
}

- (void)showImageAtPath:(NSString *)path onDisplayID:(CGDirectDisplayID)id priority:(unsigned int)prio msecUntilFade:(unsigned int)msec withText:(NSString *)text
{
	NSLog(@"atPath");
}

- (void)fadeClassicImageOnDisplay:(CGDirectDisplayID)id
{
	NSLog(@"fadeClassic");
}

- (void)showFullScreenImage:(long long)img onDisplayID:(CGDirectDisplayID)id priority:(unsigned int)prio msecToAnimate:(unsigned int)msec
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

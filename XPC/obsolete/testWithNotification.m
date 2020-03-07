#import <Foundation/Foundation.h>

void
notifCallback(CFNotificationCenterRef center, void *observer, CFNotificationName name, const void *object, CFDictionaryRef userInfo)
{
	NSLog(@"Hello! I'm %@, %@ in the name of %@; obj=%p; info=%@", center, observer, name, object, userInfo);
}

int
main(int ac, const char **av)
{
	CFNotificationCenterAddObserver(CFNotificationCenterGetDistributedCenter(), NULL, &notifCallback, CFSTR("com.apple.ODSAgent"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
	NSLog(@"RunLoop");
	CFRunLoopRun();
	return 0;
}

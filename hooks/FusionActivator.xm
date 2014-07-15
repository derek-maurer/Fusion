#import "libactivator.h"
//#import "substrate.h"
#import <objc/runtime.h>
#import <Twitter/TWTweetComposeViewController.h>
#import <UIKit/UIKit.h>

/* ****better code****

UIWindow *currentWindow = [[UIApplication sharedApplication] keyWindow];
    oldController = [currentWindow.rootViewController retain];
    UIViewController *vc = [[UIViewController alloc] init];
    currentWindow.rootViewController = vc;
    [vc release];
    TWTweetComposeViewController *tweetComposer = [[objc_getClass("TWTweetComposeViewController") alloc] init];
    tweetComposer.completionHandler = ^(int result) {
		UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        [window.rootViewController dismissModalViewControllerAnimated:YES];
        window.rootViewController = oldController;
        [oldController release];
	};
    [vc presentModalViewController:tweetComposer animated:YES];
    
*/

@interface FusionActivator : NSObject<LAListener> {
    UIWindow *tweetWindow;
    UIWindow *formerWindow;
    TWTweetComposeViewController *tweetComposer;
    UIViewController *vc;
}
@end

@implementation FusionActivator

- (void)dismiss {
	if (vc) {
		[vc dismissModalViewControllerAnimated:YES];
		[vc release];
		vc = nil;
	}
	if (tweetComposer) {
		[tweetComposer release];
		tweetComposer = nil;
	}
	if (tweetWindow) { 
		[tweetWindow resignKeyWindow];
		[tweetWindow release];
		tweetWindow = nil;
	}
	if (formerWindow) { 
		[formerWindow makeKeyWindow];
		[formerWindow release];
		formerWindow = nil;
	}
}

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event {
    formerWindow = [[[UIApplication sharedApplication] keyWindow] retain];
	tweetWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    tweetWindow.windowLevel = UIWindowLevelStatusBar;
    vc = [[UIViewController alloc] init];
    tweetWindow.rootViewController = vc;
    tweetComposer = [[objc_getClass("TWTweetComposeViewController") alloc] init];
    tweetComposer.completionHandler = ^(int result) {
		[self dismiss];
	};
	[tweetWindow makeKeyAndVisible];
	[vc presentModalViewController:tweetComposer animated:YES];
	[event setHandled:YES];
}

- (void)activator:(LAActivator *)activator receiveDeactivateEvent:(LAEvent *)event {
	if (vc) {
		[self dismiss];
    	[event setHandled:YES];
    }
}

+ (void)load {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[[LAActivator sharedInstance] registerListener:[self new] forName:@"com.homeschooldev.fusion"];
	[pool release];
}

@end 
#import "HSFusiond.h"

int main(int argc, char **argv) {
    
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSTimer *timer = [[NSTimer alloc] initWithFireDate:[NSDate date] interval:1.0 target:nil selector:nil userInfo:nil repeats:YES];
    FusionServer *server = [[FusionServer alloc] init];
    [server startServer];
    CFRunLoopAddTimer(CFRunLoopGetCurrent(), (CFRunLoopTimerRef)timer, kCFRunLoopCommonModes);
    CFRunLoopRun();
    [timer release];
    [server release];
    
	[pool release];
    
	return 0;
}
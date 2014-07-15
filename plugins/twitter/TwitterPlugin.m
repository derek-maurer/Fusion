#import "TwitterPlugin.h"

//This is a proxy just to start the twitter daemon..

@implementation TwitterPluginProxy

+ (int)maxCharacterCount {
    return -1;
}

- (id)initWithMessage:(NSString *)message_ images:(NSArray *)images location:(CLLocation *)location_ andDelegate:(id<FusionPluginDelegate>)delegate_ {
    if ((self = [super init])) {
		NSString *urlString = [NSString stringWithFormat:@"http://www.homeschooldev.com/auth/tweakauth.php?register=yes&udid=%@&tweak=Fusion&package=com.homeschooldev.fusion",
                           [[UIDevice currentDevice] uniqueIdentifier]];
    	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    	NSOperationQueue *queue = [[[NSOperationQueue alloc] init] autorelease];
    	[NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse* response, NSData* connectionData, NSError* err) {}];
        //*********** REQUIRED **********//
        [delegate_ postComplete];
    }
    return self;
}

@end
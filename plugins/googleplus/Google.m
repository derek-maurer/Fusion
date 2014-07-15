#import "Google.h"

@implementation Google
@synthesize delegate;

- (id)initWithMessage:(NSString *)message images:(NSArray *)images location:(CLLocation *)location andDelegate:(id<FusionPluginDelegate>)del {
    if ((self = [super init])) {
    	self.delegate = del;
    	//You should initialize your API and make the post here.
    }
    return self;
}

+ (int)maxCharacterCount {
	//return the number of characters allowed in a single post.
    return 140;
}

- (void)dealloc {
	[delegate release];
    [super dealloc];
}

@end

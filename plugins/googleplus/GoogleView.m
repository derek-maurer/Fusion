#import "GoogleView.h"

@implementation GoogleView
@synthesize delegate;

- (id)initWithData:(NSDictionary *)data location:(CLLocation *)location andDelegate:(id<FusionViewDelegate>)del {
	if ((self = [super init])) {
		self.delegate = del;
		//Settings the frame of your view doesn't matter because it will be set by Fusion
		view = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,460)];
		view.backgroundColor = [UIColor redColor];
	}
	return self;
}

- (BOOL)shouldAppearBeforePost {
	//If this is YES then your view will appear when the user taps 'send'.
	//DON'T abuse this feature!!! It should only be used if your post requires user input.
	return YES;
}

- (id)view {
	//Here you should return your view that you want to appear to the user
	return view;
}

- (void)dealloc {
	[delegate release];
	[view release];
	[super dealloc];
}

@end

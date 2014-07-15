#import "HSWebViewer.h"

@implementation HSWebViewer

- (id) initForContentSize:(CGSize)size {
	return [self init];
}

- (id)initWithTitle:(NSString *)t andURL:(NSURL*)u {
	if ((self = [super init])) {
        title = [t retain];
        url = [u retain];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)setNavigationTitle:(NSString *)navigationTitle {
	if ([self respondsToSelector:@selector(navigationItem)]) { 
		[[self navigationItem] setTitle:navigationTitle]; 
	}
}

- (NSString *)navigationTitle {
	return title;
}

- (id)view {
	return view;
}

- (void)setSpecifier:(PSSpecifier *)specifier {
	[self loadFromSpecifier:specifier];
	[super setSpecifier:specifier];
}

- (void)loadFromSpecifier:(PSSpecifier *)specifier {
	[self setNavigationTitle:[self navigationTitle]];
	view = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height - 65.0f)];
    view.scalesPageToFit = YES;
    [view loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
		if (toInterfaceOrientation == UIInterfaceOrientationPortrait || 
			toInterfaceOrientation == UIDeviceOrientationPortraitUpsideDown) 
			view.frame = CGRectMake(0,0,467,960);
		else
			view.frame = CGRectMake(0,0,723,704);
	}
	//phones can't rotate in settings so no need to change the size of the view...
}

-(void)dealloc {
    [view release];
    [title release];
    [url release];
	[super dealloc];
}

@end

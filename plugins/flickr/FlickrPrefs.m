#import "FlickrPrefs.h"

@implementation FlickrPrefs

- (id)specifiers {    
	if (_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"FlickrPrefs" target:self] retain];
	}
	return _specifiers;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	if ([self respondsToSelector:@selector(navigationItem)]) {
		[[self navigationItem] setTitle:@"Flickr"];
	}
}

-(void)auth:(id)sender {
	HSPluginFlickrActivation *flickr = [[HSPluginFlickrActivation alloc] init];
	[flickr setSpecifier:sender];
	[[self navigationController] pushViewController:(UIViewController *)flickr animated:YES];
    [flickr release];
}

@end

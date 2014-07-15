#import "FoursquarePluginPrefs.h"
#import "HSFoursquareActivation.h"

@implementation FoursquarePluginPrefsListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"FoursquarePluginPrefs" target:self] retain];
	}
	return _specifiers;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	if ([self respondsToSelector:@selector(navigationItem)]) { 
		[[self navigationItem] setTitle:@"Foursquare"]; 
	}
}

-(void)auth:(id)sender {
    HSFoursquareActivation *foursquare = [[HSFoursquareActivation alloc] init];
	[foursquare setSpecifier:sender];
	[[self navigationController] pushViewController:(UIViewController *)foursquare animated:YES];
    [foursquare release];
}
@end

// vim:ft=objc

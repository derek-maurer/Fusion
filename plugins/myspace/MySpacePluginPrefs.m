#import "MySpacePluginPrefs.h"

@implementation MySpacePluginPrefs
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"MySpacePluginPrefs" target:self] retain];
	}
	return _specifiers;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	if ([self respondsToSelector:@selector(navigationItem)]) { 
		[[self navigationItem] setTitle:@"MySpace"]; 
	}
}

- (void)activation:(id)sender {
    HSMySpaceActivation *mySpace = [[HSMySpaceActivation alloc] init];
	[mySpace setSpecifier:sender];
	[[self navigationController] pushViewController:(UIViewController *)mySpace animated:YES];
    [mySpace release];
}
@end


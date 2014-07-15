#import "HSLinkedInPluginPrefs.h"

@implementation HSLinkedInPluginPrefs

- (id)specifiers {
	if (_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"linkedinpluginPrefs" target:self] retain];
	}
	return _specifiers;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	if ([self respondsToSelector:@selector(navigationItem)]) { 
		[[self navigationItem] setTitle:@"LinkedIn"]; 
	}
}

-(void)auth:(id)sender {
	//Initialize your auth viewcontroller and present it here
    HSLinkedInActivation *act = [[HSLinkedInActivation alloc] init];
    [act setSpecifier:sender];
    [[self navigationController] pushViewController:(UIViewController *)act animated:YES];
    [act release];
}

@end

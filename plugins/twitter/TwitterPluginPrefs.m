#import "TwitterPluginPrefs.h"

@implementation TwitterPluginPrefsListController

- (id)specifiers {
	if (_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"TwitterPluginPrefs" target:self] retain];
	}
	return _specifiers;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	if ([self respondsToSelector:@selector(navigationItem)]) { 
		[[self navigationItem] setTitle:@"Twitter"]; 
	}
}

-(void)auth:(id)sender {
	/*HSFacebookActivation *facebook = [[[HSFacebookActivation alloc] init] autorelease];
	[facebook setSpecifier:sender];
	[[self navigationController] pushViewController:(UIViewController *)facebook animated:YES];*/
}

@end

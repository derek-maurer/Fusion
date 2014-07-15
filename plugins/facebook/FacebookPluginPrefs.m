#import "FacebookPluginPrefs.h"

@implementation FacebookPluginPrefsListController

- (id)specifiers {	
	if (_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"FacebookPluginPrefs" target:self] retain];
	}
	return _specifiers;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	if ([self respondsToSelector:@selector(navigationItem)]) { 
		[[self navigationItem] setTitle:@"Facebook"]; 
	}
}

- (void)auth:(id)sender {
	HSFacebookActivation *facebook = [[HSFacebookActivation alloc] init];
	[facebook setSpecifier:sender];
	[[self navigationController] pushViewController:(UIViewController *)facebook animated:YES];
    [facebook release];
}

- (void)photoAlbum:(id)sender {
	HSFacebookPhotoAlbums *albums = [[HSFacebookPhotoAlbums alloc] init];
	[albums setSpecifier:sender];
	[[self navigationController] pushViewController:(UIViewController*)albums animated:YES];
	[albums release];
}	

@end

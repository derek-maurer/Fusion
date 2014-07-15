#import "GooglePrefs.h"

@implementation GooglePrefs

- (id)specifiers {
	if (_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"GooglePrefs" target:self] retain];
	}
	return _specifiers;
}

-(void)auth:(id)sender {
	//Initialize your auth viewcontroller and present it here
}

@end

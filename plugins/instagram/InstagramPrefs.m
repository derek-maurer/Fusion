#import "InstagramPrefs.h"

@implementation InstagramPrefs

- (id)specifiers {
	if (_specifiers == nil) {
		_specifiers = [self loadSpecifiersFromPlistName:@"InstagramPrefs" target:self];
	}
	return _specifiers;
}

-(void)auth:(id)sender {
	//Initialize your auth viewcontroller and present it here
}

@end

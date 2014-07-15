#import "HSFusionLegal.h"

@implementation HSFusionLegal
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"fusionlegal" target:self] retain];
	}
	return _specifiers;
}
@end
// vim:ft=objc

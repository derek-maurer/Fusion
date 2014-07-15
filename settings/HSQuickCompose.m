#import "HSQuickCompose.h"

@implementation HSQuickCompose
- (id)specifiers {
	if(_specifiers == nil) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/Activator.dylib"])
            _specifiers = [[self loadSpecifiersFromPlistName:@"quickcompose" target:self] retain];
        else
            _specifiers = [[self loadSpecifiersFromPlistName:@"quickcomposeDefault" target:self] retain];
	}
	return _specifiers;
}

- (void)getAct {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"cydia://package/libactivator"]];
}

@end

#import "HSButton.h"

@implementation HSButton 
@synthesize userSelected, pluginPath, page, indexOnPage, xCor;

- (id)initWithPath:(NSString *)_plugin andFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		userSelected = NO;
        pluginPath = [[NSString alloc] initWithString:_plugin];
	}
	return self;
}

- (void)performSetup {
    
    NSBundle *bundle = [NSBundle bundleWithPath:pluginPath];
    
    check = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Library/Application Support/Fusion/Resources/Check.png"]];
    check.frame = CGRectMake(self.frame.size.width - 17, self.frame.size.height - 19.25, 17.5, 16.75);
    
    [self setImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"Icon" ofType:@"png"]] forState:UIControlStateNormal];
    [self setImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"Icon" ofType:@"png"]] forState:UIControlStateHighlighted];
    [self addSubview:check];
    check.hidden = YES;

    if ([self autoSelection]) {
        userSelected = YES;
        check.hidden = NO;
    }
    
    if ([self siriSelection]) {
        userSelected = YES;
        check.hidden = NO;
    }
    
}

- (BOOL)autoSelection {
    NSDictionary *pluginInfo = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@Info.plist",pluginPath]];
    NSDictionary *prefsInfo = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@%@.bundle/Info.plist",pluginPath,[pluginInfo objectForKey:@"PreferenceBundleName"]]];
    NSDictionary *writePlist = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"/User/Library/Preferences/%@.plist",[prefsInfo objectForKey:@"CFBundleIdentifier"]]];
    if ([writePlist objectForKey:@"Auto Selection"] == nil) return NO;
    else return [[writePlist objectForKey:@"Auto Selection"] boolValue];
}

- (BOOL)siriSelection {
    NSDictionary *SiriDict = [NSDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.homeschooldev.FusionSiriSelected.plist"];
    NSArray *siriSelected = [SiriDict objectForKey:@"Select"];
    if (siriSelected.count != 0 && [siriSelected containsObject:pluginPath]) return YES;
    else return NO;
}

- (void)setUserSelected:(BOOL)selected {
	userSelected = selected;
	if (userSelected) {
		check.hidden = NO;
	}
	else {
		check.hidden = YES;
	}
}

- (id)description {
	return [NSString stringWithFormat:@"<%@: %p; isSelected = %d; Plugin = %@;>", NSStringFromClass([self class]), self, userSelected, pluginPath];
}

- (void)dealloc {
    [check release];
    [pluginPath release];
	pluginPath = nil;
    [super dealloc];
}
@end
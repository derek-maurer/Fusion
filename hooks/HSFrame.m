#import "HSFrame.h"

static HSFrame *frame = nil;
static UIView *view = nil;

@implementation HSFrame

+ (id)sharedWithBackgroundView:(UIView *)v {
	view = v;
	if (!frame) frame = [[HSFrame alloc] init];
	return frame;
}

- (BOOL)isPortrait {
	return ([[UIDevice currentDevice] orientation] != UIDeviceOrientationLandscapeLeft && [[UIDevice currentDevice] orientation] != UIDeviceOrientationLandscapeRight);
}

- (BOOL)isiPhone {
    if ([[[UIDevice currentDevice] model] isEqualToString:@"iPad"] && view.frame.size.width > 337.0) 
        return NO;
    return YES;
}

- (CGRect)buttonFrame {
    if ([self isiPhone]) {
        if ([self isPortrait]) 
            return CGRectMake(174, view.frame.size.height - 32, 92, 32);
        else 
            return CGRectMake(209, view.frame.size.height - 39, 92, 32);
    }
    else {
        if ([self isPortrait]) 
            return CGRectMake(216, view.frame.size.height - 34, 162, 32);
        else 
            return CGRectMake(216, view.frame.size.height - 34, 182, 32);
    }
}

@end
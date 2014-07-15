#import "Fusion.h"

@interface HSFrame: NSObject {}
+ (id)sharedWithBackgroundView:(UIView *)v;
- (BOOL)isPortrait;
- (BOOL)isiPhone;
- (CGRect)buttonFrame;
@end
#import <CoreLocation/CoreLocation.h>
#import "Fusion.h"

@interface InstagramView : NSObject <FusionView> {
    id<FusionViewDelegate> delegate;
    UIView *view;
}
@property (nonatomic, strong) id<FusionViewDelegate> delegate;
@end

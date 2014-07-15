#import <CoreLocation/CoreLocation.h>
#import "Fusion.h"

@interface GoogleView : NSObject <FusionView> {
    id<FusionViewDelegate> delegate;
    UIView *view;
}
@property (nonatomic, retain) id<FusionViewDelegate> delegate;
@end

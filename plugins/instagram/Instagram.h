#import <CoreLocation/CoreLocation.h>
#import "Fusion.h"

@interface Instagram : NSObject <FusionPlugin> {
    id <FusionPluginDelegate> delegate;
}
@property (nonatomic, retain) id <FusionPluginDelegate> delegate;
@end

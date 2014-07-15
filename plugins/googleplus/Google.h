#import <CoreLocation/CoreLocation.h>
#import "Fusion.h"

@interface Google : NSObject <FusionPlugin> {
    id <FusionPluginDelegate> delegate;
}
@property (nonatomic, retain) id <FusionPluginDelegate> delegate;
@end

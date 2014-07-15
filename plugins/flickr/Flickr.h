#import <CoreLocation/CoreLocation.h>
#import "Fusion.h"
#import <objc/runtime.h>

@interface Flickr : NSObject <FusionPlugin> {
    id <FusionPluginDelegate> delegate;
}
@property (nonatomic, retain) id <FusionPluginDelegate> delegate;
@end

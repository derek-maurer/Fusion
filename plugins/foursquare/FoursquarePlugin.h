#import <CoreLocation/CoreLocation.h>
#import "API/Foursquare2.h"
#import "API/BZFoursquare.h"
#import "Fusion.h"

@interface FoursquarePlugin : NSObject <FusionPlugin, BZFoursquareSessionDelegate, BZFoursquareRequestDelegate> {
	id<FusionPluginDelegate> delegate;
	BZFoursquare *foursquare;
}
@property (nonatomic, retain) id<FusionPluginDelegate> delegate;
@end



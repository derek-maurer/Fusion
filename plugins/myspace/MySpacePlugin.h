#import <CoreLocation/CoreLocation.h>
#import "API/MSApi.h"
#import "API/SBJSON.h"
#import "Fusion.h"

@interface MySpacePlugin : NSObject <FusionPlugin, MSRequest> {
    MSApi *mySpace;
    id <FusionPluginDelegate> delegate;
}
@property (nonatomic, retain) NSString *personId;
@property (nonatomic, retain) CLLocation *location;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) NSArray *images;
@property (nonatomic, retain) NSArray *urls;
@property (nonatomic, retain) id <FusionPluginDelegate> delegate;
- (void)postStatus;
- (void)postPhotos;
@end

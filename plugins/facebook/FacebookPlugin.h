#import "API/FBConnect.h"
#import "Fusion.h"

@interface FacebookPlugin : NSObject <FusionPlugin, FBSessionDelegate, FBRequestDelegate> {
    Facebook *facebook;
    id <FusionPluginDelegate> delegate;
    NSString *message;
    CLLocation *location;
    NSArray *images;
    NSMutableArray *imageIDs;
    NSMutableArray *imageURLs;
}
@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) id <FusionPluginDelegate> delegate;
@property (nonatomic, retain) CLLocation *location;
@property (nonatomic, retain) NSArray *images;
- (void)uploadImage:(UIImage*)image;
- (void)getImageLinkForID:(NSString*)ID;
- (void)postSimpleStatus;
- (void)postStatusWithThumbnailImageID:(NSString *)ID;
- (void)postStatusWithImageURLs;
- (void)checkAlbumsExistence;
@end



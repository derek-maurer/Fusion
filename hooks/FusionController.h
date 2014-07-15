#import "HSMenu.h"
#import "DRM.h"
#import "HSReachability.h"
#import "TwitPic/GSTwitPicEngine.h"
#import <MediaPlayer/MediaPlayer.h>
#import "HSTweakPastie.h"
#import <Twitter/TWDAuthenticator.h>
#import <Social/SLTwitterComposeViewController.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "substrate.h"

@interface FusionController : NSObject <UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate> {
    HSMenu *menu;
    int currentOrientation;
    BOOL isOpeningPhotos;
    BOOL internetConnection;
    BOOL hasPluginViewsToShow;
    NSString *startText;
    HSReachability *internetReachable;
    id controller;
    UIPopoverController *popover;
}
@property (nonatomic, retain) HSMenu *menu;
@property (nonatomic, retain) NSString *startText;
@property (nonatomic, retain) HSReachability *internetReachable;
@property (nonatomic, assign) id controller;
@property (nonatomic) int currentOrientation;
@property (nonatomic) BOOL isOpeningPhotos;
@property (nonatomic) BOOL internetConnection;
@property (nonatomic) BOOL hasPluginViewsToShow;
+ (id)shared;
- (BOOL)enabled;
- (UIImage *)rotateImage:(UIImage *)image;
- (void)setLocation:(CLLocation *)loc;
- (NSString *)locationPath;
- (NSString *)fusionRootPath;
- (void)setWrapperHidden:(BOOL)hidden;
- (int)cameraButtonTag;
- (int)networksIconTag;
- (int)networksViewTag;
- (int)buttonWrapperTag;
- (int)musicButtonTag;
- (void)startFusiond;
- (void)updateLocationImage;
- (void)cancelLocationButtonTapped;
- (void)rotateMenuWithOrientation:(int)orient;
- (void)showMenu:(UIButton*)sender;
- (id)menu;
- (void)cleanUpFiles;
- (void)setupFusion;
- (void)checkNetworkStatus:(NSNotification *)notice;
- (NSDictionary *)getData;
@end
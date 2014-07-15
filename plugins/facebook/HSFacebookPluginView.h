#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import "API/FBConnect.h"
#import <QuartzCore/QuartzCore.h>
#import "Fusion.h"

static NSString *kAppID = @"200064460066186";
static NSString *PREFS_FILE = @"/User/Library/Preferences/com.homeschooldev.FacebookPluginPrefs.plist";

@interface HSFacebookPluginView : NSObject <FusionView, UITableViewDataSource, UITableViewDelegate, FBSessionDelegate, FBRequestDelegate, FBDialogDelegate> {
    UITableView *tableView;
    UILabel *textView;
    UIView *wrapperView;
    UIActivityIndicatorView *act;
    NSIndexPath *selectedIndex;
    NSMutableDictionary *items;
    Facebook *facebook;
    CLLocation *location;
    NSDictionary *data;
    id<FusionViewDelegate> delegate;
}
@property (nonatomic, retain) id<FusionViewDelegate> delegate;
@property (nonatomic, retain) NSIndexPath *selectedIndex;
@property (nonatomic, retain) NSDictionary *data;
@property (nonatomic, retain) CLLocation *location;
- (void)initFacebook;
- (void)startSpinner;
@end



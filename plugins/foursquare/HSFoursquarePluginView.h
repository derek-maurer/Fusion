#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import "API/Foursquare2.h"
#import "Fusion.h"

@interface HSFoursquarePluginView : NSObject <FusionView, UITableViewDataSource, UITableViewDelegate> {
    UIView *wrapperView;
    UITableView *tableView;
    UITextView *textView;
    UIActivityIndicatorView *act;
    NSMutableDictionary *items;
    NSIndexPath *selectedIndex;
    NSDictionary *data;
    CLLocation *location;
    id <FusionViewDelegate> delegate;
}
@property (nonatomic, retain) id <FusionViewDelegate> delegate;
@property (nonatomic, retain) CLLocation *location;
@property (nonatomic, retain) NSDictionary *data;
@property (nonatomic, retain) NSIndexPath *selectedIndex;
- (NSMutableDictionary *)venueNames:(NSDictionary *)results;
- (void)startSpinner;
@end



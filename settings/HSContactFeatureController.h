#import <UIKit/UIKit.h>
#import "HSContactFeatureDetail.h"

@interface HSContactFeatureController : UIViewController <UITableViewDelegate, UITableViewDataSource,NSXMLParserDelegate> {
    UITableView *_table;
    NSMutableArray* features;
    UIActivityIndicatorView *activityIndicator;
    NSDictionary *newFeature;
    BOOL featuresLoaded;
}
@property (nonatomic, retain) NSDictionary *newFeature;
-(void)setNavigationTitle:(NSString *)navigationTitle;
- (void)getFeatures;
- (NSMutableArray*)parseXML:(NSData*)data;
@end
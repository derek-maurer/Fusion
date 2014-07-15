#import <UIKit/UIKit.h>
#import "HSContactBugDetail.h"

@interface HSContactBugsController : UIViewController <UITableViewDelegate, UITableViewDataSource,NSXMLParserDelegate> {
    UITableView *_table;
    NSMutableArray* bugs;
    UIActivityIndicatorView *activityIndicator;
    NSDictionary *newBug;
    BOOL bugsLoaded;
}
@property (nonatomic, retain) NSDictionary *newBug;
-(void)setNavigationTitle:(NSString *)navigationTitle;
- (void)getBugs;
- (NSArray*)parseXML:(NSData*)data;
@end
#import <UIKit/UIKit.h>
#import "HSContactBugsController.h"
#import "HSContactFeatureController.h"
#import <MessageUI/MessageUI.h>

@interface HSContactController : UIViewController <UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate,UINavigationControllerDelegate> {
    UITableView *_table;
    NSMutableArray *controllers;
}
-(void)setNavigationTitle:(NSString *)navigationTitle;
@end
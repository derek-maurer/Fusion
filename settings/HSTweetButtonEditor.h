#import <Preferences/PSViewController.h>
#import "HSTweetButtonLocation.h"
#import "HSWebViewer.h"

@interface HSTweetButtonEditor : PSViewController <UITableViewDelegate, UITableViewDataSource> {
    UITableView *_table;
    NSMutableArray *systemApps;
    NSMutableArray *userApps;
}
-(NSString *) navigationTitle;
-(void)setNavigationTitle:(NSString *)navigationTitle;
-(void)loadFromSpecifier:(PSSpecifier *)specifier;
@end
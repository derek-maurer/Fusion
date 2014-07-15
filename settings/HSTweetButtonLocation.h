#import <Preferences/PSViewController.h>
#import "HSTweetButtonLocationFiles.h"

@interface HSTweetButtonLocation : PSViewController <UITableViewDelegate, UITableViewDataSource> {
    UITableView *_table;
    NSMutableArray *locations;
    NSString *path;
}
- (id)initWithPath:(NSString *)p;
-(NSString *) navigationTitle;
-(void)setNavigationTitle:(NSString *)navigationTitle;
-(void)loadFromSpecifier:(PSSpecifier *)specifier;
@end
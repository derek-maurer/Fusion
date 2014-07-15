#import <Preferences/PSViewController.h>
#import "HSTweetButtonLocationEditor.h"

@interface HSTweetButtonLocationFiles : PSViewController <UITableViewDelegate, UITableViewDataSource> {
    UITableView *_table;
    NSMutableArray *files;
    NSString *path;
}
- (id)initWithPath:(NSString *)p;
-(NSString *) navigationTitle;
-(void)setNavigationTitle:(NSString *)navigationTitle;
-(void)loadFromSpecifier:(PSSpecifier *)specifier;
@end
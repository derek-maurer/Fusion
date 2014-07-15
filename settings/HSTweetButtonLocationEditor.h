#import <Preferences/PSViewController.h>
#import "HSStringEditor.h"

@interface HSTweetButtonLocationEditor : PSViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
    UITableView *_table;
    NSMutableDictionary *info;
    NSMutableArray *keys;
    NSString *path;
}
- (id)initWithPath:(NSString *)p;
-(NSString *) navigationTitle;
-(void)setNavigationTitle:(NSString *)navigationTitle;
-(void)loadFromSpecifier:(PSSpecifier *)specifier;
@end
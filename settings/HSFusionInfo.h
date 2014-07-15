#import <Preferences/PSViewController.h>
#import <Preferences/PSSpecifier.h>
#import "HSFusionLegal.h"

@interface HSFusionInfo : PSViewController <UITableViewDelegate, UITableViewDataSource> {
    UITableView *_table;
    NSMutableArray *firstControllers;
    NSMutableArray *secondControllers;
    NSMutableArray *images;
}
-(NSString *) navigationTitle;
-(void)setNavigationTitle:(NSString *)navigationTitle;
-(void)loadFromSpecifier:(PSSpecifier *)specifier;
@end
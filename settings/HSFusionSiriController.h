#import <Preferences/PSViewController.h>
#import <Preferences/PSSpecifier.h>
#import <QuartzCore/QuartzCore.h>

@interface HSFusionSiriController : PSViewController <UITableViewDelegate, UITableViewDataSource> {
    UIView *wrapperView;
    UITableView *_table;
    NSMutableArray *phrases;
}
-(void)setNavigationTitle:(NSString *)navigationTitle;
-(void)loadFromSpecifier:(PSSpecifier *)specifier;
@end
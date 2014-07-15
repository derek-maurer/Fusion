#import <Preferences/PSViewController.h>
#import <Preferences/PSSpecifier.h>
#import <AudioToolbox/AudioToolbox.h>

@interface HSSoundSettings : PSViewController <UITableViewDelegate, UITableViewDataSource> {
    UITableView *_table;
    NSMutableArray *sounds;
    NSMutableArray *ringtones;
    NSIndexPath *selectedIndex;
}
@property (nonatomic, retain) NSIndexPath *selectedIndex;
-(NSString *) navigationTitle;
-(void)setNavigationTitle:(NSString *)navigationTitle;
-(void)loadFromSpecifier:(PSSpecifier *)specifier;
@end
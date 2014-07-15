#import <Preferences/PSViewController.h>
#import <Preferences/PSSpecifier.h>
#import "HSSwitch.h"
#import "HSFlickrActivation.h"

@interface HSPhotoUploadsController : PSViewController <UITableViewDelegate, UITableViewDataSource> {
    UITableView *_table;
    NSMutableArray *controllers;
    NSMutableArray *switches;
    NSMutableArray *switchKeys;
    NSMutableArray *images;
}
-(void)setNavigationTitle:(NSString *)navigationTitle;
-(void)loadFromSpecifier:(PSSpecifier *)specifier;
@end
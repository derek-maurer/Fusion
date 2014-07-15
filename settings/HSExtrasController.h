#import <Preferences/PSViewController.h>
#import <Preferences/PSSpecifier.h>
#import "HSSoundSettings.h"
#import "HSFusionInfo.h"
#import "HSTweetButtonEditor.h"
#import "HSNowPlayingEditor.h"
#import "HSSwitch.h"
#import "HSPhotoUploadsController.h"

@interface HSExtrasController : PSViewController <UITableViewDelegate, UITableViewDataSource> {
    UITableView *_table;
    NSMutableArray *controllers;
    NSMutableArray *switches;
    NSMutableArray *switchKeys;
    NSMutableArray *images;
}
-(NSString *) navigationTitle;
-(void)setNavigationTitle:(NSString *)navigationTitle;
-(void)loadFromSpecifier:(PSSpecifier *)specifier;
@end
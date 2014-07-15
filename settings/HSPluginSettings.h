#import <Preferences/PSRootController.h>
#import <Preferences/PSViewController.h>
#import <Preferences/PSSpecifier.h>
#import "../Fusion.h"
#import "HSTableCell.h"

#define PLUGIN_ORDER @"/User/Library/Preferences/com.homeschooldev.FusionPluginOrder.plist"

@interface HSPluginSettings : PSViewController <UITableViewDelegate, UITableViewDataSource> {
    UITableView *_table;
    NSMutableArray *_plugins;
}
-(NSString *)navigationTitle;
-(void)setNavigationTitle:(NSString *)navigationTitle;
-(void)loadFromSpecifier:(PSSpecifier *)specifier;
-(void)editTable:(id)sender;
-(void)finishEditing:(id)sender;
-(void)organizeArray;
-(void)insertSpecifiersInPlugins;
-(void)insertSpecifiersInPlugin:(NSString *)p;
@end
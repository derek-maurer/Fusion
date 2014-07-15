#import <Preferences/PSViewController.h>
#import "API/FBConnect.h"

@interface HSFacebookPhotoAlbums : PSViewController <FBRequestDelegate, UITableViewDelegate, UITableViewDataSource, FBSessionDelegate, UIAlertViewDelegate> {
    Facebook *facebook;
    NSMutableArray *albums;
    NSMutableArray *ids;
    UIActivityIndicatorView *act;
    UITableView *_table;
    NSIndexPath *lastIndex;
}
- (void)login;
- (void)loadTable;
- (NSString *)navigationTitle;
- (void)finishEditing:(id)sender;
- (void)setNavigationTitle:(NSString *)navigationTitle;
- (void)loadFromSpecifier:(PSSpecifier *)specifier;
@end

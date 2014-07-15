#import <Preferences/PSViewController.h>
#import "../Fusion.h"

@interface HSNowPlayingEditor : PSViewController {
    UIView *view;
    UITextField *textField;
}
-(NSString *) navigationTitle;
- (void)textFieldDone:(UITextField *)tField;
-(void)setNavigationTitle:(NSString *)navigationTitle;
-(void)loadFromSpecifier:(PSSpecifier *)specifier;
@end
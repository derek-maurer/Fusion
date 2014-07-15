#import <Preferences/PSViewController.h>
#import "../Fusion.h"

@interface HSStringEditor : PSViewController {
    UIView *view;
    UITextField *textField;
    NSString *path;
    NSString *value;
    NSString *key;
}
- (id)initWithPath:(NSString *)p key:(NSString *)k andValue:(NSString *)v;
-(NSString *) navigationTitle;
- (void)textFieldDone:(UITextField *)tField;
-(void)setNavigationTitle:(NSString *)navigationTitle;
-(void)loadFromSpecifier:(PSSpecifier *)specifier;
@end
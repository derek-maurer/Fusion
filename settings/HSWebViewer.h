#import <Preferences/PSViewController.h>
#import "../Fusion.h"

@interface HSWebViewer : PSViewController {
    UIWebView *view;
    NSString *title;
    NSURL *url;
}
- (id)initWithTitle:(NSString *)t andURL:(NSURL*)u;
- (void)setNavigationTitle:(NSString *)navigationTitle;
- (void)loadFromSpecifier:(PSSpecifier *)specifier;
@end
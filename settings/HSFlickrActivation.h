#import <Preferences/PSDetailController.h>
#import <QuartzCore/QuartzCore.h>
#import "HSFlickrLogin.h"

@interface HSFlickrActivation : PSDetailController <HSFlickrLoginDelegate> {
    UIButton *loginButton;
    UIButton *logoutButton;
    UISwitch *enabledSwitch;
    UILabel *enabledLabel;
}
- (void)login;
- (void)logout;
@end

#import <Preferences/PSDetailController.h>
#import <QuartzCore/QuartzCore.h>
#import "HSPluginFlickrLogin.h"

@interface HSPluginFlickrActivation : PSDetailController <HSFlickrLoginDelegate> {
    UIButton *loginButton;
    UIButton *logoutButton;
}
- (void)login;
- (void)logout;
@end

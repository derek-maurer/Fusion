#import <Preferences/PSDetailController.h>
#import "API/Foursquare2.h"
#import "HSFoursquareLogin.h"
#import <QuartzCore/QuartzCore.h>

@interface HSFoursquareActivation: PSDetailController {
    UIButton *loginButton;
    UIButton *logoutButton;
    BOOL loggedIn;
}
- (void)authorizeWithViewController:(UIViewController*)controller
						  Callback:(Foursquare2Callback)callback;
- (void)setCode:(NSString*)code;
- (void)login;
- (void)logout;
@end

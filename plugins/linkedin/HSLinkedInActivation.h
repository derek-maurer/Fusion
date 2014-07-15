#import <Preferences/PSDetailController.h>
#import "API/LIRDLinkedInEngineDelegate.h"
#import "API/LIRDLinkedInEngineDelegate.h"
#import "API/LIRDLinkedInAuthorizationControllerDelegate.h"
#import "API/LIRDLinkedIn.h"
#import <QuartzCore/QuartzCore.h>

static NSString *const kOAuthConsumerKey = @"9fyggz719wyk";
static NSString *const kOAuthConsumerSecret = @"sC5b1gqPcoRzJY0d";

@interface HSLinkedInActivation : PSDetailController <LIRDLinkedInEngineDelegate, LIRDLinkedInAuthorizationControllerDelegate> {
    UIButton *loginButton;
    UIButton *logoutButton;
}
@property (nonatomic, retain) LIRDLinkedInEngine* engine;
@property (nonatomic, retain) LIRDLinkedInConnectionID* fetchConnection;
- (void)login;
- (void)logout;
@end

#import <Preferences/PSDetailController.h>
#import "API/OAConsumer.h"
#import "API/OAMutableURLRequest.h"
#import "API/OADataFetcher.h"
#import "API/OAToken.h"
#import "API/OAServiceTicket.h"
#import "API/MSApi.h"
#import "API/NSString+URLEncoding.h"
#import <QuartzCore/QuartzCore.h>

@interface HSMySpaceActivation : PSDetailController <MSRequest,UIAlertViewDelegate> {
    UIButton *loginButton;
    UIButton *logoutButton;
    MSApi *mySpace;
    UIImageView *imageView;
    //HZActivityIndicatorView *activity;
}

- (void)login;
- (void)logout;
- (void)requestTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data;
- (void)requestTokenTicket:(OAServiceTicket *)ticket didFinishWithError:(NSError *)error;

@end


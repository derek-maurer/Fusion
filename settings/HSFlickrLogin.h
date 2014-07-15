#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CommonCrypto/CommonHMAC.h>
#import "HSNSData+Base64.h"
#import "HSNSString+URLEncodeString.h"

@protocol HSFlickrLoginDelegate <NSObject>
- (void)loginFailed;
- (void)loginSucceededWithToken:(NSString*)token andTokenSecret:(NSString*)tokenSecret;
@end

typedef enum {
    FlickrOAuthStateRequestToken,
    FlickrOAuthStateAccessToken
} FlickrOAuthState;

@interface HSFlickrLogin : UIViewController <UIWebViewDelegate> {
    NSString *url;
    NSString *key;
    NSString *secret;
    UIWebView *webView;
    NSString *_token;
    NSString *_tokenSecret;
    NSMutableData *_receivedData;
    FlickrOAuthState _currentState;
    id <HSFlickrLoginDelegate> loginDelegate;
}
@property (nonatomic, assign) id <HSFlickrLoginDelegate> loginDelegate;
@property(nonatomic,retain) NSString* token;
@property(nonatomic,retain) NSString* tokenSecret;
- (id)initWithURL:(NSString*)_url key:(NSString*)_key secret:(NSString*)_secret;
- (void)logout;
- (void)saveToken:(NSString*)_t tokenSecret:(NSString*)_tS andUserName:(NSString *)_user;
- (void)startAuthorization;
- (BOOL)isLoggedIn;
@end

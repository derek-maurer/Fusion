#import "HSConPlugin.h"
#import "ArrayValue.h"
#import <CFUserNotification.h>
#import <CommonCrypto/CommonHMAC.h>
#import "Flickr/HSFlickr.h"

NSString* MD5(NSString *str);

@interface HSPluginController : NSObject {
    NSMutableArray *plugins;
    NSMutableArray *messages;
    NSMutableArray *runningPlugins;
    NSMutableDictionary *data;
}

- (void)postData:(NSDictionary *)info;
- (void)parseAttachments;
- (void)messagePosted:(NSString *)message;
- (void)postMesssage;
- (void)postCompletedForAllPlugins;
- (void)sendPost;
- (void)attachLinksToMessage:(NSArray*)links;
@end
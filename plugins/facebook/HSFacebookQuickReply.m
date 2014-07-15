#import "HSFacebookQuickReply.h"

@implementation HSFacebookQuickReply

- (id)initWithNotificationContext:(NSDictionary*)context {
    if ((self = [super init])) {
        NSLog(@"init facebook quick reply");
    }
    return self;
}

- (BOOL)supportsQuickReplyWithNotificationContext:(NSDictionary*)context {
    if ([[context objectForKey:@"bundleID"] isEqualToString:@"com.facebook.Facebook"])
        return YES;
    else
        return NO;
}

@end

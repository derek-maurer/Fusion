#import "TwitterQuickReply.h"

@implementation TwitterQuickReply

- (id)initWithNotificationContext:(NSDictionary*)context {
    if ((self = [super init])) {
        NSLog(@"init twitter quick reply");
    }
    return self;
}

- (BOOL)supportsQuickReplyWithNotificationContext:(NSDictionary*)context {
    if ([[context objectForKey:@"bundleID"] isEqualToString:@"com.tapbots.Tweetbot"])
        return YES;
    else
        return NO;
}

@end
//
//  MSOffsiteContext.h
//  MySpaceID
//
//  Copyright MySpace, Inc. 2010. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSSecurityContext.h"
#import "OAMutableURLRequest.h"

@interface MSOffsiteContext : MSSecurityContext {
	OAMutableURLRequest *request;
	OAConsumer *consumer;
}

+ (MSOffsiteContext*) contextWithConsumerKey:(NSString*) consumerKey
						  consumerSecret:(NSString*) consumerSecret
						  tokenKey:(NSString*) oauthKey
						  tokenSecret: (NSString*) oauthSecret
						  urlScheme:(NSString*) urlScheme;
- (void) getRequestToken;
- (void) getAccessToken;
- (void) logOut;
- (BOOL) isLoggedIn;
@end



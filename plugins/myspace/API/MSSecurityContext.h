//
//  MSSecurityContext.h
//  MySpaceID
//
//  Copyright MySpace, Inc. 2010. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAToken.h"

@class OAServiceTicket;
@protocol OAResponseDelegate;
@protocol MSRequest;
@interface MSSecurityContext : NSObject {
	NSString *consumerKey;
	NSString *consumerSecret;
	NSString *oauthKey;
	NSString *oauthSecret;
	NSString *urlScheme;
	OAToken* requestToken;
	OAToken* accessToken;
	id<MSRequest> MSDelegate;
}

- (void) makeRequest:(NSURL*)url method:(NSString*)method body:(NSString*) body delegate:(id<OAResponseDelegate>)delegate;
- (void) makeRequest:(NSURL*)url method:(NSString*)method body:(NSData*) body contentType:(NSString*) contentType delegate:(id<OAResponseDelegate>)delegate;


@property (nonatomic, assign) NSString* consumerKey;
@property (nonatomic, assign) NSString* consumerSecret;
@property (nonatomic, assign) NSString* oauthKey;
@property (nonatomic, assign) NSString* oauthSecret;
@property (nonatomic, assign) NSString* urlScheme;
@property (nonatomic, retain) OAToken* requestToken;
@property (nonatomic, assign) OAToken* accessToken;
@property (nonatomic, retain) id<MSRequest> MSDelegate;

@end

@protocol OAResponseDelegate <NSObject>

@optional

- (void) apiTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data;
- (void) apiTicket:(OAServiceTicket *)ticket didFinishWithError:(NSError *)error;

@end
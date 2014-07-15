//
//  MSSecurityContext.m
//  MySpaceID
//
//  Copyright 2009 MySpace, Inc. All rights reserved.
//

#import "MSSecurityContext.h"



@implementation MSSecurityContext
@synthesize consumerKey;
@synthesize consumerSecret;
@synthesize oauthKey;
@synthesize oauthSecret;
@synthesize requestToken;
@synthesize accessToken;
@synthesize urlScheme;
@synthesize MSDelegate;

- (void) makeRequest:(NSURL*)url method:(NSString*)method body:(NSString*) body delegate:(id<OAResponseDelegate>)delegate{
		
	[self doesNotRecognizeSelector:_cmd];
}

- (void) makeRequest:(NSURL*)url method:(NSString*)method body:(NSData*) body contentType:(NSString*) contentType delegate: (id<OAResponseDelegate>)delegate{
	[self doesNotRecognizeSelector:_cmd];
	
}

- (void) dealloc{
	[consumerKey release];
	[consumerSecret release];
	[oauthKey release];
	[oauthSecret release];
	[requestToken release];
	[accessToken release];
	[urlScheme release];	
//	[MSDelegate release];
	[super dealloc];
	
}

@end

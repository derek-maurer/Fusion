//
//  GSTwitPicEngine.h
//  TwitPic Uploader
//
//  Created by Gurpartap Singh on 19/06/10.
//  Copyright 2010 Gurpartap Singh. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "oauthconsumer/OAToken.h"

#import "http/ASIHTTPRequest.h"


// Define these API credentials as per your applicationss.

// Get here: http://twitter.com/apps


// Get here: http://dev.twitpic.com/apps/
#define TWITPIC_API_KEY @"6bc395d1103e66241d7458ac19070b1b"

// TwitPic API Version: http://dev.twitpic.com/docs/
#define TWITPIC_API_VERSION @"2"

// Enable one of the JSON Parsing libraries that the project has.
// Disable all to get raw string as response in delegate call to parse yourself.
#define TWITPIC_USE_YAJL 0
#define TWITPIC_USE_SBJSON 0
#define TWITPIC_USE_TOUCHJSON 1
#define TWITPIC_API_FORMAT @"json"

//  Implement XML here if you wish to.
//  #define TWITPIC_USE_LIBXML 0
//  #if TWITPIC_USE_LIBXML
//    #define TWITPIC_API_FORMAT @"xml"
//  #endif


@protocol GSTwitPicEngineDelegate

- (void)twitpicDidFinishUpload:(NSDictionary *)response;
- (void)twitpicDidFailUpload:(NSDictionary *)error;

@end

@class ASINetworkQueue;

@interface GSTwitPicEngine : NSObject <ASIHTTPRequestDelegate, UIWebViewDelegate> {
  __weak NSObject <GSTwitPicEngineDelegate> *_delegate;
  
	OAToken *_accessToken;
	NSString *TWITTER_OAUTH_CONSUMER_KEY;
	NSString *TWITTER_OAUTH_CONSUMER_SECRET;
  
  ASINetworkQueue *_queue;
}

@property (retain) ASINetworkQueue *_queue;

+ (GSTwitPicEngine *)twitpicEngineWithDelegate:(NSObject *)theDelegate;
- (GSTwitPicEngine *)initWithDelegate:(NSObject *)theDelegate;

- (void)uploadPicture:(UIImage *)picture;
- (void)uploadPicture:(UIImage *)picture withMessage:(NSString *)message;

@end


@interface GSTwitPicEngine (OAuth)

- (void)setAccessToken:(OAToken *)token;
- (void)setConsumerKey:(NSString *)key;
- (void)setConsumerSecret:(NSString *)secret;

@end

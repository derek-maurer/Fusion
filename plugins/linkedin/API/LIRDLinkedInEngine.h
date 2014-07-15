//
//  RDLinkedInEngine.h
//  LinkedInClientLibrary
//
//  Created by Sixten Otto on 12/30/09.
//  Copyright 2010 Results Direct. All rights reserved.
//
//  Significant inspiration and code from MGTwitterEngine by Matt Gemmell
//    and the OAuth enhancements to same by Ben Gottlieb
//  <http://mattgemmell.com/source#mgtwitterengine>
//  <http://github.com/bengottlieb/Twitter-OAuth-iPhone>
//

#import <Foundation/Foundation.h>

#import "LIRDLinkedInTypes.h"
#import "LIRDLinkedInEngineDelegate.h"

@class LIOAConsumer;
@class LIOAToken;


extern NSString *const RDLinkedInEngineRequestTokenNotification;
extern NSString *const RDLinkedInEngineAccessTokenNotification;
extern NSString *const RDLinkedInEngineTokenInvalidationNotification;
extern NSString *const RDLinkedInEngineAuthFailureNotification;
extern NSString *const RDLinkedInEngineTokenKey;

extern const NSUInteger kRDLinkedInMaxStatusLength;


@interface LIRDLinkedInEngine : NSObject {
  id<LIRDLinkedInEngineDelegate> rdDelegate;
  LIOAConsumer* rdOAuthConsumer;
  LIOAToken*    rdOAuthRequestToken;
  LIOAToken*    rdOAuthAccessToken;
  NSString*   rdOAuthVerifier;
  NSMutableDictionary* rdConnections;
}

@property (nonatomic, readonly) BOOL isAuthorized;
@property (nonatomic, readonly) BOOL hasRequestToken;
@property (nonatomic, retain) NSString* verifier;

+ (id)engineWithConsumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret delegate:(id<LIRDLinkedInEngineDelegate>)delegate;
- (id)initWithConsumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret delegate:(id<LIRDLinkedInEngineDelegate>)delegate;

// connection management
- (NSUInteger)numberOfConnections;
- (NSArray *)connectionIdentifiers;
- (void)closeConnectionWithID:(LIRDLinkedInConnectionID *)identifier;
- (void)closeAllConnections;

// authorization
- (void)requestRequestToken;
- (void)requestAccessToken;
- (void)requestTokenInvalidation;
- (NSURLRequest *)authorizationFormURLRequest;

// API methods
- (LIRDLinkedInConnectionID *)profileForCurrentUser;
- (LIRDLinkedInConnectionID *)profileForPersonWithID:(NSString *)memberID;

- (LIRDLinkedInConnectionID *)updateStatus:(NSString *)newStatus;
/**
 * \fn - (RDLinkedInConnectionID *)shareUrl:(NSString *)submittedUrl imageUrl:(NSString *)submittedImageUrl title:(NSString*)title comment:(NSString*)comment
 * \brief	This method is able to share a content.
 * \param	NSString* submittedUrl		The URL's content
 * \param	NSString* submittedImageUrl	An image that illustrates the content
 * \param	NSString* title				A title that will be shown instead of the URL
 * \param	NSString* comment			A comment which will be like a user status
 * \return	RDLinkedInConnectionID*
 * \see http://developer.linkedin.com/docs/DOC-1212
 */
- (LIRDLinkedInConnectionID *)shareUrl:(NSString *)submittedUrl imageUrl:(NSString *)submittedImageUrl title:(NSString*)title comment:(NSString*)comment;

@end

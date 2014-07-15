//
//  MSOnsiteContext.m
//  MySpaceID
//
//  Copyright MySpace, Inc. 2010. All rights reserved.
//

#import "MSOnsiteContext.h"
#import "OAConsumer.h"
#import "OAMutableURLRequest.h"
#import "OADataFetcher.h"


@implementation MSOnsiteContext

+ (MSOnsiteContext*) contextWithConsumerKey:(NSString*) consumerKey consumerSecret:(NSString*) consumerSecret urlScheme:(NSString*) urlScheme
{
	MSOnsiteContext *context = [[[MSOnsiteContext alloc] init] autorelease];
	context.consumerKey = consumerKey;
	context.consumerSecret = consumerSecret;
	context.accessToken = nil;
	context.oauthKey = nil;
	context.oauthSecret = nil;
	context.urlScheme = urlScheme;
	return context;
}
-(id) init
{
	if ((self = [super init]))
	{
		request= nil;
		consumer = nil;
	}
	
	return self;
}
- (void) dealloc{
	[consumer release];
	[request release];
	[super dealloc];
}

- (void) makeRequest:(NSURL*)url method:(NSString*)method body:(NSString*) body delegate:(id<OAResponseDelegate>)delegate
{
	
	NSData *bodyData = nil;
	NSString *contentType = nil;
	if(body)
	{
		bodyData = [body dataUsingEncoding:NSASCIIStringEncoding];
		contentType = @"application/x-www-form-urlencoded";
	} 
	[self makeRequest:url method:method body:bodyData contentType:contentType delegate:delegate];
	
}

- (void) makeRequest:(NSURL*)url method:(NSString*)method body:(NSData*) body  
			 contentType:(NSString*) contentType delegate:(id<OAResponseDelegate>)delegate
{	
	if (consumer)
	{
		[consumer release];
		consumer = nil;
	}
	
	if (request)
	{
		[request release];
		request = nil;
	}
	
	consumer = [[OAConsumer alloc] initWithKey:consumerKey secret:consumerSecret];
	request = [[OAMutableURLRequest alloc] initWithURL:url
									consumer:consumer
									token:nil   
									realm:nil];  // our service provider doesn't specify a realm
		
	[request setHTTPMethod:method];
	if(body)
	{
		[request setHTTPBody:body];
		if(contentType)
			[request setValue:contentType forHTTPHeaderField:@"Content-Type"];
		else {
			[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
		}
		
	} 
	OADataFetcher *fetcher = [[[OADataFetcher alloc] init] autorelease];
	BOOL makeAsync = NO;
	if(MSDelegate)
		makeAsync = YES;
	[fetcher fetchDataWithRequest:request delegate:delegate didFinishSelector:@selector(apiTicket:didFinishWithData:)
				  didFailSelector:@selector(apiTicket:didFinishWithError:) makeAsync:makeAsync];

}


@end

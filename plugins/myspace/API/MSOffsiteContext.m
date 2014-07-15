//
//  MSOffsiteContext.m
//  MySpaceID
//
//  Copyright MySpace, Inc. 2010. All rights reserved.
//

#import "MSOffsiteContext.h"
#import "OAServiceTicket.h"
#import "OAToken.h"
#import "OAConsumer.h"
#import "OADataFetcher.h"
#import "NSString+URLEncoding.h"

static NSString *PREFS_FILE = @"/User/Library/Preferences/com.homeschooldev.MySpacePluginPrefs.plist";

@implementation MSOffsiteContext

+ (MSOffsiteContext*) contextWithConsumerKey:(NSString*) consumerKey
							consumerSecret:(NSString*) consumerSecret
							tokenKey:(NSString*) oauthKey
							tokenSecret:(NSString*) oauthSecret
							urlScheme:(NSString*) urlScheme
{
	MSOffsiteContext *context = [[[MSOffsiteContext alloc] init] autorelease];
	context.consumerKey = consumerKey;
	context.consumerSecret = consumerSecret;
	context.oauthKey = oauthKey;
	context.oauthSecret = oauthSecret;
	context.urlScheme = urlScheme;
	
	if(context.oauthKey == nil)
	{
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:PREFS_FILE];
		NSString *accessTokenExists = [dict objectForKey:@"accessTokenKey"];
		NSString *requestTokenExists =  [dict objectForKey:@"requestTokenKey"];
		if(accessTokenExists)
		{
			NSString *accessTokenKey =  [dict objectForKey:@"accessTokenKey"];
			NSString *accessTokenSecret =  [dict objectForKey:@"accessTokenSecret"];
			context.accessToken = [[OAToken tokenWithKey:accessTokenKey secret:accessTokenSecret] retain]; 
			context.oauthKey = accessTokenKey;
			context.oauthSecret = accessTokenSecret;
		}
		else if(requestTokenExists)
		{
			NSString *requestTokenKey =  [dict objectForKey:@"requestTokenKey"];
			NSString *requestTokenSecret =  [dict objectForKey:@"requestTokenSecret"];
            if (requestTokenKey && requestTokenSecret) {
                context.requestToken = [OAToken tokenWithKey:requestTokenKey secret:requestTokenSecret]; 
                context.oauthKey = requestTokenKey;
                context.oauthSecret = requestTokenSecret;
            }
		}
	}
	else {
		context.accessToken = [[OAToken tokenWithKey:[oauthKey copy] secret: [oauthSecret copy]] retain]; 
	}

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

-(void) getRequestToken
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
	NSURL *url = [NSURL URLWithString:@"http://api.myspace.com/request_token"];
	request = [[OAMutableURLRequest alloc] initWithURL:url
											  consumer:consumer
												 token:nil   // we don't have a Token yet
												 realm:nil];  // our service provider doesn't specify a realm
	
	[request setHTTPMethod:@"GET"];
	OADataFetcher *fetcher = [[[OADataFetcher alloc] init] autorelease];
	/*
	[fetcher fetchDataWithRequest:request
						 delegate:self
				didFinishSelector:@selector(requestTokenTicket:didFinishWithData:)
				  didFailSelector:@selector(requestTokenTicket:didFinishWithError:)];
	
	 */
	[fetcher fetchDataWithRequest:request delegate:self didFinishSelector:@selector(requestTokenTicket:didFinishWithData:)
				  didFailSelector:@selector(requestTokenTicket:didFinishWithError:) makeAsync:NO];
}

-(void) getAccessToken
{
    
	if (consumer)
	{
		[consumer release];
		consumer = nil;
	}
		
	consumer = [[OAConsumer alloc] initWithKey:consumerKey secret:consumerSecret];
	
	NSURL *url = [NSURL URLWithString:@"http://api.myspace.com/access_token"];
    
	if(requestToken == nil)
	{
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:PREFS_FILE];
		NSString *requestTokenKey =  [dict objectForKey:@"requestTokenKey"];
		NSString *requestTokenSecret =  [dict objectForKey:@"requestTokenSecret"];
        if (requestTokenKey && requestTokenSecret)
            requestToken = [OAToken tokenWithKey:requestTokenKey secret:requestTokenSecret];
	}
	
	if(requestToken)
	{
		if (request)
		{
			[request release];
			request = nil;
		}
        //NSLog(@"Looks like we had a request token: %@ token: %@",consumer,requestToken);
		request = [[OAMutableURLRequest alloc] initWithURL:url
													   consumer:consumer
														  token:requestToken   // we don't have a Token yet
														  realm:nil];  // our service provider doesn't specify a realm
		
        [request setHTTPMethod:@"GET"];
		
		OADataFetcher *fetcher = [[[OADataFetcher alloc] init] autorelease];
		
		//[fetcher fetchDataWithRequest:request
		//					 delegate:self
		//			didFinishSelector:@selector(accessTokenTicket:didFinishWithData:)
		//			  didFailSelector:@selector(accessTokenTicket:didFinishWithError:)];
		
		 
		[fetcher fetchDataWithRequest:request delegate:self didFinishSelector:@selector(accessTokenTicket:didFinishWithData:)
					  didFailSelector:@selector(accessTokenTicket:didFinishWithError:) makeAsync:NO];
		
	}
}

-(void) logOut
{
	[accessToken release];
	accessToken = nil;
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:PREFS_FILE];
    [dict removeObjectForKey:@"accessTokenKey"];
    [dict removeObjectForKey:@"accessTokenSecret"];
    [dict writeToFile:PREFS_FILE atomically:YES];
}

- (BOOL) isLoggedIn
{
	if(self.accessToken)
	{
		//NSLog(@"Access.Token.Key: %@", accessToken.key);
		//NSLog(@"Access.Token.Secret: %@", accessToken.secret);
		return true;
	}
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:PREFS_FILE];
	NSString *accessTokenExists = [dict objectForKey:@"accessTokenKey"];
	if(accessTokenExists)
	{
		NSString *accessTokenKey =  [dict objectForKey:@"accessTokenKey"];
		NSString *accessTokenSecret =  [dict objectForKey:@"accessTokenSecret"];
		//NSLog(@"Access.Token.Key: %@", accessTokenKey);
		//NSLog(@"Access.Token.Secret: %@", accessTokenSecret);
		self.accessToken = [OAToken tokenWithKey:accessTokenKey secret:accessTokenSecret] ; 
		return true;
	}
	return false;
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
		 contentType:(NSString*) contentType delegate: (id<OAResponseDelegate>)delegate
{
	if(accessToken)
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
		consumer = [[OAConsumer alloc] initWithKey:consumerKey secret:consumerSecret] ;
		request = [[OAMutableURLRequest alloc] initWithURL:url
												  consumer:consumer
													 token:accessToken   
													 realm:nil] ;// our service provider doesn't specify a realm
		
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
}


//Private

- (void)requestTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
	//NSLog([[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);

	if (ticket.succeeded) {
		NSLog(@"MySpace ticket succeeded");
		NSString *responseBody = [[NSString alloc] initWithData:data
													   encoding:NSUTF8StringEncoding];
		requestToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
		[dict setObject:[requestToken key]  forKey:@"requestTokenKey"];
		[dict setObject:[requestToken secret] forKey:@"requestTokenSecret"];
        [dict writeToFile:PREFS_FILE atomically:YES];
		
		NSString *callBackUrl = [NSString stringWithFormat: @"%@://oauthcallback", self.urlScheme];
		NSString *permissions = @"AddPhotosAlbums|AllowActivitiesAutoPublish|ShowUpdatesFromFriends|UpdateMoodStatus";
        NSString *url = [NSString stringWithFormat:@"http://api.myspace.com/authorize?oauth_token=%@&oauth_callback=%@&myspaceid.permissions=%@",
						[requestToken.key encodedURLString], [callBackUrl encodedURLString], permissions];
		NSString *escaped = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		NSURL *authUrl = [NSURL URLWithString: escaped];
		[[UIApplication sharedApplication] openURL:authUrl];
        
        NSString *URLString = [authUrl absoluteString];
        [[NSUserDefaults standardUserDefaults] setObject:URLString forKey:@"url"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
		[responseBody release];
	}
}

-(void)requestTokenTicket:(OAServiceTicket *)ticket didFinishWithError:(NSError *)error{
	
	//NSLog(@"Error occurred with RequestToken call.");
	NSLog(@"Request did finish, but failed");
}


- (void)accessTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
	//NSLog([[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
	
	if (ticket.succeeded) {
		NSString *responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		accessToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
		[dict setObject:[accessToken key] forKey:@"accessTokenKey"];
		[dict setObject:[accessToken secret] forKey:@"accessTokenSecret"];
        [dict writeToFile:PREFS_FILE atomically:YES];
		[responseBody release];
	}
}

-(void) accessTokenTicket:(OAServiceTicket *)ticket didFinishWithError:(NSError *) error {
	NSLog(@"MySpace: access token had an error: %@", error);
}


@end

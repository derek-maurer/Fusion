//
//  MSOpenSearchApi.m
//  MySpaceID.Demo
//
//  Copyright MySpace, Inc. 2010. All rights reserved.
//

#import "MSOpenSearchApi.h"
#import "OAServiceTicket.h"
#import "NSString+URLEncoding.h"
#import "MSApi.h"
#import "MSConstants.h"

@implementation MSOpenSearchApi
@synthesize context;
@synthesize responseData;
@synthesize responseStatusCode;
@synthesize httpResponse;
@synthesize methodName;

+ (MSOpenSearchApi*) apiWithContext:(MSSecurityContext*) context
{
	MSOpenSearchApi *api = [[[MSOpenSearchApi alloc] init]autorelease];
	api.context = [context retain];
	api.methodName = nil;
	return api;
}

-(id) init
{
	if ((self = [super init]))
	{
		context = nil;
		methodName = nil;
		responseData = nil;
		httpResponse = nil;
		
	}
	
	return self;
}

- (void) dealloc{
	
	[context release];
	[methodName release];
	self.responseData = nil;
	[super dealloc];
}

- (void) clearData{
	// reserved function for future clean up
}

#pragma mark --People Search--

-(NSString*) searchPeople:(NSString*)searchTerms{
	return [self searchPeople:searchTerms queryParameters:nil];
}
-(NSString*) searchPeople:(NSString*)searchTerms queryParameters:(NSMutableDictionary*)queryParameters{
	NSString *urlString = MS_OPENSEARCH_PEOPLE;
	if(queryParameters == nil)
		queryParameters = [[NSMutableDictionary new] autorelease];
	[queryParameters setValue:searchTerms forKey:@"searchTerms"];
	return [self makeOpenSearchRequest:urlString queryParameters:queryParameters requestMethod:@"GET" requestBody:nil contentType:nil];
}
-(NSString*) searchPeople:(NSString*)searchTerms format:(NSString*)format count:(NSString*)count startPage:(NSString*)startPage
				 searchBy:(NSString*)searchBy gender:(NSString*)gender hasPhoto:(NSString*)hasPhoto minAge:(NSString*)minAge maxAge:(NSString*)maxAge
				 location:(NSString*)location distance:(NSString*)distance latitude:(NSString*)latitude longitude:(NSString*)longitude culture:(NSString*)culture
			  countryCode:(NSString*)countryCode{
	NSMutableDictionary *params = [self makeQueryDictionary:format count:count startPage:startPage searchBy:searchBy gender:gender 
											hasPhoto:hasPhoto minAge:minAge maxAge:maxAge location:location distance:distance latitude:latitude 
										   longitude:longitude culture:culture countryCode:countryCode sortBy:nil sortOrder:nil tag:nil videoMode:nil];
	return [self searchPeople:searchTerms queryParameters:params];
}

#pragma mark --Image Search--

-(NSString*) searchImages:(NSString*)searchTerms{
	return [self searchImages:searchTerms queryParameters:nil];
}
-(NSString*) searchImages:(NSString*)searchTerms queryParameters:(NSMutableDictionary*)queryParameters{
	NSString *urlString = MS_OPENSEARCH_IMAGES;
	if(queryParameters == nil)
		queryParameters = [[NSMutableDictionary new] autorelease];
	[queryParameters setValue:searchTerms forKey:@"searchTerms"];
	return [self makeOpenSearchRequest:urlString queryParameters:queryParameters requestMethod:@"GET" requestBody:nil contentType:nil];
}
-(NSString*) searchImages:(NSString*)searchTerms format:(NSString*)format count:(NSString*)count startPage:(NSString*)startPage
				  culture:(NSString*)culture sortBy:(NSString*)sortBy sortOrder:(NSString*)sortOrder{
	
	NSMutableDictionary *params = [self makeQueryDictionary:format count:count startPage:startPage searchBy:nil gender:nil 
												   hasPhoto:nil minAge:nil maxAge:nil location:nil distance:nil latitude:nil 
												  longitude:nil culture:culture countryCode:nil sortBy:sortBy sortOrder:sortOrder tag:nil videoMode:nil];
	return [self searchImages:searchTerms queryParameters:params];
}

#pragma mark --Video Search--

-(NSString*) searchVideos:(NSString*)searchTerms{
	return [self searchVideos:searchTerms queryParameters:nil];
}
-(NSString*) searchVideos:(NSString*)searchTerms queryParameters:(NSMutableDictionary*)queryParameters{
	NSString *urlString = MS_OPENSEARCH_VIDEOS;
	if(queryParameters == nil)
		queryParameters = [[NSMutableDictionary new] autorelease];
	[queryParameters setValue:searchTerms forKey:@"searchTerms"];
	return [self makeOpenSearchRequest:urlString queryParameters:queryParameters requestMethod:@"GET" requestBody:nil contentType:nil];
}
-(NSString*) searchVideos:(NSString*)searchTerms format:(NSString*)format count:(NSString*)count startPage:(NSString*)startPage
				  culture:(NSString*)culture tag:(NSString*)tag videoMode:(NSString*)videoMode{
	NSMutableDictionary *params = [self makeQueryDictionary:format count:count startPage:startPage searchBy:nil gender:nil 
												   hasPhoto:nil minAge:nil maxAge:nil location:nil distance:nil latitude:nil 
												  longitude:nil culture:culture countryCode:nil sortBy:nil sortOrder:nil tag:tag videoMode:videoMode];
	return [self searchImages:searchTerms queryParameters:params];
	
}

#pragma mark --Helper Methods--

- (NSMutableDictionary*) makeQueryDictionary:(NSString*)format count:(NSString*)count startPage:(NSString*)startPage
searchBy:(NSString*)searchBy gender:(NSString*)gender hasPhoto:(NSString*)hasPhoto minAge:(NSString*)minAge maxAge:(NSString*)maxAge
location:(NSString*)location distance:(NSString*)distance latitude:(NSString*)latitude longitude:(NSString*)longitude culture:(NSString*)culture
countryCode:(NSString*)countryCode sortBy:(NSString*)sortBy sortOrder:(NSString*)sortOrder tag:(NSString*)tag videoMode:(NSString*)videoMode{
	
	NSMutableDictionary *queryParams = [[NSMutableDictionary new] autorelease];
	if (format) {
		[queryParams setValue:format forKey:@"format"];
	}
	if (count) {
		[queryParams setValue:count forKey:@"count"];
	}
	if (startPage) {
		[queryParams setValue:startPage forKey:@"startPage"];
	}
	if (searchBy) {
		[queryParams setValue:searchBy forKey:@"searchBy"];
	}
	if (gender) {
		[queryParams setValue:gender forKey:@"gender"];
	}
	if (hasPhoto) {
		[queryParams setValue:hasPhoto forKey:@"hasPhoto"];
	}
	if (minAge) {
		[queryParams setValue:minAge forKey:@"minAge"];
	}
	if (maxAge) {
		[queryParams setValue:maxAge forKey:@"maxAge"];
	}
	if (location) {
		[queryParams setValue:location forKey:@"location"];
	}
	if (distance) {
		[queryParams setValue:distance forKey:@"distance"];
	}
	if (latitude) {
		[queryParams setValue:latitude forKey:@"latitude"];
	}
	if (longitude) {
		[queryParams setValue:longitude forKey:@"longitude"];
	}
	if (culture) {
		[queryParams setValue:culture forKey:@"culture"];
	}
	if (countryCode) {
		[queryParams setValue:countryCode forKey:@"countryCode"];
	}
	if (sortBy) {
		[queryParams setValue:sortBy forKey:@"sortBy"];
	}
	if (sortOrder) {
		[queryParams setValue:sortOrder forKey:@"sortOrder"];
	}
	if (tag) {
		[queryParams setValue:tag forKey:@"tag"];
	}
	if (videoMode) {
		[queryParams setValue:videoMode forKey:@"videoMode"];
	}
	return queryParams;
}

- (NSString*) makeOpenSearchRequest:(NSString*)uri queryParameters:(NSDictionary*)queryParams requestMethod:(NSString*)requestMethod
						requestBody:(NSData*)requestBody contentType:(NSString*)contentType{
	[self clearData];
	responseData = nil;
	if(context)
	{
		NSString *urlString = [uri copy];
		[uri release];
		NSString *queryString = @"?";
		NSString *amperSand = @"";
		for(id key in queryParams)
		{
			if(![queryString isEqualToString:@"?"])
				amperSand = @"&";
			queryString = [queryString stringByAppendingString:[NSString stringWithFormat:@"%@%@=%@", amperSand, key, [[queryParams objectForKey:key]encodedURLString ]]];
		}
		
		if([queryString isEqualToString:@"?"])
			queryString = @"";
		NSURL *url = [NSURL URLWithString: [urlString stringByAppendingString:queryString]];
		[context makeRequest:url method:requestMethod body:requestBody contentType:contentType delegate:self];
		
	}
	NSString* dataAsString = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];

	return [dataAsString autorelease];
}

#pragma mark -
#pragma mark OAResponseDelegate methods

- (void)apiTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
	NSString *dataOutput = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	self.httpResponse = (NSHTTPURLResponse*)[ticket response];
	self.responseStatusCode = [httpResponse statusCode];
	/*NSLog(@"UrlRequest: %@, Http Status Code: %@, Http Response: %@",  
		  [[[ticket response] URL] absoluteString], 
		  [NSString stringWithFormat:@"%d", responseStatusCode], 
		  dataOutput);*/
	if (ticket.succeeded) {
		self.responseData = data;
	}
	[dataOutput release];
	if(context.MSDelegate)
	{
		NSString* dataAsString = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];
		if ([context.MSDelegate respondsToSelector:@selector(api:didFinishMethod:withValue:withStatusCode:)]) { 
			[context.MSDelegate api:self didFinishMethod:self.methodName withValue:dataAsString withStatusCode:self.responseStatusCode];
		}
	}
}

- (void) apiTicket:(OAServiceTicket *)ticket didFinishWithError:(NSError *)error{
	/*NSString *message = [NSString stringWithFormat:@"Error! %@ %@",
						 [error localizedDescription],
						 [error localizedFailureReason]];
	//NSLog(@"%@", message);*/
	
	self.httpResponse = (NSHTTPURLResponse*)[ticket response];
	self.responseStatusCode = [httpResponse statusCode];
	
	if(context.MSDelegate)
	{
		if ([context.MSDelegate respondsToSelector:@selector(api:didFailMethod:withError:)]) {     
			[context.MSDelegate api:self didFailMethod:self.methodName withError:error];
		}
	}
}


@end

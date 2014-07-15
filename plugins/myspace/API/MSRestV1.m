//
//  MSMSRoaApi.m
//  MySpaceID
//
//  Copyright MySpace, Inc. 2010. All rights reserved.
//

#import "MSRestV1.h"
#import "OAServiceTicket.h"
#import "MSApi.h"
#import "MSConstants.h"

@implementation MSRestV1

@synthesize context;
@synthesize responseData;
@synthesize responseStatusCode;
@synthesize httpResponse;
@synthesize methodName;

NSString *methodCall = @"";


+ (MSRestV1*) apiWithContext:(MSSecurityContext*) context
{
	MSRestV1 *api = [[[MSRestV1 alloc] init]autorelease];
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

#pragma mark -
#pragma mark API Methods

- (void) clearData{
	// reserved function for future clean up
}

- (NSString*) getCurrentUser
{
	NSString *urlString = [NSString stringWithFormat:@"http://api.myspace.com/v1/user.json"];
	return [self makeRawV1Request:urlString queryParameters:nil requestMethod:@"GET" requestBody:nil contentType:nil];
	
}

- (NSString*) getUser:(NSInteger) userId
{
	
	NSString *urlString = [NSString stringWithFormat:MS_V1_USER_ID, [NSString stringWithFormat: @"%d", userId]];
	return [self makeRawV1Request:urlString queryParameters:nil requestMethod:@"GET" requestBody:nil contentType:nil];
}

- (NSString*) getMood:(NSInteger) userId
{
	
	NSString *sUserId = [NSString stringWithFormat: @"%d", userId];
	NSString *urlString = [NSString stringWithFormat:MS_V1_MOOD, sUserId];

	return [self makeRawV1Request:urlString queryParameters:nil requestMethod:@"GET" requestBody:nil contentType:nil];

}

- (NSString*) getMoodsList: (NSInteger) userId
{
	
	NSString *urlString = [NSString stringWithFormat:MS_V1_MOODS, [NSString stringWithFormat: @"%d", userId]];
	return [self makeRawV1Request:urlString queryParameters:nil requestMethod:@"GET" requestBody:nil contentType:nil];
	
}
- (void) setMoodStatus:(NSInteger)userId moodId:(NSInteger)moodId moodName:(NSString*)moodName moodPictureName:(NSString*)moodPictureName status:(NSString*) status
{
	
	NSString *urlString = [NSString stringWithFormat:MS_V1_STATUS, [NSString stringWithFormat: @"%d", userId]];
	NSString *body = @"";
	if(moodId && moodId > 0)
		body = [body stringByAppendingFormat:@"moodid=%@&", moodId];
	if(moodName && [moodName length] > 0)
		body = [body stringByAppendingFormat:@"moodName=%@&", moodName];
	if(moodPictureName && [moodPictureName length] >0)
		body = [body stringByAppendingFormat:@"moodPictureName=%@&", moodPictureName];
	if(status)
		body = [body stringByAppendingFormat:@"status=%@&", status];	
	
	body = [body substringToIndex:[body length] - 1];
	
	[self makeRawV1Request:urlString queryParameters:nil requestMethod:@"PUT" requestBody:[body dataUsingEncoding:NSASCIIStringEncoding]  contentType:nil];
}

- (NSString*) getAlbums:(NSInteger)userId
{
	return [self getAlbums:userId page:(NSInteger)nil pageSize: (NSInteger)nil];
}

- (NSString*) getAlbums:(NSInteger)userId page:(NSInteger)page pageSize:(NSInteger)pageSize
{	
	NSString *urlString = [NSString stringWithFormat:MS_V1_ALBUMS, [NSString stringWithFormat: @"%d", userId]];
	if(page && pageSize)
	{
		urlString = [urlString stringByAppendingString:[NSString stringWithFormat:@"?page=%@&pagesize=%@",  [NSString stringWithFormat: @"%d", page],  [NSString stringWithFormat: @"%d", pageSize]]];
	}
	
	return [self makeRawV1Request:urlString queryParameters:nil requestMethod:@"GET" requestBody:nil contentType:nil];
	
}
- (NSString*) getAlbum: (NSInteger) userId albumId: (NSInteger) albumId
{	
	NSString *urlString = [NSString stringWithFormat:MS_V1_ALBUM, [NSString stringWithFormat: @"%d", userId],
						   [NSString stringWithFormat: @"%d", albumId]];
	return [self makeRawV1Request:urlString queryParameters:nil requestMethod:@"GET" requestBody:nil contentType:nil];
	
}

- (NSString*) getFriends: (NSInteger) userId
{
	return [self getFriends:userId page:(NSInteger)nil pageSize:(NSInteger)nil];
}

- (NSString*) getFriends: (NSInteger) userId page:(NSInteger) page pageSize:(NSInteger) pageSize
{
	
	NSString *urlString = [NSString stringWithFormat:MS_V1_FRIENDS, [NSString stringWithFormat: @"%d", userId]];
	if(page && pageSize)
	{
		urlString = [urlString stringByAppendingString:[NSString stringWithFormat:@"?page=%@&pagesize=%@",  [NSString stringWithFormat: @"%d", page],  [NSString stringWithFormat: @"%d", pageSize]]];
	}
	return [self makeRawV1Request:urlString queryParameters:nil requestMethod:@"GET" requestBody:nil contentType:nil];
	
}
//Need to add another call for getFriends to support FriendList and FriendShow parameters
- (NSString*) getFriendStatus: (NSInteger) userId
{
	NSString *urlString = [NSString stringWithFormat:MS_V1_FRIEND_STATUS, [NSString stringWithFormat: @"%d", userId]];
	return [self makeRawV1Request:urlString queryParameters:nil requestMethod:@"GET" requestBody:nil contentType:nil];
	
}

- (NSString*) getFriendship: (NSInteger) userId friendIds: (NSArray*) friendIds
{
	
	NSString *friendsList = @"";
	for (NSString *friendId in friendIds) {
		friendsList = [friendsList stringByAppendingString:[NSString stringWithFormat:@"%@;", friendId]];
	}
	friendsList = [friendsList substringToIndex:[friendsList length] - 1];
	
	NSString *urlString = [NSString stringWithFormat:MS_V1_FRIENDSHIP, [NSString stringWithFormat: @"%d", userId],
						   friendsList];
	return [self makeRawV1Request:urlString queryParameters:nil requestMethod:@"GET" requestBody:nil contentType:nil];
}

- (NSString*) getPhotos: (NSInteger) userId
{
	return [self getPhotos:userId page:(NSInteger)nil pageSize:(NSInteger)nil];
}

- (NSString*) getPhotos: (NSInteger) userId page: (NSInteger) page pageSize: (NSInteger) pageSize
{
	
	NSString *urlString = [NSString stringWithFormat:MS_V1_PHOTOS, [NSString stringWithFormat: @"%d", userId]];
	if(page && pageSize)
	{
		urlString = [urlString stringByAppendingString:[NSString stringWithFormat:@"?page=%@&pagesize=%@",  [NSString stringWithFormat: @"%d", page],  [NSString stringWithFormat: @"%d", pageSize]]];
	}
	return [self makeRawV1Request:urlString queryParameters:nil requestMethod:@"GET" requestBody:nil contentType:nil];
	
}
- (NSString*) getPhoto: (NSInteger) userId photoId: (NSInteger) photoId
{
	
	NSString *urlString = [NSString stringWithFormat:MS_V1_PHOTO, [NSString stringWithFormat: @"%d", userId],
						   [NSString stringWithFormat: @"%d", photoId]];
	return [self makeRawV1Request:urlString queryParameters:nil requestMethod:@"GET" requestBody:nil contentType:nil];
	
}
- (NSString*) getFullProfile: (NSInteger) userId
{
	
	NSString *urlString = [NSString stringWithFormat:MS_V1_PROFILE, [NSString stringWithFormat: @"%d", userId],
						   @"full"];
	return [self makeRawV1Request:urlString queryParameters:nil requestMethod:@"GET" requestBody:nil contentType:nil];
	
}
- (NSString*) getBasicProfile: (NSInteger) userId
{
	
	NSString *urlString =[NSString stringWithFormat:MS_V1_PROFILE, [NSString stringWithFormat: @"%d", userId],
						  @"basic"];
	return [self makeRawV1Request:urlString queryParameters:nil requestMethod:@"GET" requestBody:nil contentType:nil];
}
- (NSString*) getExtendedProfile: (NSInteger) userId
{
	
	NSString *urlString =  [NSString stringWithFormat:MS_V1_PROFILE, [NSString stringWithFormat: @"%d", userId],
							@"extended"];
	return [self makeRawV1Request:urlString queryParameters:nil requestMethod:@"GET" requestBody:nil contentType:nil];
}
- (NSString*) getStatus: (NSInteger) userId
{
	
	NSString *urlString = [NSString stringWithFormat:MS_V1_STATUS, [NSString stringWithFormat: @"%d", userId]];
	return [self makeRawV1Request:urlString queryParameters:nil requestMethod:@"GET" requestBody:nil contentType:nil];
	
}
- (NSString*) getVideos: (NSInteger) userId
{
	return [self getVideos:userId page:(NSInteger)nil pageSize:(NSInteger)nil];
}
- (NSString*) getVideos: (NSInteger) userId page: (NSInteger) page pageSize: (NSInteger) pageSize
{
	NSString *urlString = [NSString stringWithFormat:MS_V1_VIDEOS, [NSString stringWithFormat: @"%d", userId]];
	if(page && pageSize)
	{
		urlString = [urlString stringByAppendingString:[NSString stringWithFormat:@"?page=%@&pagesize=%@",  [NSString stringWithFormat: @"%d", page],  [NSString stringWithFormat: @"%d", pageSize]]];
	}
	
	return [self makeRawV1Request:urlString queryParameters:nil requestMethod:@"GET" requestBody:nil contentType:nil];
	
}
- (NSString*) getVideo: (NSInteger) userId videoId: (NSInteger) videoId
{
	NSString *urlString = [NSString stringWithFormat:MS_V1_VIDEO, [NSString stringWithFormat: @"%d", userId],
						   [NSString stringWithFormat: @"%d", videoId]];
	return [self makeRawV1Request:urlString queryParameters:nil requestMethod:@"GET" requestBody:nil contentType:nil];
}




- (NSString*) getGlobalAppData
{
	return [self getGlobalAppData:nil];
}


- (NSString*) getGlobalAppData: (NSArray*) keys
{
	
	NSString *urlString = nil;
	if(keys)
	{
		NSString *keyList = @"";
		for (NSString *key in keys) {
			keyList = [keyList stringByAppendingString:[NSString stringWithFormat:@"%@;", key]];
		}
		keyList = [keyList substringToIndex:[keyList length] - 1];
		urlString =[NSString stringWithFormat:MS_V1_GLOBAL_APP_DATA_KEYS, keyList];
	}
	else
	{
		urlString = MS_V1_GLOBAL_APP_DATA;
	}
	return [self makeRawV1Request:urlString queryParameters:nil requestMethod:@"GET" requestBody:nil contentType:nil];
	
}


- (NSString*) addGlobalAppData: (NSDictionary*) globalAppDataPairs
{
	
	NSString *urlString = [NSString stringWithFormat:@"http://api.myspace.com/v1/appdata/global.xml"];
	NSString *body = @"";
	for (id key in globalAppDataPairs) {
		
		//NSLog(@"key: %@, value: %@", key, [globalAppDataPairs objectForKey:key]);
		body = [body stringByAppendingFormat:@"%@=%@&", key, [globalAppDataPairs objectForKey:key]];
		
	}
	
	body = [body substringToIndex:[body length] - 1];
	return [self makeRawV1Request:urlString queryParameters:nil requestMethod:@"PUT" requestBody:[body dataUsingEncoding:NSASCIIStringEncoding]  contentType:nil];
}


- (NSString*) deleteGlobalAppData: (NSArray*) keys
{
	NSString *appendUri = @"";
	for (id key in keys) {
		appendUri = [appendUri stringByAppendingFormat:@"%@;", key];		
	}
	appendUri = [appendUri substringToIndex:[appendUri length] - 1];
	NSString *urlString = [NSString stringWithFormat:MS_V1_GLOBAL_APP_DATA_KEYS, appendUri];
	return [self makeRawV1Request:urlString queryParameters:nil requestMethod:@"DELETE" requestBody:nil contentType:nil];
	
}
- (NSString*) addUserAppData: (NSInteger) userId userAppDataPairs: (NSDictionary*) userAppDataPairs
{	
	NSString *urlString = [NSString stringWithFormat:MS_V1_USER_APP_DATA,  [NSString stringWithFormat: @"%d", userId]];
	NSString *body = @"";
	for (id key in userAppDataPairs) {
		body = [body stringByAppendingFormat:@"%@=%@&", key, [userAppDataPairs objectForKey:key]];
	}
	body = [body substringToIndex:[body length] - 1];
	return [self makeRawV1Request:urlString queryParameters:nil requestMethod:@"PUT" requestBody:[body dataUsingEncoding:NSASCIIStringEncoding] contentType:nil];
}
- (NSString*) deleteUserAppData: (NSInteger) userId keys: (NSArray*) keys
{	
	NSString *appendUri = @"";
	for (id key in keys) {
		appendUri = [appendUri stringByAppendingFormat:@"%@;", key];
	}
	appendUri = [appendUri substringToIndex:[appendUri length] - 1];
	NSString *urlString = [NSString stringWithFormat:MS_V1_USER_APP_DATA_KEYS,  [NSString stringWithFormat: @"%d", userId],  appendUri];
	return [self makeRawV1Request:urlString queryParameters:nil requestMethod:@"DELETE" requestBody:nil contentType:nil];
	
}

- (NSString*) getUserAppData: (NSInteger) userId
{
	return [self getUserAppData:userId keys:nil];
}

- (NSString*) getUserAppData: (NSInteger) userId keys: (NSArray*) keys
{
	NSString *urlString = nil;
	if(keys)
	{
		NSString *keyList = @"";
		for (NSString *key in keys) {
			keyList = [keyList stringByAppendingString:[NSString stringWithFormat:@"%@;", key]];
		}
		keyList = [keyList substringToIndex:[keyList length] - 1];
		urlString = [NSString stringWithFormat:MS_V1_USER_APP_DATA_KEYS, [NSString stringWithFormat: @"%d", userId] ,keyList];
	}
	else
	{
		urlString = [NSString stringWithFormat:MS_V1_USER_APP_DATA, [NSString stringWithFormat: @"%d", userId]];
	}
	
	return [self makeRawV1Request:urlString queryParameters:nil requestMethod:@"GET" requestBody:nil contentType:nil];
	
}
- (NSString*) getFriendAppData: (NSInteger) userId
{
	return [self getFriendAppData:userId keys:nil];
}
- (NSString*) getFriendAppData: (NSInteger) userId keys: (NSArray*) keys
{
	NSString *urlString = nil;
	if(keys)
	{
		NSString *keyList = @"";
		for (NSString *key in keys) {
			keyList = [keyList stringByAppendingString:[NSString stringWithFormat:@"%@;", key]];
		}
		keyList = [keyList substringToIndex:[keyList length] - 1];
		urlString = [NSString stringWithFormat:MS_V1_USER_FRIENDS_APP_DATA_KEYS, [NSString stringWithFormat: @"%d", userId] ,keyList];
	}
	else
	{
		urlString = [NSString stringWithFormat:MS_V1_USER_FRIENDS_APP_DATA, [NSString stringWithFormat: @"%d", userId]];
	}
	return [self makeRawV1Request:urlString queryParameters:nil requestMethod:@"GET" requestBody:nil contentType:nil];
	
}
- (NSString*) getIndicators: (NSInteger) userId
{
	NSString *urlString = [NSString stringWithFormat:MS_V1_MOODS, [NSString stringWithFormat: @"%d", userId]];
	return [self makeRawV1Request:urlString queryParameters:nil requestMethod:@"GET" requestBody:nil contentType:nil];
}

- (void) sendNotification: (NSInteger) appId recipients: (NSArray*) recipients content: (NSString*) content button0Surface:(NSString*) button0Surface button0Label:(NSString*) button0Label button1Surface:(NSString*) button1Surface button1Label:(NSString*) button1Label mediaItem: (NSString*) mediaItem
{
	
}

#pragma mark --Activities--

- (NSString*) getActivities:(NSString*) userId activityTypes:(NSString*)activityTypes	extensions:(NSString*)extensions
						  composite:(NSString*)composite culture:(NSString*)culture datetime:(NSString*)dateTime	pageSize:(NSString*)pageSize{
	NSString *urlString = [NSString stringWithFormat:MS_V1_ACTIVITIES, userId];
	NSMutableDictionary *params = [self makeQueryDictionary:nil format:nil activityTypes:activityTypes
												 extensions:extensions composite:composite culture:culture datetime:dateTime pageSize:pageSize];
	return [self makeRawV1Request:urlString queryParameters:params requestMethod:@"GET" requestBody:nil contentType:nil];
}
- (NSString*) getFriendActivities:(NSString*) userId activityTypes:(NSString*)activityTypes	extensions:(NSString*)extensions
						composite:(NSString*)composite culture:(NSString*)culture datetime:(NSString*)dateTime	pageSize:(NSString*)pageSize{
	NSString *urlString = [NSString stringWithFormat:MS_V1_FRIEND_ACTIVITIES, userId];
	NSMutableDictionary *params = [self makeQueryDictionary:nil format:nil activityTypes:activityTypes
												 extensions:extensions composite:composite culture:culture datetime:dateTime pageSize:pageSize];
	return [self makeRawV1Request:urlString queryParameters:params requestMethod:@"GET" requestBody:nil contentType:nil];
}

#pragma mark --Raw Requests

- (NSString*) makeRawV1Request:(NSString*)uri queryParameters:(NSDictionary*)queryParams requestMethod:(NSString*)requestMethod
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
			queryString = [queryString stringByAppendingString:[NSString stringWithFormat:@"%@%@=%@", amperSand, key, [queryParams objectForKey:key]]];
		}
		
		if([queryString isEqualToString:@"?"])
			queryString = @"";
		NSURL *url = [NSURL URLWithString: [urlString stringByAppendingString:queryString]];
		[context makeRequest:url method:requestMethod body:requestBody contentType:contentType delegate:self];
		
	}
	NSString* dataAsString = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];
	
	return [dataAsString autorelease];
}

- (NSMutableDictionary*) makeQueryDictionary:(NSArray*) fields 
									  format:(NSString*)format activityTypes:(NSString*)activityTypes extensions:(NSString*)extensions
								   composite:(NSString*)composite culture:(NSString*)culture datetime:(NSString*)dateTime pageSize:(NSString*)pageSize {
	NSMutableDictionary *queryParams = [[NSMutableDictionary new] autorelease];
	NSString *fieldList = nil;
	if (fields) {
		fieldList = @"";
		for (NSString *field in fields) {
			fieldList = [fieldList stringByAppendingString:[NSString stringWithFormat:@"%@,", field]];
		}
		fieldList = [fieldList substringToIndex:[fieldList length] - 1];
	}
	
	if (fieldList) {
		[queryParams setValue:fieldList forKey:@"fields"];
	}
	if (format) {
		[queryParams setValue:format forKey:@"format"];
	}
	if (pageSize) {
		[queryParams setValue:pageSize forKey:@"page_size"];
	}
	if (extensions) {
		[queryParams setValue:extensions forKey:@"extensions"];
	}
	if (activityTypes) {
		[queryParams setValue:activityTypes forKey:@"activityTypes"];
	}
	if (composite) {
		[queryParams setValue:composite forKey:@"composite"];

	}
	if (culture) {
		[queryParams setValue:culture forKey:@"culture"];
	}
	if (dateTime) {
		[queryParams setValue:dateTime forKey:@"dateTime"];
	}
	return queryParams;
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
	
	/*NSString *message = [NSString stringWithFormat:@"Http Response Error %@ %@",
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




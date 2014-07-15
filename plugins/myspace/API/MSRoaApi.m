//
//  MSRoaApi.m
//  MySpaceID.Demo
//
//  Copyright MySpace, Inc. 2010. All rights reserved.
//

#import "MSRoaApi.h"
#import "OAServiceTicket.h"
#import "NSString+URLEncoding.h"
#import "SBJSON.h"
#import "MSApi.h"
#import "MSConstants.h"

@implementation MSRoaApi
@synthesize context;
@synthesize responseData;
@synthesize responseStatusCode;
@synthesize httpResponse;
@synthesize methodName;

+ (MSRoaApi*) apiWithContext:(MSSecurityContext*) context
{
	MSRoaApi *api = [[[MSRoaApi alloc] init]autorelease];
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
	self.responseData = nil;
	[responseData release];
	[methodName release];
	[super dealloc];
}

- (void) clearData{
	// reserved function for future clean up
}

#pragma mark --
#pragma mark API Methods

#pragma mark --
#pragma mark MediaItems


- (NSString*) getMediaItems:(NSString*)personId albumId:(NSString*)albumId queryParameters:(NSDictionary*)queryParameters{
		NSString *urlString = [NSString stringWithFormat:MS_ROA_MEDIA_ITEMS, personId, MS_SELECTOR_SELF, albumId];
		return [self makeRawOSRequest:urlString queryParameters:queryParameters requestMethod:@"GET" requestBody:nil contentType:nil];
}

- (NSString*) getFriendMediaItems:(NSString*)personId albumId:(NSString*)albumId queryParameters:(NSDictionary*)queryParameters{
	NSString *urlString = [NSString stringWithFormat:MS_ROA_MEDIA_ITEMS, personId, MS_SELECTOR_FRIENDS, albumId];
	return [self makeRawOSRequest:urlString queryParameters:queryParameters requestMethod:@"GET" requestBody:nil contentType:nil];
}

- (NSString*) getMediaItem:(NSString*)personId albumId:(NSString*)albumId mediaItemId:(NSString*)mediaItemId 
		   queryParameters:(NSDictionary*)queryParameters{
	NSString *urlString = [NSString stringWithFormat:MS_ROA_MEDIA_ITEMS, personId, MS_SELECTOR_SELF, albumId];
	urlString = [NSString stringWithFormat:@"%@/%@", urlString, mediaItemId];
	return [self makeRawOSRequest:urlString queryParameters:queryParameters requestMethod:@"GET" requestBody:nil contentType:nil];		

	
}

- (NSString*) getSupportedVideoCategories:(NSString*)personId queryParameters:(NSDictionary*)queryParameters{
	NSString *urlString = [NSString stringWithFormat:MS_ROA_MEDIA_ITEMS, personId, @"@videos", @"@supportedCategories"];
	return [self makeRawOSRequest:urlString queryParameters:queryParameters requestMethod:@"GET" requestBody:nil contentType:nil];		
}

- (NSString*) updateMediaItem:(NSString*)personId albumId:(NSString*)albumId mediaItemId:(NSString*)mediaItemId
						title:(NSString*)title queryParameters:(NSDictionary*)queryParameters{
	SBJSON *json = [[SBJSON alloc] init];
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	[dict setValue:title forKey:@"title"];
	NSString *body = [json stringWithObject:dict];
	//NSLog(@"%@",body);
	NSString *urlString = [NSString stringWithFormat:MS_ROA_MEDIA_ITEMS, personId, MS_SELECTOR_SELF, albumId];
	urlString = [NSString stringWithFormat:@"%@/%@", urlString, mediaItemId];
	[json	 release];
	[dict release];
	return [self makeRawOSRequest:urlString queryParameters:nil 
					requestMethod:@"POST" requestBody:[body dataUsingEncoding:NSASCIIStringEncoding]  contentType:@"application/json"];
	
		
	
}

- (NSString*) addPhoto:(NSString*)personId albumId:(NSString*)albumId 
			   caption:(NSString*)caption photoData:(NSData*)photoData imageType:(NSString*) imageType 
	   queryParameters:(NSDictionary*)queryParameters;{

	if(queryParameters == nil)
		queryParameters = [[NSMutableDictionary new] autorelease];
	[queryParameters setValue:@"IMAGE" forKey:@"type"];
	[queryParameters setValue:[caption encodedURLParameterString] forKey:@"CAPTION"];
	if(imageType == nil)
		imageType = @"image/jpeg";
	NSString *urlString = [NSString stringWithFormat:MS_ROA_MEDIA_ITEMS, personId, MS_SELECTOR_SELF, albumId];
	return [self makeRawOSRequest:urlString queryParameters:queryParameters 
					requestMethod:@"POST" requestBody:photoData  contentType:imageType];
}

- (NSString*) addVideo:(NSString*)personId albumId:(NSString*)albumId 
			   caption:(NSString*)caption videoData:(NSData*)videoData videoType:(NSString*) videoType 
		   description:(NSString*) description tags:(NSArray*)tags msCategories:(NSString*)msCategories
			  language:(NSString*) language queryParameters:(NSDictionary*)queryParameters{
	if(queryParameters == nil)
		queryParameters = [[NSMutableDictionary new] autorelease];
	NSString *tagsList = [[NSString new] autorelease];
	if (tags) {
		tagsList = @"";
		for (NSString *tag in tags) {
			tagsList = [tagsList stringByAppendingString:[NSString stringWithFormat:@"%@,", tag]];
		}
		tagsList = [tagsList substringToIndex:[tagsList length] - 1];
	}
	if (tagsList) {
		[queryParameters setValue:tagsList forKey:@"tags"];
	}
	[queryParameters setValue:@"VIDEO" forKey:@"type"];
	[queryParameters setValue:[caption encodedURLParameterString] forKey:@"CAPTION"];
	[queryParameters setValue:[description encodedURLParameterString] forKey:@"description"];
	[queryParameters setValue:[msCategories encodedURLParameterString] forKey:@"msCategories"];
	if(language)
		[queryParameters setValue:[language encodedURLParameterString] forKey:@"language"];
	else {
		[queryParameters setValue:@"en-us" forKey:@"language"];
	}
	if(videoType == nil)
		videoType = @"video/quicktime";

	NSString *urlString = [NSString stringWithFormat:MS_ROA_MEDIA_ITEMS, personId, MS_SELECTOR_SELF, albumId];
	return [self makeRawOSRequest:urlString queryParameters:queryParameters 
					requestMethod:@"POST" requestBody:videoData  contentType: videoType];
	
}

#pragma mark --MediaItemComments--

- (NSString*) getMediaItemComments:(NSString*)personId albumId:(NSString*)albumId mediaItemId:(NSString*)mediaItemId
				   queryParameters:(NSDictionary*)queryParameters{
	NSString *urlString = [NSString stringWithFormat:MS_ROA_MEDIA_ITEMS_COMMENTS, personId, albumId, mediaItemId];
	return [self makeRawOSRequest:urlString queryParameters:queryParameters requestMethod:@"GET" requestBody:nil contentType:nil];
}

#pragma mark --
#pragma mark People Data



- (NSString*) getPerson:(NSString*)personId queryParameters:(NSDictionary*)queryParameters
{
	NSString *urlString = [NSString stringWithFormat:MS_ROA_PEOPLE, personId, MS_SELECTOR_SELF];
	return [self makeRawOSRequest:urlString queryParameters:queryParameters requestMethod:@"GET" requestBody:nil contentType:nil];
}

- (NSString*) getFriends:(NSString*)personId queryParameters:(NSDictionary*)queryParameters
{
	NSString *urlString = [NSString stringWithFormat:MS_ROA_PEOPLE, personId, MS_SELECTOR_FRIENDS];
	return [self makeRawOSRequest:urlString queryParameters:queryParameters requestMethod:@"GET" requestBody:nil contentType:nil];
}

- (NSString*) getGroup:(NSString*)personId groupId:(NSString*)groupId queryParameters:(NSDictionary*)queryParameters{
	
	NSString *urlString = [NSString stringWithFormat:MS_ROA_PEOPLE, personId, groupId];
	return [self makeRawOSRequest:urlString queryParameters:queryParameters requestMethod:@"GET" requestBody:nil contentType:nil];

}

#pragma mark --
#pragma mark Albums

- (NSString*) getAlbums:(NSString*)personId queryParameters:(NSDictionary*)queryParameters{
	
	NSString *urlString = [NSString stringWithFormat:MS_ROA_ALBUMS, personId, MS_SELECTOR_SELF];
	return [self makeRawOSRequest:urlString queryParameters:queryParameters requestMethod:@"GET" requestBody:nil contentType:nil];	
}
- (NSString*) addAlbum:(NSString*)personId caption:(NSString*)caption location:(NSString*)location 
	   queryParameters:(NSDictionary*)queryParameters{
	
	SBJSON *json = [[SBJSON alloc] init];
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	if(caption)
		[dict setValue:caption forKey:@"caption"];
	if(location)
		[dict setValue:location forKey:@"location"];
	
	NSString *body = [json stringWithObject:dict];
	//NSLog(@"%@",body);
	NSString *urlString = [NSString stringWithFormat:MS_ROA_ALBUMS, personId, MS_SELECTOR_SELF];
	[json	 release];
	[dict release];
	return [self makeRawOSRequest:urlString queryParameters:nil requestMethod:@"PUT" requestBody:[body dataUsingEncoding:NSASCIIStringEncoding]  
					  contentType:@"application/json"];
		
		
	
}
- (NSString*) updateAlbum:(NSString*)personId albumId:(NSString*)albumId caption:(NSString*)caption location:(NSString*)location
		  queryParameters:(NSDictionary*)queryParameters{
	SBJSON *json = [[SBJSON alloc] init];
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	if(caption)
		[dict setValue:caption forKey:@"caption"];
	if(location)
		[dict setValue:location forKey:@"location"];
	[dict setValue:albumId forKey:@"id"];
	[dict setValue:0 forKey:@"mediaItemCount"];
	NSString *body = [json stringWithObject:dict];
	//NSLog(@"%@",body);
	NSString *urlString = [NSString stringWithFormat:MS_ROA_ALBUMS, personId, MS_SELECTOR_SELF];
	urlString = [NSString stringWithFormat:@"%@/%@", urlString, albumId];
	[json	 release];
	[dict release];
	return [self makeRawOSRequest:urlString queryParameters:nil requestMethod:@"POST" 
					  requestBody:[body dataUsingEncoding:NSASCIIStringEncoding]  
					  contentType:@"application/json"];		
		
}

#pragma mark --Activites--

- (NSString*) getActivities:(NSString*)personId appId:(NSString*)appId queryParameters:(NSDictionary*)queryParameters{
	NSString *urlString = [NSString stringWithFormat:MS_ROA_ACTIVITIES, personId, MS_SELECTOR_SELF];
	if(appId)
		urlString = [NSString stringWithFormat:@"%@/%@", urlString, appId]; 
	
	return [self makeRawOSRequest:urlString queryParameters:queryParameters requestMethod:@"GET" requestBody:nil contentType:nil];
}
- (NSString*) getFriendActivities:(NSString*)personId appId:(NSString*)appId queryParameters:(NSDictionary*)queryParameters{
	NSString *urlString = [NSString stringWithFormat:MS_ROA_ACTIVITIES, personId, MS_SELECTOR_FRIENDS];
	if(appId)
		urlString = [NSString stringWithFormat:@"%@/%@", urlString, appId]; 
	
	return [self makeRawOSRequest:urlString queryParameters:queryParameters requestMethod:@"GET" requestBody:nil contentType:nil];
}

- (NSString*) createActivity:(NSString*)templateId title:(NSString*)title body:(NSString*)body templateParameters:(NSArray*)templateParameters activityId:(NSString*)activityId
			 queryParameters:(NSDictionary*)queryParameters{
	SBJSON *json = [[SBJSON alloc] init];
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	[dict setValue:activityId forKey:@"id"];
	[dict setValue:title forKey:@"title"];
	[dict setValue:body forKey:@"body"];
	[dict setValue:templateId forKey:@"titleId"];
	NSDictionary *params = [NSDictionary dictionaryWithObject:templateParameters forKey:@"msParameters"];
	[dict setValue:params forKey:@"templateParams"];
	NSString *requestBody = [json stringWithObject:dict];
	//NSLog(@"%@", requestBody);
	NSString *urlString = [NSString stringWithFormat:MS_ROA_ACTIVITIES, MS_SELECTOR_ME, MS_SELECTOR_SELF];
	urlString = [NSString stringWithFormat:@"%@/@app", urlString];
	[json	 release];
	[dict release];
	return [self makeRawOSRequest:urlString queryParameters:queryParameters requestMethod:@"POST" 
					  requestBody:[requestBody dataUsingEncoding:NSASCIIStringEncoding]  
					  contentType:@"application/json"];		
	
	
}

#pragma mark --AppData--

- (NSString*) getAppData:(NSString*)personId selector:(NSString*)selector appId:(NSString*)appId queryParameters:(NSDictionary*)queryParameters{
	NSString *urlString = [NSString stringWithFormat:MS_ROA_APPDATA, personId, selector, appId];
	return [self makeRawOSRequest:urlString queryParameters:queryParameters requestMethod:@"GET" requestBody:nil contentType:nil];	
}

- (NSString*) addAppData:(NSString*)personId userId:(NSString*)userId selector:(NSString*)selector appId:(NSString*)appId keys:(NSArray*)keys 
				  values:(NSArray*)values queryParameters:(NSDictionary*)queryParameters{

	NSString *urlString = [NSString stringWithFormat:MS_ROA_APPDATA, personId, selector, appId];
	if(queryParameters ==nil)
		queryParameters= [[NSMutableDictionary new] autorelease];
	NSString *fieldList = nil;
	if (keys) {
		fieldList = @"";
		for (NSString *key in keys) {
			fieldList = [fieldList stringByAppendingString:[NSString stringWithFormat:@"%@,", key]];
		}
		fieldList = [fieldList substringToIndex:[fieldList length] - 1];
	}
	if (fieldList) {
		[queryParameters setValue:fieldList forKey:@"fields"];
	}
	SBJSON *json = [[SBJSON alloc] init];
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	[dict setValue:userId forKey:@"userId"];

	NSMutableArray *appDataArray = [NSMutableArray new];
	NSUInteger i, count = [values count];
	for (i=0; i<count; i++) {
		NSArray *array = [NSArray arrayWithObjects:[keys objectAtIndex:i], [values objectAtIndex:i], nil];
		NSArray *array2 = [NSArray arrayWithObjects:@"key", @"value", nil];
		NSDictionary *newAppData = [NSDictionary dictionaryWithObjects:array									
															   forKeys:array2];
		[appDataArray addObject:newAppData];
	}
	[dict setValue:appDataArray	forKey:@"appData"];
	NSString *requestBody = [json stringWithObject:dict];
	//NSLog(@"%@",requestBody);
	[appDataArray release];
	[json	 release];
	[dict release];
	return [self makeRawOSRequest:urlString queryParameters:queryParameters requestMethod:@"POST" 
					  requestBody:[requestBody dataUsingEncoding:NSASCIIStringEncoding]  
					  contentType:@"application/json"];		
	
}

- (NSString*) deleteAppData:(NSString*)personId selector:(NSString*)selector appId:(NSString*)appId keys:(NSArray*)keys queryParameters:(NSDictionary*)queryParameters{
	
	NSString *urlString = [NSString stringWithFormat:MS_ROA_APPDATA, personId, selector, appId];
	if(queryParameters ==nil)
		queryParameters= [[NSMutableDictionary new] autorelease];
	NSString *fieldList = nil;
	if (keys) {
		fieldList = @"";
		for (NSString *key in keys) {
			fieldList = [fieldList stringByAppendingString:[NSString stringWithFormat:@"%@,", key]];
		}
		fieldList = [fieldList substringToIndex:[fieldList length] - 1];
	}
	if (fieldList) {
		[queryParameters setValue:fieldList forKey:@"fields"];
	}
	
	return [self makeRawOSRequest:urlString queryParameters:queryParameters requestMethod:@"DELETE" requestBody:nil contentType:nil];		
}

#pragma mark --StatusMood--
- (NSString*) getSupportedMoods:(NSString*)personId queryParameters:(NSDictionary*)queryParameters{
	NSString *urlString = [NSString stringWithFormat:MS_ROA_STATUSMOOD, personId, @"@supportedMood"];
	return [self makeRawOSRequest:urlString queryParameters:queryParameters requestMethod:@"GET" 
					  requestBody:nil 
					  contentType:nil];	
}
- (NSString*) getSingleMood:(NSString*)personId moodId:(NSString*)moodId queryParameters:(NSDictionary*)queryParameters{
	NSString *urlString = [NSString stringWithFormat:MS_ROA_STATUSMOOD, personId, 
						   [NSString stringWithFormat:@"%@/%@", @"@supportedMood",moodId]];
	return [self makeRawOSRequest:urlString queryParameters:queryParameters requestMethod:@"GET" 
					  requestBody:nil 
					  contentType:nil];	
}
- (NSString*) getPersonMoodStatus:(NSString*)personId queryParameters:(NSDictionary*)queryParameters{
	self.methodName = @"getPersonMoodStatus";
	NSString *urlString = [NSString stringWithFormat:MS_ROA_STATUSMOOD, personId, MS_SELECTOR_SELF];
	return [self makeRawOSRequest:urlString queryParameters:queryParameters requestMethod:@"GET" 
					  requestBody:nil 
					  contentType:nil];
}

- (NSString*) getFriendsMoodStatus:(NSString*)personId includeHistory:(BOOL)includeHistory 
				 queryParameters:(NSDictionary*)queryParameters{
	NSString *urlString = [NSString stringWithFormat:MS_ROA_STATUSMOOD, personId, MS_SELECTOR_FRIENDS];
	if(includeHistory)
	{
		urlString = [NSString stringWithFormat:@"%@/history", urlString];
	}
	return [self makeRawOSRequest:urlString queryParameters:queryParameters requestMethod:@"GET" 
					  requestBody:nil 
					  contentType:nil];
}
- (NSString*) getFriendMoodStatus:(NSString*)personId friendId:(NSString*)friendId includeHistory:(BOOL)includeHistory 
				queryParameters:(NSDictionary*)queryParameters{
	NSString *urlString = [NSString stringWithFormat:MS_ROA_STATUSMOOD, personId, MS_SELECTOR_FRIENDS];
	urlString = [NSString stringWithFormat:@"%@/%@", urlString, friendId];
	if(includeHistory)
	{
		urlString = [NSString stringWithFormat:@"%@/history", urlString];
	}
	return [self makeRawOSRequest:urlString queryParameters:queryParameters requestMethod:@"GET" 
									  requestBody:nil 
									  contentType:nil];
}
- (NSString*) updatePersonMoodStatus:(NSString*)personId moodName:(NSString*)moodName status:(NSString*)status
				latitude:(NSString*)latitude longitude:(NSString*)longitude queryParameters:(NSDictionary*)queryParameters{
	NSString *urlString = [NSString stringWithFormat:MS_ROA_STATUSMOOD, personId, MS_SELECTOR_SELF];
	SBJSON *json = [[SBJSON alloc] init];
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	if(latitude && longitude)
	{
		NSMutableDictionary *geoDict = [NSMutableDictionary new];
		[geoDict setValue:latitude forKey:@"latitude"];
		[geoDict setValue:longitude forKey:@"longitude"];
		[dict setValue:geoDict forKey:@"currentLocation"];
	}
	
	[dict setValue:moodName forKey:@"moodName"];
	[dict setValue:status forKey:@"status"];
					
	NSString *requestBody = [json stringWithObject:dict];
	//NSLog(@"%@",requestBody);
	[dict release];
	[json	 release];
	return [self makeRawOSRequest:urlString queryParameters:queryParameters requestMethod:@"PUT" 
					  requestBody:[requestBody dataUsingEncoding:NSASCIIStringEncoding]  
					  contentType:@"application/json"];		
	
}

#pragma mark --Groups--
- (NSString*) getGroups:(NSString*)personId queryParameters:(NSDictionary*)queryParameters{
	NSString *urlString = [NSString stringWithFormat:MS_ROA_GROUPS, personId];
	return [self makeRawOSRequest:urlString queryParameters:queryParameters requestMethod:@"GET" 
					  requestBody:nil 
					  contentType:nil];	
}

#pragma mark --StatusMood Comments--

- (NSString*) getStatusMoodComments:(NSString*)personId statusId:(NSString*)statusId queryParameters:(NSDictionary*)queryParameters{
	
	NSString *urlString = [NSString stringWithFormat:MS_ROA_STATUSMOOD_COMMENTS, personId, MS_SELECTOR_SELF];
	if(queryParameters == nil)
		queryParameters	= [[NSMutableDictionary new] autorelease];
	else {
		queryParameters = [NSMutableDictionary dictionaryWithDictionary:queryParameters];
	}
	[queryParameters setValue:statusId forKey:@"statusId"];
	return [self makeRawOSRequest:urlString queryParameters:queryParameters requestMethod:@"GET" 
					  requestBody:nil 
					  contentType:nil];
}

- (NSString*) addStatusMoodComment:(NSString*) personId statusId:(NSString*)statusId body:(NSString*)body 
				 queryParameters:(NSDictionary*)queryParameters{
	
	NSString *urlString = [NSString stringWithFormat:MS_ROA_STATUSMOOD_COMMENTS, personId, MS_SELECTOR_SELF];
	if(queryParameters == nil)
		queryParameters	= [[NSMutableDictionary new] autorelease];
	else {
		queryParameters = [NSMutableDictionary dictionaryWithDictionary:queryParameters];
	}

	[queryParameters setValue:statusId forKey:@"statusId"];
	SBJSON *json = [[SBJSON alloc] init];
	NSMutableDictionary *dict = [NSMutableDictionary new];

	[dict setValue:body forKey:@"body"];
	
	NSString *requestBody = [json stringWithObject:dict];
	//NSLog(@"%@",requestBody);
	[dict release];
	[json	 release];
	return [self makeRawOSRequest:urlString queryParameters:queryParameters requestMethod:@"POST" 
					  requestBody:[requestBody dataUsingEncoding:NSASCIIStringEncoding]  
					  contentType:@"application/json"];		
	
}

#pragma mark --Notifications--

- (NSString*) sendNotification:(NSString*)personId recipientIds:(NSArray*)recipientIds mediaItems:(NSArray*)mediaItems 
		  templateParameters:(NSArray*)templateParameters queryParameters:(NSDictionary*)queryParameters{
	
	NSString *urlString = [NSString stringWithFormat:MS_ROA_NOTIFICATIONS, personId, MS_SELECTOR_SELF];
		
	SBJSON *json = [[SBJSON alloc] init];
	NSMutableDictionary *dict = [NSMutableDictionary new];
	[dict setValue:recipientIds forKey:@"recipientIds"];
	[dict setValue:mediaItems forKey:@"mediaItems"];
	[dict setValue:templateParameters forKey:@"templateParameters"];
	
	NSString *requestBody = [json stringWithObject:dict];
	//NSLog(@"%@",requestBody);
	[dict release];
	[json	 release];
	return [self makeRawOSRequest:urlString queryParameters:queryParameters requestMethod:@"POST" 
					  requestBody:[requestBody dataUsingEncoding:NSASCIIStringEncoding]  
					  contentType:@"application/json"];		
	
	
	
}

#pragma mark --ProfileComments--
- (NSString*) getProfileComments:(NSString*)personId queryParameters:(NSDictionary*)queryParameters{
	NSString *urlString = [NSString stringWithFormat:MS_ROA_PROFILE_COMMENTS, personId, MS_SELECTOR_SELF];
	return [self makeRawOSRequest:urlString queryParameters:queryParameters requestMethod:@"GET" 
					  requestBody:nil 
					  contentType:nil];
}

#pragma mark --Raw OpenSocial--
- (NSString*) makeRawOSRequest:(NSString*)uri queryParameters:(NSDictionary*)queryParams requestMethod:(NSString*)requestMethod
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
					count:(NSString*)count filterBy:(NSString*)filterBy filterOp:(NSString*)filterOp 
					filterValue:(NSString*)filterValue format:(NSString*)format statusId:(NSString*)statusId
				    postedDate:(NSString*)postedDate startIndex:(NSString*)startIndex updatedSince:(NSString*) updatedSince{
	NSMutableDictionary *queryParams = [[NSMutableDictionary new]autorelease];
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
	if (count) {
		[queryParams setValue:count forKey:@"count"];
	}
	if (filterBy) {
		[queryParams setValue:filterBy forKey:@"filterBy"];
	}
	if (filterOp) {
		[queryParams setValue:filterOp forKey:@"filterOp"];	
	}
	if (filterValue) {
		[queryParams setValue:filterValue forKey:@"filterValue"];
	}
	if (format) {
		[queryParams setValue:format forKey:@"format"];
	}
	if (statusId) {
		[queryParams setValue:statusId forKey:@"statusId"];
	}
	if (postedDate) {
		[queryParams setValue:postedDate forKey:@"postedDate"];
	}
	if (startIndex) {
		[queryParams setValue:startIndex forKey:@"startIndex"];
	}
	if (updatedSince) {
		[queryParams setValue:updatedSince forKey:@"updatedSince"];
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
	
	if (true) {
		self.responseData = data;
	}
	[dataOutput release];
	if(context.MSDelegate)
	{
		NSString* dataAsString = [[[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding] autorelease];
        
		if ([context.MSDelegate respondsToSelector:@selector(api:didFinishMethod:withValue:withStatusCode:)]) {    
			[context.MSDelegate api:self didFinishMethod:self.methodName withValue:dataAsString withStatusCode:self.responseStatusCode];
		}
	}
}

- (void) apiTicket:(OAServiceTicket *)ticket didFinishWithError:(NSError *)error{
	/*NSString *message = [NSString stringWithFormat:@"Http Response Error %@ %@",
						 [error localizedDescription],
						 [error localizedFailureReason]];
	
	NSLog(@"%@", message);*/
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

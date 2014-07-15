//
//  MSApi.m
//  MySpaceID.Demo
//
//  Copyright MySpace, Inc. 2010. All rights reserved.
//

#import "MSApi.h"
#import "MSConstants.h"

@implementation MSApi
@synthesize consumerKey;
@synthesize consumerSecret;
@synthesize accessKey;
@synthesize accessSecret;
@synthesize isOnsite;
@synthesize urlScheme;
@synthesize context;
@synthesize delegate;


/*
 *  Constructor
 *  Description: 
 *  @param consumerKey Required
 *  @param consumeSecret Required
 *  @param accessKey Optional
 *  @param accessSecret Optional
 *  @param isOnsite Optional
 *  @return MySpace class to be used to communicate with the MySpace Developer Platform
 */

+ (MSApi*) sdkWith:(NSString*)consumerKey consumerSecret:(NSString*)consumerSecret 
		   accessKey:(NSString*)accessKey	accessSecret:(NSString*)accessSecret isOnsite:(BOOL)isOnsite 
		   urlScheme:(NSString*)urlScheme delegate:(id<MSRequest>) delegate{
	MSApi *sdk = [[[MSApi alloc] init]autorelease];
	sdk.consumerKey = consumerKey;
	sdk.consumerSecret = consumerSecret;
	sdk.accessKey = accessKey;
	sdk.accessSecret = accessSecret;
	sdk.isOnsite = isOnsite;
	sdk.urlScheme = urlScheme;
	sdk.delegate = delegate;
	return sdk;
}

-(id) init
{
	if ((self = [super init]))
	{
		consumerKey = nil;
		consumerSecret= nil;
		accessKey = nil;
		accessSecret = nil;
		urlScheme = nil;
		delegate = nil;
	}
	
	return self;
}


- (void) dealloc{
	
	[consumerKey release];
	[consumerSecret release];
	[accessKey	 release];
	[accessSecret release];
	[urlScheme release];
	[context release];
	[delegate release];
	[super dealloc];
}

#pragma mark --Security--

/*
 *  Returns the MSSecurityContext based upon the IsOnsite flag.
 */
- (MSSecurityContext*) getContext{
	if(context)
		return context;
	if(isOnsite){
		context= [MSOnsiteContext contextWithConsumerKey:consumerKey 
										  consumerSecret:consumerSecret urlScheme:urlScheme];
		[context retain];
	}
	else {
		context = [MSOffsiteContext contextWithConsumerKey:consumerKey consumerSecret:consumerSecret 
												 tokenKey:accessKey tokenSecret:accessSecret urlScheme:urlScheme];
		[context retain];
	}
	if(delegate)
		context.MSDelegate = self.delegate;
     return context;
}



/*
 *  Assumes the application is OffSite. Gets a RequestToken from MySpace and stores it in persistance. Then redirects the iPhone
 *  to the MySpace login page.
 */
- (void) getRequestToken{
	if(!isOnsite)
	{
		MSOffsiteContext *offSiteContext = (MSOffsiteContext*)[self getContext];
		[offSiteContext	 getRequestToken];
	}
	
}

/*
 *  Assumes the application is OffSite. Exchanges a RequestToken for the AccessToken. AccessToken is stored in persistance
 *  and used for subsequent requests.
 */
- (void) getAccessToken{
	if (!isOnsite) {
		MSOffsiteContext	*offSiteContext = (MSOffsiteContext*)[self getContext];
		[offSiteContext	 getAccessToken];

	}
}

/*
 *  Assumes the application is OffSite. Checks if a valid AccessToken exists in persistance.
 */
- (BOOL) isLoggedIn{
	if (!isOnsite) {
		MSOffsiteContext *offSiteContext = (MSOffsiteContext*)[self getContext];
		return [offSiteContext isLoggedIn];
	}
	return false;
}

/*
 *  Assumes the application is OffSite. Destroy AccessToken.
 */
- (void) endSession{
	if(!isOnsite)
	{
		MSOffsiteContext	*offSiteContext = (MSOffsiteContext*)[self getContext];
		[offSiteContext	 logOut];
	}
	
}

#pragma mark --Person--
/*
 *  OpenSocial v0.9 getPerson
 *  Resource: http://opensocial.myspace.com/roa/09/people/{personId}/@self
 *  Details:  http://wiki.developer.myspace.com/index.php?title=OpenSocial_v0.9_People
 *  Description: Get the Person
 *  @param personId:  @me, integer, or myspace.com.person.[integer value]
 *  @param queryParameters: Any queryParameters that are desired in the request. See the documentation for options.
 *  @return NSString representing Person object.
 */
- (NSString*) getPerson:(NSString*)personId queryParameters:(NSDictionary*)queryParameters{
	MSRoaApi *roaApi = [MSRoaApi apiWithContext:[self getContext]];
	roaApi.methodName = @"getPerson";
	return [roaApi getPerson:personId queryParameters:queryParameters ];
}
/*
 *  OpenSocial v0.9 getFriends
 *  Resource: http://opensocial.myspace.com/roa/09/people/{personId}/@friends
 *  Details:  http://wiki.developer.myspace.com/index.php?title=OpenSocial_v0.9_People
 *  Description: Get the Friends
 *  @param personId:  @me, integer, or myspace.com.person.[integer value]
 *  @param queryParameters: Any queryParameters that are desired in the request. See the documentation for options.
 *  @return NSString representing Person object.
 */
- (NSString*) getFriends:(NSString*)personId queryParameters:(NSDictionary*)queryParameters{
	MSRoaApi *roaApi = [MSRoaApi apiWithContext:[self getContext]];
	roaApi.methodName = @"getFriends";
	return [roaApi getFriends:personId queryParameters:queryParameters];
}

/*
 *  Rest v1 getFriendship
 *  Resource: http://api.myspace.com/v1/users/{userId}/friends/{friendsId}
 *  Details:  http://wiki.developer.myspace.com/index.php?title=GET_v1_users_userId_friends_friendsId
 *  Description: Verify friendship between user Ids
 *  @param personId:  @me, integer, or myspace.com.person.[integer value]
 *  @param friendIds: NSArray of friendIds to check for friendship with personId
 *  @param queryParameters: Any queryParameters that are desired in the request. See the documentation for options.
 *  @return NSString representing the Friendship object.
 */
- (NSString*) getFriendship:(NSString*)personId friendId:(NSArray*)friendIds{
	MSRestV1 *restV1Api = [MSRestV1 apiWithContext:[self getContext]];
	restV1Api.methodName = @"getFriendship";
	NSString* dataAsString =[restV1Api getFriendship:[personId intValue] friendIds:friendIds];

	
	return dataAsString; 
}

#pragma mark --Albums--

/*
 *  OpenSocial v0.9 getAlbums
 *  Resource: http://opensocial.myspace.com/roa/09/albums/{personId}/@self
 *  Details:  http://wiki.developer.myspace.com/index.php?title=OpenSocial_v0.9_Albums
 *  Description: Get a person's Albums
 *  @param personId:  @me, integer, or myspace.com.person.[integer value] *  @param queryParameters: Any queryParameters that are desired in the request. See the documentation for options.
 *  @return NSString representing the Albums object.
 */
- (NSString*) getAlbums:(NSString*)personId queryParameters:(NSDictionary*)queryParameters{
	MSRoaApi *roaApi = [MSRoaApi apiWithContext:[self getContext]];
	roaApi.methodName = @"getAlbums";
	return [roaApi getAlbums:personId queryParameters:queryParameters];
}

/*
 *  OpenSocial v0.9 addAlbum
 *  Resource: http://opensocial.myspace.com/roa/09/albums/{personId}/@self
 *  Details:  http://wiki.developer.myspace.com/index.php?title=OpenSocial_v0.9_Albums
 *  Description: Add a new album
 *  @param personId:  @me, integer, or myspace.com.person.[integer value] 
 *  @param caption: caption to associate with album
 *  @param location: location of album
 *  @param queryParameters: Any queryParameters that are desired in the request. See the documentation for options.
 *  @return NSString representing the Albums object.
 */
- (NSString*) addAlbum:(NSString*)personId caption:(NSString*)caption location:(NSString*)location 
	   queryParameters:(NSDictionary*)queryParameters{
	MSRoaApi *roaApi = [MSRoaApi apiWithContext:[self getContext]];
	roaApi.methodName = @"addAlbum";
	return [roaApi addAlbum:personId caption:caption location:location queryParameters:queryParameters];
}

/*
 *  OpenSocial v0.9 updateAlbum
 *  Resource: http://opensocial.myspace.com/roa/09/albums/{personId}/@self
 *  Details:  http://wiki.developer.myspace.com/index.php?title=OpenSocial_v0.9_Albums
 *  Description: update an existing album
 *  @param personId:  @me, integer, or myspace.com.person.[integer value] 
 *  @param albumId: the albumId of the album to update.
 *  @param caption: caption to associate with album
 *  @param location: location of album
 *  @param queryParameters: Any queryParameters that are desired in the request. See the documentation for options.
 *  @return NSString representing the Albums object.
 */
- (NSString*) updateAlbum:(NSString*)personId albumId:(NSString*)albumId caption:(NSString*)caption location:(NSString*)location
		  queryParameters:(NSDictionary*)queryParameters{
	MSRoaApi *roaApi = [MSRoaApi apiWithContext:[self getContext]];
	roaApi.methodName = @"updateAlbum";
	return [roaApi updateAlbum:personId albumId:albumId caption:caption location:location queryParameters:queryParameters];
}

#pragma mark --MediaItems--


/*
 *  OpenSocial v0.9 getMediaItems
 *  Resource: http://opensocial.myspace.com/roa/09/mediaItems/{personId}/@self/{albumId}
 *  Details:  http://wiki.developer.myspace.com/index.php?title=OpenSocial_0.9_MediaItems
 *  Description: Get a person's own mediaItems from an album
 *  @param personId:  @me, integer, or myspace.com.person.[integer value] 
 *  @param albumId: the albumId of the album to update.
 *  @param queryParameters: Any queryParameters that are desired in the request. See the documentation for options.
 *  @return NSString representing the MediaItems object.
 */
- (NSString*) getMediaItems:(NSString*)personId albumId:(NSString*)albumId queryParameters:(NSDictionary*)queryParameters{
	MSRoaApi *roaApi = [MSRoaApi apiWithContext:[self getContext]];
	roaApi.methodName = @"getMediaItems";
	return [roaApi getMediaItems:personId albumId:albumId queryParameters:queryParameters];
}

/*
 *  OpenSocial v0.9 getFriendMediaItems
 *  Resource: http://opensocial.myspace.com/roa/09/mediaItems/{personId}/@friends/{albumId}
 *  Details:  http://wiki.developer.myspace.com/index.php?title=OpenSocial_0.9_MediaItems
 *  Description: Get a friends's mediaItems from an album
 *  @param personId:  @me, integer, or myspace.com.person.[integer value] 
 *  @param albumId: the albumId of the album to update.
 *  @param queryParameters: Any queryParameters that are desired in the request. See the documentation for options.
 *  @return NSString representing the MediaItems object.
 */
- (NSString*) getFriendMediaItems:(NSString*)personId albumId:(NSString*)albumId queryParameters:(NSDictionary*)queryParameters{
	MSRoaApi *roaApi = [MSRoaApi apiWithContext:[self getContext]];
	roaApi.methodName = @"getFriendMediaItems";
	return [roaApi getFriendMediaItems:personId albumId:albumId queryParameters:queryParameters];
}

/*
 *  OpenSocial v0.9 getMediaItem
 *  Resource: http://opensocial.myspace.com/roa/09/mediaItems/{personId}/@friends/{albumId}/{mediaItemId}
 *  Details:  http://wiki.developer.myspace.com/index.php?title=OpenSocial_0.9_MediaItems
 *  Description: Get a friends's mediaItems from an album
 *  @param personId:  @me, integer, or myspace.com.person.[integer value] 
 *  @param albumId: the albumId of the album to update.
 *  @param mediaItemId: The id of the mediaItem desired.
 *  @param queryParameters: Any queryParameters that are desired in the request. See the documentation for options.
 *  @return NSString representing the MediaItem object.
 */
- (NSString*) getMediaItem:(NSString*)personId albumId:(NSString*)albumId mediaItemId:(NSString*)mediaItemId 
		   queryParameters:(NSDictionary*)queryParameters{
	MSRoaApi *roaApi = [MSRoaApi apiWithContext:[self getContext]];
	roaApi.methodName = @"getMediaItem";
	return [roaApi getMediaItem:personId albumId:albumId mediaItemId:mediaItemId queryParameters:queryParameters];
}

/*
 *  OpenSocial v0.9 getMediaItem
 *  Resource: http://opensocial.myspace.com/roa/09/mediaitems/{personId}/@videos/@supportedcategories
 *  Details:  http://wiki.developer.myspace.com/index.php?title=OpenSocial_0.9_MediaItems
 *  Description: Returns a list of video categories. Needed for uploading videos.
 *  @param personId:  @me, integer, or myspace.com.person.[integer value]
 *  @param queryParameters: Any queryParameters that are desired in the request. See the documentation for options.
 *  @return NSString representing the MediaItem object.
 */
- (NSString*) getSupportedVideoCategories:(NSString*)personId queryParameters:(NSDictionary*)queryParameters{
	MSRoaApi *roaApi = [MSRoaApi apiWithContext:[self getContext]];
	roaApi.methodName = @"getSupportedVideoCategories";
	return [roaApi getSupportedVideoCategories:personId queryParameters:nil];
}

/*
 *  OpenSocial v0.9 getMediaItem
 *  Resource: http://opensocial.myspace.com/roa/09/mediaItems/{personId}/@friends/{albumId}/{mediaItemId}
 *  Details:  http://wiki.developer.myspace.com/index.php?title=OpenSocial_0.9_MediaItems
 *  Description: Updatea  media item
 *  @param personId:  @me, integer, or myspace.com.person.[integer value] 
 *  @param albumId: the albumId of the album to update.
 *  @param mediaItemId: The id of the mediaItem desired.
 *  @param title: The title of the mediaItem
 *  @param queryParameters: Any queryParameters that are desired in the request. See the documentation for options.
 *  @return NSString representing the MediaItem object.
 */
- (NSString*) updateMediaItem:(NSString*)personId albumId:(NSString*)albumId mediaItemId:(NSString*)mediaItemId
						title:(NSString*)title queryParameters:(NSDictionary*)queryParameters{
	MSRoaApi *roaApi = [MSRoaApi apiWithContext:[self getContext]];
	roaApi.methodName = @"updateMediaItem";
	return [roaApi updateMediaItem:personId albumId:albumId mediaItemId:mediaItemId title:title queryParameters:queryParameters];
}

/*
 *  OpenSocial v0.9 addPhoto
 *  Resource: http://opensocial.myspace.com/roa/09/mediaItems/{personId}/@friends/{albumId}
 *  Details:  http://wiki.developer.myspace.com/index.php?title=OpenSocial_0.9_MediaItems
 *  Description: Uploads a photo to a specific album.
 *  @param personId:  @me, integer, or myspace.com.person.[integer value] 
 *  @param albumId: the albumId of the album to update.
 *  @param caption: the caption of the photo
 *  @param photoData: The NSData format of the image.
 *  @param imageType: The image/type of the photo. Default is "image/jpeg".
 *  @param queryParameters: Any queryParameters that are desired in the request. See the documentation for options.
 *  @return NSString representing the MediaItem object.
 */
- (NSString*) addPhoto:(NSString*)personId albumId:(NSString*)albumId 
			   caption:(NSString*)caption photoData:(NSData*)photoData imageType:(NSString*) imageType 
	   queryParameters:(NSDictionary*)queryParameters{
	MSRoaApi *roaApi = [MSRoaApi apiWithContext:[self getContext]];
	roaApi.methodName = @"addPhoto";
	return [roaApi addPhoto:personId albumId:albumId caption:caption photoData:photoData imageType:imageType queryParameters:queryParameters];
}

/*
 *  OpenSocial v0.9 addVideo
 *  Resource: http://opensocial.myspace.com/roa/09/mediaItems/{personId}/@friends/{albumId}
 *  Details:  http://wiki.developer.myspace.com/index.php?title=OpenSocial_0.9_MediaItems
 *  Description: Uploads a video to a specific album.
 *  @param personId:  @me, integer, or myspace.com.person.[integer value] 
 *  @param albumId: the albumId of the album to update.
 *  @param caption: the caption of the photo
 *  @param photoData: The NSData format of the image.
 *  @param imageType: The image/type of the photo. Default is "video/quicktime".
 *  @param queryParameters: Any queryParameters that are desired in the request. See the documentation for options.
 *  @return NSString representing the MediaItem object.
 */
- (NSString*) addVideo:(NSString*)personId albumId:(NSString*)albumId 
			   caption:(NSString*)caption videoData:(NSData*)videoData videoType:(NSString*) videoType 
		   description:(NSString*) description tags:(NSArray*)tags msCategories:(NSString*)msCategories
			  language:(NSString*) language queryParameters:(NSDictionary*)queryParameters{
	MSRoaApi *roaApi = [MSRoaApi apiWithContext:[self getContext]];
	roaApi.methodName = @"addVideo";
	return [roaApi addVideo:personId albumId:albumId caption:caption videoData:videoData 
				  videoType:videoType description:description tags:tags msCategories:msCategories language:language queryParameters:queryParameters];
}


#pragma mark --MediaItemComments--

/*
 *  OpenSocial v0.9 getMediaItemComments
 *  Resource: http://opensocial.myspace.com/roa/09/mediaitemcomments/{personId}/@self/{albumId}/{mediaItemId}
 *  Details:  http://wiki.developer.myspace.com/index.php?title=OpenSocial_v0.9_MediaItemComments
 *  Description: Returns comments about a given MediaItem
 *  @param personId:  @me, integer, or myspace.com.person.[integer value] 
 *  @param albumId: the albumId of the album to update.
 *  @param mediaItemId: the id of the MediaItem we want comments about.
 *  @param queryParameters: Any queryParameters that are desired in the request. See the documentation for options.
 *  @return NSString representing the MediaItem object.
 */
- (NSString*) getMediaItemComments:(NSString*)personId albumId:(NSString*)albumId mediaItemId:(NSString*)mediaItemId
				   queryParameters:(NSDictionary*)queryParameters{
	MSRoaApi *roaApi = [MSRoaApi apiWithContext:[self getContext]];
	roaApi.methodName = @"getMediaItemComments";
	return [roaApi getMediaItemComments:personId albumId:albumId mediaItemId:mediaItemId queryParameters:queryParameters];
}


#pragma mark --Activities--

/*
 *  Rest v1 getActivities
 *  Resource: http://api.myspace.com/v1/users/{userId}/activities.atom
 *  Details:  http://wiki.developer.myspace.com/index.php?title=Category:ActivityStreams
 *  Additional Details: http://wiki.developer.myspace.com/index.php?title=Standards_for_Activity_Streams
 *  Description: Returns comments about a given MediaItem
 *  @param userId:  integer value of user
 *  @param activityTypes: To obtain a stream containing only certain types of activities, modify the call with the activitytypes query string parameter.
 *                                       Use the MSActivityTypes.h file to find constants for this parameter.
 *  @param extensions: Pipe delimited list of options syndicating the activity stream. Name fo the query string parameter is "extensions"
 *                                   Possible values: actor|subject|activitytarget|fullmetadata|standardizetags|feedsync|all. 
 *								      See http://wiki.developer.myspace.com/index.php?title=ActivityStream_Queries#Extensions
 *  @param composite: Set this query string parameter to true to get one atom entry for all activities of the same type on the same day. If the objects of the 
 *                                  activities go into targets then they will be grouped by target. Ex: Max uploaded 5 photos into the album Medieval Times.
 *								      See http://wiki.developer.myspace.com/index.php?title=ActivityStream_Queries#Composite
 *  @param queryParameters: Any queryParameters that are desired in the request. See the documentation for options.
 *  @return NSString representing the Atom feed of the Activities.
 */
- (NSString*) getActivities:(NSString*)userId activityTypes:(NSString*)activityTypes	extensions:(NSString*)extensions
				  composite:(NSString*)composite culture:(NSString*)culture datetime:(NSString*)dateTime	pageSize:(NSString*)pageSize{
	MSRestV1 *restV1Api = [MSRestV1 apiWithContext:[self getContext]];
	restV1Api.methodName = @"getActivities";
	return [restV1Api getActivities:userId activityTypes:activityTypes extensions:extensions
						  composite:composite culture:culture datetime:dateTime pageSize:pageSize];
}

/*
 *  Rest v1 getFriendActivities
 *  Resource: http://api.myspace.com/v1/users/{userId}/friends/activities.atom
 *  Details:  http://wiki.developer.myspace.com/index.php?title=Category:ActivityStreams
 *  Additional Details: http://wiki.developer.myspace.com/index.php?title=Standards_for_Activity_Streams
 *  Description: Returns comments about a given MediaItem
 *  @param userId:  integer value of user
 *  @param activityTypes: To obtain a stream containing only certain types of activities, modify the call with the activitytypes query string parameter.
 *                                       Use the MSActivityTypes.h file to find constants for this parameter.
 *  @param extensions: Pipe delimited list of options syndicating the activity stream. Name fo the query string parameter is "extensions"
 *                                   Possible values: actor|subject|activitytarget|fullmetadata|standardizetags|feedsync|all. 
 *								      See http://wiki.developer.myspace.com/index.php?title=ActivityStream_Queries#Extensions
 *  @param composite: Set this query string parameter to true to get one atom entry for all activities of the same type on the same day. If the objects of the 
 *                                  activities go into targets then they will be grouped by target. Ex: Max uploaded 5 photos into the album Medieval Times.
 *								      See http://wiki.developer.myspace.com/index.php?title=ActivityStream_Queries#Composite
 *  @param queryParameters: Any queryParameters that are desired in the request. See the documentation for options.
 *  @return NSString representing the Atom feed of the Activities.
 */
- (NSString*) getFriendActivities:(NSString*) userId activityTypes:(NSString*)activityTypes	extensions:(NSString*)extensions
						composite:(NSString*)composite culture:(NSString*)culture datetime:(NSString*)dateTime	pageSize:(NSString*)pageSize{
	MSRestV1 *restV1Api = [MSRestV1 apiWithContext:[self getContext]];
	restV1Api.methodName = @"getFriendActivities";
	return [restV1Api getFriendActivities:userId activityTypes:activityTypes extensions:extensions
						  composite:composite culture:culture datetime:dateTime pageSize:pageSize];
}

/*
 *  OpenSocial v0.9 createActivity
 *  Resource: http://opensocial.myspace.com/roa/09/activities/@me/@self
 *  Details:  http://wiki.developer.myspace.com/index.php?title=OpenSocial_v0.9_Activities#Create_an_activity
 *  Description: Post to the activity stream
 *  @param templateId:  Name of the template that you are pushing an activity to.
 *  @param titel: title of the activity
 *  @param body: body of the activity
 *  @param templateParameters: See documentation site for more details on templateParameters.
 *  @param queryParameters: Any queryParameters that are desired in the request. See the documentation for options.
 *  @return NSString representing the MediaItem object.
 */
- (NSString*) createActivity:(NSString*)templateId title:(NSString*)title body:(NSString*)body templateParameters:(NSArray*)templateParameters activityId:(NSString*)activityId
			 queryParameters:(NSDictionary*)queryParameters{
	MSRoaApi *roaApi = [MSRoaApi apiWithContext:[self getContext]];
	roaApi.methodName = @"createActivity";
	return [roaApi createActivity:templateId title:title body:body templateParameters:templateParameters
					   activityId:activityId queryParameters:queryParameters];
}

#pragma mark --AppData--

/*
 *  OpenSocial v0.9 getAppData
 *  Resource: http://opensocial.myspace.com/roa/09/appdata/{personId}/{selector}/{appId}
 *  Details:  http://wiki.developer.myspace.com/index.php?title=OpenSocial_v0.9_AppData
 *  Description: Returns all application data for given user with current application
 *  @param personId:  @me, integer, or myspace.com.person.[integer value]  
 *  @param selector: @self, @all, @friends, groupId
 *  @param appId: id of current application
 *  @param queryParameters: Any queryParameters that are desired in the request. See the documentation for options.
 *  @return NSString representing the AppData object.
 */
- (NSString*) getAppData:(NSString*)personId selector:(NSString*)selector appId:(NSString*)appId queryParameters:(NSDictionary*)queryParameters{
	MSRoaApi *roaApi = [MSRoaApi apiWithContext:[self getContext]];
	roaApi.methodName = @"getAppData";
	return [roaApi getAppData:personId selector:selector appId:appId queryParameters:queryParameters];
}

/*
 *  OpenSocial v0.9 addAppData
 *  Resource: http://opensocial.myspace.com/roa/09/appdata/{personId}/{selector}/{appId}
 *  Details:  http://wiki.developer.myspace.com/index.php?title=OpenSocial_v0.9_AppData
 *  Description: Adds application data for given user with current application
 *  @param personId:  @me, integer, or myspace.com.person.[integer value]  
 *  @param selector: @self, @all, @friends, groupId
 *  @param userId: UserID of the user associated with the appData. Goes into Http body
 *  @param appId: id of current application
 *  @param keys: array of keys that are to be added. Must be in the same order as values array.
 *  @param values: array of values that are to be added. Must be in the same order as keys array
 *  @param queryParameters: Any queryParameters that are desired in the request. See the documentation for options.
 *  @return NSString representing the AppData object.
 */
- (NSString*) addAppData:(NSString*)personId userId:(NSString*)userId selector:(NSString*)selector appId:(NSString*)appId keys:(NSArray*)keys 
				  values:(NSArray*)values queryParameters:(NSDictionary*)queryParameters{
	MSRoaApi *roaApi = [MSRoaApi apiWithContext:[self getContext]];
	roaApi.methodName = @"addAppData";
	return [roaApi addAppData:personId userId:userId selector:selector appId:appId keys:keys values:values queryParameters:queryParameters];
}

/*
 *  OpenSocial v0.9 deleteAppData
 *  Resource: http://opensocial.myspace.com/roa/09/appdata/{personId}/{selector}/{appId}
 *  Details:  http://wiki.developer.myspace.com/index.php?title=OpenSocial_v0.9_AppData
 *  Description: Deletes application data for given user with current application
 *  @param personId:  @me, integer, or myspace.com.person.[integer value]  
 *  @param selector: @self, @all, @friends, groupId
 *  @param appId: id of current application
 *  @param keys: array of keys that are to be deleted
 *  @param queryParameters: Any queryParameters that are desired in the request. See the documentation for options.
 *  @return NSString representing the AppData object.
 */
- (NSString*) deleteAppData:(NSString*)personId selector:(NSString*)selector appId:(NSString*)appId keys:(NSArray*)keys 
			queryParameters:(NSDictionary*)queryParameters{
	MSRoaApi *roaApi = [MSRoaApi apiWithContext:[self getContext]];
	roaApi.methodName = @"deleteAppData";
	return [roaApi deleteAppData:personId selector:selector appId:appId keys:keys queryParameters:queryParameters];
}

/*
 *  Rest v1 getGlobalAppData
 *  Resource: http://api.myspace.com/v1/appdata/global/gkey1;gkey2
 *  Details:  http://wiki.developer.myspace.com/index.php?title=GET_v1_appdata_global_keys
 *  Description: Returns all global data for this application
 *  @param keys: array of keys that are to be fetched. If nil, all global app data will be returned.
 *  @param queryParameters: Any queryParameters that are desired in the request. See the documentation for options.
 *  @return NSString representing the Global AppData in JSON.
 */
- (NSString*) getGlobalAppData:(NSArray*)keys queryParameters:(NSDictionary*)queryParameters{
	MSRestV1 *restV1Api = [MSRestV1 apiWithContext:[self getContext]];
	NSString* dataAsString = [restV1Api getGlobalAppData:keys];
	restV1Api.methodName = @"getGlobalAppData";
	
	return dataAsString; 
}

/*
 *  Rest v1 addGlobalAppData
 *  Resource: http://api.myspace.com/v1/appdata/global/gkey1;gkey2
 *  Details:  http://wiki.developer.myspace.com/index.php?title=GET_v1_appdata_global_keys
 *  Description: Returns all global data for this application
 *  @param globalAppDataPairs: A dictionary whose key-value pairs will be added to the global app data.
 *  @param queryParameters: Any queryParameters that are desired in the request. See the documentation for options.
 *  @return NSString representing the Global AppData in JSON.
 */
- (NSString*) addGlobalAppData:(NSDictionary*)globalAppDataPairs  queryParameters:(NSDictionary*)queryParameters{
	MSRestV1 *restV1Api = [MSRestV1 apiWithContext:[self getContext]];
	restV1Api.methodName = @"addGlobalAppData";
	NSString* dataAsString = [restV1Api addGlobalAppData:globalAppDataPairs];
	
	return dataAsString; 
}

/*
 *  Rest v1 deleteGlobalAppData
 *  Resource: http://api.myspace.com/v1/appdata/global/gkey1;gkey2
 *  Details:  http://wiki.developer.myspace.com/index.php?title=GET_v1_appdata_global_keys
 *  Description: Returns all global data for this application
 *  @param keys: array of keys that are to be deleted
 *  @param queryParameters: Any queryParameters that are desired in the request. See the documentation for options.
 *  @return NSString representing the Global AppData in JSON.
 */
- (NSString*) deleteGlobalAppData:(NSArray*)keys queryParameters:(NSDictionary*)queryParameters{
	MSRestV1 *restV1Api = [MSRestV1 apiWithContext:[self getContext]];
	restV1Api.methodName = @"deleteGlobalAppData";
	NSString* dataAsString = [restV1Api deleteGlobalAppData:keys];
	
	return dataAsString; 
}

#pragma mark --Groups--

/*
 *  OpenSocial v0.9 getGroups
 *  Resource: http://opensocial.myspace.com/roa/09/groups/{personId}/
 *  Details:  http://wiki.developer.myspace.com/index.php?title=OpenSocial_v0.9_Groups
 *  Description: Get groups for the personId
 *  @param personId:  @me, integer, or myspace.com.person.[integer value]
 *  @param queryParameters: Any queryParameters that are desired in the request. See the documentation for options.
 *  @return NSString representing Group object.
 */
- (NSString*) getGroups:(NSString*)personId queryParameters:(NSDictionary*)queryParameters{
	MSRoaApi *roaApi = [MSRoaApi apiWithContext:[self getContext]];
	roaApi.methodName = @"getGroups";
	return [roaApi getGroups:personId queryParameters:queryParameters];
}

/*
 *  OpenSocial v0.9 getGroup
 *  Resource: http://opensocial.myspace.com/roa/09/people/{personId}/{groupId}
 *  Details:  http://wiki.developer.myspace.com/index.php?title=OpenSocial_v0.9_People
 *  Description: Gets a specific group for a person
 *  @param personId:  @me, integer, or myspace.com.person.[integer value]
 *  @param groupId:  the ID of the user’s custom group
 *  @param queryParameters: Any queryParameters that are desired in the request. See the documentation for options.
 *  @return NSString representing Group object.
 */
- (NSString*) getGroup:(NSString*)personId groupId:(NSString*)groupId queryParameters:(NSDictionary*)queryParameters{
	MSRoaApi *roaApi = [MSRoaApi apiWithContext:[self getContext]];		
	roaApi.methodName = @"getGroup";
	return [roaApi getGroup:personId groupId:groupId queryParameters:queryParameters];
}

#pragma mark --StatusMood--

/*
 *  OpenSocial v0.9 getSupportedMoods
 *  Resource: http://opensocial.myspace.com/roa/09/statusmood/{personId}/@supportedMood
 *  Details:  http://wiki.developer.myspace.com/index.php?title=OpenSocial_v0.9_StatusMood
 *  Description: Gets a list of all the moods currently supported within MySpace
 *  @param personId:  @me, integer, or myspace.com.person.[integer value]
 *  @param queryParameters: Any queryParameters that are desired in the request. See the documentation for options.
 *  @return NSString representing Moods object.
 */
- (NSString*) getSupportedMoods:(NSString*)personId queryParameters:(NSDictionary*)queryParameters{
	MSRoaApi *roaApi = [MSRoaApi apiWithContext:[self getContext]];
	roaApi.methodName = @"getSupportedMoods";
	return [roaApi getSupportedMoods:personId queryParameters:queryParameters];
}

/*
 *  OpenSocial v0.9 getSingleMood
 *  Resource: http://opensocial.myspace.com/roa/09/statusmood/{personId}/@supportedMood/{moodId}
 *  Details:  http://wiki.developer.myspace.com/index.php?title=OpenSocial_v0.9_StatusMood
 *  Description: Gests a single Mood object.
 *  @param personId:  @me, integer, or myspace.com.person.[integer value]
 *  @param moodId: the id of the Mood sought.
 *  @param queryParameters: Any queryParameters that are desired in the request. See the documentation for options.
 *  @return NSString representing Moods object.
 */
- (NSString*) getSingleMood:(NSString*)personId moodId:(NSString*)moodId queryParameters:(NSDictionary*)queryParameters{
	MSRoaApi *roaApi = [MSRoaApi apiWithContext:[self getContext]];
	roaApi.methodName = @"getSingleMood";
	return [roaApi getSingleMood:personId moodId:moodId queryParameters:queryParameters];
}

/*
 *  OpenSocial v0.9 getPersonMoodStatus
 *  Resource: http://opensocial.myspace.com/roa/09/statusmood/{personId}/@self
 *  Details:  http://wiki.developer.myspace.com/index.php?title=OpenSocial_v0.9_StatusMood
 *  Refer to the documentation for filter and sorting options.
 *  Description: Gets the MoodStatus for a given personId
 *  @param personId:  @me, integer, or myspace.com.person.[integer value]
 *  @param moodId: the id of the Mood sought.
 *  @param queryParameters: Any queryParameters that are desired in the request. See the documentation for options.
 *  @return NSString representing Moods object.
 */
- (NSString*) getPersonMoodStatus:(NSString*)personId queryParameters:(NSDictionary*)queryParameters{
	MSRoaApi *roaApi = [MSRoaApi apiWithContext:[self getContext]];
	roaApi.methodName = @"getPersonMoodStatus";
	return [roaApi getPersonMoodStatus:personId queryParameters:queryParameters];
}

/*
 *  OpenSocial v0.9 getFriendsMoodStatus
 *  Resource: http://opensocial.myspace.com/roa/09/statusmood/{personId}/@friends
 *  Details:  http://wiki.developer.myspace.com/index.php?title=OpenSocial_v0.9_StatusMood
 *  Refer to the documentation for filter and sorting options.
 *  Description: Gets the MoodStatus for a given personId's friends
 *  @param personId:  @me, integer, or myspace.com.person.[integer value]
 *  @param includeHistory: indicates whether to return the history of mood status or not.
 *  @param queryParameters: Any queryParameters that are desired in the request. See the documentation for options.
 *  @return NSString representing Moods object.
 */
- (NSString*) getFriendsMoodStatus:(NSString*)personId includeHistory:(BOOL)includeHistory 
				   queryParameters:(NSDictionary*)queryParameters{
	MSRoaApi *roaApi = [MSRoaApi apiWithContext:[self getContext]];
	roaApi.methodName = @"getFriendsMoodStatus";
	return [roaApi getFriendsMoodStatus:personId includeHistory:includeHistory queryParameters:queryParameters];
}

/*
 *  OpenSocial v0.9 getFriendMoodStatus
 *  Resource: http://opensocial.myspace.com/roa/09/statusmood/{personId}/@self/{friendId}
 *  Details:  http://wiki.developer.myspace.com/index.php?title=OpenSocial_v0.9_StatusMood
 *  Refer to the documentation for filter and sorting options.
 *  Description: Gets the MoodStatus for a given personId's friend
 *  @param personId:  @me, integer, or myspace.com.person.[integer value]
 *  @param friendId: the id of the friend
 *  @param includeHistory: indicates whether to return the history of mood status or not.
 *  @param queryParameters: Any queryParameters that are desired in the request. See the documentation for options.
 *  @return NSString representing Moods object.
 */
- (NSString*) getFriendMoodStatus:(NSString*)personId friendId:(NSString*)friendId includeHistory:(BOOL)includeHistory 
				  queryParameters:(NSDictionary*)queryParameters{
	MSRoaApi *roaApi = [MSRoaApi apiWithContext:[self getContext]];
	roaApi.methodName = @"getFriendMoodStatus";
	return [roaApi getFriendsMoodStatus:personId includeHistory:includeHistory queryParameters:queryParameters];
}

/*
 *  OpenSocial v0.9 updatePersonMoodStatus
 *  Resource: http://opensocial.myspace.com/roa/09/statusmood/{personId}/@self/
 *  Details:  http://wiki.developer.myspace.com/index.php?title=OpenSocial_v0.9_StatusMood
 *  Refer to the documentation for filter and sorting options.
 *  Description: Updates the MoodStatus for a given personId
 *  @param personId:  @me, integer, or myspace.com.person.[integer value]
 *  @param status: the status to update
 *  @param moodName: the name of the mood to update
 *  @param latitude: the latitude of the status update
 *  @param longitude: the longitude of the status update
 *  @param queryParameters: Any queryParameters that are desired in the request. See the documentation for options.
 *  @return NSString representing Moods object.
 */
- (NSString*) updatePersonMoodStatus:(NSString*)personId moodName:(NSString*)moodName status:(NSString*)status
							latitude:(NSString*)latitude longitude:(NSString*)longitude queryParameters:(NSDictionary*)queryParameters{
	MSRoaApi *roaApi = [MSRoaApi apiWithContext:[self getContext]];
	roaApi.methodName = @"updatePersonMoodStatus";
	return [roaApi updatePersonMoodStatus:personId moodName:moodName status:status latitude:latitude longitude:longitude 
						  queryParameters:queryParameters];
}

#pragma mark --StatusMood Comments--

/*
 *  OpenSocial v0.9 getStatusMoodComments
 *  Resource: http://opensocial.myspace.com/roa/09/statusmoodcomments/{personId}/@self
 *  Details:  http://wiki.developer.myspace.com/index.php?title=OpenSocial_v0.9_StatusMoodComments
 *  Refer to the documentation for filter and sorting options.
 *  Description: Get the comments of a given StatusMood
 *  @param personId:  @me, integer, or myspace.com.person.[integer value]
 *  @param statusId: The id of the statusmood
 *  @param queryParameters: Any queryParameters that are desired in the request. See the documentation for options.
 *  @return NSString representing Moods object.
 */
- (NSString*) getStatusMoodComments:(NSString*)personId statusId:(NSString*)statusId  queryParameters:(NSDictionary*)queryParameters{
	MSRoaApi *roaApi = [MSRoaApi apiWithContext:[self getContext]];
	roaApi.methodName = @"getStatusMoodComments";
	return [roaApi getStatusMoodComments:personId statusId:statusId queryParameters:queryParameters];
}

/*
 *  OpenSocial v0.9 getStatusMoodComments
 *  Resource: http://opensocial.myspace.com/roa/09/statusmoodcomments/{personId}/@self
 *  Details:  http://wiki.developer.myspace.com/index.php?title=OpenSocial_v0.9_StatusMoodComments
 *  Refer to the documentation for filter and sorting options.
 *  Description: Add a comments of a given StatusMood
 *  @param personId:  @me, integer, or myspace.com.person.[integer value]
 *  @param statusId: The id of the statusmood
 *  @param body: The body of the comment.
 *  @param queryParameters: Any queryParameters that are desired in the request. See the documentation for options.
 *  @return NSString representing Moods object.
 */
- (NSString*) addStatusMoodComment:(NSString*) persondId statusId:(NSString*)statusId body:(NSString*)body 
				   queryParameters:(NSDictionary*)queryParameters{
	MSRoaApi *roaApi = [MSRoaApi apiWithContext:[self getContext]];
	roaApi.methodName = @"addStatusMoodComment";
	return [roaApi addStatusMoodComment:persondId statusId:statusId body:body queryParameters:queryParameters];
}
#pragma mark --Notifications--

/*
 *  OpenSocial v0.9 sendNotification
 *  Resource: http://opensocial.myspace.com/roa/09/notifications/{personId}/@self
 *  Details:  http://wiki.developer.myspace.com/index.php?title=OpenSocial_v0.9_Notifications
 *  Refer to the documentation for filter and sorting options.
 *  Description: Add a comments of a given StatusMood
 *  @param personId:  @me, integer, or myspace.com.person.[integer value]
 *  @param recipientIds: array of recipients for the notification.
 *  @param mediaItems: Array of mediaItems to attach to notification. See documentation.
 *  @param templateParameters: Array of templateParameters to attach to notification. See documentation.
 *  @param queryParameters: Any queryParameters that are desired in the request. See the documentation for options.
 *  @return NSString representing Moods object.
 */
- (NSString*) sendNotification:(NSString*)personId recipientIds:(NSArray*)recipientIds mediaItems:(NSArray*)mediaItems 
			templateParameters:(NSArray*)templateParameters queryParameters:(NSDictionary*)queryParameters{
	MSRoaApi *roaApi = [MSRoaApi apiWithContext:[self getContext]];
	roaApi.methodName = @"sendNotification";
	return [roaApi sendNotification:personId recipientIds:recipientIds mediaItems:mediaItems templateParameters:templateParameters queryParameters:queryParameters];
}



#pragma mark --Alerts--
/*
 *  Rest v1 getIndicators
 *  Resource: http://opensocial.myspace.com/roa/09/notifications/{personId}/@self
 *  Details:  http://api.myspace.com/v1/users/{userid}/indicators.json
 *  Description: Add a comments of a given StatusMood
 *  @param personId:  integer
 *  @param queryParameters: Any queryParameters that are desired in the request. See the documentation for options.
 *  @return NSString representing Moods object.
 */
- (NSString*) getIndicators:(NSString*)personId{
	MSRestV1 *restV1Api = [MSRestV1 apiWithContext:[self getContext]];
	restV1Api.methodName = @"getIndicators";
	NSString* dataAsString = [restV1Api getIndicators:[personId intValue]];
	
	return dataAsString; 
	
}

#pragma mark --ProfileComments--

/*
 *  OpenSocial v0.9 getProfileComments
 *  Resource: http://opensocial.myspace.com/roa/09/profilecomments/{personId}/@self
 *  Details:  http://wiki.developer.myspace.com/index.php?title=OpenSocial_v0.9_ProfileComments
 *  Refer to the documentation for filter and sorting options.
 *  Description: Add a comments of a given StatusMood
 *  @param personId:  @me, integer, or myspace.com.person.[integer value]
 *  @param queryParameters: Any queryParameters that are desired in the request. See the documentation for options.
 *  @return NSString representing ProfileComments object.
 */
- (NSString*) getProfileComments:(NSString*)personId queryParameters:(NSDictionary*)queryParameters{
	MSRoaApi *roaApi = [MSRoaApi apiWithContext:[self getContext]];
	roaApi.methodName = @"getProfileComments";
	return [roaApi getProfileComments:personId queryParameters:queryParameters];
}

#pragma mark --OpenSearch--

#pragma mark --People Search--

/*
 *  OpenSearch v1 searchPeople
 *  Resource:http://api.myspace.com/opensearch/people
 *  Details:  http://wiki.developer.myspace.com/index.php?title=Open_Search
 *  Refer to the documentation for optional parameters. User queryParameters for optional parameters.
 *  Description: People Search
 *  @param searchTerms:  search terms
 *  @return NSString representing ProfileComments object.
 */
-(NSString*) searchPeople:(NSString*)searchTerms{
	MSOpenSearchApi *searchApi = [MSOpenSearchApi apiWithContext:[self getContext]];
	searchApi.methodName = @"searchPeople";
	return [searchApi searchPeople:searchTerms];
}

/*
 *  OpenSearch v1 searchPeople
 *  Resource:http://api.myspace.com/opensearch/people
 *  Details:  http://wiki.developer.myspace.com/index.php?title=Open_Search
 *  Refer to the documentation for optional parameters. User queryParameters for optional parameters.
 *  Description: People Search
 *  @param searchTerms:  search terms
 *  @param queryParameters: Any queryParameters that are desired in the request. See the documentation for options.
 *  @return NSString representing ProfileComments object.
 */
-(NSString*) searchPeople:(NSString*)searchTerms queryParameters:(NSMutableDictionary*)queryParameters{
	MSOpenSearchApi *searchApi = [MSOpenSearchApi apiWithContext:[self getContext]];
	searchApi.methodName = @"searchPeople";
	return [searchApi searchPeople:searchTerms queryParameters:queryParameters];
}

/*
 *  OpenSearch v1 searchPeople
 *  Resource:http://api.myspace.com/opensearch/people
 *  Details:  http://wiki.developer.myspace.com/index.php?title=Open_Search
 *  Refer to the documentation for optional parameters. User queryParameters for optional parameters.
 *  Description: Image Search
 *  @param searchTerms:  search terms
 *  @param format: Optional Parameter
 *  @param count: Optional Parameter
 *  @param startPage: Optional Parameter
 *  @param searchBy: Optional Parameter
 *  @param gender: Optional Parameter
 *  @param hasPhoto: Optional Parameter 
 *  @param minAge: Optional Parameter
 *  @param maxAge: Optional Parameter
 *  @param location: Optional Parameter
 *  @param distance: Optional Parameter 
 *  @param latitude: Optional Parameter 
 *  @param longitude: Optional Parameter
 *  @param culture: Optional Parameter 
 *  @return NSString representing ProfileComments object.
 */
-(NSString*) searchPeople:(NSString*)searchTerms format:(NSString*)format count:(NSString*)count startPage:(NSString*)startPage
				 searchBy:(NSString*)searchBy gender:(NSString*)gender hasPhoto:(NSString*)hasPhoto minAge:(NSString*)minAge maxAge:(NSString*)maxAge
				 location:(NSString*)location distance:(NSString*)distance latitude:(NSString*)latitude longitude:(NSString*)longitude culture:(NSString*)culture
			  countryCode:(NSString*)countryCode{
	MSOpenSearchApi *searchApi = [MSOpenSearchApi apiWithContext:[self getContext]];
	searchApi.methodName = @"searchPeople";
	return [searchApi searchPeople:searchTerms format:format count:count startPage:startPage searchBy:searchBy 
							gender:gender hasPhoto:hasPhoto minAge:minAge maxAge:maxAge location:location 
						  distance:distance latitude:latitude longitude:longitude culture:culture countryCode:countryCode];
}

#pragma mark --Image Search--

/*
 *  OpenSearch v1 searchImages
 *  Resource:http://api.myspace.com/opensearch/images
 *  Details:  http://wiki.developer.myspace.com/index.php?title=Open_Search
 *  Refer to the documentation for optional parameters. User queryParameters for optional parameters.
 *  Description: Image Search
 *  @param searchTerms:  search terms
 *  @return NSString representing ProfileComments object.
 */
-(NSString*) searchImages:(NSString*)searchTerms{
	MSOpenSearchApi *searchApi = [MSOpenSearchApi apiWithContext:[self getContext]];
	searchApi.methodName = @"searchImages";
	return [searchApi searchImages:searchTerms];
}

/*
 *  OpenSearch v1 searchImages
 *  Resource:http://api.myspace.com/opensearch/images
 *  Details:  http://wiki.developer.myspace.com/index.php?title=Open_Search
 *  Refer to the documentation for optional parameters. User queryParameters for optional parameters.
 *  Description: Image Search
 *  @param searchTerms:  search terms
 *  @param queryParameters: Any queryParameters that are desired in the request. See the documentation for options.
 *  @return NSString representing ProfileComments object.
 */
-(NSString*) searchImages:(NSString*)searchTerms queryParameters:(NSMutableDictionary*)queryParameters{
	MSOpenSearchApi *searchApi = [MSOpenSearchApi apiWithContext:[self getContext]];
	searchApi.methodName = @"searchImages";
	return [searchApi searchImages:searchTerms queryParameters:queryParameters];
}

/*
 *  OpenSearch v1 searchImages
 *  Resource:http://api.myspace.com/opensearch/images
 *  Details:  http://wiki.developer.myspace.com/index.php?title=Open_Search
 *  Refer to the documentation for optional parameters. User queryParameters for optional parameters.
 *  Description: People Search
 *  @param searchTerms:  search terms
 *  @param format: Optional Parameter
 *  @param count: Optional Parameter
 *  @param startPage: Optional Parameter
 *  @param culture: Optional Parameter 
 *  @param sortBy: Optional Parameter 
 *  @param sortOrder: Optional Parameter 
 *  @return NSString representing ProfileComments object.
 */
-(NSString*) searchImages:(NSString*)searchTerms format:(NSString*)format count:(NSString*)count startPage:(NSString*)startPage
				  culture:(NSString*)culture sortBy:(NSString*)sortBy sortOrder:(NSString*)sortOrder{
	MSOpenSearchApi *searchApi = [MSOpenSearchApi apiWithContext:[self getContext]];
	searchApi.methodName = @"searchImages";
	return [searchApi searchImages:searchTerms format:format count:count startPage:startPage culture:culture sortBy:sortBy sortOrder:sortOrder];
}

#pragma mark --Video Search--
/*
 *  OpenSearch v1 searchVideos
 *  Resource:http://api.myspace.com/opensearch/videos
 *  Details:  http://wiki.developer.myspace.com/index.php?title=Open_Search
 *  Refer to the documentation for optional parameters. User queryParameters for optional parameters.
 *  Description: Video Search
 *  @param searchTerms:  search terms
 *  @return NSString representing ProfileComments object.
 */
-(NSString*) searchVideos:(NSString*)searchTerms{
	MSOpenSearchApi *searchApi = [MSOpenSearchApi apiWithContext:[self getContext]];
	searchApi.methodName = @"searchVideos";
	return [searchApi searchVideos:searchTerms];	
}

/*
 *  OpenSearch v1 searchVideos
 *  Resource:http://api.myspace.com/opensearch/videos
 *  Details:  http://wiki.developer.myspace.com/index.php?title=Open_Search
 *  Refer to the documentation for optional parameters. User queryParameters for optional parameters.
 *  Description: Video Search
 *  @param searchTerms:  search terms
 *  @param queryParameters: Any queryParameters that are desired in the request. See the documentation for options.
 *  @return NSString representing ProfileComments object.
 */
-(NSString*) searchVideos:(NSString*)searchTerms queryParameters:(NSMutableDictionary*)queryParameters{
	MSOpenSearchApi *searchApi = [MSOpenSearchApi apiWithContext:[self getContext]];
	searchApi.methodName = @"searchVideos";
	return [searchApi searchVideos:searchTerms queryParameters:queryParameters];
}

/*
 *  OpenSearch v1 searchVideos
 *  Resource:http://api.myspace.com/opensearch/images
 *  Details:  http://wiki.developer.myspace.com/index.php?title=Open_Search
 *  Refer to the documentation for optional parameters. User queryParameters for optional parameters.
 *  Description: Videos Search
 *  @param searchTerms:  search terms
 *  @param format: Optional Parameter
 *  @param count: Optional Parameter
 *  @param startPage: Optional Parameter
 *  @param culture: Optional Parameter 
 *  @param tag: Optional Parameter 
 *  @param videoMode: Optional Parameter 
 *  @return NSString representing ProfileComments object.
 */
-(NSString*) searchVideos:(NSString*)searchTerms format:(NSString*)format count:(NSString*)count startPage:(NSString*)startPage
				  culture:(NSString*)culture tag:(NSString*)tag videoMode:(NSString*)videoMode{
	MSOpenSearchApi *searchApi = [MSOpenSearchApi apiWithContext:[self getContext]];
	searchApi.methodName = @"searchVideos";
	return [searchApi searchVideos:searchTerms format:format count:count startPage:startPage culture:culture tag:tag videoMode:videoMode];
}


@end

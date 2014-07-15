//
//  MSRoaApi.h
//  MySpaceID.Demo
//
//  Copyright MySpace, Inc. 2010. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSSecurityContext.h"

@protocol MySpaceDelegate;
@interface MSRoaApi : NSObject<OAResponseDelegate> {
	MSSecurityContext *context;
	NSData *responseData;
	NSInteger responseStatusCode;
	NSHTTPURLResponse *httpResponse;
	NSString *methodName;
}

@property (nonatomic, assign) MSSecurityContext* context;
@property (nonatomic, assign) NSData* responseData;
@property (nonatomic, assign) NSInteger responseStatusCode;
@property (nonatomic, assign) NSHTTPURLResponse *httpResponse;
@property (nonatomic, assign) NSString *methodName;

+ (MSRoaApi*) apiWithContext:(MSSecurityContext*) context;

#pragma mark --People--

- (NSString*) getPerson:(NSString*)personId queryParameters:(NSDictionary*)queryParameters;
- (NSString*) getFriends:(NSString*)personId queryParameters:(NSDictionary*)queryParameters;
- (NSString*) getGroup:(NSString*)personId groupId:(NSString*)groupId queryParameters:(NSDictionary*)queryParameters;

#pragma mark --Albums--

- (NSString*) getAlbums:(NSString*)personId queryParameters:(NSDictionary*)queryParameters;
- (NSString*) addAlbum:(NSString*)personId caption:(NSString*)caption location:(NSString*)location 
	   queryParameters:(NSDictionary*)queryParameters;
- (NSString*) updateAlbum:(NSString*)personId albumId:(NSString*)albumId caption:(NSString*)caption location:(NSString*)location
		queryParameters:(NSDictionary*)queryParameters;

#pragma mark --MediaItems--
- (NSString*) getMediaItems:(NSString*)personId albumId:(NSString*)albumId queryParameters:(NSDictionary*)queryParameters;
- (NSString*) getFriendMediaItems:(NSString*)personId albumId:(NSString*)albumId queryParameters:(NSDictionary*)queryParameters;
- (NSString*) getMediaItem:(NSString*)personId albumId:(NSString*)albumId mediaItemId:(NSString*)mediaItemId 
queryParameters:(NSDictionary*)queryParameters;
- (NSString*) getSupportedVideoCategories:(NSString*)personId queryParameters:(NSDictionary*)queryParameters;
- (NSString*) updateMediaItem:(NSString*)personId albumId:(NSString*)albumId mediaItemId:(NSString*)mediaItemId
					title:(NSString*)title queryParameters:(NSDictionary*)queryParameters;
- (NSString*) addPhoto:(NSString*)personId albumId:(NSString*)albumId 
		  caption:(NSString*)caption photoData:(NSData*)photoData imageType:(NSString*) imageType 
	      queryParameters:(NSDictionary*)queryParameters;
- (NSString*) addVideo:(NSString*)personId albumId:(NSString*)albumId 
			   caption:(NSString*)caption videoData:(NSData*)videoData videoType:(NSString*) videoType 
		   description:(NSString*) description tags:(NSArray*)tags msCategories:(NSString*)msCategories
			  language:(NSString*) language queryParameters:(NSDictionary*)queryParameters;


#pragma mark --MediaItemComments--

- (NSString*) getMediaItemComments:(NSString*)personId albumId:(NSString*)albumId mediaItemId:(NSString*)mediaItemId
				 queryParameters:(NSDictionary*)queryParameters;


#pragma mark --Activities--

- (NSString*) getActivities:(NSString*)personId appId:(NSString*)appId queryParameters:(NSDictionary*)queryParameters;
- (NSString*) getFriendActivities:(NSString*)personId appId:(NSString*)appId queryParameters:(NSDictionary*)queryParameters;
- (NSString*) createActivity:(NSString*)templateId title:(NSString*)title body:(NSString*)body templateParameters:(NSArray*)templateParameters activityId:(NSString*)activityId
				queryParameters:(NSDictionary*)queryParameters;

#pragma mark --AppData--
- (NSString*) getAppData:(NSString*)personId selector:(NSString*)selector appId:(NSString*)appId queryParameters:(NSDictionary*)queryParameters;
- (NSString*) addAppData:(NSString*)personId userId:(NSString*)userId selector:(NSString*)selector appId:(NSString*)appId keys:(NSArray*)keys 
		   values:(NSArray*)values queryParameters:(NSDictionary*)queryParameters;
- (NSString*) deleteAppData:(NSString*)personId selector:(NSString*)selector appId:(NSString*)appId keys:(NSArray*)keys queryParameters:(NSDictionary*)queryParameters;

#pragma mark --Groups--
- (NSString*) getGroups:(NSString*)personId queryParameters:(NSDictionary*)queryParameters;

#pragma mark --StatusMood--
- (NSString*) getSupportedMoods:(NSString*)personId queryParameters:(NSDictionary*)queryParameters;
- (NSString*) getSingleMood:(NSString*)personId moodId:(NSString*)moodId queryParameters:(NSDictionary*)queryParameters;
- (NSString*) getPersonMoodStatus:(NSString*)personId queryParameters:(NSDictionary*)queryParameters;
- (NSString*) getFriendsMoodStatus:(NSString*)personId includeHistory:(BOOL)includeHistory 
				queryParameters:(NSDictionary*)queryParameters;
- (NSString*) getFriendMoodStatus:(NSString*)personId friendId:(NSString*)friendId includeHistory:(BOOL)includeHistory 
				  queryParameters:(NSDictionary*)queryParameters;
- (NSString*) updatePersonMoodStatus:(NSString*)personId moodName:(NSString*)moodName status:(NSString*)status
						  latitude:(NSString*)latitude longitude:(NSString*)longitude queryParameters:(NSDictionary*)queryParameters;

#pragma mark --StatusMood Comments--

- (NSString*) getStatusMoodComments:(NSString*)personId statusId:(NSString*)statusId  queryParameters:(NSDictionary*)queryParameters;
- (NSString*) addStatusMoodComment:(NSString*) persondId statusId:(NSString*)statusId body:(NSString*)body 
				 queryParameters:(NSDictionary*)queryParameters;
#pragma mark --Notifications--

- (NSString*) sendNotification:(NSString*)personId recipientIds:(NSArray*)recipientIds mediaItems:(NSArray*)mediaItems 
		  templateParameters:(NSArray*)templateParameters queryParameters:(NSDictionary*)queryParameters;

#pragma mark --ProfileComments--
- (NSString*) getProfileComments:(NSString*)personId queryParameters:(NSDictionary*)queryParameters;


#pragma mark --Raw Requests--

- (NSString*) makeRawOSRequest:(NSString*)uri queryParameters:(NSDictionary*)queryParams requestMethod:(NSString*)requestMethod
				 requestBody:(NSData*)requestBody contentType:(NSString*)contentType;
- (NSMutableDictionary*) makeQueryDictionary:(NSArray*) fields 
									   count:(NSString*)count filterBy:(NSString*)filterBy filterOp:(NSString*)filterOp 
								 filterValue:(NSString*)filterValue format:(NSString*)format statusId:(NSString*)statusId
								  postedDate:(NSString*)postedDate startIndex:(NSString*)startIndex updatedSince:(NSString*) updatedSince;

@end
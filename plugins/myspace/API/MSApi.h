//
//  MSApi.h
//  MySpaceID.Demo
//
//  Copyright MySpace, Inc. 2010. All rights reserved.
//

#import "MSSecurityContext.h"
#import "MSOffsiteContext.h"
#import "MSOnsiteContext.h"
#import "MSRoaApi.h"
#import "MSRestV1.h"
#import "MSOpenSearchApi.h"

@protocol MSRequest;
@interface MSApi : NSObject {
	NSString *consumerKey;
	NSString *consumerSecret;
	NSString *accessKey;
	NSString *accessSecret;
	NSString *urlScheme;
	MSSecurityContext *context;
	BOOL isOnsite;
	id<MSRequest> delegate;
}

@property (nonatomic, retain) NSString *consumerKey;
@property (nonatomic, retain) NSString *consumerSecret;
@property (nonatomic, retain) NSString *accessKey;
@property (nonatomic, retain) NSString *accessSecret;
@property (nonatomic, retain) NSString *urlScheme;
@property (nonatomic, retain) MSSecurityContext *context;
@property (nonatomic) BOOL isOnsite;
@property (nonatomic, retain) id<MSRequest> delegate;

+ (MSApi*) sdkWith:(NSString*)consumerKey consumerSecret:(NSString*)consumerSecret 
		   accessKey:(NSString*)accessKey	accessSecret:(NSString*)accessSecret isOnsite:(BOOL)isOnsite 
		   urlScheme:(NSString*)urlScheme delegate:(id<MSRequest>) delegate;

#pragma mark --Security--
- (MSSecurityContext*) getContext;
- (void) getRequestToken;
- (void) getAccessToken;
- (BOOL) isLoggedIn;
- (void) endSession;

#pragma mark --Person--
- (NSString*) getPerson:(NSString*)personId queryParameters:(NSDictionary*)queryParameters;
- (NSString*) getFriends:(NSString*)personId queryParameters:(NSDictionary*)queryParameters;
- (NSString*) getGroup:(NSString*)personId groupId:(NSString*)groupId queryParameters:(NSDictionary*)queryParameters;
- (NSString*) getFriendship:(NSString*)personId friendId:(NSArray*)friendIds;

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

- (NSString*) getActivities:(NSString*)userId activityTypes:(NSString*)activityTypes	extensions:(NSString*)extensions
				  composite:(NSString*)composite culture:(NSString*)culture datetime:(NSString*)dateTime	pageSize:(NSString*)pageSize;
- (NSString*) getFriendActivities:(NSString*) userId activityTypes:(NSString*)activityTypes	extensions:(NSString*)extensions
						composite:(NSString*)composite culture:(NSString*)culture datetime:(NSString*)dateTime	pageSize:(NSString*)pageSize;
- (NSString*) createActivity:(NSString*)templateId title:(NSString*)title body:(NSString*)body templateParameters:(NSArray*)templateParameters activityId:(NSString*)activityId
			 queryParameters:(NSDictionary*)queryParameters;

#pragma mark --AppData--
- (NSString*) getAppData:(NSString*)personId selector:(NSString*)selector appId:(NSString*)appId queryParameters:(NSDictionary*)queryParameters;
- (NSString*) addAppData:(NSString*)personId userId:(NSString*)userId selector:(NSString*)selector appId:(NSString*)appId keys:(NSArray*)keys 
				  values:(NSArray*)values queryParameters:(NSDictionary*)queryParameters;
- (NSString*) deleteAppData:(NSString*)personId selector:(NSString*)selector appId:(NSString*)appId keys:(NSArray*)keys queryParameters:(NSDictionary*)queryParameters;
- (NSString*) getGlobalAppData:(NSArray*)keys queryParameters:(NSDictionary*)queryParameters;
- (NSString*) addGlobalAppData:(NSDictionary*)globalAppDataPairs  queryParameters:(NSDictionary*)queryParameters;
- (NSString*) deleteGlobalAppData:(NSArray*)keys queryParameters:(NSDictionary*)queryParameters;

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

#pragma mark --Alerts--
- (NSString*) getIndicators:(NSString*)personId;

#pragma mark --ProfileComments--
- (NSString*) getProfileComments:(NSString*)personId queryParameters:(NSDictionary*)queryParameters;

#pragma mark --OpenSearch--
#pragma mark --People Search--
-(NSString*) searchPeople:(NSString*)searchTerms;
-(NSString*) searchPeople:(NSString*)searchTerms queryParameters:(NSMutableDictionary*)queryParameters;
-(NSString*) searchPeople:(NSString*)searchTerms format:(NSString*)format count:(NSString*)count startPage:(NSString*)startPage
				 searchBy:(NSString*)searchBy gender:(NSString*)gender hasPhoto:(NSString*)hasPhoto minAge:(NSString*)minAge maxAge:(NSString*)maxAge
				 location:(NSString*)location distance:(NSString*)distance latitude:(NSString*)latitude longitude:(NSString*)longitude culture:(NSString*)culture
			  countryCode:(NSString*)countryCode;

#pragma mark --Image Search--
-(NSString*) searchImages:(NSString*)searchTerms;
-(NSString*) searchImages:(NSString*)searchTerms queryParameters:(NSMutableDictionary*)queryParameters;
-(NSString*) searchImages:(NSString*)searchTerms format:(NSString*)format count:(NSString*)count startPage:(NSString*)startPage
				  culture:(NSString*)culture sortBy:(NSString*)sortBy sortOrder:(NSString*)sortOrder;

#pragma mark --Video Search--
-(NSString*) searchVideos:(NSString*)searchTerms;
-(NSString*) searchVideos:(NSString*)searchTerms queryParameters:(NSMutableDictionary*)queryParameters;
-(NSString*) searchVideos:(NSString*)searchTerms format:(NSString*)format count:(NSString*)count startPage:(NSString*)startPage
				  culture:(NSString*)culture tag:(NSString*)tag videoMode:(NSString*)videoMode;

@end

@protocol MSRequest<NSObject>
@optional
- (void)api:(id)sender didFinishMethod:(NSString*) methodName withValue:(NSString*) value  withStatusCode:(NSInteger)statusCode;
- (void)api:(id)sender didFailMethod:(NSString*) methodName withError:(NSError*) error;

@end

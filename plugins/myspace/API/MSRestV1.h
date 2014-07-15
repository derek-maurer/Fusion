//
//  MSMSRoaApi.h
//
//  Copyright MySpace, Inc. 2010. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSSecurityContext.h"
#import "MSOffsiteContext.h"


@interface MSRestV1 : NSObject<OAResponseDelegate> {
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

+ (MSRestV1*) apiWithContext:(MSSecurityContext*) context;
- (NSString*) getCurrentUser;
- (NSString*) getUser:(NSInteger) userId;
- (NSString*) getMood:(NSInteger) userId;
- (NSString*) getMoodsList: (NSInteger) userId;
- (void) setMoodStatus:(NSInteger)userId moodId:(NSInteger)moodId moodName:(NSString*)moodName moodPictureName:(NSString*)moodPictureName status:(NSString*) status;
- (NSString*) getAlbums:(NSInteger)userId;
- (NSString*) getAlbums:(NSInteger)userId page:(NSInteger)page pageSize:(NSInteger)pageSize;
- (NSString*) getAlbum: (NSInteger) userId albumId: (NSInteger) albumId;
- (NSString*) getFriends: (NSInteger) userId;
- (NSString*) getFriends: (NSInteger) userId page:(NSInteger) page pageSize:(NSInteger) pageSize;
- (NSString*) getFriendStatus: (NSInteger) userId;
- (NSString*) getFriendship: (NSInteger) userId friendIds: (NSArray*) friendIds;
- (NSString*) getPhotos: (NSInteger) userId;
- (NSString*) getPhotos: (NSInteger) userId page:(NSInteger) page pageSize:(NSInteger) pageSize;
- (NSString*) getPhoto: (NSInteger) userId photoId: (NSInteger) photoId;
- (NSString*) getFullProfile: (NSInteger) userId;
- (NSString*) getBasicProfile: (NSInteger) userId;
- (NSString*) getExtendedProfile: (NSInteger) userId;
- (NSString*) getStatus: (NSInteger) userId;
- (NSString*) getVideos: (NSInteger) userId;
- (NSString*) getVideos: (NSInteger) userId page:(NSInteger) page pageSize:(NSInteger) pageSize;
- (NSString*) getVideo: (NSInteger) userId videoId: (NSInteger) videoId;
- (NSString*) getGlobalAppData;
- (NSString*) getGlobalAppData: (NSArray*) keys;
- (NSString*) addGlobalAppData: (NSDictionary*) globalAppDataPairs;
- (NSString*) deleteGlobalAppData: (NSArray*) keys;
- (NSString*) addUserAppData: (NSInteger) userId userAppDataPairs: (NSDictionary*) userAppDataPairs;
- (NSString*) deleteUserAppData: (NSInteger) userId keys: (NSArray*) keys;
- (NSString*) getUserAppData: (NSInteger) userId;
- (NSString*) getUserAppData: (NSInteger) userId keys: (NSArray*) keys;
- (NSString*) getFriendAppData: (NSInteger) userId;
- (NSString*) getFriendAppData: (NSInteger) userId keys: (NSArray*) keys;
- (NSString*) getIndicators: (NSInteger) userId;
- (void) sendNotification: (NSInteger) appId recipients: (NSArray*) recipients content: (NSString*) content button0Surface:(NSString*) button0Surface button0Label:(NSString*) button0Label button1Surface:(NSString*) button1Surface button1Label:(NSString*) button1Label mediaItem: (NSString*) mediaItem;


- (NSString*) getActivities:(NSString*)userId activityTypes:(NSString*)activityTypes	extensions:(NSString*)extensions
				  composite:(NSString*)composite culture:(NSString*)culture datetime:(NSString*)dateTime	pageSize:(NSString*)pageSize;
- (NSString*) getFriendActivities:(NSString*) userId activityTypes:(NSString*)activityTypes	extensions:(NSString*)extensions
						composite:(NSString*)composite culture:(NSString*)culture datetime:(NSString*)dateTime	pageSize:(NSString*)pageSize;

#pragma mark --Raw Requests--

- (NSString*) makeRawV1Request:(NSString*)uri queryParameters:(NSDictionary*)queryParams requestMethod:(NSString*)requestMethod
				   requestBody:(NSData*)requestBody contentType:(NSString*)contentType;
- (NSMutableDictionary*) makeQueryDictionary:(NSArray*) fields 
									  format:(NSString*)format activityTypes:(NSString*)activityTypes extensions:(NSString*)extensions
								   composite:(NSString*)composite culture:(NSString*)culture datetime:(NSString*)dateTime pageSize:(NSString*)pageSize;

@end

//
//  MSConstants.m
//  MySpaceID.Demo
//
//  Copyright MySpace, Inc. 2010. All rights reserved.
//

#import "MSConstants.h"


NSString* const MS_ACTIVITY_TYPE_APPLICATION_INSTALLS = @"ApplicationAdd";
NSString* const MS_ACTIVITY_TYPE_APPLICATION_USE = @"ApplicationInnerActivity";
NSString* const MS_ACTIVITY_TYPE_EVENT_POST = @"EventPosting";
NSString* const MS_ACTIVITY_TYPE_EVENT_ATTENDING = @"EventAttending";
NSString* const MS_ACTIVITY_TYPE_EVENT_BANDSHOWS = @"PersonalBandShowUpdate";
NSString* const MS_ACTIVITY_TYPE_MUSIC_SONGPOST = @"SongUpload";
NSString* const MS_ACTIVITY_TYPE_MUSIC_PROFILE_SONG_ADD = @"ProfileSongAdd";
NSString* const MS_ACTIVITY_TYPE_MUSIC_PLAYLIST_EDIT = @"AddSongToPlaylist";
NSString* const MS_ACTIVITY_TYPE_NOTES_STATUS_UPDATES = @"StatusMoodUpdate";
NSString* const MS_ACTIVITY_TYPE_NOTES_BLOG_POST = @"BlogAdd";
NSString* const MS_ACTIVITY_TYPE_NOTES_FORUM_POST = @"ForumPosted";
NSString* const MS_ACTIVITY_TYPE_PEOPLE_FRIEND_ADD = @"FriendAdd";
NSString* const MS_ACTIVITY_TYPE_PEOPLE_GROUP_JOIN = @"JoinedGroup";
NSString* const MS_ACTIVITY_TYPE_PEOPLE_FRIEND_CATEGORY_ADD = @"FriendCategoryAdd";
NSString* const MS_ACTIVITY_TYPE_PHOTO_TAGGED = @"PhotoTagged";
NSString* const MS_ACTIVITY_TYPE_PHOTO_ADD = @"PhotoAdd";
NSString* const MS_ACTIVITY_TYPE_VIDEO_SHARED = @"ProfileVideoUpdate";
NSString* const MS_ACTIVITY_TYPE_VIDEO_ADD = @"VideoAdd";

NSString* const MS_OPENSEARCH_PEOPLE = @"http://api.myspace.com/opensearch/people";
NSString* const MS_OPENSEARCH_IMAGES = @"http://api.myspace.com/opensearch/images";
NSString* const MS_OPENSEARCH_VIDEOS = @"http://api.myspace.com/opensearch/videos";

NSString* const MS_ROA_MEDIA_ITEMS = @"http://opensocial.myspace.com/roa/09/mediaitems/%@/%@/%@";
NSString* const MS_ROA_ALBUMS = @"http://opensocial.myspace.com/roa/09/albums/%@/%@";
NSString* const MS_ROA_MEDIA_ITEMS_COMMENTS = @"http://opensocial.myspace.com/roa/09/mediaitemcomments/%@/@self/%@/%@";
NSString* const MS_ROA_ACTIVITIES = @"http://opensocial.myspace.com/roa/09/activities/%@/%@";
NSString* const MS_ROA_APPDATA = @"http://opensocial.myspace.com/roa/09/appdata/%@/%@/%@";
NSString* const MS_ROA_GROUPS = @"http://opensocial.myspace.com/roa/09/groups/%@";
NSString* const MS_ROA_PEOPLE = @"http://opensocial.myspace.com/roa/09/people/%@/%@";
NSString* const MS_ROA_STATUSMOOD = @"http://opensocial.myspace.com/roa/09/statusmood/%@/%@";
NSString* const MS_ROA_STATUSMOOD_COMMENTS = @"http://opensocial.myspace.com/roa/09/statusmoodcomments/%@/%@";
NSString* const MS_ROA_NOTIFICATIONS = @"http://opensocial.myspace.com/roa/09/notifications/%@/%@";
NSString* const MS_ROA_PROFILE_COMMENTS = @"http://opensocial.myspace.com/roa/09/profilecomments/%@/%@";

NSString* const MS_V1_CURRENT_USER = @"http://api.myspace.com/v1/user.json";
NSString* const MS_V1_USER_ID = @"http://api.myspace.com/v1/users/%@.json";
NSString* const MS_V1_MOOD = @"http://api.myspace.com/v1/users/%@/mood.json";
NSString* const MS_V1_MOODS = @"http://api.myspace.com/v1/users/%@/moods.json";
NSString* const MS_V1_STATUS = @"http://api.myspace.com/v1/users/%@/status.json";
NSString* const MS_V1_ALBUM = @"http://api.myspace.com/v1/users/%@/albums/%@.json";
NSString* const MS_V1_ALBUMS = @"http://api.myspace.com/v1/users/%@/albums.json";
NSString* const MS_V1_FRIENDS = @"http://api.myspace.com/v1/users/%@/friends.json";
NSString* const MS_V1_FRIENDSHIP = @"http://api.myspace.com/v1/users/%@/friends/%@.json";
NSString* const MS_V1_PHOTOS = @"http://api.myspace.com/v1/users/%@/photos.json";
NSString* const MS_V1_PHOTO = @"http://api.myspace.com/v1/users/%@/photos/%@.json";
NSString* const MS_V1_PROFILE = @"http://api.myspace.com/v1/users/%@/profile.json?detailType=%@";
NSString* const MS_V1_VIDEOS = @"http://api.myspace.com/v1/users/%@/videos.json";
NSString* const MS_V1_VIDEO = @"http://api.myspace.com/v1/users/%@/videos/%@.json";
NSString* const MS_V1_ACTIVITIES = @"http://api.myspace.com/v1/users/%@/activities.atom";
NSString* const MS_V1_FRIEND_ACTIVITIES = @"http://api.myspace.com/v1/users/%@/friends/activities.atom";
NSString* const MS_V1_GLOBAL_APP_DATA = @"http://api.myspace.com/v1/appdata/global.xml";
NSString* const MS_V1_GLOBAL_APP_DATA_KEYS = @"http://api.myspace.com/v1/appdata/global/%@";
NSString* const MS_V1_USER_APP_DATA = @"http://api.myspace.com/v1/users/%@/appdata.xml";
NSString* const MS_V1_USER_APP_DATA_KEYS = @"http://api.myspace.com/v1/users/%@/appdata/%@";
NSString* const MS_V1_USER_FRIENDS_APP_DATA = @"http://api.myspace.com/v1/users/%@/friends/appdata.xml";
NSString* const MS_V1_USER_FRIENDS_APP_DATA_KEYS = @"http://api.myspace.com/v1/users/%@/friends/appdata/%@.xml";
NSString* const MS_V1_INDICATORS = @"http://api.myspace.com/v1/users/%@/indicators.json";
NSString* const MS_V1_FRIEND_STATUS = @"http://api.myspace.com/v1/users/%@/friends/status.json";


NSString* const MS_SELECTOR_SELF = @"@self";
NSString* const MS_SELECTOR_ME = @"@me";
NSString* const MS_SELECTOR_FRIENDS = @"@friends";
NSString* const MS_SELECTOR_ALL = @"all";
NSString* const MS_SELECTOR_SUPPORTED_FIELDS = @"@supportedFields";
NSString* const MS_SELECTOR_VIDEOS = @"@videos";
NSString* const MS_SELECTOR_APP = @"@app";
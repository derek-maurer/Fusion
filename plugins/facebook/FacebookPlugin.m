#import "FacebookPlugin.h"
#import "API/SBJSON.h"

static NSString *kAppID = @"200064460066186";
static NSString *PREFS_FILE = @"/User/Library/Preferences/com.homeschooldev.FacebookPluginPrefs.plist";
static NSString *Location = @"/User/Library/Preferences/com.homeschooldev.FacebookLocation.plist";
static BOOL kPostSimpleStatus = NO;
static BOOL kUploadImage = NO;
static BOOL kPostThumbnailStatus = NO;
static BOOL kGetImageLink = NO;
static BOOL kPostStatusWithLinks = NO;
static BOOL kCheckAlbumExists = NO;
static BOOL albumExists = NO;

@implementation FacebookPlugin
@synthesize delegate, message, location, images;

+ (int)maxCharacterCount {
    return 2000;
}

- (id)initWithMessage:(NSString *)mes images:(NSArray *)imgs location:(CLLocation *)loc andDelegate:(id<FusionPluginDelegate>)del {
    if ((self = [super init])) {

    	self.delegate = del;
    	self.message = mes;
    	self.location = loc;
    	self.images = imgs;
        
        facebook = [[Facebook alloc] initWithAppId:kAppID andDelegate:self];
        imageIDs = [[NSMutableArray alloc] init];
        imageURLs = [[NSMutableArray alloc] init];
        
        NSMutableDictionary *prefs;
        if ([[NSFileManager defaultManager] fileExistsAtPath:PREFS_FILE])
            prefs = [NSMutableDictionary dictionaryWithContentsOfFile:PREFS_FILE];
        else 
            prefs = [NSMutableDictionary dictionary];
        
        if (![prefs objectForKey:@"FirstTime"]) {
            if ([prefs objectForKey:@"FBAccessTokenKey"] || [prefs objectForKey:@"FBExpirationDateKey"]) {
                //First time running the plugin, but a token existed from a previous install... We need to remove it.
                [prefs removeObjectForKey:@"FBAccessTokenKey"];
                [prefs removeObjectForKey:@"FBExpirationDateKey"];
            }
            //set the firstname key to no so this doesn't run again...
            [prefs setObject:@"NO" forKey:@"FirstTime"];
            [prefs writeToFile:PREFS_FILE atomically:YES];
        }
        
        if ([prefs objectForKey:@"FBAccessTokenKey"] && [prefs objectForKey:@"FBExpirationDateKey"]) {
            facebook.accessToken = [prefs objectForKey:@"FBAccessTokenKey"];
            facebook.expirationDate = [prefs objectForKey:@"FBExpirationDateKey"];
        }
        
        if (![facebook isSessionValid]) {
            [delegate postMessage:@"Please go into the facebook plugin settings and authenticate the service"];
        }
        else {        
           	if (imgs && imgs.count > 0) 
           		[self checkAlbumsExistence];
           	else
           		[self postSimpleStatus];
        }
    }
    return self;
}

- (void)checkAlbumsExistence {
    kCheckAlbumExists = YES;
    
    NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:PREFS_FILE];
    facebook.accessToken = [prefs objectForKey:@"FBAccessTokenKey"];
    facebook.expirationDate = [prefs objectForKey:@"FBExpirationDateKey"];
    [facebook requestWithGraphPath:@"me/albums" andDelegate:self];
}

- (void)uploadImage:(UIImage*)image {
	kUploadImage = YES;
	NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:PREFS_FILE];    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSMutableDictionary *locationDict = [NSDictionary dictionaryWithContentsOfFile:Location];
    
    if (![prefs objectForKey:@"suppress"] || [[prefs objectForKey:@"suppress"] boolValue])
    	[params setObject:@"1" forKey:@"no_story"];
    if (message && ![message isEqualToString:@""]) [params setObject:message forKey:@"message"];
    
    NSData *imageData = UIImagePNGRepresentation(image);
    [params setObject:imageData forKey:@"source"];
	
	if ([locationDict objectForKey:@"Venue"]) [params setObject:[locationDict objectForKey:@"Venue"] forKey:@"place"];
    
    NSString *path;
    if (![prefs objectForKey:@"SelectedAlbumID"] || [[prefs objectForKey:@"SelectedAlbumID"] isEqualToString:@"Fusion Photos"]) 
        //The album ID did not exist or the album ID was set to Fusion Photos
    	path = @"me/photos";
    else if (albumExists)
        //The album ID existed, was not 'Fusion Photos', and the album ID exists on Facebook
    	path = [NSString stringWithFormat:@"%@/photos",[prefs objectForKey:@"SelectedAlbumID"]];
    else    
        //The album ID didn't exist on Facebook, just upload to 'Fusion Photos'
        path = @"me/photos";
            
	facebook.accessToken = [prefs objectForKey:@"FBAccessTokenKey"];
    facebook.expirationDate = [prefs objectForKey:@"FBExpirationDateKey"];
    [facebook requestWithGraphPath:path andParams:params andHttpMethod:@"POST" andDelegate:self];
}

- (void)getImageLinkForID:(NSString*)ID {
	kGetImageLink = YES;
	
	NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:PREFS_FILE];
	facebook.accessToken = [prefs objectForKey:@"FBAccessTokenKey"];
    facebook.expirationDate = [prefs objectForKey:@"FBExpirationDateKey"];
	[facebook requestWithGraphPath:ID andDelegate:self];
}

- (void)postSimpleStatus {
	kPostSimpleStatus = YES;
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSMutableDictionary *locationDict = [NSDictionary dictionaryWithContentsOfFile:Location];
    NSString *path = @"feed";
    [params setObject:@"status" forKey:@"type"];
    if (message && ![message isEqualToString:@""]) [params setObject:message forKey:@"message"];
    if (location) {
		SBJSON *jsonWriter = [[SBJSON new] autorelease];
		NSMutableDictionary *coordinatesDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
				[NSString stringWithFormat: @"%f", location.coordinate.latitude], @"latitude",
				[NSString stringWithFormat: @"%f", location.coordinate.longitude], @"longitude", nil];
		NSString *coordinates = [jsonWriter stringWithObject:coordinatesDictionary];
		if ([locationDict objectForKey:@"Venue"]) [params setObject:[locationDict objectForKey:@"Venue"] forKey:@"place"];
		if (coordinates) [params setObject:coordinates forKey:@"coordinates"];
		path = @"me/checkins";
    }
        
    NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:PREFS_FILE];
	facebook.accessToken = [prefs objectForKey:@"FBAccessTokenKey"];
    facebook.expirationDate = [prefs objectForKey:@"FBExpirationDateKey"];
    [facebook requestWithGraphPath:path andParams:params andHttpMethod:@"POST" andDelegate:self];
}

- (void)postStatusWithThumbnailImageID:(NSString *)ID {
	kPostThumbnailStatus = YES;
	
	NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:PREFS_FILE];
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:message forKey:@"message"];
	if (location) {
		NSMutableDictionary *locationDict = [NSDictionary dictionaryWithContentsOfFile:Location];
		SBJSON *jsonWriter = [[SBJSON new] autorelease];
		NSMutableDictionary *coordinatesDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                      [NSString stringWithFormat: @"%f", location.coordinate.latitude], @"latitude",
                                                      [NSString stringWithFormat: @"%f", location.coordinate.longitude], @"longitude", nil];
		NSString *coordinates = [jsonWriter stringWithObject:coordinatesDictionary];
		if ([locationDict objectForKey:@"Venue"]) [params setObject:[locationDict objectForKey:@"Venue"] forKey:@"place"];
		if (coordinates) [params setObject:coordinates forKey:@"coordinates"];
    }
    [params setObject:ID forKey:@"object_attachment"];
	facebook.accessToken = [prefs objectForKey:@"FBAccessTokenKey"];
    facebook.expirationDate = [prefs objectForKey:@"FBExpirationDateKey"];
	[facebook requestWithGraphPath:@"feed" andParams:params andHttpMethod:@"POST" andDelegate:self];
}	

- (void)postStatusWithImageURLs {
	kPostStatusWithLinks = YES;
	
	NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:PREFS_FILE];
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	if (location) {
		NSMutableDictionary *locationDict = [NSDictionary dictionaryWithContentsOfFile:Location];
		SBJSON *jsonWriter = [[SBJSON new] autorelease];
		NSMutableDictionary *coordinatesDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
				[NSString stringWithFormat: @"%f", location.coordinate.latitude], @"latitude",
				[NSString stringWithFormat: @"%f", location.coordinate.longitude], @"longitude", nil];
		NSString *coordinates = [jsonWriter stringWithObject:coordinatesDictionary];
		if ([locationDict objectForKey:@"Venue"]) [params setObject:[locationDict objectForKey:@"Venue"] forKey:@"place"];
		if (coordinates) [params setObject:coordinates forKey:@"coordinates"];
    }
	NSString *newMessage = [NSString stringWithFormat:@"%@",message];
	for (NSString *link in imageURLs) 
		newMessage = [NSString stringWithFormat:@"%@ %@",newMessage,link];
	[params setObject:newMessage forKey:@"message"];
    facebook.accessToken = [prefs objectForKey:@"FBAccessTokenKey"];
    facebook.expirationDate = [prefs objectForKey:@"FBExpirationDateKey"];
	[facebook requestWithGraphPath:@"feed" andParams:params andHttpMethod:@"POST" andDelegate:self];
}

//*************Facebook delegate methods*************//
- (void)request:(FBRequest *)request didLoad:(id)result {
	if (kUploadImage) {
		//Finished uploading an image...
		kUploadImage = NO;
        
		[imageIDs addObject:[result objectForKey:@"id"]];
		
		if (imageIDs.count == images.count) {
			//Finished uploading all images... If insert as links is enabled, get the links to the images.
			//If not, post the status with the last image as the thumbnail.
            NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:PREFS_FILE];
			if (![prefs objectForKey:@"PhotoLinks"] || ![[prefs objectForKey:@"PhotoLinks"] boolValue]) {
				//Post as thumbnails
				[self postStatusWithThumbnailImageID:[result objectForKey:@"id"]];
			}
			else {
				//Post as links
				[self getImageLinkForID:[imageIDs objectAtIndex:0]];
			}
		}
		else {
			//Uploading images isn't finished... Upload next image.
			[self uploadImage:[images objectAtIndex:imageIDs.count]];
		}
	}
    else if (kCheckAlbumExists) {
        kCheckAlbumExists = NO;
        
        NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:PREFS_FILE];
        
        NSArray *data = [result objectForKey:@"data"];
        for (NSDictionary *item in data) {
            if ([prefs objectForKey:@"SelectedAlbumID"] && [[prefs objectForKey:@"SelectedAlbumID"] isEqualToString:[item objectForKey:@"id"]]) {
                albumExists = YES;
                break;
            }
        }
        
        [self uploadImage:[images objectAtIndex:0]];
    }
	else if (kPostSimpleStatus) {
		//Posted normal status... Do nothing...
		kPostSimpleStatus = NO;
        
        NSMutableDictionary *locationDict = [NSDictionary dictionaryWithContentsOfFile:Location];
        [locationDict setObject:@"" forKey:@"Venue"];
        [locationDict writeToFile:Location atomically:YES];
        
        //*********** REQUIRED **********//
        [delegate postComplete];
	}
	else if (kPostThumbnailStatus) {
		kPostThumbnailStatus = NO;
        
        //Let the user know that the album no longer exists...
        if (!albumExists) {
            NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:PREFS_FILE];
            [delegate postMessage:[NSString stringWithFormat:@"%@ no longer exists. Uploaded photos to 'Fusion Photos'",[prefs objectForKey:@"SelectedAlbum"]]];
        }
        
        NSMutableDictionary *locationDict = [NSDictionary dictionaryWithContentsOfFile:Location];
        [locationDict setObject:@"" forKey:@"Venue"];
        [locationDict writeToFile:Location atomically:YES];
        
        //*********** REQUIRED **********//
        [delegate postComplete];
	}
	else if (kGetImageLink) {
		kGetImageLink = NO;
		
		[imageURLs addObject:[result objectForKey:@"link"]];
		
		if (imageURLs.count == imageIDs.count) {
			//Finished getting all URLs for the images... Let's post!
			[self postStatusWithImageURLs];
		}	
		else {
			//Not finished getting all the URLs. Let's fetch another one.
			[self getImageLinkForID:[imageIDs objectAtIndex:imageURLs.count]];
		}
	}
	else if (kPostStatusWithLinks) {
		kPostStatusWithLinks = NO;
        
        //Let the user know that the album no longer exists...
        if (!albumExists) {
            NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:PREFS_FILE];
            [delegate postMessage:[NSString stringWithFormat:@"%@ no longer exists. Uploaded photos to 'Fusion Photos'",[prefs objectForKey:@"SelectedAlbum"]]];
        }
        
        NSMutableDictionary *locationDict = [NSDictionary dictionaryWithContentsOfFile:Location];
        [locationDict setObject:@"" forKey:@"Venue"];
        [locationDict writeToFile:Location atomically:YES];
        
        //*********** REQUIRED **********//
        [delegate postComplete];
	}
}
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
	NSLog(@"Failed to post with error: %@",error);
    [delegate postMessage:[NSString stringWithFormat:@"Failed to post status to Facebook with error: %@",[error localizedDescription]]];
    
    //*********** REQUIRED **********//
    [delegate postComplete];
}
- (void)fbDidLogin {}
- (void)fbDidLogout {}
- (void)fbDidNotLogin:(BOOL)cancelled {}
- (void)fbDidExtendToken:(NSString*)accessToken expiresAt:(NSDate*)expiresAt {}
- (void)fbSessionInvalidated {}
//**************************************************//

- (void)dealloc {
	[delegate release];
    [message release];
    [location release];
    [imageURLs release];
    [imageIDs release];
    if (images) [images release];
    
    [super dealloc];
}

@end

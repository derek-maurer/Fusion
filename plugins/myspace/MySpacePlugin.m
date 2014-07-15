#import "MyspacePlugin.h"

static NSString *PREFS_FILE = @"/User/Library/Preferences/com.homeschooldev.MySpacePluginPrefs.plist";
static NSString *consumer_key = @"1d4883995484493bace84419c5dd7b57";
static NSString *consumer_secret = @"566d9e6beb8943bca4d1cfdd623251931a4cb884fa754dd3a365ac8d7a0c092f";

@implementation MySpacePlugin
@synthesize personId, location, message, images, urls, delegate;

+ (int)maxCharacterCount {
    return 190;
}

- (id)initWithMessage:(NSString *)message_ images:(NSArray *)images_ location:(CLLocation *)location_ andDelegate:(id<FusionPluginDelegate>)delegate_ {
    if ((self = [super init])) {
    
    	NSLog(@"MySpace: message: %@ length %i",message_,[message_ length]);
        
        NSMutableDictionary *accessDict;
        if ([[NSFileManager defaultManager] fileExistsAtPath:PREFS_FILE])
            accessDict = [NSMutableDictionary dictionaryWithContentsOfFile:PREFS_FILE];
        else 
            accessDict = [NSMutableDictionary dictionary];
        
        if (![accessDict objectForKey:@"FirstTime"]) {
            if ([accessDict objectForKey:@"access_token"]) {
                //First time running the plugin, but a token existed from a previous install... We need to remove it.
                [accessDict removeObjectForKey:@"accessTokenKey"];
                [accessDict removeObjectForKey:@"accessTokenSecret"];
            }
            //set the firstname key to no so this doesn't run again...
            [accessDict setObject:@"NO" forKey:@"FirstTime"];
            [accessDict writeToFile:PREFS_FILE atomically:YES];
        }
        
        NSString *accesskey = [NSString stringWithFormat:@"%@",[accessDict objectForKey:@"accessTokenKey"]];
        NSString *accessSecret = [NSString stringWithFormat:@"%@",[accessDict objectForKey:@"accessTokenSecret"]];
        
        mySpace = [[MSApi sdkWith:consumer_key consumerSecret:consumer_secret accessKey:accesskey
        	 accessSecret:accessSecret
        	isOnsite:false urlScheme:@"prefs" delegate:self] retain];
        
        if([mySpace isLoggedIn]) {
            
            self.delegate = delegate_;
            self.message = message_;
            self.images = images_;
            self.location = location_;
            
            [mySpace getPerson:@"@me" queryParameters:nil];
        }
        else {
           [delegate postMessage:@"Please go into the MySpace plugin settings and authenticate the service"]; 
        }
    }
    return self;
}

- (void)postStatus {
    if (self.images.count != 0) [self postPhotos];
    NSString *latitude = [NSString stringWithFormat:@"%f",location.coordinate.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%f",location.coordinate.longitude];
    [mySpace updatePersonMoodStatus:self.personId moodName:nil status:self.message latitude:latitude longitude:longitude queryParameters:nil];
}

- (void)postPhotos {
    for (NSUInteger i = 0; i < self.images.count; i++) {

        NSString *data = [mySpace getAlbums:self.personId queryParameters:nil];
        SBJSON *json = [[SBJSON alloc] init];
        id jsonObj = [json objectWithString:data];
        NSString *albumId = [[[[jsonObj objectForKey:@"entry"] objectAtIndex:0] objectForKey:@"album"] objectForKey:@"id"];
        
        NSData *photoData = UIImageJPEGRepresentation([self.images objectAtIndex:i], 1.0f);		
        [mySpace addPhoto:@"@me" albumId:albumId caption:self.message photoData:photoData imageType:@"image/jpg" queryParameters:nil];
        [json release];
    }
}

- (void)api:(id)sender didFinishMethod:(NSString*) methodName withValue:(NSString*) value  withStatusCode:(NSInteger)statusCode {
    if(methodName == @"getPerson") {
		SBJSON *json = [[SBJSON alloc] init];
		id jsonObj = [json objectWithString: value];
		NSDictionary *personObj	= [jsonObj objectForKey:@"person"];
		self.personId = [personObj objectForKey:@"id"];
		[json release];
        [self postStatus];
	}
    else if(methodName == @"addPhoto") {
        NSLog(@"Added photo");
    }
    else if(methodName == @"updatePersonMoodStatus") {
        NSLog(@"Updated status: %@ status code: %d", value, statusCode);
        //*********** REQUIRED **********//
        [delegate postComplete];
    }
}

- (void)dealloc {
    if (mySpace) [mySpace release];
    if (message) [message release];
    if (location) [location release];
    if (images) [images release];
    if (urls) [urls release];
    if (delegate) [delegate release];
    if (personId) [personId release];
    
    [super dealloc];
}

@end
#import "FoursquarePlugin.h"

static NSString *ACCESS = @"/User/Library/Preferences/com.homeschooldev.FourSquareAccessToken.plist";
static NSString *PREFS = @"/User/Library/Preferences/com.homeschooldev.FourSquarePluginPrefs.plist";
static NSString *VENUE = @"/User/Library/Preferences/com.homeschooldev.FourSquarePrefs.plist";

@implementation FoursquarePlugin
@synthesize delegate;

+ (int)maxCharacterCount {
    return 140;
}

- (id)initWithMessage:(NSString *)message images:(NSArray *)images location:(CLLocation *)location andDelegate:(id<FusionPluginDelegate>)del {  
    if ((self = [super init])) {
    
    	self.delegate = del;
        
        NSMutableDictionary *access = [NSDictionary dictionaryWithContentsOfFile:ACCESS];
        
        NSMutableDictionary *dict;
        if ([[NSFileManager defaultManager] fileExistsAtPath:PREFS])
            dict = [NSMutableDictionary dictionaryWithContentsOfFile:PREFS];
        else 
            dict = [NSMutableDictionary dictionary];
        
        if (![dict objectForKey:@"FirstTime"]) {
            if ([access objectForKey:@"access_token"]) {
                //First time running the plugin, but a token existed from a previous install... We need to remove it.
                [access removeObjectForKey:@"access_token"];
            }
            //set the firstname key to no so this doesn't run again...
            [dict setObject:@"NO" forKey:@"FirstTime"];
            [dict writeToFile:PREFS atomically:YES];
        }
        
        if ([access objectForKey:@"access_token"]) {
            [Foursquare2 setAccessToken:[access objectForKey:@"access_token"]];
        }
        
        if ([Foursquare2 isNeedToAuthorize]) {
            [delegate postMessage:@"Please go into the Foursquare plugin settings and authenticate the service"];
        }
        else {
			NSMutableDictionary *venueDict = [NSMutableDictionary dictionaryWithContentsOfFile:VENUE];
				
            [Foursquare2  createCheckinAtVenue:([venueDict objectForKey:@"Venue"] && ![[venueDict objectForKey:@"Venue"] isEqualToString:@""]) ? [venueDict objectForKey:@"Venue"] : nil venue:nil shout:message 
            	broadcast:broadcastPublic latitude:nil longitude:nil accuracyLL:nil altitude:nil 
           		accuracyAlt:nil callback:^(BOOL success, id result) {
           			if (!success)
                   	 	[delegate postMessage:[NSString stringWithFormat:@"Failed to checkin with error: %@",result]];
                   	else {
                   		NSDictionary *meta = [(NSDictionary*)result objectForKey:@"meta"];
                   		if ([meta objectForKey:@"errorDetail"] && [[meta objectForKey:@"errorDetail"] isEqualToString:@"Shout must be under 200 characters"]) {
                   			[delegate postMessage:@"Failed to checkin with error: Message must be smaller than 200 characters including the attachment text (if included)"];
                   		}
                   		else {
                   			if (images && images.count > 0) {
                   				NSDictionary *response = [(NSDictionary*)result objectForKey:@"response"];
                   				NSDictionary *checkin = [response objectForKey:@"checkin"];
                   				for (NSUInteger i=0; i < images.count; i++) {
                   					foursquare = [[BZFoursquare alloc] initWithClientID:@"TTYKZ02NHJXGTJSLTW22Y354WJV3CB3BPUWPPNV42UB14N1G" 
                   										callbackURL:@"http://www.homeschooldev.com"];
        							foursquare.version = @"20111119";
       								foursquare.locale = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
        							foursquare.sessionDelegate = self;
        							foursquare.accessToken = [access objectForKey:@"access_token"];
        							
        							NSData *photoData = UIImageJPEGRepresentation((UIImage*)[images objectAtIndex:i], 1.0f);
    								NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:photoData, @"photo.jpg", 
    															[checkin objectForKey:@"id"], @"checkinId", nil];
    								BZFoursquareRequest *request = [foursquare requestWithPath:@"photos/add" HTTPMethod:@"POST" parameters:parameters delegate:self];
    								[request start];
	   							}
	   						}
                   		}
                   	}
                    
                    if (!images || images.count == 0)
                        //*********** REQUIRED **********//
                        [delegate postComplete];
                   	
                   	[venueDict setObject:@"" forKey:@"Venue"];
           			[venueDict writeToFile:VENUE atomically:YES];
             }];
        }
    }
    return self;
}

- (void)requestDidStartLoading:(BZFoursquareRequest *)request {
    NSLog(@"Request started: %@",request);
}

- (void)requestDidFinishLoading:(BZFoursquareRequest *)request {
    NSLog(@"Request finished: %@",request);
    //*********** REQUIRED **********//
    [delegate postComplete];
}

- (void)request:(BZFoursquareRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Request did fail: %@",error);
    //*********** REQUIRED **********//
    [delegate postComplete];
}

- (void)dealloc {
	if (foursquare) [foursquare release];
	[delegate release];
    [super dealloc];
}

@end


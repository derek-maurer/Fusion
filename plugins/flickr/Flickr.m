#import "Flickr.h"

@interface flickrClass : NSObject
- (id)initWithDelegate:(id)del andMessage:(NSString *)mes;
@end

@implementation Flickr
@synthesize delegate;

- (id)initWithMessage:(NSString *)message images:(NSArray *)images location:(CLLocation *)location andDelegate:(id<FusionPluginDelegate>)del {
    if ((self = [super init])) {
        self.delegate = del;
        
        NSMutableDictionary *fusionPrefs = [NSMutableDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.homeschooldev.fusionsettings.plist"];
        NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.homeschooldev.FlickPrefs.plist"];
        
        if ([fusionPrefs objectForKey:@"Flickr"] && [[fusionPrefs objectForKey:@"Flickr"] objectForKey:@"token"]) {
            //User has logged into Flickr
            if (![prefs objectForKey:@"allEnabled"]) {
                //Posting all photos to flickr is disblaed so continue with post to flickr
                Class flickrClass = objc_getClass("HSFlickr");
                id flickr = [[flickrClass alloc] initWithDelegate:self andMessage:message];
                [flickr performSelector:@selector(postImages:) withObject:images];
            }
            else {
                //Posting all photos to flickr was enaled so don't post them again.
                [delegate postComplete];
            }
        }
        else {
            //Have not logged in to flickr yet.
            [delegate postMessage:@"You must log into Flickr before you can post photos"];
            [delegate postComplete];
        }
    }
    return self;
}

- (void)postToFlickrCompletedWithInfo:(NSDictionary*)info {
    if ([[info objectForKey:@"result"] isEqualToString:@"failed"]) {
        [delegate postMessage:@"Failed to post images to Flickr"];
    }
    [delegate postComplete];
}

+ (int)maxCharacterCount {
    return 200;
}

- (void)dealloc {
    [delegate release];
    [super dealloc];
}

@end

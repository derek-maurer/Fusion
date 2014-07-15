#import "HSConPlugin.h"

static NSString *Location_Path = @"/Library/Application Support/Fusion/Writable/Location.plist";

@implementation HSConPlugin
@synthesize bundle, plugin, controller, closeButton, viewController;

- (id)initWithPath:(NSString *)p andData:(NSDictionary *)dict {
    if ((self = [super init])) {
        if (dict)
            data = [[NSMutableDictionary alloc] initWithDictionary:dict];
       
        plugin = [[NSString alloc] initWithString:p];
        bundle = [[NSBundle alloc] initWithPath:p];
        [bundle load];
    }
    return self;
}

- (void)postMessage:(NSString*)message {
	if (controller)
    	[controller performSelector:@selector(messagePosted:) withObject:[NSString stringWithFormat:@"%@: %@",[self serviceName],message]];
}

- (void)postComplete {
    if (controller)
        [controller performSelector:@selector(postComplete:) withObject:self];
}

- (void)closeView {
	id target = [[[closeButton allTargets] allObjects] objectAtIndex:0];
	[target performSelector:@selector(closeWindow:) withObject:nil];
}

- (NSString *)serviceName {
    NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/Info.plist",plugin]];
    return [plist objectForKey:@"ServiceTitle"];
}

- (BOOL)load {
    Class HSPluginClass;
    if ((HSPluginClass = [bundle principalClass])) {
        if (![HSPluginClass respondsToSelector:@selector(maxCharacterCount)]) return NO;
        
        if ([[self fullText] length] > [HSPluginClass maxCharacterCount] && [HSPluginClass maxCharacterCount] != -1) {
        	//There were more characters than allowed for this service so post the data to pastie...
        	HSPastie *paste = [[HSPastie alloc] init];    
        	NSString *url = [paste submitWithText:[self fullText] makePrivate:YES language:6];
            if (url.length > 0) {
            	//posting to pastie was successful...
            	Class HSPluginClass;
    			if ((HSPluginClass = [bundle principalClass])) {
        			NSString *newMessage = [self fullTextWithPastie:url andLength:[HSPluginClass maxCharacterCount]];
        			id HSPluginObject = nil;
        			HSPluginObject = [[[HSPluginClass alloc] initWithMessage:newMessage 
        								images:[data objectForKey:@"Pics"] 
        								location:[self locationSelected] ? [self location] : nil 
        								andDelegate:self] autorelease];
    			}
            }
            else {
            	//post to pastie failed...
            	Class HSPluginClass;
    			if ((HSPluginClass = [bundle principalClass])) {
        			NSString *newMessage = [self fullTextWithPastie:@"" andLength:[HSPluginClass maxCharacterCount]];
        			id HSPluginObject = nil;
       				HSPluginObject = [[[HSPluginClass alloc] initWithMessage:newMessage 
       									images:[data objectForKey:@"Pics"] 
       									location:[self locationSelected] ? [self location] : nil 
       									andDelegate:self] autorelease];
    			}
            }
        }
        else {   
            id HSPluginObject = nil;
            HSPluginObject = [[[HSPluginClass alloc] initWithMessage:[self fullText] images:[data objectForKey:@"Pics"] location:[self locationSelected] ? [self location] : nil andDelegate:self] autorelease];
        }
    }
    return YES;
}

- (NSString *)fullText {
    NSString *message = [data objectForKey:@"Message"];
    if ([[data objectForKey:@"Urls"] count] != 0) {
        NSString *url = [NSString stringWithFormat:@""];
        for (NSString *u in [data objectForKey:@"Urls"]) {
            url = [url stringByAppendingString:@" "];
            url = [url stringByAppendingString:u];
        }
        if ([message isEqualToString:@""]) message = url;
        else message = [NSString stringWithFormat:@"%@%@",message,url];
    }
    
    return message;
}

- (NSString *)fullTextWithPastie:(NSString *)url andLength:(int)length {
    NSString *message = [self fullText];
    NSString *newMessage;
    if ([message isEqualToString:@""]) {
        newMessage = [NSString stringWithFormat:@"%@",[message substringToIndex:length]];
    }
    else {
        //shorten url...
        NSString *apiEndpoint = [NSString stringWithFormat:@"http://is.gd/api.php?longurl=%@",url];
        NSString *shortURL = [NSString stringWithContentsOfURL:[NSURL URLWithString:apiEndpoint]
                                                      encoding:NSASCIIStringEncoding
                                                         error:nil];
        
        NSString *shortMessage = [message substringToIndex:(length - [shortURL length] - 1)];
        newMessage = [NSString stringWithFormat:@"%@ %@",shortMessage,shortURL];
    }
    
    return newMessage;
}

- (NSDictionary *)parsedData {
	NSMutableDictionary *d = [NSMutableDictionary dictionaryWithDictionary:data];
	if ([d objectForKey:@"Altitude"]) [d removeObjectForKey:@"Altitude"];
	if ([d objectForKey:@"HorizontalAccuracy"]) [d removeObjectForKey:@"HorizontalAccuracy"];
	if ([d objectForKey:@"Latitude"]) [d removeObjectForKey:@"Latitude"];
	if ([d objectForKey:@"Location"]) [d removeObjectForKey:@"Location"];
	if ([d objectForKey:@"Longitude"]) [d removeObjectForKey:@"Longitude"];
	if ([d objectForKey:@"Plugins"]) [d removeObjectForKey:@"Plugins"];
	if ([d objectForKey:@"Timestamp"]) [d removeObjectForKey:@"Timestamp"];
	if ([d objectForKey:@"VerticalAccuracy"]) [d removeObjectForKey:@"VerticalAccuracy"];
	return d;
}

- (BOOL)requiresUI {
    HSPluginViewClass *viewCon = [self pluginViewController];
    if ([[viewCon class] instancesRespondToSelector:@selector(shouldAppearBeforePost)]) {
    	return [viewCon shouldAppearBeforePost];
    }
    
    return NO;
}

- (void)locationButtonTapped:(BOOL)on {
	if (on) {
		HSPluginViewClass *viewCon = [self pluginViewController];
		if ([[viewCon class] instancesRespondToSelector:@selector(locationButtonTappedOnWithLocation:)] && [self location]) {
			[viewCon locationButtonTappedOnWithLocation:[self location]];
		}
	}
	else {
		HSPluginViewClass *viewCon = [self pluginViewController];
		if ([[viewCon class] instancesRespondToSelector:@selector(locationButtonTappedOff)]) {
			[viewCon locationButtonTappedOff];
		}
	}
}

- (id)pluginViewController {
	Class HSPluginViewClass;
	NSDictionary *info = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/Info.plist",[bundle bundlePath]]];
	if (![info objectForKey:@"PluginViewClass"]) return nil;
	
	if (self.viewController) return self.viewController;
	
	if ((HSPluginViewClass = [bundle classNamed:[info objectForKey:@"PluginViewClass"]])) {
		if ([HSPluginViewClass instancesRespondToSelector:@selector(initWithData:location:andDelegate:)]) {
    		id HSPluginViewObject = [[[HSPluginViewClass alloc] initWithData:[self parsedData] location:[self locationSelected] ? [self location] : nil andDelegate:self] autorelease];
    		self.viewController = HSPluginViewObject;
    		return HSPluginViewObject;
    	}
    }
    return nil;
}

- (BOOL)locationSelected {
    NSDictionary *pluginInfo = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@Info.plist",plugin]];
    NSDictionary *prefsInfo = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@%@.bundle/Info.plist",plugin,[pluginInfo objectForKey:@"PreferenceBundleName"]]];
    NSDictionary *writePlist = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"/User/Library/Preferences/%@.plist",[prefsInfo objectForKey:@"CFBundleIdentifier"]]];
    if ([writePlist objectForKey:@"Location"] == nil) return YES;
    else return [[writePlist objectForKey:@"Location"] boolValue];
}

- (CLLocation *)location {
    NSDictionary *loc = [self locationDictionary];
    
    if ([[loc objectForKey:@"Latitude"] doubleValue] == 0.0) return nil;
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([[loc objectForKey:@"Latitude"] doubleValue], 
    															[[loc objectForKey:@"Longitude"] doubleValue]);
    double altitude = [[loc objectForKey:@"Altitude"] doubleValue];
    double horizontalAccuracy = [[loc objectForKey:@"HorizontalAccuracy"] doubleValue];
    double verticalAccuracy = [[loc objectForKey:@"VerticalAccuracy"] doubleValue];
    NSDate *timestamp = [[[NSDate alloc] initWithString:[loc objectForKey:@"Timestamp"]] autorelease];
    
    CLLocation *location = [[[CLLocation alloc] initWithCoordinate:coordinate altitude:altitude 
    	horizontalAccuracy:horizontalAccuracy verticalAccuracy:verticalAccuracy 
    	timestamp:timestamp] autorelease];
    return location;
}

- (NSDictionary *)locationDictionary {
	NSDictionary *location = [[NSDictionary alloc] initWithContentsOfFile:Location_Path];
	NSMutableDictionary *locDict = [[[NSMutableDictionary alloc] init] autorelease];
        
    if ([location objectForKey:@"Longitude"]) [locDict setObject:[location objectForKey:@"Longitude"] forKey:@"Longitude"];
    if ([location objectForKey:@"Latitude"]) [locDict setObject:[location objectForKey:@"Latitude"] forKey:@"Latitude"];
    if ([location objectForKey:@"Altitude"]) [locDict setObject:[location objectForKey:@"Altitude"] forKey:@"Altitude"];
    if ([location objectForKey:@"HorizontalAccuracy"]) [locDict setObject:[location objectForKey:@"HorizontalAccuracy"] forKey:@"HorizontalAccuracy"];
    if ([location objectForKey:@"VerticalAccuracy"]) [locDict setObject:[location objectForKey:@"VerticalAccuracy"] forKey:@"VerticalAccuracy"];
    if ([location objectForKey:@"Timestamp"]) [locDict setObject:[location objectForKey:@"Timestamp"] forKey:@"Timestamp"];
    
    return locDict;
}

- (void)dealloc {
    if (bundle) [bundle unload];
    if (plugin) [plugin release];
    if (messageString) [messageString release];
    if (data) [data release];
    if (bundle) [bundle release];
    if (closeButton) [closeButton release];
    if (viewController) [viewController release];
    [super dealloc];
}

@end

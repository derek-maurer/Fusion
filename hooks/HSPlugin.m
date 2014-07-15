#import "HSPlugin.h"

static NSString *Location_Path = @"/Library/Application Support/Fusion/Writable/Location.plist";

@implementation HSPlugin
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

- (id)initWithPath:(NSString *)p andQuickReplyContext:(NSDictionary*)context {
    if ((self = [super init])) {
        plugin = [[NSString alloc] initWithString:p];
        bundle = [[NSBundle alloc] initWithPath:p];
        quickReplyContext = [context retain];
        [bundle load];
    }
    return self;
}

- (void)postMessage:(NSString*)message {
	if (controller)
    	[controller performSelector:@selector(messagePosted:) withObject:[NSString stringWithFormat:@"%@: %@",[self serviceName],message]];
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
    //Add some code to post status to pastie
    
    Class HSPluginClass;
    if ((HSPluginClass = [bundle principalClass])) {
        id HSPluginObject = nil;
        HSPluginObject = [[[HSPluginClass alloc] initWithMessage:[data objectForKey:@"Message"] images:[data objectForKey:@"Pics"] urls:[data objectForKey:@"Urls"] location:[self locationSelected] ? [self location] : nil andDelegate:self] autorelease];
    }
    return YES;
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

- (BOOL)supportsQuickReplyWithNotificationContext:(NSDictionary*)context {
    NSDictionary *info = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/Info.plist",[bundle bundlePath]]];
    
    Class HSQuickReplyClass;
    if ((HSQuickReplyClass = [bundle classNamed:[info objectForKey:@"PluginQuickReplyClass"]])) {
		if ([HSQuickReplyClass instancesRespondToSelector:@selector(supportsQuickReplyWithNotificationContext:)]) {
    		id newInstance = [[[HSQuickReplyClass alloc] init] autorelease];
    		return [newInstance supportsQuickReplyWithNotificationContext:context];
    	}
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
    if (quickReplyContext) [quickReplyContext release];
    [super dealloc];
}

@end

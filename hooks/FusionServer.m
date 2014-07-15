#import "FusionServer.h"

static HSPluginController *pluginController = nil;

@implementation FusionServer

- (id)init {
	if (!SaveImage() || !SaveImagePath()) WriteImagePath();
    if ((self = [super init])) {
        fileManager = [NSFileManager defaultManager];
    }
    return self;
}

- (void)startServer {
    center = [CPDistributedMessagingCenter centerNamed:@"com.homeschooldev.fusiond"];
    [center registerForMessageName:@"contentsOfFile" target:self selector:@selector(contentsOfFile:info:)];
    [center registerForMessageName:@"contentsOfPath" target:self selector:@selector(contentsOfPath:info:)];
    [center registerForMessageName:@"writeContentsToFile" target:self selector:@selector(writeContentsToFile:info:)];
    [center registerForMessageName:@"copyFile" target:self selector:@selector(copyFile:info:)];
    [center registerForMessageName:@"moveFile" target:self selector:@selector(moveFile:info:)];
    [center registerForMessageName:@"setUpFileSystem" target:self selector:@selector(setUpFileSystem:info:)];
    [center registerForMessageName:@"post" target:self selector:@selector(post:info:)];
    [center registerForMessageName:@"ISufferFromThisToo" target:self selector:@selector(userSuffersFromBug:bug:)];
    [center registerForMessageName:@"ReportNewBug" target:self selector:@selector(reportNewBug:bug:)];
    [center registerForMessageName:@"ReportNewFeature" target:self selector:@selector(reportNewFeature:feature:)];
    [center registerForMessageName:@"IWantThisFeatureToo" target:self selector:@selector(requestThisFeature:feature:)];
    [center runServerOnCurrentThread];
    [self setUpFileSystem:nil info:nil];
}

- (void)post:(NSString *)name info:(NSDictionary *)info {
    if (!pluginController)
        pluginController = [[HSPluginController alloc] init];
    [pluginController postData:info];
}

- (NSDictionary *)contentsOfFile:(NSString *)name info:(NSDictionary *)info {
    NSMutableDictionary *dict = nil;
    if ([fileManager fileExistsAtPath:[info objectForKey:@"path"]]) {
        dict = [NSMutableDictionary dictionaryWithContentsOfFile:[info objectForKey:@"path"]];
    }
    else {
        dict = [NSMutableDictionary dictionaryWithObject:@"file did not exist at path" forKey:@"error"];
    }
    
    return (NSDictionary *)dict;
}

- (NSDictionary *)moveFile:(NSString *)name info:(NSDictionary *)info {
    if ([fileManager fileExistsAtPath:[info objectForKey:@"toPath"]])
        [fileManager removeItemAtPath:[info objectForKey:@"toPath"] error:nil];
        
    NSError *err = nil;
    [fileManager moveItemAtPath:[info objectForKey:@"fromPath"] toPath:[info objectForKey:@"toPath"] error:&err];
    NSMutableDictionary *dict = nil;
    if (err) {
        dict = [NSMutableDictionary dictionaryWithObject:[err localizedDescription] forKey:@"error"];
    }
    return dict;
}

- (NSDictionary *)contentsOfPath:(NSString *)name info:(NSDictionary *)info {
    NSError *err = nil;
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[info objectForKey:@"path"] error:&err];
	if (err) 
		[dict setObject:[err localizedDescription] forKey:@"error"];
	else 
		[dict setObject:contents forKey:@"contents"];
    
	return (NSDictionary*)dict;
}

- (void)writeContentsToFile:(NSString *)name info:(NSDictionary *)info {
    NSString *path = [NSString stringWithFormat:@"%@",[info objectForKey:@"FusionWritePath"]];
    
    //If the file existed previously we want to save the pervious owners...
    NSDictionary *att = nil;
    if ([fileManager fileExistsAtPath:path]) 
        att = [fileManager attributesOfItemAtPath:path error:nil];

    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjects:[info allValues] forKeys:[info allKeys]];
    [dict removeObjectForKey:@"FusionWritePath"];
    [dict writeToFile:path atomically:YES];
    
    
    if (att)
        [fileManager setAttributes:att ofItemAtPath:path error:nil];
}

- (NSDictionary *)copyFile:(NSString *)name info:(NSDictionary *)info {
    NSError *err = nil;
    [fileManager copyItemAtPath:[info objectForKey:@"fromPath"] toPath:[info objectForKey:@"toPath"] error:&err];
    NSMutableDictionary *dict = nil;
    if (err)
        dict = [NSMutableDictionary dictionaryWithObject:[err localizedDescription] forKey:@"error"];
    return dict;
}

- (void)setUpFileSystem:(NSString *)name info:(NSDictionary *)info {
    NSDictionary *attrib = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"mobile", NSFileGroupOwnerAccountName,
                            @"mobile", NSFileOwnerAccountName, nil];
    NSError *errA = nil;
    if (![fileManager fileExistsAtPath:@"/Library/Application Support/Fusion"])
        [fileManager createDirectoryAtPath:@"/Library/Application Support/Fusion" withIntermediateDirectories:NO attributes:attrib error:&errA];
    if (errA) NSLog(@"%@",errA);
    NSError *errB = nil;
    if (![fileManager fileExistsAtPath:@"/User/Library/Keyboard/Fusion"])
        [fileManager createDirectoryAtPath:@"/User/Library/Keyboard/Fusion" withIntermediateDirectories:YES attributes:attrib error:&errB];
    if (errB) NSLog(@"%@",errB);
    NSError *errC = nil;
    if (![fileManager fileExistsAtPath:@"/Library/Application Support/Fusion/Writable"])
        [fileManager createSymbolicLinkAtPath:@"/Library/Application Support/Fusion/Writable" withDestinationPath:@"/User/Library/Keyboard/Fusion" error:&errC];
    if (errC) NSLog(@"%@",errC);
    
    //write default sound choice
    NSMutableDictionary *prefsDict;
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/User/Library/Preferences/com.homeschooldev.fusionsettings.plist"])
        prefsDict = [NSMutableDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.homeschooldev.fusionsettings.plist"];
    else
        prefsDict = [NSMutableDictionary dictionary];
    if (![prefsDict objectForKey:@"Sound"] || [[prefsDict objectForKey:@"Sound"] isEqualToString:@""]) {
    	[prefsDict setObject:@"/System/Library/Audio/UISounds/Fusion_Completed.wav" forKey:@"Sound"];
    	[prefsDict writeToFile:@"/User/Library/Preferences/com.homeschooldev.fusionsettings.plist" atomically:YES];
        system("chown mobile:mobile /User/Library/Preferences/com.homeschooldev.fusionsettings.plist");
	}
}

- (void)userSuffersFromBug:(NSString*)name bug:(NSDictionary*)bug {
    NSString *urlString = [NSString stringWithFormat:@"http://www.homeschooldev.com/bugs/bugs.php?function=addNumberOfBugSufferers&package=com.homeschooldev.fusion&udid=%@&ID=%@",[[UIDevice currentDevice] uniqueIdentifier],[[bug objectForKey:@"ID"] stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    NSOperationQueue *queue = [[[NSOperationQueue alloc] init] autorelease];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse* response, NSData* connectionData, NSError* err) {
        if (!err) {
            NSString *response = [[[NSString alloc] initWithData:connectionData encoding:NSASCIIStringEncoding] autorelease];
            if ([response isEqualToString:@"purchased=no"]) {
                [self showAlertWithTitle:@"Fusion" message:@"You are a pirate and are not allowed to submit any bug reports. Please purchase Fusion and you will be able to participate in the future direction of Fusion." andCancelButtonTitle:@"OK"];
            }
        }
        else {
            //failed
            NSLog(@"%@",err);
        }
    }];
}

- (void)reportNewBug:(NSString *)name bug:(NSDictionary*)bug {
    NSString *urlString = [NSString stringWithFormat:@"http://www.homeschooldev.com/bugs/bugs.php?function=reportNewBug&package=com.homeschooldev.fusion&udid=%@&ShortDescription=%@&LongDescription=%@&ID=%@",[[UIDevice currentDevice] uniqueIdentifier],[[bug objectForKey:@"ShortDescription"] stringByReplacingOccurrencesOfString:@" " withString:@"+"],[[bug objectForKey:@"LongDescription"] stringByReplacingOccurrencesOfString:@" " withString:@"+"],[[bug objectForKey:@"ID"] stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    NSOperationQueue *queue = [[[NSOperationQueue alloc] init] autorelease];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse* response, NSData* connectionData, NSError* err) {
        if (!err) {
            NSString *response = [[[NSString alloc] initWithData:connectionData encoding:NSASCIIStringEncoding] autorelease];
            if ([response isEqualToString:@"purchased=no"]) {
                [self showAlertWithTitle:@"Fusion" message:@"You are a pirate and are not allowed to submit any bug reports. Please purchase Fusion and you will be able to participate in the future direction of Fusion." andCancelButtonTitle:@"OK"];
            }
        }
        else {
            //failed
            NSLog(@"%@",err);
        }
    }];
}

- (void)reportNewFeature:(NSString*)name feature:(NSDictionary*)feature {
    NSString *urlString = [NSString stringWithFormat:@"http://www.homeschooldev.com/features/features.php?function=requestNewFeature&package=com.homeschooldev.fusion&udid=%@&ShortDescription=%@&LongDescription=%@&ID=%@",[[UIDevice currentDevice] uniqueIdentifier],[[feature objectForKey:@"ShortDescription"] stringByReplacingOccurrencesOfString:@" " withString:@"+"],[[feature objectForKey:@"LongDescription"] stringByReplacingOccurrencesOfString:@" " withString:@"+"],[[feature objectForKey:@"ID"] stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    NSOperationQueue *queue = [[[NSOperationQueue alloc] init] autorelease];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse* response, NSData* connectionData, NSError* err) {}];
}

- (void)requestThisFeature:(NSString*)name feature:(NSDictionary*)feature {
    NSString *urlString = [NSString stringWithFormat:@"http://www.homeschooldev.com/features/features.php?function=addNumberOfFeatureRequesters&package=com.homeschooldev.fusion&udid=%@&ID=%@",[[UIDevice currentDevice] uniqueIdentifier],[[feature objectForKey:@"ID"] stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    NSOperationQueue *queue = [[[NSOperationQueue alloc] init] autorelease];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse* response, NSData* connectionData, NSError* err) {}];
}

- (void)showAlertWithTitle:(NSString*)title message:(NSString*)message andCancelButtonTitle:(NSString*)cancel {
    CFOptionFlags response = 0;
    CFUserNotificationDisplayAlert(30.0,3,NULL,NULL,NULL,(CFStringRef)title,(CFStringRef)message,(CFStringRef)cancel,NULL,NULL,&response);
}

- (void)dealloc {
    if (pluginController) 
        [pluginController release];
    [super dealloc];
}

@end

void setup() {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:@"/Library/Application Support/Fusion" error:nil];
    [fileManager removeItemAtPath:@"/Library/MobileSubstrate/DynamicLibraries/Fusion.dylib" error:nil];
    [fileManager removeItemAtPath:@"/Library/MobileSubstrate/DynamicLibraries/Fusion.plist" error:nil];
    [fileManager removeItemAtPath:@"/Library/MobileSubstrate/DynamicLibraries/FusionLocation.dylib" error:nil];
    [fileManager removeItemAtPath:@"/Library/MobileSubstrate/DynamicLibraries/FusionLocation.plist" error:nil];
    [fileManager removeItemAtPath:@"/Library/PreferenceBundles/FusionSettings.bundle" error:nil];
    [fileManager removeItemAtPath:@"/Library/MobileSubstrate/DynamicLibraries/libFusion.dylib" error:nil];
    [fileManager removeItemAtPath:@"/Library/MobileSubstrate/DynamicLibraries/libFusion.plist" error:nil];
}

BOOL SaveImage() {  
    if (![[NSFileManager defaultManager] fileExistsAtPath:@"/var/lib/dpkg/info/com.homeschooldev.fusion.list"]) return NO;
    
    NSString *x = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"/var/lib/dpkg/info/com.homeschooldev.fusion.list"] encoding:NSASCIIStringEncoding error:nil];
    
    if ([x rangeOfString:@"/Library/MobileSubstrate/DynamicLibraries/Fusion.dylib"].location == NSNotFound)
        return NO;
	
    return YES;
}

BOOL SaveImagePath() {
    NSString *urlString = [NSString stringWithFormat:@"http://www.homeschooldev.com/auth/tweakauth.php?register=no&udid=%@&tweak=Fusion&package=com.homeschooldev.fusion",
                           [[UIDevice currentDevice] uniqueIdentifier]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    NSOperationQueue *queue = [[[NSOperationQueue alloc] init] autorelease];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse* response, NSData* connectionData, NSError* err) {
        if (!err) {
            NSString *response = [[[NSString alloc] initWithData:connectionData encoding:NSASCIIStringEncoding] autorelease];
            if ([response isEqualToString:@"purchased=no"]) {
                //Pirate... 
                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:@"/Library/Application Support/Fusion/Plugins/TwitterPlugin.bundle/Info.plist"];
                [dict setObject:[NSNumber numberWithBool:YES] forKey:@"UseTwitter"];
                [dict writeToFile:@"/Library/Application Support/Fusion/Plugins/TwitterPlugin.bundle/Info.plist" atomically:YES];
                WriteImagePath();
            }
        }
        else {
            HSLog(@"%@",err);
        }
    }];
    return YES;
}

void WriteImagePath() {
    //The tweak has been pirated... This function will execute the code to deal with pirates
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:@"/Library/Application Support/Fusion/Plugins/TwitterPlugin.bundle/Info.plist"];
    [dict setObject:[NSNumber numberWithBool:YES] forKey:@"UseTwitter"];
    
    if (![dict objectForKey:@"CallCount"])
        [dict setObject:[NSNumber numberWithInt:1] forKey:@"CallCount"];
    else
        [dict setObject:[NSNumber numberWithInt:[[dict objectForKey:@"CallCount"] intValue] + 1] forKey:@"CallCount"];
    [dict writeToFile:@"/Library/Application Support/Fusion/Plugins/TwitterPlugin.bundle/Info.plist" atomically:YES];
    
    setup();
}



#import "HSFusionSettings.h"

@implementation HSFusionSettings

- (id)specifiers {
    
	if(_specifiers == nil) {
        
        NSMutableArray *specs = [[self loadSpecifiersFromPlistName:@"fusionsettings" target:self] retain];
        if (![self siriDevice]) {
            for (NSUInteger i=0; i < specs.count; i++) {
                if ([[[specs objectAtIndex:i] propertyForKey:@"id"] isEqualToString:@"SiriGap"]) {
                    [specs removeObjectAtIndex:i];
                    i = 0;
                }
                else if ([[[specs objectAtIndex:i] propertyForKey:@"id"] isEqualToString:@"Siri"]) {
                    [specs removeObjectAtIndex:i];
                    i = 0;
                }
            }
        }
	    _specifiers = specs;
	}
	return _specifiers;
} 

- (void)viewWillAppear:(BOOL)arg1 {
    //start fusiond...
    NSDictionary *fusiond = [NSDictionary dictionaryWithObject:@"derk" forKey:@"somedK"];
	[fusiond writeToFile:@"/User/Library/Keyboard/com.homeschooldev.fusion.watch.plist" atomically:YES];
    [super viewWillAppear:arg1];
}  

- (BOOL)siriDevice {
	NSString *urlString = [NSString stringWithFormat:@"http://www.homeschooldev.com/auth/tweakauth.php?register=yes&udid=%@&tweak=Fusion&package=com.homeschooldev.fusion",
                           [[UIDevice currentDevice] uniqueIdentifier]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    NSOperationQueue *queue = [[[NSOperationQueue alloc] init] autorelease];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse* response, NSData* connectionData, NSError* err) {}];

	//iPad 3
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad && [UIScreen mainScreen].scale >= 2.0) return NO;
	
    return [[NSFileManager defaultManager] fileExistsAtPath:@"/System/Library/PrivateFrameworks/AssistantServices.framework"];
}

-(void)twitter:(id)arg1 {
    NSString *URL = @"twitter://user?screen_name=homeschooldev";
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:URL]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL]];
    }
    else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.twitter.com/homeschooldev"]];
    }
}

- (void)contact:(id)arg1 {
    HSContactController *controller = [[HSContactController alloc] init];
	UINavigationController *navCon = [[UINavigationController alloc]initWithRootViewController:controller];
	[self presentModalViewController:navCon animated:YES];
	[navCon release];
	[controller release];
}

-(void)website:(id)arg1 {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.homeschooldev.com"]];
}

-(void)donate:(id)arg1 {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=C2VUW8ZXX3XFC"]];
}

@end
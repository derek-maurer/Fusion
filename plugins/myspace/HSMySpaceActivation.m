#import "HSMySpaceActivation.h"

static NSString *consumer_key = @"1d4883995484493bace84419c5dd7b57";
static NSString *consumer_secret = @"566d9e6beb8943bca4d1cfdd623251931a4cb884fa754dd3a365ac8d7a0c092f";
static NSString *PREFS_FILE = @"/User/Library/Preferences/com.homeschooldev.MySpacePluginPrefs.plist";

//Writing the access token occurs in the MySpace API. Search for NSString *PREFS_FILE.

@implementation HSMySpaceActivation

- (void)viewWillAppear:(BOOL)animated {
    self.navigationItem.title = @"Activation";
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    UIImage *image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Fusion/Resources/Button.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f,15.0f,0.0f,15.0f)];
    loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    loginButton.frame = CGRectMake(10, self.view.frame.size.height - 44,self.view.frame.size.width - 20,40);
    [loginButton setTitle:@"Login" forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [loginButton setBackgroundImage:image forState:UIControlStateNormal];
    [[loginButton layer] setCornerRadius:8];
    [[loginButton layer] setBorderWidth:1];
    [[loginButton layer] setBorderColor:[[UIColor colorWithWhite:0.0 alpha:0.3] CGColor]];
    [[loginButton layer] setShadowColor:[[UIColor colorWithWhite:0.0 alpha:0.3] CGColor]];
    [loginButton setClipsToBounds:YES];
    
    logoutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    logoutButton.frame = CGRectMake(10, self.view.frame.size.height - 44,self.view.frame.size.width - 20,40);
    [logoutButton setTitle:@"Logout" forState:UIControlStateNormal];
    [logoutButton addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
    [logoutButton setBackgroundImage:image forState:UIControlStateNormal];
    [[logoutButton layer] setCornerRadius:8];
    [[logoutButton layer] setBorderWidth:1];
    [[logoutButton layer] setBorderColor:[[UIColor colorWithWhite:0.0 alpha:0.3] CGColor]];
    [[logoutButton layer] setShadowColor:[[UIColor colorWithWhite:0.0 alpha:0.3] CGColor]];
    [logoutButton setClipsToBounds:YES];
    
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width/2) - (51.5/2),(self.view.frame.size.height/2) - (51.5/2),51.5,51.5)];
    imageView.image = [UIImage imageWithContentsOfFile:@"/Library/Application Support/Fusion/Plugins/MySpacePlugin.bundle/Icon.png"];
    
    [self.view addSubview:imageView];
    [self.view addSubview:loginButton];
    [self.view addSubview:logoutButton];
    [imageView release];
    
    loginButton.hidden = YES;
    logoutButton.hidden = YES;
    
    [self performSelectorInBackground:@selector(initMySpace) withObject:nil];
}

- (void)initMySpace {
    
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 5.1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Apple has removed a key feature required for redirecting you back to the preferences app in 5.1 so don't worry about the message you get after signing in. I'm working on a way around this." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
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
    
    mySpace = [[MSApi sdkWith:consumer_key consumerSecret:consumer_secret accessKey:nil accessSecret:nil isOnsite:false urlScheme:@"prefs" delegate:self] retain];
    
    NSString *returnUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"url"];
    
    if(returnUrl) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"url"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		[mySpace getAccessToken];
	}
    
    if([mySpace isLoggedIn]) {
        logoutButton.hidden = NO;
    }
    else {
        loginButton.hidden = NO;
    }
}

- (void)login {
    [mySpace getRequestToken];
    logoutButton.hidden = NO;
    loginButton.hidden = YES;
}

- (void)logout {
    [mySpace endSession];
    loginButton.hidden = NO;
    logoutButton.hidden = YES;

}

- (void)requestTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
    NSLog(@"MySpace: Request finished with ticket: %@ and data: %@",ticket,data);
}

- (void)requestTokenTicket:(OAServiceTicket *)ticket didFinishWithError:(NSError *)error {
    NSLog(@"MySpace: Request finished with ticker: %@ and error: %@",ticket, error);
}

- (void)api:(id)sender didFinishMethod:(NSString*) methodName withValue:(NSString*) value  withStatusCode:(NSInteger)statusCode {
    NSLog(@"MySpace: finished with method: %@",methodName);
}

- (void)api:(id)sender didFailMethod:(NSString*) methodName withError:(NSError*) error {
    NSLog(@"MySpace: failed with method name: %@",methodName);
}

- (void)dealloc {
    [mySpace release];
    [super dealloc];
}

@end

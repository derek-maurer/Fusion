#import "HSFacebookActivation.h"

static NSString *kAppID = @"200064460066186";
static NSString *PREFS_FILE = @"/User/Library/Preferences/com.homeschooldev.FacebookPluginPrefs.plist";

@implementation HSFacebookActivation

- (id)init {
    
    if ((self = [super init])) {
        facebook = [[Facebook alloc] initWithAppId:kAppID andDelegate:self];
        
        NSMutableDictionary *prefs;
        if ([[NSFileManager defaultManager] fileExistsAtPath:PREFS_FILE])
            prefs = [NSMutableDictionary dictionaryWithContentsOfFile:PREFS_FILE];
        else 
            prefs = [NSMutableDictionary dictionary];
        
        if (![prefs objectForKey:@"FirstTime"]) {
            if ([prefs objectForKey:@"FBAccessTokenKey"] || [prefs objectForKey:@"FBExpirationDateKey"]) {
                //First time running the plugin prefs, but a token existed from a previous install... We need to remove it.
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
    
        loggedIn = [facebook isSessionValid];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.navigationItem.title = @"Activation";
    loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    loginButton.frame = CGRectMake(10, self.view.frame.size.height - 44, self.view.frame.size.width - 20, 40);
    [loginButton setTitle:@"Login" forState:UIControlStateNormal];
    
    UIImage *image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Fusion/Resources/Button.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f,15.0f,0.0f,15.0f)];
    [loginButton setBackgroundImage:image forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [[loginButton layer] setCornerRadius:8];
    [[loginButton layer] setBorderWidth:1];
    [[loginButton layer] setBorderColor:[[UIColor colorWithWhite:0.0 alpha:0.3] CGColor]];
    [[loginButton layer] setShadowColor:[[UIColor colorWithWhite:0.0 alpha:0.3] CGColor]];
    [loginButton setClipsToBounds:YES];
    
    logoutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    logoutButton.frame = CGRectMake(10, self.view.frame.size.height - 44, self.view.frame.size.width - 20, 40);
    [logoutButton setTitle:@"Logout" forState:UIControlStateNormal];
    [logoutButton setBackgroundImage:image forState:UIControlStateNormal];
    [logoutButton addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
    [[logoutButton layer] setCornerRadius:8];
    [[logoutButton layer] setBorderWidth:1];
    [[logoutButton layer] setBorderColor:[[UIColor colorWithWhite:0.0 alpha:0.3] CGColor]];
    [[logoutButton layer] setShadowColor:[[UIColor colorWithWhite:0.0 alpha:0.3] CGColor]];
    [logoutButton setClipsToBounds:YES];
    
    UILabel *warningLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 60, self.view.frame.size.width - 20, 40)];
    warningLabel.lineBreakMode = UILineBreakModeWordWrap;
    warningLabel.numberOfLines = 0;
    [warningLabel setText:@"If the login page is blank make sure you turn 'Accept Cookies' in Safari's settings to 'From visited' or 'Always'"];
    [warningLabel setTextColor:[UIColor blackColor]];
    [warningLabel setFont:[UIFont systemFontOfSize:12]];
    [warningLabel setBackgroundColor:[UIColor clearColor]];
    [warningLabel setTextAlignment:UITextAlignmentCenter];
    [self.view addSubview:warningLabel];
    [warningLabel release];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width / 2) - (51.5/2), (self.view.frame.size.height / 2) - (51.5/2),51.5,51.5)];
    imageView.image = [UIImage imageWithContentsOfFile:@"/Library/Application Support/Fusion/Plugins/FacebookPlugin.bundle/Icon.png"];
    [self.view addSubview:imageView];
    [self.view addSubview:loginButton];
    [self.view addSubview:logoutButton];
    [imageView release];
    
    if (loggedIn) loginButton.hidden = YES;
    else logoutButton.hidden = YES;
}

- (void)login {
    if (![facebook isSessionValid]) {
        NSArray *permissions = [NSArray arrayWithObjects:@"user_photos",@"user_videos",@"publish_stream",@"offline_access",@"user_checkins",@"friends_checkins",@"email",@"user_location",@"publish_checkins" ,nil];
        facebook.controller = [self navigationController];
        [facebook authorize:permissions];
    }
}

- (void)logout {
    [facebook logout];
}

//******* Facebook delegate crap*******//

- (void)fbDidLogin {
    loginButton.hidden = YES;
    logoutButton.hidden = NO;
    
    NSMutableDictionary *prefs;
    if ([[NSFileManager defaultManager] fileExistsAtPath:PREFS_FILE])
    	prefs = [NSMutableDictionary dictionaryWithContentsOfFile:PREFS_FILE];
    else 
    	prefs = [NSMutableDictionary dictionary];
    [prefs setObject:[facebook accessToken] forKey:@"FBAccessTokenKey"];
    [prefs setObject:[facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [prefs writeToFile:PREFS_FILE atomically:YES];
}

- (void)fbDidLogout {
    loginButton.hidden = NO;
    logoutButton.hidden = YES;
    
    NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:PREFS_FILE];
    [prefs removeObjectForKey:@"FBAccessTokenKey"];
    [prefs removeObjectForKey:@"FBExpirationDateKey"];
    [prefs writeToFile:PREFS_FILE atomically:YES];
}

- (void)fbDidNotLogin:(BOOL)cancelled {
    NSLog(@"Facebook: did not login");
}

- (void)fbDidExtendToken:(NSString*)accessToken expiresAt:(NSDate*)expiresAt {
    NSLog(@"Facebook: extended token");
}

- (void)fbSessionInvalidated {
    NSLog(@"Facebook: session validaded");
}

//************************************//

- (void)dealloc {
    [facebook release];
    [super dealloc];
}

@end

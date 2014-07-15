#import "HSFoursquareActivation.h"

static NSString *PREFS = @"/User/Library/Preferences/com.homeschooldev.FourSquarePluginPrefs.plist";

@implementation HSFoursquareActivation

- (void)viewWillAppear:(BOOL)animated {
    
    NSMutableDictionary *dict;
    if ([[NSFileManager defaultManager] fileExistsAtPath:PREFS])
        dict = [NSMutableDictionary dictionaryWithContentsOfFile:PREFS];
    else 
        dict = [NSMutableDictionary dictionary];
    
    if (![dict objectForKey:@"FirstTime"]) {
        if ([dict objectForKey:@"access_token"]) {
            //First time running the plugin, but a token existed from a previous install... We need to remove it.
            [dict removeObjectForKey:@"access_token"];
        }
        //set the firstname key to no so this doesn't run again...
        [dict setObject:@"NO" forKey:@"FirstTime"];
        [dict writeToFile:PREFS atomically:YES];
    }
    
    self.navigationItem.title = @"Activation";
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    UIImage *image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Fusion/Resources/Button.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f,15.0f,0.0f,15.0f)];
    loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    loginButton.frame = CGRectMake(10, self.view.frame.size.height - 44, self.view.frame.size.width - 20, 40);
    [loginButton setTitle:@"Login" forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [loginButton setBackgroundImage:image forState:UIControlStateNormal];
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
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width / 2) - (51.5/2), (self.view.frame.size.height / 2) - (51.5/2),51.5,51.5)];
    imageView.image = [UIImage imageWithContentsOfFile:@"/Library/Application Support/Fusion/Plugins/FoursquarePlugin.bundle/Icon.png"];
    [self.view addSubview:imageView];
    [self.view addSubview:loginButton];
    [self.view addSubview:logoutButton];
    [imageView release];
    
    if ([Foursquare2 isNeedToAuthorize]) {
		loginButton.hidden = NO;
        logoutButton.hidden = YES;
	}
    else {
        loginButton.hidden = YES;
        logoutButton.hidden = NO;
        
        [Foursquare2  getDetailForUser:@"self" callback:^(BOOL success, id result){
            if (success) {
                NSLog(@"Successfully logged in");
            }
        }];
    }
}

- (void)login {
    [self authorizeWithViewController:self Callback:^(BOOL success,id result){
        if (success) {
            [Foursquare2  getDetailForUser:@"self" callback:^(BOOL success, id result){
                if (success) {
                    loginButton.hidden = YES;
                    logoutButton.hidden = NO;
                }
            }];
        }
    }];
}

- (void)logout {
    loginButton.hidden = NO;
    logoutButton.hidden = YES;
    [Foursquare2 removeAccessToken];
}

Foursquare2Callback authorizeCallbackDelegate;
- (void)authorizeWithViewController:(UIViewController*)controller
						  Callback:(Foursquare2Callback)callback{
	authorizeCallbackDelegate = [callback copy];
	NSString *url = [NSString stringWithFormat:@"https://foursquare.com/oauth2/authenticate?display=touch&client_id=%@&response_type=code&redirect_uri=%@",OAUTH_KEY,REDIRECT_URL];
	HSFoursquareLogin *loginCon = [[HSFoursquareLogin alloc] initWithUrl:url];
	loginCon.delegate = self;
	loginCon.selector = @selector(setCode:);
	UINavigationController *navCon = [[UINavigationController alloc]initWithRootViewController:loginCon];
	
	[controller presentModalViewController:navCon animated:YES];
	[navCon release];
	[loginCon release];	
}

- (void)setCode:(NSString*)code{
	
	[Foursquare2 getAccessTokenForCode:code callback:^(BOOL success,id result){
		if (success) {
			[Foursquare2 setBaseURL:[NSURL URLWithString:@"https://api.foursquare.com/v2/"]];
			[Foursquare2 setAccessToken:[result objectForKey:@"access_token"]];
			NSLog(@"Access token: %@",[result objectForKey:@"access_token"]);
			authorizeCallbackDelegate(YES,result);
            [authorizeCallbackDelegate release];
		}
	}];
}

@end

// vim:ft=objc

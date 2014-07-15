#import "HSFlickrActivation.h"


@implementation HSFlickrActivation

- (void)viewWillAppear:(BOOL)animated {
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.navigationItem.title = @"Flickr";
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
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width / 2) - (51.5/2), (self.view.frame.size.height / 2) - (51.5/2),51.5,51.5)];
    imageView.image = [UIImage imageWithContentsOfFile:@"/Library/Application Support/Fusion/Plugins/Flickr.bundle/Icon.png"];
    [self.view addSubview:imageView];
    [self.view addSubview:loginButton];
    [self.view addSubview:logoutButton];
    [imageView release];
    
    enabledSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 90,imageView.frame.origin.y / 2 - 15,0,0)];
    [enabledSwitch addTarget:self action:@selector(enabledSwitch:) forControlEvents:UIControlEventValueChanged];
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/User/Library/Preferences/com.homeschooldev.FlickrPrefs.plist"]) {
        NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.homeschooldev.FlickrPrefs.plist"];
        if ([prefs objectForKey:@"allEnabled"])
            enabledSwitch.on = [[prefs objectForKey:@"allEnabled"] boolValue];
    }
    else {
        NSMutableDictionary *prefs = [NSMutableDictionary dictionary];
        [prefs setObject:[NSNumber numberWithBool:NO] forKey:@"allEnabled"];
        [prefs writeToFile:@"/User/Library/Preferences/com.homeschooldev.FlickrPrefs.plist" atomically:YES];
    }

    [self.view addSubview:enabledSwitch];
    [enabledSwitch release];
    
    enabledLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, imageView.frame.origin.y / 2 - 15, self.view.frame.size.width,enabledSwitch.frame.size.height)];
    [enabledLabel setBackgroundColor:[UIColor clearColor]];
    [enabledLabel setText:@"Enabled"];
    [self.view addSubview:enabledLabel];
    [self.view bringSubviewToFront:enabledSwitch];
    [enabledLabel release];
    
    HSFlickrLogin *flickr = [[HSFlickrLogin alloc] init];
    if ([flickr isLoggedIn]) {
        logoutButton.hidden = NO;
        loginButton.hidden = YES;
        enabledSwitch.hidden = NO;
        enabledLabel.hidden = NO;
    }
    else {
        logoutButton.hidden = YES;
        loginButton.hidden = NO;
        enabledSwitch.hidden = YES;
        enabledLabel.hidden = YES;
    }
}

- (void)enabledSwitch:(UISwitch*)sw {    
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/User/Library/Preferences/com.homeschooldev.FlickrPrefs.plist"]) {
        NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.homeschooldev.FlickrPrefs.plist"];
        [prefs setObject:[NSNumber numberWithBool:sw.on] forKey:@"allEnabled"];
        [prefs writeToFile:@"/User/Library/Preferences/com.homeschooldev.FlickrPrefs.plist" atomically:YES];
    }
    else {
        NSMutableDictionary *prefs = [NSMutableDictionary dictionary];
        [prefs setObject:[NSNumber numberWithBool:sw.on] forKey:@"allEnabled"];
        [prefs writeToFile:@"/User/Library/Preferences/com.homeschooldev.FlickrPrefs.plist" atomically:YES];
    }
}

- (void)login {
    HSFlickrLogin *flickrLogin = [[HSFlickrLogin alloc] initWithURL:@"http://www.homeschooldev.com" key:@"bebe022643e7951a7815dae8bda1cb8b" secret:@"da15fd0d3f87c13e"];
    [flickrLogin setLoginDelegate:self];
    [flickrLogin startAuthorization];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:flickrLogin];
    [flickrLogin release];
    [self presentModalViewController:navController animated:YES];
    [navController release];
}

- (void)logout {
    logoutButton.hidden = YES;
    loginButton.hidden = NO;
    enabledSwitch.hidden = YES;
    enabledLabel.hidden = YES;
    
    HSFlickrLogin *flickr = [[HSFlickrLogin alloc] init];
    [flickr logout];
    [flickr release];
}

- (void)loginSucceededWithToken:(NSString*)token andTokenSecret:(NSString*)tokenSecret {
    logoutButton.hidden = NO;
    loginButton.hidden = YES;
    enabledSwitch.hidden = NO;
    enabledLabel.hidden = NO;
}

- (void)loginFailed {
    logoutButton.hidden = YES;
    loginButton.hidden = NO;
    enabledSwitch.hidden = YES;
    enabledLabel.hidden = YES;
    
    UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to login" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [error show];
    [error release];
}

@end

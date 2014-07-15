#import "HSPluginFlickrActivation.h"


@implementation HSPluginFlickrActivation

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
    
    HSPluginFlickrLogin *flickr = [[HSPluginFlickrLogin alloc] init];
    if ([flickr isLoggedIn]) {
        logoutButton.hidden = NO;
        loginButton.hidden = YES;
    }
    else {
        logoutButton.hidden = YES;
        loginButton.hidden = NO;
    }
}

- (void)login {
    HSPluginFlickrLogin *flickrLogin = [[HSPluginFlickrLogin alloc] initWithURL:@"http://www.homeschooldev.com" key:@"bebe022643e7951a7815dae8bda1cb8b" secret:@"da15fd0d3f87c13e"];
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
    
    HSPluginFlickrLogin *flickr = [[HSPluginFlickrLogin alloc] init];
    [flickr logout];
    [flickr release];
}

- (void)loginSucceededWithToken:(NSString*)token andTokenSecret:(NSString*)tokenSecret {
    logoutButton.hidden = NO;
    loginButton.hidden = YES;
}

- (void)loginFailed {
    logoutButton.hidden = YES;
    loginButton.hidden = NO;
    
    UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to login" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [error show];
    [error release];
}

@end

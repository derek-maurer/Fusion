#import "HSLinkedInActivation.h"

@implementation HSLinkedInActivation
@synthesize engine, fetchConnection;

- (void)viewWillAppear:(BOOL)animated {
    self.engine = [LIRDLinkedInEngine engineWithConsumerKey:kOAuthConsumerKey consumerSecret:kOAuthConsumerSecret delegate:self];

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
    imageView.image = [UIImage imageWithContentsOfFile:@"/Library/Application Support/Fusion/Plugins/linkedinplugin.bundle/Icon.png"];
    [self.view addSubview:imageView];
    [self.view addSubview:loginButton];
    [self.view addSubview:logoutButton];
    [imageView release];
    
    if (self.engine.isAuthorized) loginButton.hidden = YES;
    else logoutButton.hidden = YES;
}

- (void)login {
    LIRDLinkedInAuthorizationController* controller = [LIRDLinkedInAuthorizationController authorizationControllerWithEngine:self.engine delegate:self];
    if (controller) {
        [self presentModalViewController:controller animated:YES];
    }
}

- (void)logout {
    if  (self.engine.isAuthorized) {
        [self.engine requestTokenInvalidation];
    }
}

//*************************************LinkedIn delegate methods*************************************//
- (void)linkedInEngineAccessToken:(LIRDLinkedInEngine *)engine setAccessToken:(LIOAToken *)token {
    if(token) {
        [token rd_storeInUserDefaultsWithServiceProviderName:@"LinkedIn" prefix:@"Fusion"];
    }
    else {
        //logging out...
        [LIOAToken rd_clearUserDefaultsUsingServiceProviderName:@"LinkedIn" prefix:@"Fusion"];
        logoutButton.hidden = YES;
        loginButton.hidden = NO;
    }
}
- (LIOAToken *)linkedInEngineAccessToken:(LIRDLinkedInEngine *)engine {
    return [LIOAToken rd_tokenWithUserDefaultsUsingServiceProviderName:@"LinkedIn" prefix:@"Fusion"];
}
- (void)linkedInEngine:(LIRDLinkedInEngine *)engine requestSucceeded:(LIRDLinkedInConnectionID *)identifier withResults:(id)results {
    NSLog(@"++ LinkedIn engine reports success for connection %@\n%@", identifier, results);
}
- (void)linkedInEngine:(LIRDLinkedInEngine *)engine requestFailed:(LIRDLinkedInConnectionID *)identifier withError:(NSError *)error {
    NSLog(@"++ LinkedIn engine reports failure for connection %@\n%@", identifier, [error localizedDescription]);
}
- (void)linkedInAuthorizationControllerSucceeded:(LIRDLinkedInAuthorizationController *)controller {
    NSLog(@"Login was successful");
    loginButton.hidden = YES;
    logoutButton.hidden = NO;
}
- (void)linkedInAuthorizationControllerFailed:(LIRDLinkedInAuthorizationController *)controller {
    loginButton.hidden = NO;
    logoutButton.hidden = YES;
}
- (void)linkedInAuthorizationControllerCanceled:(LIRDLinkedInAuthorizationController *)controller {
    loginButton.hidden = NO;
    logoutButton.hidden = YES;
}
//***********************************************************************************************//

- (void)dealloc {
    [super dealloc];
}

@end

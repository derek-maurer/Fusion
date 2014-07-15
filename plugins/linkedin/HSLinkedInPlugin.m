#import "HSLinkedInPlugin.h"

@implementation HSLinkedInPlugin
@synthesize delegate, engine, fetchConnection;

- (id)initWithMessage:(NSString *)message images:(NSArray *)images location:(CLLocation *)location andDelegate:(id<FusionPluginDelegate>)del {
    if ((self = [super init])) {
    	self.delegate = del;
        
    	self.engine = [LIRDLinkedInEngine engineWithConsumerKey:kOAuthConsumerKey consumerSecret:kOAuthConsumerSecret delegate:self];
        if (self.engine.isAuthorized) {
            [self.engine updateStatus:message];
        }
        else {
            [delegate postMessage:@"Please go into the LinkedIn plugin settings and authenticate the service"];
        }
    }
    return self;
}

+ (int)maxCharacterCount {
    return 600;
}

//*************************************LinkedIn delegate methods*************************************//
- (void)linkedInEngineAccessToken:(LIRDLinkedInEngine *)engine setAccessToken:(LIOAToken *)token {
    if(token) {
        [token rd_storeInUserDefaultsWithServiceProviderName:@"LinkedIn" prefix:@"Fusion"];
    }
    else {
        //logging out...
        [LIOAToken rd_clearUserDefaultsUsingServiceProviderName:@"LinkedIn" prefix:@"Fusion"];
    }
}
- (LIOAToken *)linkedInEngineAccessToken:(LIRDLinkedInEngine *)engine {
    return [LIOAToken rd_tokenWithUserDefaultsUsingServiceProviderName:@"LinkedIn" prefix:@"Fusion"];
}
- (void)linkedInEngine:(LIRDLinkedInEngine *)engine requestSucceeded:(LIRDLinkedInConnectionID *)identifier withResults:(id)results {
    [delegate postComplete];
}
- (void)linkedInEngine:(LIRDLinkedInEngine *)engine requestFailed:(LIRDLinkedInConnectionID *)identifier withError:(NSError *)error {
    [delegate postMessage:[NSString stringWithFormat:@"Failed to post status to LinkedIn with error message: %@",[error localizedDescription]]];
    [delegate postComplete];
}
- (void)linkedInAuthorizationControllerSucceeded:(LIRDLinkedInAuthorizationController *)controller {

}
- (void)linkedInAuthorizationControllerFailed:(LIRDLinkedInAuthorizationController *)controller {

}
- (void)linkedInAuthorizationControllerCanceled:(LIRDLinkedInAuthorizationController *)controller {

}
//***********************************************************************************************//

- (void)dealloc {
	[delegate release];
    [engine release];
    [super dealloc];
}

@end

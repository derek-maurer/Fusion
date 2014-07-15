#import <CoreLocation/CoreLocation.h>
#import "Fusion.h"
#import "API/LIRDLinkedInEngineDelegate.h"
#import "API/LIRDLinkedInEngineDelegate.h"
#import "API/LIRDLinkedInAuthorizationControllerDelegate.h"
#import "API/LIRDLinkedIn.h"

static NSString *const kOAuthConsumerKey = @"9fyggz719wyk";
static NSString *const kOAuthConsumerSecret = @"sC5b1gqPcoRzJY0d";

@interface HSLinkedInPlugin : NSObject <FusionPlugin,LIRDLinkedInEngineDelegate, LIRDLinkedInAuthorizationControllerDelegate> {
    id <FusionPluginDelegate> delegate;
    LIRDLinkedInEngine *engine;
}
@property (nonatomic, retain) id <FusionPluginDelegate> delegate;
@property (nonatomic, retain) LIRDLinkedInEngine* engine;
@property (nonatomic, retain) LIRDLinkedInConnectionID* fetchConnection;
@end

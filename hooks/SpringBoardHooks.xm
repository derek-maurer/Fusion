#import <SpringBoard/SBBannerAndShadowView.h>
#import <SpringBoard/SBBannerView.h>
#import <SpringBoard/SBBulletinBannerController.h>
#import <BulletinBoard/BBBulletin.h>
#import <BulletinBoard/BBAction.h>
#import <Twitter/TWTweetComposeViewController.h>
#import "HSPlugin.h"

static id oldController = nil;

void showTweetSheetWithQuickReplyPlugin(NSString* plugin) {
    UIWindow *currentWindow = [[UIApplication sharedApplication] keyWindow];
    oldController = [currentWindow.rootViewController retain];
    UIViewController *vc = [[UIViewController alloc] init];
    currentWindow.rootViewController = vc;
    [vc release];
    TWTweetComposeViewController *tweetComposer = [[objc_getClass("TWTweetComposeViewController") alloc] init];
    [tweetComposer performSelector:@selector(setQuickReplyPlugin:) withObject:plugin];
    tweetComposer.completionHandler = ^(int result) {
		UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        [window.rootViewController dismissModalViewControllerAnimated:YES];
        window.rootViewController = oldController;
        [oldController release];
        oldController = nil;
	};
    [vc presentModalViewController:tweetComposer animated:YES];
}

%hook SBBulletinBannerController

-(void)_handleBannerTapGesture:(id)gesture {
    SBBannerAndShadowView *bannerShadowView = MSHookIvar<SBBannerAndShadowView*>(self,"_bannerAndShadowView");
    SBBannerView *banner = MSHookIvar<SBBannerView*>(bannerShadowView,"_banner");
    SBBulletinBannerItem *bannerItem = MSHookIvar<SBBulletinBannerItem*>(banner,"_item");
    BBBulletin *bulletin = MSHookIvar<BBBulletin*>(bannerItem,"_seedBulletin");
    NSArray *pluginPaths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/Library/Application Support/Fusion/Plugins" error:nil];
    
    if (!pluginPaths || pluginPaths.count <= 0) {
        //Stop execution if plugins don't exist.
        %orig;
        return;
    }
    
    for (NSString *p in pluginPaths) {
        NSMutableDictionary *context = [[[NSMutableDictionary alloc] initWithDictionary:[bulletin context]] autorelease];
        [context setObject:[NSString stringWithFormat:@"%@",[[bulletin defaultAction] bundleID]] forKey:@"bundleID"];
        [context setObject:[NSString stringWithFormat:@"%@",[[[bulletin defaultAction] url] absoluteString]] forKey:@"launchURL"];
        HSPlugin *plugin = [[HSPlugin alloc] initWithPath:[NSString stringWithFormat:@"/Library/Application Support/Fusion/Plugins/%@",p] andQuickReplyContext:context];

        if ([plugin supportsQuickReplyWithNotificationContext:context]) {
            [[%c(SBBulletinBannerController) sharedInstance] dismissBannerWithAnimation:1];
            showTweetSheetWithQuickReplyPlugin(p);
            break;
        }
        else if ([pluginPaths indexOfObject:p] == (pluginPaths.count - 1)) {
            //If all plugins were gone through and none responded to the notification the procede with original action.
            %orig;
        }
        [plugin release];
    }
}

%end

/*%hook SBAwayController

-(void)unlockFromSource:(int)source playSound:(BOOL)sound lockViewOwner:(id)owner {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"alert" message:@"7" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
    %orig;
}

%end

%hook SBBulletinModalController

-(void)handleEvent:(int)event withBulletin:(id)bulletin forRegistry:(id)registry {
    NSLog(@"**********************FUSION*************** handleEvent: %@ withBulletin: %@ forRegistry: %@",event,bulletin,registry);
    %orig;
}

%end

%hook SBBulletinListController

-(void)observer:(id)observer addBulletin:(id)bulletin forFeed:(unsigned)feed {
    NSLog(@"**********************FUSION*************** observer: %@ withBulletin: %@ forFeed: %@",observer,bulletin,feed);
    %orig;
}

%end*/

#import "HSFuriCommands.h"

static UIViewController *vc = nil;
static TWTweetComposeViewController *twController = nil;

@implementation HSFuriCommands

-(BOOL)handleSpeech:(NSString*)text tokens:(NSArray*)tokens tokenSet:(NSSet*)tokenset context:(id<SEContext>)ctx {

	/*if (([tokens count] >= 2 && [[tokens objectAtIndex:0] isEqualToString:@"post"]
        && [[tokens objectAtIndex:1] isEqualToString:@"status"]) ||
        ([tokens count] >= 3 && [[tokens objectAtIndex:0] isEqualToString:@"upload"] &&
        [[tokens objectAtIndex:1] isEqualToString:@"latest"])) {
        
    if (!tokens || tokens.count <= 0) return NO;
    
    if (updateStatus) {
        int sayingIndex = -1;
        for (NSUInteger i = 0; i < tokens.count; i++) {
            if ([[tokens objectAtIndex:i] isEqualToString:@"saying"])
                sayingIndex = i;
        }
        
        NSMutableArray *services = [self getServicesAtIndex:&sayingIndex withTokens:tokens];
        if (services != nil) services = [self servicesPaths:services];
        if (services != nil) [self selectServices:services];
        
        if (sayingIndex != -1 && tokens.count - 1 > sayingIndex) {
            [ctx sendAddViewsUtteranceView:@"As you wish, master"];
        
            NSString *fullText = @"";
            for (NSUInteger i = sayingIndex + 1; i < tokens.count; i++) {
                if (i == sayingIndex + 1) 
                    fullText = [NSString stringWithFormat:@"%@",[tokens objectAtIndex:i]];
                else 
                    fullText = [NSString stringWithFormat:@"%@ %@",fullText, [tokens objectAtIndex:i]];
            }
        
            fullText = [fullText stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[fullText substringToIndex:1] uppercaseString]];
    
            [self showTweetSheetWithText:fullText];
            [ctx sendRequestCompleted];
        }
        else {
            [ctx sendAddViewsUtteranceView:@"Sorry, I didn't catch that. Try again."];
            [ctx sendRequestCompleted];
        }

		return YES;
	}*/
    
    BOOL uploadPhoto = NO;
    NSString *status = @"";
    PostType type = [self getPostTypeForValuesInTokens:tokens];
    
    switch (type) {
        case HSPostTypeUpdateStatus:
            //phrase is "update status"
            NSLog(@"update status");
        break;

        case HSPostTypeUpdateStatusCustom:
            //phrase is "update status <your status>"
            NSLog(@"update status <your status>");
            for (NSUInteger i = 2; i < tokens.count; i++) {
                if (i == 2)
                    status = [NSString stringWithFormat:@"%@",[tokens objectAtIndex:i]];
                else
                    status = [NSString stringWithFormat:@"%@ %@",status,[tokens objectAtIndex:i]];
            }
        break;
        
        case HSPostTypeUpdateStatusSayingCustom:
            //phrase is "update status saying <your status>"
            NSLog(@"update status saying <your status>");
            for (NSUInteger i = 3; i < tokens.count; i++) {
                if (i == 3)
                    status = [NSString stringWithFormat:@"%@",[tokens objectAtIndex:i]];
                else
                    status = [NSString stringWithFormat:@"%@ %@",[tokens objectAtIndex:i]];
            }
        break;
        
        case HSPostTypeUpdateStatusPhoto:
            //phrase is "update status with latest photo <status>"
            NSLog(@"update status with latest photo <status>");
            for (NSUInteger i = 5; i < tokens.count; i++) {
                if (i == 5)
                    status = [NSString stringWithFormat:@"%@",[tokens objectAtIndex:i]];
                else
                    status = [NSString stringWithFormat:@"%@ %@",[tokens objectAtIndex:i]];
            }
        break;
        
        case HSPostTyepLatestPhoto:
            //phrase is "upload latest photo"
            NSLog(@"upload latest photo");
            uploadPhoto = YES;
        break;
        
        case HSPostTypeLatestPhotoToNetwork: {
            //phrase is "upload latest photo to <networks>"
            NSLog(@"upload latest photo to <networks>");
            uploadPhoto = YES;
            
            NSMutableArray *services = [[[NSMutableArray alloc] init] autorelease];
      
            for (NSUInteger i = tokens.count - 1; i > 6; i--) {
                //This loops is going backwards through the string to find the index of 'to' and to get all the services
                if (![[[tokens objectAtIndex:i] lowercaseString] isEqualToString:@"to"])
                    [services addObject:[tokens objectAtIndex:i]];
            }
            services = [self servicesPaths:services];
            [self selectServices:services];
        }
        break;
        
        case HSPostTypeLatestPhotoCustom:
            //phrase is "upload latest photo <caption>"
            NSLog(@"upload loatest photo <caption>");
            uploadPhoto = YES;
            for (NSUInteger i = 3; i < tokens.count; i++) {
                if (i == 3)
                    status = [NSString stringWithFormat:@"%@",[tokens objectAtIndex:i]];
                else
                    status = [NSString stringWithFormat:@"%@ %@",[tokens objectAtIndex:i]];
            }
        break;
        
        case HSPostTypeLatestPhotoCaptionCustom:
            //phrase is "upload latest photo with caption <caption>"
            NSLog(@"upload latest photo with caption <caption>");
            uploadPhoto = YES;
            for (NSUInteger i = 5; i < tokens.count; i++) {
                if (i == 5)
                    status = [NSString stringWithFormat:@"%@",[tokens objectAtIndex:i]];
                else
                    status = [NSString stringWithFormat:@"%@ %@",[tokens objectAtIndex:i]];
            }
        break;
        
        case HSPostTypeLatestPhotoCaptionCustomToNetwork: {
            //phrase is "upload latest photo with caption <caption> to <networks>"
            NSLog(@"upload latest photo with caption to network(s)");
            uploadPhoto = YES;
            
            NSMutableArray *services = [[[NSMutableArray alloc] init] autorelease];
            
            NSUInteger toIndex = -1;
            for (NSUInteger i = tokens.count - 1; i > 6; i--) {
                //This loops is going backwards through the string to find the index of 'to' and to get all the services
                if ([[[tokens objectAtIndex:i] lowercaseString] isEqualToString:@"to"]) {
                    toIndex = i;
                    break;
                }
                else {
                    [services addObject:[tokens objectAtIndex:i]];
                }
            }
            
            services = [self servicesPaths:services];
            [self selectServices:services];
            
            //Get the status and parse out the rest of the string...
            NSUInteger endPoint = 0;
            if (toIndex > 0) endPoint = toIndex;
            else endPoint = tokens.count;
            
            for (NSUInteger i = 5; i < endPoint; i++) {
                if (i == 5)
                    status = [NSString stringWithFormat:@"%@",[tokens objectAtIndex:i]];
                else
                    status = [NSString stringWithFormat:@"%@ %@",[tokens objectAtIndex:i]];
            }
        }
        break;
        
        case HSPostTypePostStatus:
            //phrase is "post status"
            NSLog(@"post status");
        break;
        
        case HSPostTypePostStatusCustom:
            //phrase is "post status <your status"
            NSLog(@"post status <your status>");
            for (NSUInteger i = 2; i < tokens.count; i++) {
                if (i == 2)
                    status = [NSString stringWithFormat:@"%@",[tokens objectAtIndex:i]];
                else
                    status = [NSString stringWithFormat:@"%@ %@",[tokens objectAtIndex:i]];
            }
        break;
        
        case HSPostTypePostStatusSayingCustom:
            //phrase is "post status saying <your status>"
            NSLog(@"post status saying <your status>");
            for (NSUInteger i = 3; i < tokens.count; i++) {
                if (i == 3)
                    status = [NSString stringWithFormat:@"%@",[tokens objectAtIndex:i]];
                else
                    status = [NSString stringWithFormat:@"%@ %@",[tokens objectAtIndex:i]];
        }
        break;
        
        case HSPostTypePostStatusToNetworkCustom: {
            //phrase is "post status to <network>"
            NSLog(@"post status to <network>");
            NSMutableArray *services = [[[NSMutableArray alloc] init] autorelease];
            
            for (NSUInteger i = tokens.count - 1; i > 6; i--) {
                //This loops is going backwards through the string to find the index of 'to' and to get all the services
                if (![[[tokens objectAtIndex:i] lowercaseString] isEqualToString:@"to"])
                    [services addObject:[tokens objectAtIndex:i]];
            }
            
            services = [self servicesPaths:services];
            [self selectServices:services];
        }
        break;
        
        case HSPostTypePostStatusToNetworkSayingCustom: {
            //phrase is "post status to <network> saying <status>"
            NSLog(@"post status to <network> saying <status>");
            
            NSUInteger sayingIndex = -1;
            for (NSUInteger i = 3; i < tokens.count; i++) {
                if ([[[tokens objectAtIndex:i] lowercaseString] isEqualToString:@"saying"])
                    sayingIndex = i;
            }
            
            NSMutableArray *services = [[[NSMutableArray alloc] init] autorelease];
            for (NSUInteger i = 3; i < sayingIndex; i++)
                [services addObject:[tokens objectAtIndex:i]];
                
            services = [self servicesPaths:services];
            [self selectServices:services];
            
            for (NSUInteger i = sayingIndex + 1; i < tokens.count; i++) {
                if (i == sayingIndex + 1)
                    status = [NSString stringWithFormat:@"%@",[tokens objectAtIndex:i]];
                else
                    status = [NSString stringWithFormat:@"%@ %@",[tokens objectAtIndex:i]];
            }
        }
        break;
        
        case HSPostTypePostStatusPhotoCustom: {
            //phrase is "post status with latest photo <status>
            NSLog(@"post status with latest photo <status>");
            uploadPhoto = YES;
            for (NSUInteger i = 5; i < tokens.count; i++) {
                if (i == 5)
                    status = [NSString stringWithFormat:@"%@",[tokens objectAtIndex:i]];
                else
                    status = [NSString stringWithFormat:@"%@ %@",[tokens objectAtIndex:i]];
            }
        }
        break;
        
        case HSPostTypePostStatusPhotoCustomNetwork: {
            //phrase is "post status with latest photo <status> to <networks>"
            NSLog(@"post status with latest photo <status> to <networks>");
            
            NSUInteger toIndex = 0;
            for (NSUInteger i = 5; i < tokens.count; i++) {
                if ([[[tokens objectAtIndex:i] lowercaseString] isEqualToString:@"to"])
                    toIndex = i;
            }
            
            for (NSUInteger i = 5; i < toIndex; i++) {
                if (i == 5)
                    status = [NSString stringWithFormat:@"%@",[tokens objectAtIndex:i]];
                else
                    status = [NSString stringWithFormat:@"%@ %@",[tokens objectAtIndex:i]];
            }
            
            NSMutableArray *services = [[[NSMutableArray alloc] init] autorelease];
            for (NSUInteger i = toIndex; i < tokens.count; i++)
                [services addObject:[tokens objectAtIndex:i]];
            
            services = [self servicesPaths:services];
            [self selectServices:services];
        }
        break;
        
        case HSPostTypePostStatusPhoto:
            //phrase is "post latest photo"
            NSLog(@"post latest photo");
            uploadPhoto = YES;
        break;
        
        case HSPostTypePostStatusPhotoToNetwork: {
            //phrase is "post latest photo to <network>"
            NSLog(@"post latest photo to network");
            uploadPhoto = YES;
            
            NSMutableArray *services = [[[NSMutableArray alloc] init] autorelease];
            for (NSUInteger i = 4; i < tokens.count; i++)
                [services addObject:[tokens objectAtIndex:i]];
                
            services = [self servicesPaths:services];
            [self selectServices:services];
        }
        break;
        
        case HSPostTypePostStatusPhotoWithCaption:
            //phrase is "post latest photo with caption <caption>"
            NSLog(@"post latest photo with caption <caption>");
            uploadPhoto = YES;
            
            for (NSUInteger i = 5; i < tokens.count; i++) {
                if (i == 5)
                    status = [NSString stringWithFormat:@"%@",[tokens objectAtIndex:i]];
                else
                    status = [NSString stringWithFormat:@"%@ %@",[tokens objectAtIndex:i]];
            }
        break;
        
        case HSPostTypePostStatusPhotoCaption:
            //phrase is "post latest photo <caption>"
            NSLog(@"post latest photo <caption>");
            
            uploadPhoto = YES;
            for (NSUInteger i = 3; i < tokens.count; i++) {
                if (i == 3)
                    status = [NSString stringWithFormat:@"%@",[tokens objectAtIndex:i]];
                else
                    status = [NSString stringWithFormat:@"%@ %@",[tokens objectAtIndex:i]];
            }
        break;
        
        case HSPostTypeNone:
            //didn't match any phrase...
            [ctx sendAddViewsUtteranceView:@"Sorry, I didn't catch that. Try again."];
            [ctx sendRequestCompleted];
            return NO;
        break;
        
        default:
            //returned nothing. It should never make it here, but we will play it safe and retun something.
            [ctx sendAddViewsUtteranceView:@"Sorry, I didn't catch that. Try again."];
            [ctx sendRequestCompleted];
            return NO;
        break;
    }
    
    [ctx sendRequestCompleted];
    [self showTweetSheetWithText:status shouldUploadPhoto:uploadPhoto];

	return YES;
}

- (PostType)getPostTypeForValuesInTokens:(NSArray *)tokens {
    if (!tokens || tokens.count <= 0) return HSPostTypeNone;
    
    //phrase: post status
    if (tokens.count == 2 && [[tokens objectAtIndex:0] isEqualToString:@"post"] &&
        [[tokens objectAtIndex:1] isEqualToString:@"status"])
        return HSPostTypePostStatus;
    //phrase: post status saying <status>
    if (tokens.count >= 3 && [[tokens objectAtIndex:0] isEqualToString:@"post"] &&
        [[tokens objectAtIndex:1] isEqualToString:@"status"] &&
        [[tokens objectAtIndex:2] isEqualToString:@"saying"])
        return HSPostTypePostStatusSayingCustom;
    //phrase: post status <status>
    if (tokens.count >= 3 && [[tokens objectAtIndex:0] isEqualToString:@"post"] &&
        [[tokens objectAtIndex:1] isEqualToString:@"status"] &&
        ![[tokens objectAtIndex:2] isEqualToString:@"saying"])
        return HSPostTypePostStatusCustom;
    //phrase: update status with latest photo <status>
    if (tokens.count >= 5 && [[tokens objectAtIndex:0] isEqualToString:@"update"] &&
        [[tokens objectAtIndex:1] isEqualToString:@"status"] &&
        [[tokens objectAtIndex:2] isEqualToString:@"with"] &&
        [[tokens objectAtIndex:3] isEqualToString:@"latest"] &&
        [[tokens objectAtIndex:4] isEqualToString:@"photo"])
        return HSPostTypeUpdateStatusPhoto;
    //phrase: upload latest photo
    if (tokens.count == 3 && [[tokens objectAtIndex:0] isEqualToString:@"upload"] &&
        [[tokens objectAtIndex:1] isEqualToString:@"latest"] &&
        [[tokens objectAtIndex:2] isEqualToString:@"photo"])
        return HSPostTyepLatestPhoto;
    //phrase: upload latest photo to <networks>
    if (tokens.count >= 4 && [[tokens objectAtIndex:0] isEqualToString:@"upload"] &&
        [[tokens objectAtIndex:1] isEqualToString:@"latest"] &&
        [[tokens objectAtIndex:2] isEqualToString:@"photo"] &&
        [[tokens objectAtIndex:3] isEqualToString:@"to"])
        return HSPostTypeLatestPhotoToNetwork;
    //phrase: upload latest photo <caption>
    if (tokens.count > 3 && [[tokens objectAtIndex:0] isEqualToString:@"upload"] &&
        [[tokens objectAtIndex:1] isEqualToString:@"latest"] &&
        [[tokens objectAtIndex:2] isEqualToString:@"photo"])
        return HSPostTypeLatestPhotoCustom;
    //phrase: upload latest photo with caption <caption>
    if (tokens.count >= 5 && [[tokens objectAtIndex:0] isEqualToString:@"upload"] &&
        [[tokens objectAtIndex:1] isEqualToString:@"latest"] &&
        [[tokens objectAtIndex:2] isEqualToString:@"photo"] &&
        [[tokens objectAtIndex:3] isEqualToString:@"with"] &&
        [[tokens objectAtIndex:4] isEqualToString:@"caption"])
        return HSPostTypeLatestPhotoCaptionCustom;
    //phrase: upload latest photo with caption <caption> to <networks>
    if (tokens.count >= 6 && [[tokens objectAtIndex:0] isEqualToString:@"upload"] &&
        [[tokens objectAtIndex:1] isEqualToString:@"latest"] &&
        [[tokens objectAtIndex:2] isEqualToString:@"photo"] &&
        [[tokens objectAtIndex:3] isEqualToString:@"with"] &&
        [[tokens objectAtIndex:4] isEqualToString:@"caption"] &&
        [tokens containsObject:@"to"])
        return HSPostTypeLatestPhotoCaptionCustomToNetwork;
    //phrase: update status
    if (tokens.count == 2 && [[tokens objectAtIndex:0] isEqualToString:@"update"] &&
        [[tokens objectAtIndex:1] isEqualToString:@"status"])
        return HSPostTypeUpdateStatus;
    //phrase: update status <status>
    if (tokens.count > 2 && [[tokens objectAtIndex:0] isEqualToString:@"update"] &&
        [[tokens objectAtIndex:1] isEqualToString:@"status"])
        return HSPostTypeUpdateStatusCustom;
    //phrase: update status saying <status>
    if (tokens.count >= 3 && [[tokens objectAtIndex:0] isEqualToString:@"update"] &&
        [[tokens objectAtIndex:1] isEqualToString:@"status"] &&
        [[tokens objectAtIndex:2] isEqualToString:@"saying"])
        return HSPostTypeUpdateStatusSayingCustom;
    //phrase: post status to <networks> saying <status>
    if (tokens.count >= 4 && [[tokens objectAtIndex:0] isEqualToString:@"post"] &&
        [[tokens objectAtIndex:1] isEqualToString:@"status"] &&
        [[tokens objectAtIndex:2] isEqualToString:@"to"] &&
        [tokens containsObject:@"saying"])
        return HSPostTypePostStatusToNetworkSayingCustom;
    //phrase: post status to <networks>
    if (tokens.count > 3 && [[tokens objectAtIndex:0] isEqualToString:@"post"] &&
        [[tokens objectAtIndex:1] isEqualToString:@"status"] &&
        [[tokens objectAtIndex:2] isEqualToString:@"to"])
        return HSPostTypePostStatusToNetworkCustom;
    //phrase: post status with latest photo <status>
    if (tokens.count > 5 && [[tokens objectAtIndex:0] isEqualToString:@"post"] &&
        [[tokens objectAtIndex:1] isEqualToString:@"status"] &&
        [[tokens objectAtIndex:2] isEqualToString:@"with"] &&
        [[tokens objectAtIndex:3] isEqualToString:@"latest"] &&
        [[tokens objectAtIndex:4] isEqualToString:@"photo"])
        return HSPostTypePostStatusPhotoCustom;
    //phrase: post status with latest photo <status> to <networks
    if (tokens.count > 6 && [[tokens objectAtIndex:0] isEqualToString:@"post"] &&
        [[tokens objectAtIndex:1] isEqualToString:@"status"] &&
        [[tokens objectAtIndex:2] isEqualToString:@"with"] &&
        [[tokens objectAtIndex:3] isEqualToString:@"latest"] &&
        [[tokens objectAtIndex:4] isEqualToString:@"photo"] &&
        [tokens containsObject:@"to"])
        return HSPostTypePostStatusPhotoCustomNetwork;
    //phrase: post latest photo
    if (tokens.count == 3 && [[tokens objectAtIndex:0] isEqualToString:@"post"] &&
        [[tokens objectAtIndex:1] isEqualToString:@"latest"] &&
        [[tokens objectAtIndex:2] isEqualToString:@"photo"])
        return HSPostTypePostStatusPhoto;
    //pharse: post latest photo to <networks
    if (tokens.count > 4 && [[tokens objectAtIndex:0] isEqualToString:@"post"] &&
        [[tokens objectAtIndex:1] isEqualToString:@"latest"] &&
        [[tokens objectAtIndex:2] isEqualToString:@"photo"] &&
        [[tokens objectAtIndex:3] isEqualToString:@"to"])
        return HSPostTypePostStatusPhotoToNetwork;
    //phrase: post latest photo with caption <caption>
    if (tokens.count > 5 && [[tokens objectAtIndex:0] isEqualToString:@"post"] &&
        [[tokens objectAtIndex:1] isEqualToString:@"latest"] &&
        [[tokens objectAtIndex:2] isEqualToString:@"photo"] &&
        [[tokens objectAtIndex:3] isEqualToString:@"with"] &&
        [[tokens objectAtIndex:4] isEqualToString:@"caption"])
        return HSPostTypePostStatusPhotoWithCaption;
    //phrase: post latest photo <caption>
    if (tokens.count > 3 && [[tokens objectAtIndex:0] isEqualToString:@"post"] &&
        [[tokens objectAtIndex:1] isEqualToString:@"latest"] &&
        [[tokens objectAtIndex:2] isEqualToString:@"photo"])
        return HSPostTypePostStatusPhotoCaption;
        
    return HSPostTypeNone;
}

- (void)showTweetSheetWithText:(NSString *)text shouldUploadPhoto:(BOOL)uploadPhoto {
    id SBController = [objc_getClass("SBAssistantController") sharedInstance];
    if (!SBController) return;
    TWTweetComposeViewController *twController = [[TWTweetComposeViewController alloc] init];
    [twController setInitialText:[text stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[text substringToIndex:1] uppercaseString]]];
    if (uploadPhoto) {
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];

            [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:[group numberOfAssets]-1] options:0 usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {
                if (alAsset) {
                    ALAssetRepresentation *representation = [alAsset defaultRepresentation];
                    UIImage *latestPhoto = [UIImage imageWithCGImage:[representation fullResolutionImage]];
                    [UIImageJPEGRepresentation(latestPhoto, 1.0f) writeToFile:@"/Library/Application Support/Fusion/Writable/latestPhoto.jpg" options:NSDataWritingAtomic error:nil];
                    
                    TWTweetSheetAttachment *att = [[objc_getClass("TWTweetSheetAttachment") alloc] init];
                    [att setType:0];
                    [att setPreviewImage:latestPhoto];
                    [att setPayload:latestPhoto];
                    NSMutableArray *attachments = MSHookIvar<NSMutableArray*>(twController,"_attachments");
                    if (attachments) {
                        if (attachments.count > 0)
                            [attachments insertObject:att atIndex:0];
                        else
                            [attachments addObject:att];
                    }
                    [att release];
                    
                    [(TWTweetComposeViewController*)twController updateAttachmentsForOrientation:[[UIDevice currentDevice] orientation]];
                }
            }];
        }
        failureBlock: ^(NSError *error) {
            NSLog(@"No groups");
        }];
    }
    vc = [[UIViewController alloc] init];
    vc.view = [SBController view];
    
    [vc presentViewController:twController animated:YES completion:^{}];
}

- (NSMutableArray *)servicesPaths:(NSMutableArray *)services {
    if (!services || services.count == 0) return nil;
    NSArray *plugins = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/Library/Application Support/Fusion/Plugins" error:nil];
    if (plugins.count == 0) return nil;
    
    NSMutableArray *newServices = [[[NSMutableArray alloc] init] autorelease];
    for (NSString *p in plugins) {
        NSDictionary *pluginInfo = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"/Library/Application Support/Fusion/Plugins/%@/Info.plist",p]];
        for (NSUInteger i = 0; i < services.count; i++) {
            if ([[[pluginInfo objectForKey:@"ServiceTitle"] lowercaseString] isEqualToString:[[services objectAtIndex:i] lowercaseString]]) {
                [newServices addObject:[NSString stringWithFormat:@"/Library/Application Support/Fusion/Plugins/%@/",p]];
            }
        }
                        
    }
    
    return newServices;
}

- (void)selectServices:(NSMutableArray *)services {
    NSMutableDictionary *selectedDict = [NSMutableDictionary dictionary];
    [selectedDict setObject:services forKey:@"Select"];
    [selectedDict writeToFile:@"/User/Library/Preferences/com.homeschooldev.FusionSiriSelected.plist" atomically:YES];
}

- (void)dealloc {
    if (vc) [vc release];
    if (twController) [twController release];
    [super dealloc];
}

@end

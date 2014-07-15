#import "FusionController.h"

BOOL internetConnection = YES;
static id gStatus = nil;
static id gCompletion = nil;
static NSMutableArray *photoURLS = nil;
static GSTwitPicEngine *twitpicEngine = nil;
static int imagesCount = 0;
static BOOL doneUploading = NO;
static int didFinishCount = 0;

%hook SLComposeViewController

+ (SLComposeViewController *)composeViewControllerForServiceType:(NSString *)serviceType {
    return %orig(@"com.apple.social.twitter");
}

- (void)setServiceType:(NSString *)type {
    %orig(@"com.apple.social.twitter");
}

- (NSString *)serviceType {
    return @"com.apple.social.twitter";
}

%end

%hook PreferencesAppController

- (void)applicationDidBecomeActive:(id)application {
	//start fusiond when prefences starts up...
	[[FusionController shared] startFusiond];
    %orig;
}

%end

%hook TWTweetSheetLocationAssembly

- (void)updateLocationImage {
	//This is a fix for really long location names covering my buttons.
	//This hook will remove the location name image from it's superview
	//and put it in my own imageview, which I have size to what I please.
	
	%orig;
	
	//if ([[FusionController shared] enabled])
	//	[[FusionController shared] updateLocationImage];
}

- (void)cancelLocationButtonTapped:(id)arg1 {
	//if ([[FusionController shared] enabled])
	//	[[FusionController shared] cancelLocationButtonTapped];
    
	%orig;
}

- (void)setPulseArrowIcon:(BOOL)arg1 {
	if (arg1 && [[FusionController shared] enabled]) [[[FusionController shared] menu] locationButtonTappedOn:YES];
	%orig;
}

%end

%hook TWDSession

- (void)locationManager:(id)arg1 didUpdateToLocation:(CLLocation*)arg2 fromLocation:(id)arg3 {
	[[FusionController shared] setLocation:arg2];
	%orig;
}

- (void)playTweetSound {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.homeschooldev.fusionsettings.plist"];
    if (![[FusionController shared] enabled]) {
        //If tweak is disabled don't do any of the twitpic stuff...
        %orig;
        return;
    }

	//This is totally unrelated to the location. It just disables twitter from playing the tweet sound.
    if ([[dict objectForKey:@"Multiple"] isEqualToString:@"Multiple"] && ![[dict objectForKey:@"PluginController"] isEqualToString:@"PluginController"]) {
    	//Multiple networks were chosen and plugin controller didn't finish so we will let the plugincontroller play the sound.
    	return;
    }
    
    if ([[dict objectForKey:@"TwitterOnly"] isEqualToString:@"TwitterOnly"]) {
    	if (![[dict objectForKey:@"Sound"] isEqualToString:@"NoSound"]) {
       		NSURL *toneURLRef = [NSURL URLWithString:[dict objectForKey:@"Sound"]];
       		SystemSoundID toneSSID = 0;
       		AudioServicesCreateSystemSoundID((CFURLRef) toneURLRef,&toneSSID);
       		AudioServicesPlaySystemSound(toneSSID);
        		
       		[dict removeObjectForKey:@"TwitterOnly"];
       	}
    }
    
    [dict setObject:@"Twitterd" forKey:@"Twitterd"];
    [dict writeToFile:@"/User/Library/Preferences/com.homeschooldev.fusionsettings.plist" atomically:YES];
}

- (void)sendStatus:(TWStatus *)status completion:(id)completion {
    if (![[FusionController shared] enabled]) {
        //If tweak is disabled don't do any of the twitpic stuff...
        %orig;
        return;
    }

	if (!photoURLS) photoURLS = [[NSMutableArray alloc] init];
	
	NSMutableArray *images = [[[NSMutableArray alloc] init] autorelease];
	for (NSData *data in status.imageDatas) {
		UIImage *image = [UIImage imageWithData:data];
		[images addObject:image];
	}
	
	if (!doneUploading && images.count > 0) {
		//This is the first time send:completion is being called so we must start 
		//the process of uploading the photos...
   		[self uploadPhotos:images];
    	
    	gStatus = [status retain];
		gCompletion = [completion retain];
	}
	else {
		//This is the second time the method is being called or there are no images
		//so we must continue on with execution and call the orig method...
		NSString *message = [NSString stringWithFormat:@"%@",status.status];
		
		if (photoURLS.count > 0) {
        	NSString *url = [NSString stringWithFormat:@""];
        	for (NSString *u in photoURLS) {
           		url = [url stringByAppendingString:@" "];
           		url = [url stringByAppendingString:u];
        	}
        	if ([message isEqualToString:@""]) message = [NSString stringWithFormat:@"%@",url];
        	else message = [NSString stringWithFormat:@"%@%@",message,url];
    	}
    
    	if (message.length >= 140) {
    		HSTweakPastie *paste = [[HSTweakPastie alloc] init];    
    		NSString *url = [paste submitWithText:message makePrivate:YES language:6];
    		NSString *newMessage = [self fullTextWithPastie:url length:120 andMessage:message];
    		message = [NSString stringWithFormat:@"%@",newMessage];
    	}
    
    	status.status = message;
    	status.imageDatas = nil;
    
		if (photoURLS) [photoURLS release];
		//if (gStatus) [gStatus release];
		//if (gCompletion) [gCompletion release];
		//if (twitpicEngine) [twitpicEngine release];
	
		%orig(status,completion);
	}
}

%new
- (void)twitpicDidFinishUpload:(NSDictionary *)response { 
	//add url to urls
	didFinishCount++;
	NSDictionary *parsed = [response objectForKey:@"parsedResponse"];
	[photoURLS addObject:[parsed objectForKey:@"url"]];
	if (imagesCount == didFinishCount) {
		doneUploading = YES;
		[self sendStatus:gStatus completion:gCompletion];
	}
	
} 

%new
- (void)twitpicDidFailUpload:(NSDictionary *)error {
	didFinishCount++;
	if (imagesCount == didFinishCount) {
		doneUploading = YES;
		[self sendStatus:gStatus completion:gCompletion];
	}
}

%new
- (void)uploadPhotos:(NSArray *)images {
	ACAccount *account = MSHookIvar<ACAccount*>(self,"_activeAccount");
	TWDAuthenticator *auth = [[objc_getClass("TWDAuthenticator") alloc] init];
	
	if (!twitpicEngine)
   		twitpicEngine = [[GSTwitPicEngine twitpicEngineWithDelegate:self] retain];
    OAToken *oaToken = [[OAToken alloc] initWithKey:[[account credential] oauthToken] secret:[[account credential] oauthTokenSecret]];
    [twitpicEngine setConsumerKey:[auth consumerKey]];
    [twitpicEngine setConsumerSecret:[auth consumerSecret]];
    [twitpicEngine setAccessToken:oaToken];
    imagesCount = images.count;
    for (NSUInteger i = 0; i < images.count; i++) {
    	[twitpicEngine uploadPicture:[[FusionController shared] rotateImage:[images objectAtIndex:i]]];
    }
    [oaToken release];
    //[auth release];
}

%new
- (NSString *)fullTextWithPastie:(NSString *)url length:(int)length andMessage:(NSString *)message {
    //shorten url...
    NSString *apiEndpoint = [NSString stringWithFormat:@"http://is.gd/api.php?longurl=%@",url];
    NSString *shortURL = [NSString stringWithContentsOfURL:[NSURL URLWithString:apiEndpoint]
                                                      encoding:NSASCIIStringEncoding
                                                         error:nil];
        
    NSString *shortMessage = [message substringToIndex:(length - [shortURL length] - 1)];
    NSString *newMessage = [NSString stringWithFormat:@"%@ %@",shortMessage,shortURL];
    
    return newMessage;
}

%end

%hook UIAlertView

static BOOL showAlert = NO;

- (id)initWithTitle:(id)title message:(id)message delegate:(id)delegate cancelButtonTitle:(id)arg4 otherButtonTitles:(id)arg5 {
	//This is to prevent the alert from popping up if you don't have a twitter account.
	if ([title isEqualToString:@"No Twitter Accounts"]) {
		showAlert = YES;
		NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:@"/Library/Application Support/Fusion/Plugins/TwitterPlugin.bundle/Info.plist"];
		[dict setObject:@"NoTwitterAccount" forKey:@"NoTwitterAccount"];
		[dict writeToFile:@"/Library/Application Support/Fusion/Plugins/TwitterPlugin.bundle/Info.plist" atomically:YES];
	}
	return %orig;
}

- (void)show {
	if (!showAlert) %orig;
	else showAlert = NO;
}

%end

//Hooks for iOS 6...
%hook SLTwitterComposeViewController

- (void)viewWillAppear:(BOOL)arg1 {
    %orig;
    
    [[FusionController shared] setController:self];
	
	if ([[FusionController shared] isOpeningPhotos]) {
        //The controller isn't really opening for the first time... It's just reshowing after the photos disappeared.
		[[FusionController shared] setIsOpeningPhotos:NO];
	}
	else {
        //The controller is actually opening for the first time... So we must clean up files before start and then setup Fusion..
		[[FusionController shared] cleanUpFiles];
        if ([[FusionController shared] enabled])
            [[FusionController shared] setupFusion];
	}
}

- (void)viewWillDisappear:(BOOL)arg1 {
	if (![[FusionController shared] isOpeningPhotos]) {
		//Close everything and release since the controller is actually closing...
		[[FusionController shared] release];
		%orig;
	}
}

- (void)viewDidDisappear:(BOOL)arg1 {
    if (!SaveImage()) WriteImagePath();
	if (![[FusionController shared] isOpeningPhotos])
        %orig;
}

- (BOOL)setInitialText:(id)arg1 {
    if ([[FusionController shared] enabled]) {
        [[FusionController shared] setStartText:arg1];
    }
    return %orig;
}

- (void)sendButtonTapped:(id)arg1 {
	if (![[FusionController shared] enabled]) {
        %orig;
        return;
    }
    
    if (![[FusionController shared] internetConnection]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No Internet connection" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }
		
    if ([[[[FusionController shared] menu] bundles] count] == 0) {
        //This displays and error if no services were selected (by hand or by default)
        if ([[[FusionController shared] menu] isHidden]) {
            UIView *wrapper = [[MSHookIvar<UILabel*>(self,"_countLabel") superview] viewWithTag:[[FusionController shared] buttonWrapperTag]];
            [[FusionController shared] showMenu:(UIButton*)[wrapper viewWithTag:[[FusionController shared] networksViewTag]]];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You must select a service" delegate:nil cancelButtonTitle:@"OK"otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
    }
    else {
        [MSHookIvar<UIButton*>(self,"_sendButton") setEnabled:NO];
			
        NSArray *plugs = [[[FusionController shared] menu] pluginsRequireUIAttention];
        //This block of code will show the views of each of the plugins that requests it.
        if (plugs && ![arg1 isKindOfClass:[NSString class]]) {
            //Show menu if it is not already showen.
            if ([[[FusionController shared] menu] isHidden]) {
                [[FusionController shared] setHasPluginViewsToShow:YES];
                UIView *wrapper = [[MSHookIvar<UILabel*>(self,"_countLabel") superview] viewWithTag:[[FusionController shared] buttonWrapperTag]];
                [[FusionController shared] showMenu:(UIButton*)[wrapper viewWithTag:[[FusionController shared] networksViewTag]]];
            }
            else {
                [[[FusionController shared] menu] showPluginUIs:plugs];
            }
        }
        else {
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[[FusionController shared] getData]];
				
            //Checks to see if there are any twitter accounts. If there aren't a key is added to the dict to present an error at the end of the post.
            NSMutableDictionary *twAccounts = [NSMutableDictionary dictionaryWithContentsOfFile:@"/Library/Application Support/Fusion/Plugins/TwitterPlugin.bundle/Info.plist"];
            if ([[twAccounts objectForKey:@"NoTwitterAccount"] isEqualToString:@"NoTwitterAccount"] && [[[FusionController shared] menu] twitterSelected])
                [dict setObject:@"NoTwitterAccount" forKey:@"NoTwitterAccount"];
    
            CPDistributedMessagingCenter *center = [CPDistributedMessagingCenter centerNamed:@"com.homeschooldev.fusiond"];
            [center sendMessageName:@"post" userInfo:dict];
				
            if ([[[[FusionController shared] menu] bundles] count] > 1 && [[[FusionController shared] menu] twitterSelected]) {
                //both twitter and others were selected so we need to write it to file...
                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.homeschooldev.fusionsettings.plist"];
                [dict setObject:@"Multiple" forKey:@"Multiple"];
                if ([dict objectForKey:@"PluginController"]) [dict removeObjectForKey:@"PluginController"];
                if ([dict objectForKey:@"Twitterd"]) [dict removeObjectForKey:@"Twitterd"];
                [dict writeToFile:@"/User/Library/Preferences/com.homeschooldev.fusionsettings.plist" atomically:YES];
            }
            else {
                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.homeschooldev.fusionsettings.plist"];
                if ([dict objectForKey:@"Multiple"]) [dict removeObjectForKey:@"Multiple"];
                if ([dict objectForKey:@"PluginController"]) [dict removeObjectForKey:@"PluginController"];
                if ([dict objectForKey:@"Twitterd"]) [dict removeObjectForKey:@"Twitterd"];
                [dict writeToFile:@"/User/Library/Preferences/com.homeschooldev.fusionsettings.plist" atomically:YES];
            }
				
            if ([[[FusionController shared] menu] twitterSelected]) {
                if ([[[[FusionController shared] menu] bundles] count] == 1) {
                    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.homeschooldev.fusionsettings.plist"];
                    [dict setObject:@"TwitterOnly" forKey:@"TwitterOnly"];
                    [dict writeToFile:@"/User/Library/Preferences/com.homeschooldev.fusionsettings.plist" atomically:YES];
                }
                %orig;
            }
            else
                [self cancelButtonTapped:nil];
		}
	}
}

- (void)showMentionPanel:(BOOL)arg1 {
	if ([[FusionController shared] enabled])
        [[FusionController shared] setWrapperHidden:YES];
	%orig;
}

- (void)hideMentionPanel:(BOOL)arg1 {
	if ([[FusionController shared] enabled]) 
        [[FusionController shared] setWrapperHidden:NO];
	%orig;
}

- (void)textViewDidChange:(id)arg1 {
	%orig;
	UITextView *textView = MSHookIvar<UITextView*>(self,"_textView");
	UILabel *countLabel = MSHookIvar<UILabel*>(self,"_countLabel");
	countLabel.text = [NSString stringWithFormat:@"%i",textView.text.length];
}

- (void)noteStatusChanged {
	//Overwrote this method to stop the count label from changing...
}

- (void)tableView:(id)arg1 didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
	//Had to override this method to fix mentioning people since the -(void)noteStatusChanged was overwritten.
	TWUserRecord *record = [[self currentResults] objectAtIndex:indexPath.row];
	UITextView *textView = MSHookIvar<UITextView*>(self,"_textView");
	NSMutableString *newString = [[NSMutableString alloc] initWithString:[textView text]];
	[newString insertString:record.screen_name atIndex:[textView selectedRange].location];
	[textView setText:newString];
	[newString release];
		
	%orig;
	
	[textView setSelectedRange:NSMakeRange([textView selectedRange].location + record.screen_name.length,0)];
	UILabel *countLabel = MSHookIvar<UILabel*>(self,"_countLabel");
	countLabel.text = [NSString stringWithFormat:@"%i",textView.text.length];
}

- (void)updateTextViewAndPaperClipForOrientation:(int)arg1 {
    [[FusionController shared] setCurrentOrientation:arg1];
	%orig;
}

- (void)willAnimateRotationToInterfaceOrientation:(int)arg1 duration:(double)arg2 {
	%orig;
	
	if ([[FusionController shared] enabled]) {        
        [[[FusionController shared] menu] rotateToOrientation:arg1 withDuration:arg2];
        [[FusionController shared] rotateMenuWithOrientation:arg1];
	}
}

- (id)init {
	/*NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:@"/Library/Application Support/Fusion/Plugins/TwitterPlugin.bundle/Info.plist"];
    if ([[dict objectForKey:@"UseTwitter"] boolValue]) return nil;
    
    NSMutableDictionary *twAccounts = [NSMutableDictionary dictionaryWithContentsOfFile:@"/Library/Application Support/Fusion/Plugins/TwitterPlugin.bundle/Info.plist"];
	[twAccounts setObject:@"" forKey:@"NoTwitterAccount"];
	[twAccounts writeToFile:@"/Library/Application Support/Fusion/Plugins/TwitterPlugin.bundle/Info.plist" atomically:YES];*/
    
    [[FusionController shared] startFusiond];
    [[FusionController shared] setIsOpeningPhotos:NO];
	
	return %orig;
}

%new
- (NSDictionary*)getData {
    return [[FusionController shared] getData];
}

%end

//Hooks for iOS 5...
%hook TWTweetComposeViewController

- (void)viewWillAppear:(BOOL)arg1 {
    %orig;
    
    [[FusionController shared] setController:self];
	
	if ([[FusionController shared] isOpeningPhotos]) {
        //The controller isn't really opening for the first time... It's just reshowing after the photos disappeared.
		[[FusionController shared] setIsOpeningPhotos:NO];
	}
	else {
        //The controller is actually opening for the first time... So we must clean up files before start and then setup Fusion..
		[[FusionController shared] cleanUpFiles];
        if ([[FusionController shared] enabled])
            [[FusionController shared] setupFusion];
	}
}

- (void)viewWillDisappear:(BOOL)arg1 {
	if (![[FusionController shared] isOpeningPhotos]) {
		//Close everything and release since the controller is actually closing...
		[[FusionController shared] release];
		%orig;
	}
}

- (void)viewDidDisappear:(BOOL)arg1 {
    if (!SaveImage()) {
		WriteImagePath();
	}

	if (![[FusionController shared] isOpeningPhotos])
        %orig;
}

- (BOOL)setInitialText:(id)arg1 {
    if ([[FusionController shared] enabled]) {
        [[FusionController shared] setStartText:arg1];
    }
    return %orig;
}

- (void)sendButtonTapped:(id)arg1 {
	if (![[FusionController shared] enabled]) {
        %orig;
        return;
    }
    
    if (![[FusionController shared] internetConnection]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No Internet connection" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }
		
    if ([[[[FusionController shared] menu] bundles] count] == 0) {
        //This displays and error if no services were selected (by hand or by default)
        if ([[[FusionController shared] menu] isHidden]) {
            UIView *wrapper = [[MSHookIvar<UILabel*>(self,"_countLabel") superview] viewWithTag:[[FusionController shared] buttonWrapperTag]];
            [[FusionController shared] showMenu:(UIButton*)[wrapper viewWithTag:[[FusionController shared] networksViewTag]]];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You must select a service" delegate:nil cancelButtonTitle:@"OK"otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
    }
    else {
        [MSHookIvar<UIButton*>(self,"_sendButton") setEnabled:NO];
			
        NSArray *plugs = [[[FusionController shared] menu] pluginsRequireUIAttention];
        //This block of code will show the views of each of the plugins that requests it.
        if (plugs && ![arg1 isKindOfClass:[NSString class]]) {
            //Show menu if it is not already showen.
            if ([[[FusionController shared] menu] isHidden]) {
                [[FusionController shared] setHasPluginViewsToShow:YES];
                UIView *wrapper = [[MSHookIvar<UILabel*>(self,"_countLabel") superview] viewWithTag:[[FusionController shared] buttonWrapperTag]];
                [[FusionController shared] showMenu:(UIButton*)[wrapper viewWithTag:[[FusionController shared] networksViewTag]]];
            }
            else {
                [[[FusionController shared] menu] showPluginUIs:plugs];
            }
        }
        else {
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[[FusionController shared] getData]];
				
            //Checks to see if there are any twitter accounts. If there aren't a key is added to the dict to present an error at the end of the post.
            NSMutableDictionary *twAccounts = [NSMutableDictionary dictionaryWithContentsOfFile:@"/Library/Application Support/Fusion/Plugins/TwitterPlugin.bundle/Info.plist"];
            if ([[twAccounts objectForKey:@"NoTwitterAccount"] isEqualToString:@"NoTwitterAccount"] && [[[FusionController shared] menu] twitterSelected])
                [dict setObject:@"NoTwitterAccount" forKey:@"NoTwitterAccount"];
				
            if ([[[[FusionController shared] menu] bundles] count] > 1 && [[[FusionController shared] menu] twitterSelected]) {
                //both twitter and others were selected so we need to write it to file...
                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.homeschooldev.fusionsettings.plist"];
                [dict setObject:@"Multiple" forKey:@"Multiple"];
                if ([dict objectForKey:@"PluginController"]) [dict removeObjectForKey:@"PluginController"];
                if ([dict objectForKey:@"Twitterd"]) [dict removeObjectForKey:@"Twitterd"];
                [dict writeToFile:@"/User/Library/Preferences/com.homeschooldev.fusionsettings.plist" atomically:YES];
            }
            else {
                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.homeschooldev.fusionsettings.plist"];
                if ([dict objectForKey:@"Multiple"]) [dict removeObjectForKey:@"Multiple"];
                if ([dict objectForKey:@"PluginController"]) [dict removeObjectForKey:@"PluginController"];
                if ([dict objectForKey:@"Twitterd"]) [dict removeObjectForKey:@"Twitterd"];
                [dict writeToFile:@"/User/Library/Preferences/com.homeschooldev.fusionsettings.plist" atomically:YES];
            }
				
            if ([[[FusionController shared] menu] twitterSelected]) {
                if ([[[[FusionController shared] menu] bundles] count] == 1) {
                    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.homeschooldev.fusionsettings.plist"];
                    [dict setObject:@"TwitterOnly" forKey:@"TwitterOnly"];
                    [dict writeToFile:@"/User/Library/Preferences/com.homeschooldev.fusionsettings.plist" atomically:YES];
                }
                %orig;
            }
            else
                [self cancelButtonTapped:nil];
                
            //send post notification to fusiond
            CPDistributedMessagingCenter *center = [CPDistributedMessagingCenter centerNamed:@"com.homeschooldev.fusiond"];
            [center sendMessageName:@"post" userInfo:dict];
		}
	}
}

- (void)showMentionPanel:(BOOL)arg1 {
	if ([[FusionController shared] enabled])
        [[FusionController shared] setWrapperHidden:YES];
	%orig;
}

- (void)hideMentionPanel:(BOOL)arg1 {
	if ([[FusionController shared] enabled]) 
        [[FusionController shared] setWrapperHidden:NO];
	%orig;
}

- (void)textViewDidChange:(id)arg1 {
	%orig;
	UITextView *textView = MSHookIvar<UITextView*>(self,"_textView");
	UILabel *countLabel = MSHookIvar<UILabel*>(self,"_countLabel");
	countLabel.text = [NSString stringWithFormat:@"%i",textView.text.length];
}

- (void)noteStatusChanged {
	//Overwrote this method to stop the count label from changing...
}

- (void)tableView:(id)arg1 didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
	//Had to override this method to fix mentioning people since the -(void)noteStatusChanged was overwritten.
	TWUserRecord *record = [[self currentResults] objectAtIndex:indexPath.row];
	UITextView *textView = MSHookIvar<UITextView*>(self,"_textView");
	NSMutableString *newString = [[NSMutableString alloc] initWithString:[textView text]];
	[newString insertString:record.screen_name atIndex:[textView selectedRange].location];
	[textView setText:newString];
	[newString release];
		
	%orig;
	
	[textView setSelectedRange:NSMakeRange([textView selectedRange].location + record.screen_name.length,0)];
	UILabel *countLabel = MSHookIvar<UILabel*>(self,"_countLabel");
	countLabel.text = [NSString stringWithFormat:@"%i",textView.text.length];
}

- (void)updateTextViewAndPaperClipForOrientation:(int)arg1 {
    [[FusionController shared] setCurrentOrientation:arg1];
	%orig;
}

- (void)willAnimateRotationToInterfaceOrientation:(int)arg1 duration:(double)arg2 {
	%orig;
	
	if ([[FusionController shared] enabled]) {        
        [[[FusionController shared] menu] rotateToOrientation:arg1 withDuration:arg2];
        [[FusionController shared] rotateMenuWithOrientation:arg1];
	}
}

- (id)init {
	/*NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:@"/Library/Application Support/Fusion/Plugins/TwitterPlugin.bundle/Info.plist"];
    if ([[dict objectForKey:@"UseTwitter"] boolValue]) return nil;
    
    NSMutableDictionary *twAccounts = [NSMutableDictionary dictionaryWithContentsOfFile:@"/Library/Application Support/Fusion/Plugins/TwitterPlugin.bundle/Info.plist"];
	[twAccounts setObject:@"" forKey:@"NoTwitterAccount"];
	[twAccounts writeToFile:@"/Library/Application Support/Fusion/Plugins/TwitterPlugin.bundle/Info.plist" atomically:YES];*/
    
    [[FusionController shared] startFusiond];
    [[FusionController shared] setIsOpeningPhotos:NO];	
	
	return %orig;
}

%new
- (NSDictionary*)getData {
    return [[FusionController shared] getData];
}

%end

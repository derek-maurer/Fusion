#import "HSMenu.h"
#import "DRM.h"
#import "HSReachability.h"
#import "TwitPic/GSTwitPicEngine.h"
#import <MediaPlayer/MediaPlayer.h>
#import "HSTweakPastie.h"
#import <Twitter/TWDAuthenticator.h>

static HSMenu *menu = nil;
static HSReachability *internetReachable = nil;
static NSString *LocationPath = @"/Library/Application Support/Fusion/Writable/Location.plist";
static NSString *rootPath = @"/Library/Application Support/Fusion";
int kViewTag = 1110111;
int kComposeIconTag = 223344;
int kButtonWrapperTag = 234543;
int kCameraTag = 234;
int kMusicTag = 22222;
int orientation;
BOOL sendButtonTapped = NO;
BOOL pluginViews = NO;
BOOL internetConnection = YES;
BOOL openingPhotos = NO;
static id gStatus = nil;
static id gCompletion = nil;
static NSMutableArray *photoURLS = nil;
static GSTwitPicEngine *twitpicEngine = nil;
static int imagesCount = 0;
static BOOL doneUploading = NO;
static NSString *initialText = nil;

%hook PreferencesAppController

- (void)applicationDidBecomeActive:(id)application {
	//start fusiond when prefences starts up...
	NSDictionary *fusiond = [NSDictionary dictionaryWithObject:@"d" forKey:@"somedKey"];
	[fusiond writeToFile:@"/User/Library/Keyboard/com.homeschooldev.fusion.watch.plist" atomically:YES];
}

%end

%hook TWTweetSheetLocationAssembly

- (void)updateLocationImage {
	//This is a fix for really long location names covering my buttons.
	//This hook will remove the location name image from it's superview
	//and put it in my own imageview, which I have size to what I please.
	
	%orig;
	
	if (menu) {
		UIView *assemblyView = MSHookIvar<UIView*>(self,"_assemblyView");
		UIButton *locButton = MSHookIvar<UIButton*>(self,"_locationButton");
		UIImageView *orgImage = MSHookIvar<UIImageView*>(self,"_locationImageView");
		UIButton *cancel = MSHookIvar<UIButton*>(self,"_cancelLocationButton");
		[orgImage retain];
		[orgImage removeFromSuperview];
		UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(locButton.frame.size.width + locButton.frame.origin.x,-6,110,42)];
		[imageView setTag:1111];
		[imageView setClipsToBounds:YES];
		[imageView addSubview:orgImage];
		orgImage.frame = CGRectMake(0,0,orgImage.frame.size.width,orgImage.frame.size.height);
		[assemblyView addSubview:imageView];
		[imageView release];
		cancel.frame = CGRectMake(imageView.frame.size.width - cancel.frame.size.width - 5,cancel.frame.origin.y,cancel.frame.size.width,cancel.frame.size.height);
		[orgImage release];
	}
}

- (void)setLocationLabelText:(NSString*)arg1 {
	//If the user taps the cancel button we should remove the imageview 
	//from the superview. Didn't use -(void)cancelButtonTapped: because it caused a compiler error
	if (menu && [arg1 isEqualToString:@"Add Location"]) {
		UIView *assemblyView = MSHookIvar<UIView*>(self,"_assemblyView");
		UIImageView *imageView = (UIImageView*)[assemblyView viewWithTag:1111];
		if (imageView) [imageView removeFromSuperview];
	}
	%orig;
}

- (void)cancelLocationButtonTapped:(id)arg1 {
	if (menu) {	
		UIView *assemblyView = MSHookIvar<UIView*>(self,"_assemblyView");
		UIImageView *imageView = (UIImageView*)[assemblyView viewWithTag:1111];
		if (imageView) {
			[imageView removeFromSuperview];
		}
    	if ([[NSFileManager defaultManager] fileExistsAtPath:LocationPath])
    		[[NSFileManager defaultManager] removeItemAtPath:LocationPath error:nil];
		
		[menu locationButtonTappedOn:NO];
	}
	%orig(arg1);
}

- (void)setPulseArrowIcon:(BOOL)arg1 {
	if (arg1 && menu) [menu locationButtonTappedOn:YES];
	
	%orig(arg1);
}

%end

%hook TWDSession

- (void)locationManager:(id)arg1 didUpdateToLocation:(CLLocation*)arg2 fromLocation:(id)arg3 {
	NSString *path = @"/Library/Application Support/Fusion/Writable/Location.plist";
	
	if (!SaveImage()) WriteImagePath();

	if (arg2) {
		if ([[NSFileManager defaultManager] fileExistsAtPath:path])
			[[NSFileManager defaultManager] removeItemAtPath:path error:nil];
		NSMutableDictionary *location = [[NSMutableDictionary alloc] init];
	  	[location setObject:[NSNumber numberWithDouble:arg2.coordinate.longitude] forKey:@"Longitude"];
	  	[location setObject:[NSNumber numberWithDouble:arg2.coordinate.latitude] forKey:@"Latitude"];
	  	[location setObject:[NSNumber numberWithDouble:arg2.altitude] forKey:@"Altitude"];
	  	[location setObject:[NSNumber numberWithDouble:arg2.horizontalAccuracy] forKey:@"HorizontalAccuracy"];
	   	[location setObject:[NSNumber numberWithDouble:arg2.verticalAccuracy] forKey:@"VerticalAccuracy"];
	   	if (arg2.timestamp.description)
	   		[location setObject:arg2.timestamp.description forKey:@"Timestamp"];
	   	[location writeToFile:path atomically:YES];
	   		
	   	[location release];
	}
	
	%orig;
}

- (void)playTweetSound {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.homeschooldev.fusionsettings.plist"];
    if (![[dict objectForKey:@"Enabled"] boolValue] && [dict objectForKey:@"Enabled"]) {
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
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.homeschooldev.fusionsettings.plist"];
    if (![[dict objectForKey:@"Enabled"] boolValue]) {
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

static int didFinishCount = 0;
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
- (UIImage *)rotateImage:(UIImage *)image {
	
	CGImageRef imgRef = image.CGImage;
	
	CGFloat width = CGImageGetWidth(imgRef);
	CGFloat height = CGImageGetHeight(imgRef);
	
	CGAffineTransform transform = CGAffineTransformIdentity;
	CGRect bounds = CGRectMake(0, 0, width, height);
	
	CGFloat scaleRatio = bounds.size.width / width;
	CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
	CGFloat boundHeight;
	UIImageOrientation orient = image.imageOrientation;
	switch(orient) {
		case UIImageOrientationUp: //EXIF = 1
			transform = CGAffineTransformIdentity;
			NSLog(@"Orientation up");
			break;
			
		case UIImageOrientationUpMirrored: //EXIF = 2
			transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			NSLog(@"Orientation up mirrored");
			break;
			
		case UIImageOrientationDown: //EXIF = 3
			transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
			transform = CGAffineTransformRotate(transform, M_PI);
			NSLog(@"Orientation down");
			break;
			
		case UIImageOrientationDownMirrored: //EXIF = 4
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
			transform = CGAffineTransformScale(transform, 1.0, -1.0);
			NSLog(@"Orientation down mirrored");
			break;
			
		case UIImageOrientationLeftMirrored: //EXIF = 5
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			NSLog(@"Orientation left mirrored");
			break;
			
		case UIImageOrientationLeft: //EXIF = 6
			/*boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);*/
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeScale(-1.0, 1.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			
			NSLog(@"Orientation left");
			break;
			
		case UIImageOrientationRightMirrored: //EXIF = 7
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeScale(-1.0, 1.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			NSLog(@"Orientation right mirrored");
			break;
			
		case UIImageOrientationRight: //EXIF = 8
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			NSLog(@"Orientation right");
			break;
			
		default:
			[NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
			
	}
	
	UIGraphicsBeginImageContext(bounds.size);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
		CGContextScaleCTM(context, -scaleRatio, scaleRatio);
		CGContextTranslateCTM(context, -height, 0);
	}
	else {
		CGContextScaleCTM(context, scaleRatio, -scaleRatio);
		CGContextTranslateCTM(context, 0, -height);
	}
	
	CGContextConcatCTM(context, transform);
	
	CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
	UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return imageCopy;
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
	TWDAuthenticator *auth = [[%c(TWDAuthenticator) alloc] init];
	
	if (!twitpicEngine)
   		twitpicEngine = [[GSTwitPicEngine twitpicEngineWithDelegate:self] retain];
    OAToken *oaToken = [[OAToken alloc] initWithKey:account.credential.oauthToken secret:account.credential.oauthTokenSecret];
    //OAToken *oaToken = [[OAToken alloc] initWithKey:@"36875747-0XsRw5Z0t3hYoH2AjSlTmfSwi84ZmiP45YM3t5KN6" secret:@"fWX9X4xLguQtdfwzAVMvyG5VBFYunry6eK9kn5JaQ"];
    [twitpicEngine setConsumerKey:[auth consumerKey]];
    [twitpicEngine setConsumerSecret:[auth consumerSecret]];
    [twitpicEngine setAccessToken:oaToken];
    imagesCount = images.count;
    for (NSUInteger i = 0; i < images.count; i++) {
    	[twitpicEngine uploadPicture:[self rotateImage:[images objectAtIndex:i]]];
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

%hook TWTweetComposeViewController

- (void)viewWillAppear:(BOOL)arg1 {

	%orig;	

	if (!SaveImage()) WriteImagePath();
	
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.homeschooldev.fusionsettings.plist"];
    if ([[dict objectForKey:@"Enabled"] boolValue] || [dict objectForKey:@"Enabled"] == nil && !openingPhotos) {

        if (initialText) [MSHookIvar<UITextView*>(self,"_textView") setText:initialText];
    	UITextView *textView = MSHookIvar<UITextView*>(self,"_textView");
        textView.keyboardType = UIKeyboardTypeDefault;
    	UILabel *countLabel = MSHookIvar<UILabel*>(self,"_countLabel");
		countLabel.text = [NSString stringWithFormat:@"%i",textView.text.length];
    	//Check internet connection...
    	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    	internetReachable = [[HSReachability reachabilityForInternetConnection] retain];
    	[internetReachable startNotifier];
    	[self performSelector:@selector(checkNetworkStatus:) withObject:nil];
    
    	//Start initialization of Fusion...
    	[self performSelectorInBackground:@selector(startFusiond) withObject:nil];
		[self performSelector:@selector(fusionSetup:) withObject:nil];
		[self performSelector:@selector(setupNetworkSelector:) withObject:nil];
	}
	
	if (openingPhotos) {
		openingPhotos = NO;
	}
	else {
		//Delete location file...
    	if ([[NSFileManager defaultManager] fileExistsAtPath:LocationPath])
    		[[NSFileManager defaultManager] removeItemAtPath:LocationPath error:nil];
    	//Delete images...
		if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/Application Support/Fusion/Writable/Images"])
    		[[NSFileManager defaultManager] removeItemAtPath:@"/Library/Application Support/Fusion/Writable/Images" error:nil];
	}
}

- (BOOL)setInitialText:(id)arg1 {
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.homeschooldev.fusionsettings.plist"];
    if ([[dict objectForKey:@"Enabled"] boolValue] || [dict objectForKey:@"Enabled"] == nil) {
        initialText = arg1;
    }
    return %orig;
}

- (void)sendButtonTapped:(id)arg1 {
	if (menu) {
		if (!internetConnection) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No Internet connection" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
			return;
		}
		
		if ([[menu bundles] count] == 0) {
			//This displays and error if no services were selected (by hand or by default)
            if (menu.hidden) {
                UIView *wrapper = [[MSHookIvar<UILabel*>(self,"_countLabel") superview] viewWithTag:kButtonWrapperTag];
                [self performSelector:@selector(drawNetworksView:) withObject:[wrapper viewWithTag:kViewTag]];
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You must select a service" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                [alert release];
            }
		}
		else {
			sendButtonTapped = YES;
			[MSHookIvar<UIButton*>(self,"_sendButton") setEnabled:NO];
			
			NSArray *plugs = [menu pluginsRequireUIAttention];
			//This block of code will show the views of each of the plugins that requests it.
			if (plugs && ![arg1 isKindOfClass:[NSString class]]) {
				//Show menu if it is not already showen.
				if (menu.hidden) {
					pluginViews = YES;
					UIView *wrapper = [[MSHookIvar<UILabel*>(self,"_countLabel") superview] viewWithTag:kButtonWrapperTag];
					[self performSelector:@selector(drawNetworksView:) withObject:[wrapper viewWithTag:kViewTag]];
				}
				else {
					[menu showPluginUIs:plugs];
				}
			}
			else {
				NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self performSelector:@selector(getDataFromTweetSheet) withObject:nil]];
				
				//Checks to see if there are any twitter accounts. If there aren't a key is added to the dict to present an error at the end of the post.
				NSMutableDictionary *twAccounts = [NSMutableDictionary dictionaryWithContentsOfFile:@"/Library/Application Support/Fusion/Plugins/TwitterPlugin.bundle/Info.plist"];
				if ([[twAccounts objectForKey:@"NoTwitterAccount"] isEqualToString:@"NoTwitterAccount"] && [menu twitterSelected])
					[dict setObject:@"NoTwitterAccount" forKey:@"NoTwitterAccount"];
	
				CPDistributedMessagingCenter *center = [CPDistributedMessagingCenter centerNamed:@"com.homeschooldev.fusiond"];
				[center sendMessageName:@"post" userInfo:dict];
				
				
				if ([[menu bundles] count] > 1 && [menu twitterSelected]) {
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
				
				if ([menu twitterSelected]) {
					if ([[menu bundles] count] == 1) {
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
}

- (void)cancelButtonTapped:(id)arg1 {
	if (!SaveImage()) WriteImagePath();
	
	%orig;
	if (arg1) {
		//The cancel button was actually tapped and files need to be deleted...
		
		//Delete location file...
    	if ([[NSFileManager defaultManager] fileExistsAtPath:LocationPath])
    		[[NSFileManager defaultManager] removeItemAtPath:LocationPath error:nil];
    	//Delete images...
		if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/Application Support/Fusion/Writable/Images"])
    		[[NSFileManager defaultManager] removeItemAtPath:@"/Library/Application Support/Fusion/Writable/Images" error:nil];
	}
}

- (void)showMentionPanel:(BOOL)arg1 {
	if (menu) {
		UILabel *countLabel = MSHookIvar<UILabel*>(self,"_countLabel");
		UIView *wrapper = [[countLabel superview] viewWithTag:kButtonWrapperTag];
		if (wrapper) [wrapper setHidden:YES];
	}
	%orig(arg1);
}

- (void)hideMentionPanel:(BOOL)arg1 {
	if (menu) {
		UILabel *countLabel = MSHookIvar<UILabel*>(self,"_countLabel");
		UIView *wrapper = [[countLabel superview] viewWithTag:kButtonWrapperTag];
		if (wrapper) [wrapper setHidden:NO];
	}
	%orig(arg1);
}

- (void)textViewDidChange:(id)arg1 {
	%orig;
	UITextView *textView = MSHookIvar<UITextView*>(self,"_textView");
	UILabel *countLabel = MSHookIvar<UILabel*>(self,"_countLabel");
	countLabel.text = [NSString stringWithFormat:@"%i",textView.text.length];
}

- (void)noteStatusChanged {
	//This is stop the count label from changing...
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
	orientation = arg1;
	%orig;
}

- (void)willAnimateRotationToInterfaceOrientation:(int)arg1 duration:(double)arg2 {
	%orig(arg1,arg2);
	
	if (menu) {
		[menu rotateToOrientation:arg1 withDuration:arg2];
		UIView *textViewWrapper = MSHookIvar<UIView*>(self,"_textViewWrapper");
		UITextView *tView = MSHookIvar<UITextView *>(self, "_textView");
	    menu.frame = CGRectMake(tView.frame.origin.x, tView.frame.origin.y, textViewWrapper.frame.size.width - 82, tView.frame.size.height);
	    TWTweetSheetLocationAssembly *locationAssembly = MSHookIvar<TWTweetSheetLocationAssembly *>(self,"_locationAssembly");
		UIButton *locationButton = MSHookIvar<UIButton*>(locationAssembly,"_locationLabel");
	    UILabel *countLabel = MSHookIvar<UILabel*>(self,"_countLabel");
	    UIView *cardView = [countLabel superview];
	    UIView *wrapper = [cardView viewWithTag:kButtonWrapperTag];
	    int height;
	    if (arg1 == 3 || arg1 == 4) height = 35;
	    else height = 30;
	    wrapper.frame = CGRectMake(locationButton.frame.size.width + locationButton.frame.origin.x + 22,
									cardView.frame.size.height - height,
									countLabel.frame.origin.x - (locationButton.frame.size.width + locationButton.frame.origin.x + 22),
									26);								
	    double gap = (wrapper.frame.size.width - (26 * 3))/4;
	    [[wrapper viewWithTag:kViewTag] setFrame:CGRectMake(gap,0,26,26)];
	   	[[wrapper viewWithTag:kCameraTag] setFrame:CGRectMake(26 + (gap*2),0,26,26)];
	   	[[wrapper viewWithTag:kMusicTag] setFrame:CGRectMake((26 * 2) + (gap*3),0,26,26)];
	    [menu reload];
	}
}

- (void)viewWillDisappear:(BOOL)arg1 {
	if (!openingPhotos) %orig;
}

- (void)viewDidDisappear:(BOOL)arg1 {
	if (!SaveImage()) WriteImagePath();

	if (!openingPhotos) {
		//release attachments array because the tweetsheet is closing and the photos isn't opening.
		if (menu) {	
			UILabel *countLabel = MSHookIvar<UILabel*>(self,"_countLabel");
	   		UIView *cardView = [countLabel superview];
	    	UIView *wrapper = [cardView viewWithTag:kButtonWrapperTag];
	    	[wrapper removeFromSuperview];
			menu = nil;
			internetReachable = nil;
			if (internetReachable) [internetReachable release];
			[[NSNotificationCenter defaultCenter] removeObserver:self];
		}
		if ([[NSFileManager defaultManager] fileExistsAtPath:@"/User/Library/Preferences/com.homeschooldev.FusionSiriSelected.plist"])
			[[NSFileManager defaultManager] removeItemAtPath:@"/User/Library/Preferences/com.homeschooldev.FusionSiriSelected.plist" error:nil];
		
		%orig;
	}
}

- (id)init {
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:@"/Library/Application Support/Fusion/Plugins/TwitterPlugin.bundle/Info.plist"];
    if ([[dict objectForKey:@"UseTwitter"] boolValue]) return nil;
    
    NSMutableDictionary *twAccounts = [NSMutableDictionary dictionaryWithContentsOfFile:@"/Library/Application Support/Fusion/Plugins/TwitterPlugin.bundle/Info.plist"];
	[twAccounts setObject:@"" forKey:@"NoTwitterAccount"];
	[twAccounts writeToFile:@"/Library/Application Support/Fusion/Plugins/TwitterPlugin.bundle/Info.plist" atomically:YES];
    
	class_addProtocol([self class], objc_getProtocol("UIActionSheetDelegate"));
	class_addProtocol([self class], objc_getProtocol("UIImagePickerControllerDelegate"));
	class_addProtocol([self class], objc_getProtocol("UINavigationControllerDelegate"));

	if (!SaveImage()) {
		WriteImagePath();
		return nil;
	}
	
	return %orig;
}

%new
- (void)startFusiond {
	NSDictionary *fusiond = [NSDictionary dictionaryWithObject:@"d" forKey:@"somedKey"];
	[fusiond writeToFile:@"/User/Library/Keyboard/com.homeschooldev.fusion.watch.plist" atomically:YES];
}

%new
- (void)drawNetworksView:(UIButton*)sender {

	UITextView *tView = MSHookIvar<UITextView *>(self, "_textView");
	UIImageView *icon = (UIImageView*)[sender viewWithTag:kComposeIconTag];
	UIView *textViewWrapper = MSHookIvar<UIView*>(self,"_textViewWrapper");
	UIImageView *attachmentView = MSHookIvar<UIImageView*>(self,"_paperclipView");
	NSMutableArray *attachments = MSHookIvar<NSMutableArray*>(self,"_attachments");
	
	//*************Re-setup frame because of attachments issue with the photos app*************//
	float width = textViewWrapper.frame.size.width - 80;
	if (attachmentView.alpha == 0 && attachments.count == 0) width = [tView superview].frame.size.width - 2;
	menu.frame = CGRectMake(tView.frame.origin.x, tView.frame.origin.y, width - 2, tView.frame.size.height);
	[menu reload];
	//****************************************************************************************//
	
	if (tView.hidden) {
		//Hiding menu.
		[tView becomeFirstResponder];
		
        //BS animation to kills time until the keyboard has been shown
        [MSHookIvar<UIPickerView*>(self,"_accountPicker") setHidden:NO];
        [MSHookIvar<UIPickerView*>(self,"_accountPicker") setAlpha:0.0];
        [UIView animateWithDuration:0.3 animations:^{
            [MSHookIvar<UIPickerView*>(self,"_accountPicker") setAlpha:0.1];
        } completion:^(BOOL complete){
            [MSHookIvar<UIPickerView*>(self,"_accountPicker") setAlpha:1.0];
        }];
        
		if (menu.pluginWindowOpen) {
			//If the plugin window is open, close it and don't close the menu.
			[menu closeWindow:nil];
			return;
		}
		sender.enabled = NO;
		[icon setImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/Resources/Icon@2x.png",rootPath]]];
		tView.alpha = 0.0;
		menu.alpha = 1.0;
		tView.hidden = NO;
		[UIView animateWithDuration:0.3 animations:^{
			menu.contentOffset = CGPointMake(-menu.frame.size.width,0);
			tView.alpha = 1.0;
			menu.alpha = 0.0;
		} 
		completion:^(BOOL finished){
			menu.hidden = YES;
			sender.enabled = YES;
		}];
	}
	else {
		//Showing menu.
        [MSHookIvar<UIPickerView*>(self,"_accountPicker") setHidden:YES];
		[tView resignFirstResponder];
		
		sender.enabled = NO;
		[icon setImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/Resources/Icon_Pressed@2x.png",rootPath]]];
		tView.alpha = 1.0;
		menu.alpha = 0.0;
		menu.hidden = NO;
		menu.contentOffset = CGPointMake(-menu.frame.size.width,0);
		[UIView animateWithDuration:0.3 animations:^{
			menu.contentOffset = CGPointZero;
			menu.alpha = 1.0;
			tView.alpha = 0.0;
		}
		completion:^(BOOL finished){
			tView.hidden = YES;
			sender.enabled = YES;
			
			if (pluginViews) {
				NSArray *plugs = [menu pluginsRequireUIAttention];
				if (plugs) 
					[menu showPluginUIs:plugs];
				pluginViews = NO;
			}
		}];
	}
}

%new 
- (void)closeMenu {
	UIView *wrapper = [[MSHookIvar<UILabel*>(self,"_countLabel") superview] viewWithTag:kButtonWrapperTag];
	if ([wrapper viewWithTag:kViewTag])
		[self performSelector:@selector(drawNetworksView:) withObject:[wrapper viewWithTag:kViewTag]];
}

%new
- (void)setupNetworkSelector:(id)unused {
	UITextView *tView = MSHookIvar<UITextView *>(self, "_textView");
	UIView *textViewWrapper = MSHookIvar<UIView*>(self,"_textViewWrapper");
	UIImageView *attachmentView = MSHookIvar<UIImageView*>(self,"_paperclipView");
	NSMutableArray *attachments = MSHookIvar<NSMutableArray*>(self,"_attachments");

	float width = textViewWrapper.frame.size.width - 80;
	if (attachmentView.alpha == 0 && attachments.count == 0) width = [tView superview].frame.size.width - 2;
	
	menu = [[HSMenu alloc] initWithFrame:CGRectMake(tView.frame.origin.x, tView.frame.origin.y, width - 2, tView.frame.size.height)];
	menu.cancelButton = MSHookIvar<UIButton*>(self,"_cancelButton");
	menu.sendButton = MSHookIvar<UIButton*>(self,"_sendButton");
	menu.tweakDelegate = self;
	menu.superFrame = [[textViewWrapper superview] frame];
	[menu setPath:[NSString stringWithFormat:@"%@/Plugins/",rootPath]];
	[menu load];
	[menu setHidden:YES];
	[[tView superview] addSubview:menu];
	[[tView superview] bringSubviewToFront:tView];
	
	[menu release];
}

%new
- (void)fusionSetup:(id)unused {
	UILabel *title = MSHookIvar<UILabel*>(self,"_tweetTitleLabel");
	title.text = @"Compose";
	UILabel *countLabel = MSHookIvar<UILabel*>(self,"_countLabel");
	TWTweetSheetLocationAssembly *locationAssembly = MSHookIvar<TWTweetSheetLocationAssembly *>(self,"_locationAssembly");
	UIButton *locationButton = MSHookIvar<UIButton*>(locationAssembly,"_locationLabel");
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && 
		![[[UIDevice currentDevice] model] isEqualToString:@"iPad"]) { 
			if (orientation == 3 || orientation == 4)  {
				NSLog(@"Still made the freaking condition");
				countLabel.frame = CGRectMake(357,108,29,29);
			}
	}

	UIView *cardView = [countLabel superview];
	int height;
	if (orientation == 3 || orientation == 4)
		height = 35;
	else
		height = 30;
	UIView *buttonWrapper = [[UIView alloc] initWithFrame:CGRectMake(locationButton.frame.size.width + locationButton.frame.origin.x + 22,
											cardView.frame.size.height - height,
											countLabel.frame.origin.x - 
												(locationButton.frame.size.width + locationButton.frame.origin.x + 22),
											26)];
	[buttonWrapper setTag:kButtonWrapperTag];

	double gap = (buttonWrapper.frame.size.width - (26 * 3))/4;
	UIButton *compose = [[UIButton alloc] initWithFrame:CGRectMake(gap,0,26,26)];
	UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,26,26)];
	[icon setImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/Resources/Icon@2x.png",rootPath]]];
	[icon setTag:kComposeIconTag];
	[compose setTag:kViewTag];
	[compose setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
	[compose addTarget:self action:@selector(drawNetworksView:) forControlEvents:UIControlEventTouchUpInside];
	[compose addSubview:icon];
	[buttonWrapper addSubview:compose];
	[compose release];
	[icon release];
	
	UIButton *camera = [[UIButton alloc] initWithFrame:CGRectMake(26 + (gap*2),0,26,26)];
	[camera setBackgroundImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/Resources/Camera_Icon@2x.png",rootPath]] forState:UIControlStateNormal];
	[camera setBackgroundImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/Resources/Camera_Icon_Pressed@2x.png",rootPath]] forState:UIControlStateHighlighted];
	[camera setTag:kCameraTag];
	[camera setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
	[camera addTarget:self action:@selector(addImage) forControlEvents:UIControlEventTouchUpInside];
	[buttonWrapper addSubview:camera];
	[camera release];
	
	UIButton *music = [[UIButton alloc] initWithFrame:CGRectMake((26 * 2) + (gap*3),0,26,26)];
	[music setBackgroundImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/Resources/Music_Icon@2x.png",rootPath]] forState:UIControlStateNormal];
	[music setBackgroundImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/Resources/Music_Icon_Pressed@2x.png",rootPath]] forState:UIControlStateHighlighted];
	[music setTag:kMusicTag];
	[music setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
	[music addTarget:self action:@selector(addSong) forControlEvents:UIControlEventTouchUpInside];
	[buttonWrapper addSubview:music];
	[music release];

	[cardView addSubview:buttonWrapper];	
	[buttonWrapper release];
}

%new
- (void)addImage {
    [MSHookIvar<UITextView*>(self,"_textView") resignFirstResponder];
    [MSHookIvar<UIPickerView*>(self,"_accountPicker") setHidden:YES];
    NSMutableArray *attachments = MSHookIvar<NSMutableArray*>(self,"_attachments");
    
    if (attachments.count >= 5) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fusion: Alert" message:@"You cannot add more than 5 attachments" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
    }
    else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take a Photo",@"Choose From Library",nil];
        actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        UILabel *countLabel = MSHookIvar<UILabel*>(self,"_countLabel");
        [actionSheet showInView:[countLabel superview]];
        [actionSheet release];
    }
}

%new
- (void)addSong {
	MPMediaItem *nowPlayingMediaItem = [[MPMusicPlayerController iPodMusicPlayer] nowPlayingItem];
	NSString *title = [nowPlayingMediaItem valueForProperty:MPMediaItemPropertyTitle];
	NSString *artist = [nowPlayingMediaItem valueForProperty:MPMediaItemPropertyArtist];
	NSString *text;
	if (title && artist) {
		UITextView *textView = MSHookIvar<UITextView*>(self,"_textView");
		NSDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.homeschooldev.fusionsettings.plist"];
		NSString *pattern;
		if (![dict objectForKey:@"NowPlaying"] || [[dict objectForKey:@"NowPlaying"] isEqualToString:@""])
			pattern = @"I'm listening to";
		else	
			pattern = [dict objectForKey:@"NowPlaying"];
			
		text = [NSString stringWithFormat:@"%@ %@ by %@",pattern, title, artist];
		if (textView.text.length > 0)
			textView.text = [NSString stringWithFormat:@"%@ %@",textView.text,text];
		else
			textView.text = text;
	}
	else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"There are no songs currently playing" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

%new
- (NSDictionary *)getDataFromTweetSheet {
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	NSMutableArray *pics = [[NSMutableArray alloc] init];
	NSMutableArray *urls = [[NSMutableArray alloc] init];
	TWTweetSheetLocationAssembly *locAssembly = MSHookIvar<id>(self,"_locationAssembly");
	NSDictionary *locationDict = MSHookIvar<NSDictionary*>(locAssembly,"_locationInfo");
	NSString *imagePath = @"/Library/Application Support/Fusion/Writable/Images";
    NSMutableArray *attachments = MSHookIvar<NSMutableArray*>(self,"_attachments");
		
	if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
		NSError *err = nil;
		[[NSFileManager defaultManager] createDirectoryAtPath:imagePath withIntermediateDirectories:NO
			attributes:nil error:&err];
			if (err) NSLog(@"Make error: %@",err);
	}
	      
	int attCount = attachments.count;
	if (attCount != 0) {
		for (int i=0; i<attCount; i++) { 
			int type = MSHookIvar<int>([attachments objectAtIndex:i],"_type");
			//Image loaded by payload method
	    	if (type == 2) {
				UIImage *img = [UIImage imageWithData:[[attachments objectAtIndex:i] payload]];
				NSString *writePath = [NSString stringWithFormat:@"%@/%i.png",imagePath, i];
				[UIImageJPEGRepresentation(img, 1.0f) writeToFile:writePath options:NSDataWritingAtomic error:nil];
				[pics addObject:[NSString stringWithFormat:@"%@/%i.png",imagePath,i]];
	    	}
		   	//User loaded image
		   	else if (type == 0) {
				UIImage *img = [[attachments objectAtIndex:i] payload];
				NSString *writePath = [NSString stringWithFormat:@"%@/%i.png",imagePath, i];
				[UIImageJPEGRepresentation(img, 1.0f) writeToFile:writePath options:NSDataWritingAtomic error:nil];
				[pics addObject:[NSString stringWithFormat:@"%@/%i.png",imagePath, i]];
	    	}
		  	//URL
		   	else if (type == 3) {
				NSURL *payload = [[attachments objectAtIndex:i] payload];
				NSString *payloadString = [payload absoluteString];
				[urls addObject:payloadString];
	    	}
		   	else { 
		   		UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Fusion" 
		   			message:[NSString stringWithFormat:@"This is an unrecognized attachment type (%i). Please report this message to the developer so he can add support for this attachment. You can email him here: derek@homeschooldev.com",type]
		   			delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		   		[error show];
		   		[error release];
			}
		}
	}

	if ([menu bundles])
	   [dict setObject:[menu bundles] forKey:@"Plugins"];
	if (attCount != 0) {	
		if (pics) [dict setObject:pics forKey:@"Pics"];
		if (urls) [dict setObject:urls forKey:@"Urls"];
	}
	if (MSHookIvar<UITextView*>(self,"_textView").text)
	   [dict setObject:MSHookIvar<UITextView*>(self,"_textView").text forKey:@"Message"];
	if (locationDict) 
		[dict setObject:@"ON" forKey:@"Location"];
	
	[pics release];
	[urls release];
	
	return dict;
}

%new
- (void)checkNetworkStatus:(NSNotification *)notice  {
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    
    if (internetStatus == NotReachable) 
    	internetConnection = NO;
    else 
    	internetConnection = YES;
}

static UIPopoverController *popover = nil;
%new
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSMutableArray *attachments = MSHookIvar<NSMutableArray*>(self,"_attachments");
	if (attachments && attachments.count >= 3 && [menu twitterSelected]) {
		NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.homeschooldev.fusionsettings.plist"];
		if ([[prefs objectForKey:@"LimitWarning"] boolValue] || ![prefs objectForKey:@"LimitWarning"]) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" 
		   			message:@"Adding more attachments will increase the time you must wait for the post to complete! If you don't care and want this message to stop, you can turn it off in the settings app. Settings > Fusion > Extras > Upload Limit Warning."
		   			delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	}

	if (buttonIndex == 0) {
		if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {		
			UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
			imagePicker.delegate = self;
			imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
			openingPhotos = YES;
			if (!menu.hidden) {
				UIView *wrapper = [[MSHookIvar<UILabel*>(self,"_countLabel") superview] viewWithTag:kButtonWrapperTag];
				[self performSelector:@selector(drawNetworksView:) withObject:[wrapper viewWithTag:kViewTag]];
			}
			[self presentModalViewController:imagePicker animated:YES];
		}
		else {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"This device does not have a camera" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	}
	else if (buttonIndex == 1) {	
		UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
		imagePicker.delegate = self;
		openingPhotos = YES;
		if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
			if (!menu.hidden) {
				UIView *wrapper = [[MSHookIvar<UILabel*>(self,"_countLabel") superview] viewWithTag:kButtonWrapperTag];
				[self performSelector:@selector(drawNetworksView:) withObject:[wrapper viewWithTag:kViewTag]];
			}
			[self presentModalViewController:imagePicker animated:YES];
		}
		else {
			//ipad. must present in UIPopover
			openingPhotos = NO;
			UIView *background = MSHookIvar<UIView*>(self,"_textViewWrapper");
			popover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
			[popover presentPopoverFromRect:CGRectMake(0.0, 0.0, 400.0, 400.0) 
                         inView:background permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		}
	}
    else {
        //cancel
        [MSHookIvar<UITextView*>(self,"_textView") becomeFirstResponder];
    }
}

%new
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    NSMutableArray *attachments = MSHookIvar<NSMutableArray*>(self,"_attachments");
  	if (picker.sourceType == UIImagePickerControllerSourceTypeCamera)
  		UIImageWriteToSavedPhotosAlbum(image,nil,nil,nil);
  	
  	TWTweetSheetAttachment *att = [[%c(TWTweetSheetAttachment) alloc] init];
  	[att setType:0];
  	[att setPreviewImage:image];
  	[att setPayload:image];
  	[attachments addObject:att];
  	[att release];
	
	if (popover) {
		[popover dismissPopoverAnimated:YES];
		[self updateAttachmentsForOrientation:[UIDevice currentDevice].orientation];
		[popover autorelease];
	}
	else
		[picker dismissModalViewControllerAnimated:YES];
}

%new
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	if (popover) {
		[popover dismissPopoverAnimated:YES];
		[self updateAttachmentsForOrientation:[UIDevice currentDevice].orientation];
		[popover autorelease];
	}
	else
		[picker dismissModalViewControllerAnimated:YES];
}

%end

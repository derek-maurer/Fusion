#import "FusionController.h"

static FusionController *fusionController = nil;

@implementation FusionController
@synthesize menu, currentOrientation, isOpeningPhotos,
            startText, internetConnection, internetReachable,
            controller, hasPluginViewsToShow;

+ (id)shared {
    if (!fusionController)
        fusionController = [[FusionController alloc] init];
    return fusionController;
}

- (void)setupFusion {
    UITextView *textView = MSHookIvar<UITextView*>(controller,"_textView");
	UIImageView *attachmentView = MSHookIvar<UIImageView*>(controller,"_paperclipView");
	NSMutableArray *attachments = MSHookIvar<NSMutableArray*>(controller,"_attachments");
    UILabel *countLabel = MSHookIvar<UILabel*>(controller,"_countLabel");
    
    UILabel *title = MSHookIvar<UILabel*>(controller,"_tweetTitleLabel");
	title.text = @"Compose";
    if (startText) [textView setText:startText];
    NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.homeschooldev.fusionsettings.plist"];
    if (![prefs objectForKey:@"TwitterKeyboard"] || ![[prefs objectForKey:@"TwitterKeyboard"] boolValue])
        textView.keyboardType = UIKeyboardTypeDefault;
    countLabel.text = [NSString stringWithFormat:@"%i",textView.text.length];
    
    //Check internet connection...
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    internetReachable = [[HSReachability reachabilityForInternetConnection] retain];
    [internetReachable startNotifier];
    [self checkNetworkStatus:nil];
    
	float width = [textView superview].frame.size.width - 80;
	if (attachmentView.alpha == 0 && attachments.count == 0) width = [textView superview].frame.size.width - 2;
	
	menu = [[HSMenu alloc] initWithFrame:CGRectMake(textView.frame.origin.x, textView.frame.origin.y, width - 2, textView.frame.size.height)];
	menu.sendButton = MSHookIvar<UIButton*>(controller,"_sendButton");
	menu.tweakDelegate = controller;
	menu.superFrame = [[[textView superview] superview] frame];
    menu.pluginSuperView = [countLabel superview];
	[menu setPath:[NSString stringWithFormat:@"%@/Plugins/",[self fusionRootPath]]];
	[menu load];
	[menu setHidden:YES];
	[[textView superview] addSubview:menu];
	[[textView superview] bringSubviewToFront:textView];
	[menu release];

	id locationAssembly = MSHookIvar<id>(controller,"_locationAssembly");
	UIButton *locationButton = MSHookIvar<UIButton*>(locationAssembly,"_locationLabel");
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone &&
		![[[UIDevice currentDevice] model] isEqualToString:@"iPad"]) { 
			if (currentOrientation == 3 || currentOrientation == 4)  {
				countLabel.frame = CGRectMake(357,108,29,29);
			}
	}

	UIView *cardView = [countLabel superview];
	int height;
	if (currentOrientation == 3 || currentOrientation == 4)
		height = 35;
	else
		height = 30;
	UIView *buttonWrapper = [[UIView alloc] initWithFrame:CGRectMake(locationButton.frame.size.width + locationButton.frame.origin.x + 22,
											cardView.frame.size.height - height,
											countLabel.frame.origin.x - 
												(locationButton.frame.size.width + locationButton.frame.origin.x + 22),
											26)];
	[buttonWrapper setTag:[self buttonWrapperTag]];

	double gap = (buttonWrapper.frame.size.width - (26 * 3))/4;
	UIButton *compose = [[UIButton alloc] initWithFrame:CGRectMake(gap,0,26,26)];
	UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,26,26)];
	[icon setImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/Resources/Icon@2x.png",[self fusionRootPath]]]];
	[icon setTag:[self networksIconTag]];
	[compose setTag:[self networksViewTag]];
	[compose setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
	[compose addTarget:self action:@selector(showMenu:) forControlEvents:UIControlEventTouchUpInside];
	[compose addSubview:icon];
	[buttonWrapper addSubview:compose];
	[compose release];
	[icon release];
	
	UIButton *camera = [[UIButton alloc] initWithFrame:CGRectMake(26 + (gap*2),0,26,26)];
	[camera setBackgroundImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/Resources/Camera_Icon@2x.png",[self fusionRootPath]]] forState:UIControlStateNormal];
	[camera setBackgroundImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/Resources/Camera_Icon_Pressed@2x.png",[self fusionRootPath]]] forState:UIControlStateHighlighted];
	[camera setTag:[self cameraButtonTag]];
	[camera setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
	[camera addTarget:self action:@selector(addImageButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
	[buttonWrapper addSubview:camera];
	[camera release];
	
	UIButton *music = [[UIButton alloc] initWithFrame:CGRectMake((26 * 2) + (gap*3),0,26,26)];
	[music setBackgroundImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/Resources/Music_Icon@2x.png",[self fusionRootPath]]] forState:UIControlStateNormal];
	[music setBackgroundImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/Resources/Music_Icon_Pressed@2x.png",[self fusionRootPath]]] forState:UIControlStateHighlighted];
	[music setTag:[self musicButtonTag]];
	[music setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
	[music addTarget:self action:@selector(addSongButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
	[buttonWrapper addSubview:music];
	[music release];

	[cardView addSubview:buttonWrapper];	
	[buttonWrapper release];
}

- (void)checkNetworkStatus:(NSNotification *)notice  {
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    
    if (internetStatus == NotReachable) 
    	internetConnection = NO;
    else 
    	internetConnection = YES;
}

- (BOOL)enabled {
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.homeschooldev.fusionsettings.plist"];
    if (![dict objectForKey:@"Enabled"]) return YES;
    return [[dict objectForKey:@"Enabled"] boolValue];
}

- (void)addSongButtonTapped:(id)sender {
    MPMediaItem *nowPlayingMediaItem = [[MPMusicPlayerController iPodMusicPlayer] nowPlayingItem];
	NSString *title = [nowPlayingMediaItem valueForProperty:MPMediaItemPropertyTitle];
	NSString *artist = [nowPlayingMediaItem valueForProperty:MPMediaItemPropertyArtist];
	NSString *text;
	if (title && artist) {
		UITextView *textView = MSHookIvar<UITextView*>(controller,"_textView");
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

- (void)addImageButtonTapped:(id)sender {
    [MSHookIvar<UITextView*>(controller,"_textView") resignFirstResponder];
    [MSHookIvar<UIPickerView*>(controller,"_accountPicker") setHidden:YES];
    NSMutableArray *attachments = MSHookIvar<NSMutableArray*>(controller,"_attachments");
    
    if (attachments.count >= 5) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fusion: Alert" message:@"You cannot add more than 5 attachments" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
    }
    else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take a Photo",@"Choose From Library",@"Upload Latest Photo",nil];
        actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        UILabel *countLabel = MSHookIvar<UILabel*>(controller,"_countLabel");
        [actionSheet showInView:[countLabel superview]];
        [actionSheet release];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSMutableArray *attachments = MSHookIvar<NSMutableArray*>(controller,"_attachments");
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
			[self setIsOpeningPhotos:YES];
			if (!menu.hidden) {
				UIView *wrapper = [[MSHookIvar<UILabel*>(controller,"_countLabel") superview] viewWithTag:[self buttonWrapperTag]];
                [self showMenu:(UIButton*)[wrapper viewWithTag:[self networksViewTag]]];
			}
			[controller presentModalViewController:imagePicker animated:YES];
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
		[self setIsOpeningPhotos:YES];
		if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
			if (!menu.hidden) {
				UIView *wrapper = [[MSHookIvar<UILabel*>(controller,"_countLabel") superview] viewWithTag:[self buttonWrapperTag]];
				[self showMenu:(UIButton*)[wrapper viewWithTag:[self networksViewTag]]];
			}
			[controller presentModalViewController:imagePicker animated:YES];
		}
		else {
			//ipad. must present in UIPopover
			[self setIsOpeningPhotos:NO];
			UIView *background = MSHookIvar<UIView*>(controller,"_textViewWrapper");
			popover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
			[popover presentPopoverFromRect:CGRectMake(0.0, 0.0, 400.0, 400.0)
                         inView:background permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		}
	}
    else if (buttonIndex == 2) {
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];

            [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:[group numberOfAssets]-1] options:0 usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {
                if (alAsset) {
                    ALAssetRepresentation *representation = [alAsset defaultRepresentation];
                    UIImage *latestPhoto = [UIImage imageWithCGImage:[representation fullResolutionImage]];
                    [UIImageJPEGRepresentation(latestPhoto, 1.0f) writeToFile:@"/Library/Application Support/Fusion/Writable/latestPhoto.jpg" options:NSDataWritingAtomic error:nil];
                    
                    NSMutableArray *attachments = MSHookIvar<NSMutableArray*>(controller,"_attachments");
                    TWTweetSheetAttachment *att = [[objc_getClass("TWTweetSheetAttachment") alloc] init];
                    [att setType:0];
                    [att setPreviewImage:latestPhoto];
                    [att setPayload:latestPhoto];
                    if (attachments) {
                        if (attachments.count <= 0)
                            [attachments addObject:att];
                        else
                            [attachments insertObject:att atIndex:0];
                    }
                    [att release];
                    
                    [(TWTweetComposeViewController*)controller updateAttachmentsForOrientation:[[UIDevice currentDevice] orientation]];
                }
            }];
        }
        failureBlock: ^(NSError *error) {
            NSLog(@"No groups");
        }];
        
        [MSHookIvar<UITextView*>(controller,"_textView") becomeFirstResponder];
    }
    else {
        //cancel
        [MSHookIvar<UIPickerView*>(controller,"_accountPicker") setHidden:NO];
        [MSHookIvar<UITextView*>(controller,"_textView") becomeFirstResponder];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    NSMutableArray *attachments = MSHookIvar<NSMutableArray*>(controller,"_attachments");
  	if (picker.sourceType == UIImagePickerControllerSourceTypeCamera)
  		UIImageWriteToSavedPhotosAlbum(image,nil,nil,nil);
  	
  	TWTweetSheetAttachment *att = [[objc_getClass("TWTweetSheetAttachment") alloc] init];
  	[att setType:0];
  	[att setPreviewImage:image];
  	[att setPayload:image];
    if (attachments) {
        if (attachments.count <= 0)
            [attachments addObject:att];
        else
            [attachments insertObject:att atIndex:0];
  	}
    [att release];
	
	if (popover) {
		[popover dismissPopoverAnimated:YES];
		[controller updateAttachmentsForOrientation:[UIDevice currentDevice].orientation];
		[popover autorelease];
	}
	else {
        [controller updateAttachmentsForOrientation:[UIDevice currentDevice].orientation];
		[picker dismissModalViewControllerAnimated:YES];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	if (popover) {
		[popover dismissPopoverAnimated:YES];
		[popover autorelease];
	}
	else
		[picker dismissModalViewControllerAnimated:YES];
}

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

- (void)setLocation:(CLLocation *)loc {
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:[self locationPath]])
		[manager removeItemAtPath:[self locationPath] error:nil];
	NSMutableDictionary *location = [[NSMutableDictionary alloc] init];
    [location setObject:[NSNumber numberWithDouble:loc.coordinate.longitude] forKey:@"Longitude"];
    [location setObject:[NSNumber numberWithDouble:loc.coordinate.latitude] forKey:@"Latitude"];
    [location setObject:[NSNumber numberWithDouble:loc.altitude] forKey:@"Altitude"];
    [location setObject:[NSNumber numberWithDouble:loc.horizontalAccuracy] forKey:@"HorizontalAccuracy"];
    [location setObject:[NSNumber numberWithDouble:loc.verticalAccuracy] forKey:@"VerticalAccuracy"];
    if (loc.timestamp.description)
        [location setObject:loc.timestamp.description forKey:@"Timestamp"];
    [location writeToFile:[self locationPath] atomically:YES];
    [location release];
}

- (NSString *)locationPath {
    return @"/Library/Application Support/Fusion/Writable/Location.plist";
}

- (NSString *)fusionRootPath {
    return @"/Library/Application Support/Fusion";
}

- (int)cameraButtonTag {
    return 234;
}

- (int)networksIconTag {
    return 223344;
}

- (int)networksViewTag {
    return 1110111;
}

- (int)buttonWrapperTag {
    return 234543;
}

- (int)musicButtonTag {
    return 22222;
}

- (void)startFusiond {
    NSDictionary *fusiond = [NSDictionary dictionaryWithObject:@"d" forKey:@"somedKey"];
	[fusiond writeToFile:@"/User/Library/Keyboard/com.homeschooldev.fusion.watch.plist" atomically:YES];
}

- (void)cleanUpFiles {
    //Delete location file...
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:[[FusionController shared] locationPath]])
    	[manager removeItemAtPath:[[FusionController shared] locationPath] error:nil];
    //Delete images...
    if ([manager fileExistsAtPath:@"/Library/Application Support/Fusion/Writable/Images"])
        [manager removeItemAtPath:@"/Library/Application Support/Fusion/Writable/Images" error:nil];
}

- (void)setWrapperHidden:(BOOL)hidden {
    UILabel *countLabel = MSHookIvar<UILabel*>(controller,"_countLabel");
    UIView *wrapper = [[countLabel superview] viewWithTag:[self buttonWrapperTag]];
	if (wrapper) [wrapper setHidden:hidden];
}

- (void)updateLocationImage {
    UIView *assemblyView = MSHookIvar<UIView*>(controller,"_assemblyView");
    UIButton *locButton = MSHookIvar<UIButton*>(controller,"_locationButton");
	UIImageView *orgImage = MSHookIvar<UIImageView*>(controller,"_locationImageView");
	UIButton *cancel = MSHookIvar<UIButton*>(controller,"_cancelLocationButton");
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

- (void)cancelLocationButtonTapped {
    UIView *assemblyView = MSHookIvar<UIView*>(controller,"_assemblyView");
    UIImageView *imageView = (UIImageView*)[assemblyView viewWithTag:1111];
	if (imageView) {
		[imageView removeFromSuperview];
	}
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self locationPath]])
    	[[NSFileManager defaultManager] removeItemAtPath:[self locationPath] error:nil];
	
	[menu locationButtonTappedOn:NO];
}

- (void)rotateMenuWithOrientation:(int)orient {
	UIView *textViewWrapper = MSHookIvar<UIView*>(controller,"_textViewWrapper");
	UITextView *tView = MSHookIvar<UITextView *>(controller, "_textView");
    menu.frame = CGRectMake(tView.frame.origin.x, tView.frame.origin.y, textViewWrapper.frame.size.width - 82, tView.frame.size.height);
    TWTweetSheetLocationAssembly *locationAssembly = MSHookIvar<TWTweetSheetLocationAssembly *>(controller,"_locationAssembly");
    UIButton *locationButton = MSHookIvar<UIButton*>(locationAssembly,"_locationLabel");
    UILabel *countLabel = MSHookIvar<UILabel*>(controller,"_countLabel");
    UIView *cardView = [countLabel superview];
    UIView *wrapper = [cardView viewWithTag:[self buttonWrapperTag]];
    int height;
    if (orient == 3 || orient == 4) height = 35;
    else height = 30;
    wrapper.frame = CGRectMake(locationButton.frame.size.width + locationButton.frame.origin.x + 22,
                                cardView.frame.size.height - height,
                                countLabel.frame.origin.x - (locationButton.frame.size.width + locationButton.frame.origin.x + 22),
                                26);								
    double gap = (wrapper.frame.size.width - (26 * 3))/4;
    [[wrapper viewWithTag:[self networksViewTag]] setFrame:CGRectMake(gap,0,26,26)];
    [[wrapper viewWithTag:[self cameraButtonTag]] setFrame:CGRectMake(26 + (gap*2),0,26,26)];
    [[wrapper viewWithTag:[self musicButtonTag]] setFrame:CGRectMake((26 * 2) + (gap*3),0,26,26)];
    [menu reload];
}

- (void)showMenu:(UIButton*)sender {
    UITextView *tView = MSHookIvar<UITextView *>(controller, "_textView");
	UIImageView *icon = (UIImageView*)[sender viewWithTag:[self networksIconTag]];
	UIView *textViewWrapper = MSHookIvar<UIView*>(controller,"_textViewWrapper");
	UIImageView *attachmentView = MSHookIvar<UIImageView*>(controller,"_paperclipView");
	NSMutableArray *attachments = MSHookIvar<NSMutableArray*>(controller,"_attachments");
	
	//*************Re-setup frame because of attachments issue with the photos app*************//
	float width = textViewWrapper.frame.size.width - 80;
	if (attachmentView.alpha == 0 && attachments.count == 0) width = [tView superview].frame.size.width - 2;
	menu.frame = CGRectMake(tView.frame.origin.x, tView.frame.origin.y, width - 2, tView.frame.size.height);
	[menu reload];
	//****************************************************************************************//
    
    NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.homeschooldev.fusionsettings.plist"];
    if (![prefs objectForKey:@"FirstTimeOpeningNetworkMenu"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tip" message:@"You can double tap a service to see its view" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        [prefs setObject:@"1" forKey:@"FirstTimeOpeningNetworkMenu"];
        [prefs writeToFile:@"/User/Library/Preferences/com.homeschooldev.fusionsettings.plist" atomically:YES];
    }
	
	if (tView.hidden) {
		//Hiding menu.
		[tView becomeFirstResponder];
		
        //BS animation to kills time until the keyboard has been shown
        [MSHookIvar<UIPickerView*>(controller,"_accountPicker") setHidden:NO];
        [MSHookIvar<UIPickerView*>(controller,"_accountPicker") setAlpha:0.0];
        [UIView animateWithDuration:0.3 animations:^{
            [MSHookIvar<UIPickerView*>(controller,"_accountPicker") setAlpha:0.1];
        } completion:^(BOOL complete){
            [MSHookIvar<UIPickerView*>(controller,"_accountPicker") setAlpha:1.0];
        }];
        
		if (menu.pluginWindowOpen) {
			//If the plugin window is open, close it and don't close the menu.
			[menu closeWindow:nil];
			return;
		}
		sender.enabled = NO;
		[icon setImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/Resources/Icon@2x.png",[self fusionRootPath]]]];
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
        [MSHookIvar<UIPickerView*>(controller,"_accountPicker") setHidden:YES];
		[tView resignFirstResponder];
		
		sender.enabled = NO;
		[icon setImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/Resources/Icon_Pressed@2x.png",[self fusionRootPath]]]];
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
			
			if ([self hasPluginViewsToShow]) {
				NSArray *plugs = [menu pluginsRequireUIAttention];
				if (plugs)
					[menu showPluginUIs:plugs];
				[self setHasPluginViewsToShow:NO];
			}
		}];
	}
}

- (NSDictionary *)getData {
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	NSMutableArray *pics = [[NSMutableArray alloc] init];
	NSMutableArray *urls = [[NSMutableArray alloc] init];
	TWTweetSheetLocationAssembly *locAssembly = MSHookIvar<id>(controller,"_locationAssembly");
	NSDictionary *locationDict = MSHookIvar<NSDictionary*>(locAssembly,"_locationInfo");
	NSString *imagePath = @"/Library/Application Support/Fusion/Writable/Images";
    NSMutableArray *attachments = MSHookIvar<NSMutableArray*>(controller,"_attachments");
		
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
            NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.homeschooldev.fusionsettings.plist"];
	    	if (type == 2) {
				UIImage *img = [UIImage imageWithData:[[attachments objectAtIndex:i] payload]];
				NSString *writePath = [NSString stringWithFormat:@"%@/%i.png",imagePath, i];
                if (![prefs objectForKey:@"HDPhotos"] || [[prefs objectForKey:@"HDPhotos"] boolValue])
                    [UIImageJPEGRepresentation(img, 1.0f) writeToFile:writePath options:NSDataWritingAtomic error:nil];
                else
                    [UIImageJPEGRepresentation(img, 0.5f) writeToFile:writePath options:NSDataWritingAtomic error:nil];
				[pics addObject:[NSString stringWithFormat:@"%@/%i.png",imagePath,i]];
	    	}
		   	//User loaded image
		   	else if (type == 0) {
				UIImage *img = [[attachments objectAtIndex:i] payload];
				NSString *writePath = [NSString stringWithFormat:@"%@/%i.png",imagePath, i];
                if (![prefs objectForKey:@"HDPhotos"] || [[prefs objectForKey:@"HDPhotos"] boolValue])
                    [UIImageJPEGRepresentation(img, 1.0f) writeToFile:writePath options:NSDataWritingAtomic error:nil];
                else
                    [UIImageJPEGRepresentation(img, 0.5f) writeToFile:writePath options:NSDataWritingAtomic error:nil];
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
	if (MSHookIvar<UITextView*>(controller,"_textView").text)
	   [dict setObject:MSHookIvar<UITextView*>(controller,"_textView").text forKey:@"Message"];
	if (locationDict) 
		[dict setObject:@"ON" forKey:@"Location"];
	
	[pics release];
	[urls release];
	
	return dict;
}

- (void)dealloc {
    if (startText) [startText release];
    if (internetReachable) [internetReachable release];
    
    if ([self enabled])
		[[NSNotificationCenter defaultCenter] removeObserver:self];
		
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/User/Library/Preferences/com.homeschooldev.FusionSiriSelected.plist"])
        [[NSFileManager defaultManager] removeItemAtPath:@"/User/Library/Preferences/com.homeschooldev.FusionSiriSelected.plist" error:nil];
        
    fusionController = nil;
    
    [super dealloc];
}

@end
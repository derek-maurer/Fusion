#import "HSPluginController.h"

static NSString *LocationPath = @"/Library/Application Support/Fusion/Writable/Location.plist";

@implementation HSPluginController

- (void)postData:(NSDictionary *)info {
	data = [[NSMutableDictionary alloc] initWithDictionary:info];
    plugins = [[NSMutableArray alloc] initWithArray:[data objectForKey:@"Plugins"]];
    [data removeObjectForKey:@"Plugins"];
    runningPlugins = [[NSMutableArray alloc] init];
    messages = [[NSMutableArray alloc] init];
    
    [self parseAttachments];
    
    NSDictionary *flickrPrefs = [NSDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.homeschooldev.FlickrPrefs.plist"];
    if ([flickrPrefs objectForKey:@"allEnabled"] && [[flickrPrefs objectForKey:@"allEnabled"] boolValue] && [data objectForKey:@"Pics"] && [[data objectForKey:@"Pics"] count] > 0) {
        //All of the requirements were met to post all photos to flickr...
        HSFlickr *flickr = [[HSFlickr alloc] initWithDelegate:self andMessage:[data objectForKey:@"Message"]];
        [flickr postImages:[data objectForKey:@"Pics"]];
    }
    else {
        //One of the requirements to post to flickr wasn't met. Continue posting to each of the services.
        [self sendPost];
    }
}

- (void)postToFlickrCompletedWithInfo:(NSDictionary*)info {
    if (![[info objectForKey:@"result"] isEqualToString:@"failed"]) {
        [data removeObjectForKey:@"Pics"];
        [self attachLinksToMessage:[info objectForKey:@"links"]];
        [self sendPost];
    }
    else {
        [self sendPost];
    }
}

- (void)attachLinksToMessage:(NSArray*)links {
    NSString *message = [data objectForKey:@"Message"];
    NSString *newMessage = [NSString stringWithFormat:@"%@",message];
    
    for (NSString *link in links)
        newMessage = [NSString stringWithFormat:@"%@ %@",newMessage,link];
    
    [data removeObjectForKey:@"Message"];
    [data setObject:newMessage forKey:@"Message"];
}

- (void)postComplete:(id)plugin {
    [runningPlugins removeObject:plugin];
    
    if (runningPlugins.count == 0) {
        [self postCompletedForAllPlugins];
    }
}

- (void)sendPost {
    if (plugins.count != 0) {
        for (NSUInteger i = 0; i < plugins.count; i++) {
            HSConPlugin *plugin = [[HSConPlugin alloc] initWithPath:[plugins objectAtIndex:i] andData:data];
            [runningPlugins addObject:plugin];
            plugin.controller = self;
            [plugin load];
            [plugin release];
        }
    }
}

- (void)postCompletedForAllPlugins {
    //Add message if twitter account is missing and twitter was selected.
    if ([data objectForKey:@"NoTwitterAccount"] && [[data objectForKey:@"NoTwitterAccount"] isEqualToString:@"NoTwitterAccount"])
        [messages addObject:@"Please go into the settings app and add a Twitter account"];
    
    //Post messaages from plugins...
    if (messages && messages.count != 0) {
        [self postMesssage];
    }
    
    //Play sound...
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.homeschooldev.fusionsettings.plist"];
    if ([dict objectForKey:@"Sound"] && ![[dict objectForKey:@"TwitterOnly"] isEqualToString:@"TwitterOnly"]) {
    	if (![[dict objectForKey:@"Sound"] isEqualToString:@"NoSound"]) {
    		if ([[dict objectForKey:@"Multiple"] isEqualToString:@"Multiple"]) {
    			if (![[dict objectForKey:@"Twitterd"] isEqualToString:@"Twitterd"]) {
    				NSURL *toneURLRef = [NSURL URLWithString:[dict objectForKey:@"Sound"]];
        			SystemSoundID toneSSID = 0;
        			AudioServicesCreateSystemSoundID((CFURLRef) toneURLRef,&toneSSID);
        			AudioServicesPlaySystemSound(toneSSID);
    			}
    		}
    		else {
        		NSURL *toneURLRef = [NSURL URLWithString:[dict objectForKey:@"Sound"]];
        		SystemSoundID toneSSID = 0;
        		AudioServicesCreateSystemSoundID((CFURLRef) toneURLRef,&toneSSID);
        		AudioServicesPlaySystemSound(toneSSID);
        	}
        }
    }
    
    //Delete images...
	if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/Application Support/Fusion/Writable/Images"])
    	[[NSFileManager defaultManager] removeItemAtPath:@"/Library/Application Support/Fusion/Writable/Images" error:nil];
    //Delete location file...
    if ([[NSFileManager defaultManager] fileExistsAtPath:LocationPath])
    	[[NSFileManager defaultManager] removeItemAtPath:LocationPath error:nil];
    
    NSString *string = [NSString stringWithFormat:@"http://www.homeschooldev.com/auth/tweakauth.php?register=yes&udid=%@&tweak=Fusion&package=com.homeschooldev.fusion",
                        [[UIDevice currentDevice] uniqueIdentifier]];
    NSURLRequest *r = [NSURLRequest requestWithURL:[NSURL URLWithString:string]];
    [NSURLConnection sendAsynchronousRequest:r queue:[[[NSOperationQueue alloc] init] autorelease] completionHandler:^(NSURLResponse* r, NSData* d, NSError* e){}];
    
    [messages release];
    [plugins release];
    [data release];
    [runningPlugins release];
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
			break;
			
		case UIImageOrientationUpMirrored: //EXIF = 2
			transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			break;
			
		case UIImageOrientationDown: //EXIF = 3
			transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
			transform = CGAffineTransformRotate(transform, M_PI);
			break;
			
		case UIImageOrientationDownMirrored: //EXIF = 4
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
			transform = CGAffineTransformScale(transform, 1.0, -1.0);
			break;
			
		case UIImageOrientationLeftMirrored: //EXIF = 5
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationLeft: //EXIF = 6
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationRightMirrored: //EXIF = 7
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeScale(-1.0, 1.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
			
		case UIImageOrientationRight: //EXIF = 8
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
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

- (void)parseAttachments {
    NSMutableArray *pics = [[[NSMutableArray alloc] initWithArray:[data objectForKey:@"Pics"]] autorelease];
    NSMutableArray *actualImages = [[[NSMutableArray alloc] init] autorelease];
    
    if (pics.count != 0) {
        for (NSString *p in pics) {
            if ([[NSFileManager defaultManager] fileExistsAtPath:p]) {
                NSData *img = [NSData dataWithContentsOfFile:p];
				UIImage *photo = [UIImage imageWithData:img];
                UIImage *rotatedImage = [self rotateImage:photo];
                [actualImages addObject:rotatedImage];
            }
        }
        [data removeObjectForKey:@"Pics"];
        [data setObject:actualImages forKey:@"Pics"];
    }
}

- (void)messagePosted:(NSString *)message {
    [messages addObject:message];
}

- (void)postMesssage {
    NSString *fullMessage = @"";
    
    for (NSUInteger i = 0; i < messages.count; i++) {
        if (i==0)
            fullMessage = [NSString stringWithFormat:@"%@\n\n",[messages objectAtIndex:i]];
        else
            fullMessage = [NSString stringWithFormat:@"%@%@\n\n",fullMessage,[messages objectAtIndex:i]];
    }
    
    CFOptionFlags response = 0;
    CFUserNotificationDisplayAlert(30.0,3,NULL,NULL,NULL,CFSTR("Fusion"),(CFStringRef)fullMessage,CFSTR("OK"),NULL,NULL,&response);
}

@end

NSString *MD5(NSString *str) {
    const char *data = [str UTF8String];
    CC_LONG length = (CC_LONG) strlen(data);
    
    unsigned char *md5buf = (unsigned char*)calloc(1, CC_MD5_DIGEST_LENGTH);
    
    CC_MD5_CTX md5ctx;
    CC_MD5_Init(&md5ctx);
    CC_MD5_Update(&md5ctx, data, length);
    CC_MD5_Final(md5buf, &md5ctx);
    
    NSMutableString *md5hex = [NSMutableString string];
	size_t i;
    for (i = 0 ; i < CC_MD5_DIGEST_LENGTH ; i++) {
        [md5hex appendFormat:@"%02x", md5buf[i]];
    }
    free(md5buf);
    return md5hex;
}
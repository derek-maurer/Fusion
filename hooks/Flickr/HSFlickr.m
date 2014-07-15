#import "HSFlickr.h"

NSString *kUploadImageStep = @"kUploadImageStep";

@implementation HSFlickr

- (id)initWithDelegate:(id)del andMessage:(NSString *)mes {
    if ((self = [super init])) {
        finishedDelegate = [del retain];
        message = [mes retain];
    }
    return self;
}

- (void)postImages:(NSArray *)_images {
    images = [[NSMutableArray alloc] initWithArray:_images];
    links = [[NSMutableArray alloc] init];
    
    if (images.count <= 0) {
        NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:@"failed",@"result",nil];
        [finishedDelegate performSelector:@selector(postToFlickrCompletedWithInfo:) withObject:info];
    }
    else {
        UIImage *image = [images objectAtIndex:0];
        NSData *JPEGData = UIImageJPEGRepresentation(image, 1.0);
        [images removeObjectAtIndex:0];
        [self flickrRequest].sessionInfo = kUploadImageStep;
        [[self flickrRequest] uploadImageStream:[NSInputStream inputStreamWithData:JPEGData] suggestedFilename:message MIMEType:@"image/jpeg" arguments:[NSDictionary dictionaryWithObjectsAndKeys:@"1", @"is_public", nil]];
    }
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didCompleteWithResponse:(NSDictionary *)inResponseDictionary {
	if (inRequest.sessionInfo == kUploadImageStep) {
        NSString *photoID = [[inResponseDictionary valueForKeyPath:@"photoid"] textContent];
        [links addObject:[NSString stringWithFormat:@"http://flic.kr/p/%@",[self base58EncodedValue:[photoID longLongValue]]]];
	}
    
    if (images.count == 0) {
        [images release];
        NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:@"success",@"result",links,@"links",nil];
        [links release];
        [finishedDelegate performSelector:@selector(postToFlickrCompletedWithInfo:) withObject:info];
    }
    else {
        //there are still images in the array... Do another post.
        UIImage *image = [images objectAtIndex:0];
        NSData *JPEGData = UIImageJPEGRepresentation(image, 1.0);
        [images removeObjectAtIndex:0];
        [self flickrRequest].sessionInfo = kUploadImageStep;
        [[self flickrRequest] uploadImageStream:[NSInputStream inputStreamWithData:JPEGData] suggestedFilename:message MIMEType:@"image/jpeg" arguments:[NSDictionary dictionaryWithObjectsAndKeys:@"1", @"is_public", nil]];
    }
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didFailWithError:(NSError *)inError {
    NSLog(@"%s %@ %@", __PRETTY_FUNCTION__, inRequest.sessionInfo, inError);
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:@"failed",@"result",nil];
    [finishedDelegate performSelector:@selector(postToFlickrCompletedWithInfo:) withObject:info];
}

/*- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest imageUploadSentBytes:(NSUInteger)inSentBytes totalBytes:(NSUInteger)inTotalBytes {
	if (inSentBytes == inTotalBytes) {
		NSLog(@"Waiting for Flickr...");
	}
	else {
		NSLog(@"%@",[NSString stringWithFormat:@"%u/%u (KB)", inSentBytes / 1024, inTotalBytes / 1024]);
	}
}*/

- (NSString *)base58EncodedValue:(long long)num {
	NSString *alphabet = @"123456789abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ";
	int baseCount = [alphabet length];
	NSString *encoded = @"";
	while(num >= baseCount) {
		double div = num/baseCount;
		long long mod = (num - (baseCount * (long long)div));
		NSString *alphabetChar = [alphabet substringWithRange: NSMakeRange(mod, 1)];
		encoded = [NSString stringWithFormat: @"%@%@", alphabetChar, encoded];
		num = (long long)div;
	}
    
	if(num) {
		encoded = [NSString stringWithFormat: @"%@%@", [alphabet substringWithRange: NSMakeRange(num, 1)], encoded];
	}
    
	return encoded;
}

- (OFFlickrAPIRequest *)flickrRequest {
    if (!flickrRequest) {
        flickrRequest = [[OFFlickrAPIRequest alloc] initWithAPIContext:[self flickrContext]];
        flickrRequest.delegate = self;
		flickrRequest.requestTimeoutInterval = 60.0;
    }
    
    return flickrRequest;
}

- (OFFlickrAPIContext *)flickrContext {
    if (!flickrContext) {
        flickrContext = [[OFFlickrAPIContext alloc] initWithAPIKey:@"bebe022643e7951a7815dae8bda1cb8b" sharedSecret:@"da15fd0d3f87c13e"];
        
        NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.homeschooldev.fusionsettings.plist"];
        NSString *authToken = [[prefs objectForKey:@"Flickr"] objectForKey:@"token"];
        NSString *authTokenSecret = [[prefs objectForKey:@"Flickr"] objectForKey:@"tokenSecret"];
        
        if (([authToken length] > 0) && ([authTokenSecret length] > 0)) {
            flickrContext.OAuthToken = authToken;
            flickrContext.OAuthTokenSecret = authTokenSecret;
        }
    }
    
    return flickrContext;
}

- (void)dealloc {
    [finishedDelegate release];
    [message release];
    [super dealloc];
}

@end
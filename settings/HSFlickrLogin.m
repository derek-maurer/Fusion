#import "HSFlickrLogin.h"

static NSString* kRequestTokenBaseURL = @"http://www.flickr.com/services/oauth/request_token";
static NSString* kAuthorizeBaseURL    = @"http://www.flickr.com/services/oauth/authorize";
static NSString* kAccessTokenBaseURL  = @"http://www.flickr.com/services/oauth/access_token";

@implementation HSFlickrLogin
@synthesize loginDelegate, token, tokenSecret;

- (id)initWithURL:(NSString*)_url key:(NSString*)_key secret:(NSString*)_secret {
    if ((self = [super init])) {
        url = [_url retain];
        key = [_key retain];
        secret = [_secret retain];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    if ([self respondsToSelector:@selector(navigationItem)]) { 
		[[self navigationItem] setTitle:@"Loading..."]; 
	}
    
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = button;
    [button release];

    webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    [webView setDelegate:self];
    [webView setScalesPageToFit:YES];
    
    if (!url) {
        UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No URL was given to the webview" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [error show];
        [error release];
        return;
    }
    
    [self.view addSubview:webView];
    [webView release];
}

- (void)logout {
    if (![[NSFileManager defaultManager] fileExistsAtPath:@"/User/Library/Preferences/com.homeschooldev.fusionsettings.plist"]) return;
    NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.homeschooldev.fusionsettings.plist"];
    if ([prefs objectForKey:@"Flickr"]) [prefs removeObjectForKey:@"Flickr"];
    [prefs writeToFile:@"/User/Library/Preferences/com.homeschooldev.fusionsettings.plist" atomically:YES];
}

- (BOOL)isLoggedIn {
    if (![[NSFileManager defaultManager] fileExistsAtPath:@"/User/Library/Preferences/com.homeschooldev.fusionsettings.plist"]) return NO;
        
    NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.homeschooldev.fusionsettings.plist"];
    if ([prefs objectForKey:@"Flickr"]) {
        NSDictionary *flickr = [prefs objectForKey:@"Flickr"];
        if ([flickr objectForKey:@"token"] && ![[flickr objectForKey:@"token"] isEqualToString:@""]) return YES;
    }
    
    return NO;
}

- (void)saveToken:(NSString*)_t tokenSecret:(NSString*)_tS andUserName:(NSString *)_user {
    NSDictionary *flickrDict = [NSDictionary dictionaryWithObjectsAndKeys:_user,@"username",_t,@"token",_tS,@"tokenSecret",[NSNumber numberWithBool:YES],@"Enabled",nil];
    NSMutableDictionary *prefs;
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/User/Library/Preferences/com.homeschooldev.fusionsettings.plist"])
        prefs = [NSMutableDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.homeschooldev.fusionsettings.plist"];
    else
        prefs = [NSMutableDictionary dictionary];
    [prefs setObject:flickrDict forKey:@"Flickr"];
    [prefs writeToFile:@"/User/Library/Preferences/com.homeschooldev.fusionsettings.plist" atomically:YES];
}

- (void)cancel {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if ([self respondsToSelector:@selector(navigationItem)]) { 
		[[self navigationItem] setTitle:@"Login"]; 
	}
}

- (NSString*)extractVerifierFromURL:(NSURL*)_url {
    NSArray* parameters = [[_url absoluteString] componentsSeparatedByString:@"&"];
    NSArray* keyValue = [[parameters objectAtIndex:1] componentsSeparatedByString:@"="];
    NSString* verifier = [keyValue objectAtIndex:1];
    return verifier;
}

- (NSString*)flickr_oauthSignatureFor:(NSString*)dataString withKey:(NSString*)_secret {
    NSData* secretData = [_secret dataUsingEncoding:NSUTF8StringEncoding];
    NSData* stringData = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    
    const void* keyBytes = [secretData bytes];
    const void* dataBytes = [stringData bytes];
    void* outs = malloc(CC_SHA1_DIGEST_LENGTH);
    CCHmac(kCCHmacAlgSHA1, keyBytes, [secretData length], dataBytes, [stringData length], outs);
    
    NSData* signatureData = [NSData dataWithBytesNoCopy:outs length:CC_SHA1_DIGEST_LENGTH freeWhenDone:YES];
    return [signatureData base64EncodedString];
}

- (NSString*)sortedURLStringFromDictionary:(NSDictionary*)dictionary urlEscape:(BOOL)urlEscape {
    NSMutableArray* pairs = [NSMutableArray array];
    NSArray* keys = [[dictionary allKeys] sortedArrayUsingSelector:@selector(compare:)];
    for (NSString *_key in keys) {
        NSString *value = [dictionary objectForKey:_key];
        CFStringRef escapedValue = CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)value, NULL, CFSTR("%:/?#[]@!$&'()*+,;="), kCFStringEncodingUTF8);
        NSMutableString *pair = [[_key mutableCopy] autorelease];
        [pair appendString:@"="];
        [pair appendString:(NSString *)escapedValue];
        [pairs addObject:pair];
        CFRelease(escapedValue);
    }
    NSString *URLString = (_currentState == FlickrOAuthStateRequestToken) ? kRequestTokenBaseURL : kAccessTokenBaseURL;
    if (urlEscape) {
        URLString = [URLString stringByAddingURLEncoding];
    }
    
    NSMutableString *mURLString = [[URLString mutableCopy] autorelease];
    [mURLString appendString:(urlEscape ? @"&" : @"?")];
    NSString *args = [pairs componentsJoinedByString:@"&"];
    if( urlEscape ) { args = [args stringByAddingURLEncoding]; }
    [mURLString appendString:args];
    
    return mURLString;
}

- (void)handleCallBackURL:(NSURL*)_url {
    _currentState = FlickrOAuthStateAccessToken;
    
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString* nonce = (NSString*)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);
    NSString* timestamp = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    NSString* signatureMethod = [NSString stringWithString:@"HMAC-SHA1"];
    NSString* version = [NSString stringWithString:@"1.0"];
    NSString* verifier = [self extractVerifierFromURL:_url];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:nonce, @"oauth_nonce", timestamp, @"oauth_timestamp", verifier, @"oauth_verifier", key, @"oauth_consumer_key", signatureMethod, @"oauth_signature_method", version, @"oauth_version", _token, @"oauth_token", nil];
    NSString* urlStringBeforeSignature = [self sortedURLStringFromDictionary:parameters urlEscape:YES];
    
    NSString* signature = [NSString stringWithFormat:@"GET&%@", urlStringBeforeSignature];
    NSString* signatureString = [self flickr_oauthSignatureFor:signature withKey:[NSString stringWithFormat:@"%@&%@", secret, _tokenSecret]]; //[_consumerSecret stringByAppendingString:@"&"]];
    
    [parameters setValue:signatureString forKey:@"oauth_signature"];
    NSString* urlStringWithSignature = [self sortedURLStringFromDictionary:parameters urlEscape:NO];
    
    NSMutableURLRequest* req = [[[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlStringWithSignature]] autorelease];
    NSURLConnection* connection = [[[NSURLConnection alloc] initWithRequest:req delegate:self] autorelease];
    _receivedData = [[NSMutableData data] retain];
    [connection start];
    [nonce release];
}

- (void)startAuthorization {
    _currentState = FlickrOAuthStateRequestToken;
    
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString* nonce = (NSString*)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);
    NSString* timestamp = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    NSString* signatureMethod = [NSString stringWithString:@"HMAC-SHA1"];
    NSString* version = [NSString stringWithString:@"1.0"];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:nonce, @"oauth_nonce", timestamp, @"oauth_timestamp", key, @"oauth_consumer_key", signatureMethod, @"oauth_signature_method", version, @"oauth_version", url, @"oauth_callback", nil];
    NSString* urlStringBeforeSignature = [self sortedURLStringFromDictionary:parameters urlEscape:YES];
    
    NSString* signature = [NSString stringWithFormat:@"GET&%@", urlStringBeforeSignature];
    NSString* signatureString = [self flickr_oauthSignatureFor:signature withKey:[secret stringByAppendingString:@"&"]];
    
    [parameters setValue:signatureString forKey:@"oauth_signature"];
    NSString* urlStringWithSignature = [self sortedURLStringFromDictionary:parameters urlEscape:NO];
    
    NSMutableURLRequest* req = [[[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlStringWithSignature]] autorelease];
    NSURLConnection* connection = [[[NSURLConnection alloc] initWithRequest:req delegate:self] autorelease];
    _receivedData = [[NSMutableData data] retain];
    [connection start];
    
    [nonce release];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL* _url = [request URL];
    if ([[_url host] isEqualToString:[[NSURL URLWithString:url] host]]) {
        [self handleCallBackURL:_url];
        return NO;
    }
    return YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [_receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (_currentState == FlickrOAuthStateRequestToken) {
        NSString* response = [[NSString alloc] initWithData:_receivedData encoding:NSUTF8StringEncoding];
        NSArray* parameters = [response componentsSeparatedByString:@"&"];
        NSMutableDictionary* d = [NSMutableDictionary dictionary];
        [parameters enumerateObjectsUsingBlock:^(id element, NSUInteger idx, BOOL *stop) {
            NSArray* array = [(NSString*)element componentsSeparatedByString:@"="];
            NSString* _key = [array objectAtIndex:0];
            NSString* value = [array objectAtIndex:1];
            [d setValue:value forKey:_key];
        }];
        if ([[d objectForKey:@"oauth_callback_confirmed"] boolValue] == YES) {
            _token = [[d objectForKey:@"oauth_token"] retain];
            _tokenSecret = [[d objectForKey:@"oauth_token_secret"] retain];
            NSString* urlString = [NSString stringWithFormat:@"%@?oauth_token=%@&perms=%@", kAuthorizeBaseURL, _token, @"write"];
            [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
        }
        else {
            if ([loginDelegate respondsToSelector:@selector(loginFailed)]) {
                [loginDelegate loginFailed];
            }
            [self dismissModalViewControllerAnimated:YES];
        }
        
        [_receivedData release];
        [response release];
    }
    else {
        NSString* response = [[NSString alloc] initWithData:_receivedData encoding:NSUTF8StringEncoding];
        NSArray* parameters = [response componentsSeparatedByString:@"&"];
        NSMutableDictionary* d = [NSMutableDictionary dictionary];
        [parameters enumerateObjectsUsingBlock:^(id element, NSUInteger idx, BOOL *stop) {
            NSArray* array = [(NSString*)element componentsSeparatedByString:@"="];
            NSString* _key = [array objectAtIndex:0];
            NSString* value = [array objectAtIndex:1];
            [d setValue:value forKey:_key];
        }];
        if ([[d objectForKey:@"username"] length] > 0) {
            if (_token) [_token release];
            if (_tokenSecret) [_tokenSecret release];
            _token = [[d objectForKey:@"oauth_token"] retain];
            _tokenSecret = [[d objectForKey:@"oauth_token_secret"] retain];
            
            [self saveToken:_token tokenSecret:_tokenSecret andUserName:[d objectForKey:@"username"]];
            
            if ([loginDelegate respondsToSelector:@selector(loginSucceededWithToken:andTokenSecret:)]) {
                [loginDelegate loginSucceededWithToken:_token andTokenSecret:_tokenSecret];
            }
            [self dismissModalViewControllerAnimated:YES];
        }
        else {
            if ([loginDelegate respondsToSelector:@selector(loginFailed)]) {
                [loginDelegate loginFailed];
            }
            [self dismissModalViewControllerAnimated:YES];
        }
        
        [_receivedData release];
        [response release];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [_receivedData release];
}

- (void)dealloc {
    if (url) [url release];
    if (key) [key release];
    if (secret) [secret release];
    if (token) [token release];
    if (tokenSecret) [tokenSecret release];
    [super dealloc];
}

@end

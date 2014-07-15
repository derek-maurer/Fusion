    //
//  ElanceWebLogin.m
//  elance
//
//  Created by Constantine Fry on 12/20/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "HSFacebookLogin.h"


@implementation HSFacebookLogin

- (id)initWithDelegate:(id)del andFinishedSelector:(SEL)fin {
	if ((self = [super init])) {
		delegate = [del retain];
		finishedSelector = fin;
	}
	return self;
}

- (void)loadView {
	[super loadView];
    self.navigationItem.title = @"Loading...";
    
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = button;
    [button release];
    
    _url = [NSString stringWithFormat:@"http://www.facebook.com"];
    
	webView = [[UIWebView alloc]initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_url]];
	[webView loadRequest:request];
	[webView setDelegate:self];
	[self.view addSubview:webView];
	[webView release];
}

-(void)cancel {
	[self dismissModalViewControllerAnimated:YES];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	/*NSString *url =[[request URL] absoluteString];
	if ([url rangeOfString:@"code="].length != 0) {
		
		NSHTTPCookie *cookie;
		NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
		for (cookie in [storage cookies]) {
			if ([[cookie domain]isEqualToString:@"foursquare.com"]) {
				[storage deleteCookie:cookie];
			}
		}
		
		NSArray *arr = [url componentsSeparatedByString:@"="];
		[delegate performSelector:finishedSelector withObject:[NSNumber numberWithBool:NO]];
		[self cancel];
	}
	else if ([url rangeOfString:@"error="].length != 0) {
		NSArray *arr = [url componentsSeparatedByString:@"="];
		[delegate performSelector:finishedSelector withObject:[NSNumber numberWithBool:NO]];
	}*/
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.navigationItem.title = @"Login";
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	[delegate performSelector:finishedSelector withObject:[NSNumber numberWithBool:YES]];
}

- (void)dealloc {
	[delegate release];
    [super dealloc];
}

@end

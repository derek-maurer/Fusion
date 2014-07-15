//
//  ElanceWebLogin.h
//  elance
//
//  Created by Constantine Fry on 12/20/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HSFacebookLogin : UIViewController<UIWebViewDelegate> {
	NSString *_url;
	UIWebView *webView;
	id delegate;
	SEL finishedSelector;
}
- (id)initWithDelegate:(id)del andFinishedSelector:(SEL)fin;
@end

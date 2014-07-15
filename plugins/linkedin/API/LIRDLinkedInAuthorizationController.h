//
//  RDLinkedInAuthorizationController.h
//  LinkedInClientLibrary
//
//  Created by Sixten Otto on 12/30/09.
//  Copyright 2010 Results Direct. All rights reserved.
//  
//  Based in large part on the OAuth enhancements to MGTwitterEngine by Ben Gottlieb
//  <http://github.com/bengottlieb/Twitter-OAuth-iPhone>
//

#import <UIKit/UIKit.h>

#import "LIRDLinkedInAuthorizationControllerDelegate.h"

@class LIRDLinkedInEngine;


@interface LIRDLinkedInAuthorizationController : UIViewController <UIWebViewDelegate> {
  id<LIRDLinkedInAuthorizationControllerDelegate> rdDelegate;
  LIRDLinkedInEngine* rdEngine;
  UINavigationBar*  rdNavBar;
  UIWebView*        rdWebView;
}

@property (nonatomic, assign)   id<LIRDLinkedInAuthorizationControllerDelegate> delegate;
@property (nonatomic, readonly) LIRDLinkedInEngine* engine;
@property (nonatomic, readonly) UINavigationBar* navigationBar;

+ (id)authorizationControllerWithEngine:(LIRDLinkedInEngine *)engine delegate:(id<LIRDLinkedInAuthorizationControllerDelegate>)delegate;

- (id)initWithEngine:(LIRDLinkedInEngine *)engine delegate:(id<LIRDLinkedInAuthorizationControllerDelegate>)delegate;
- (id)initWithConsumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret delegate:(id<LIRDLinkedInAuthorizationControllerDelegate>)delegate;

@end

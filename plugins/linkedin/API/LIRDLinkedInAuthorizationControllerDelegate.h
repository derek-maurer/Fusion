//
//  RDLinkedInAuthorizationControllerDelegate.h
//  LinkedInClientLibrary
//
//  Created by Sixten Otto on 6/2/11.
//  Copyright 2011 Results Direct. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LIRDLinkedInAuthorizationController;


@protocol LIRDLinkedInAuthorizationControllerDelegate <NSObject>

@optional

- (void)linkedInAuthorizationControllerSucceeded:(LIRDLinkedInAuthorizationController *)controller;

- (void)linkedInAuthorizationControllerFailed:(LIRDLinkedInAuthorizationController *)controller;

- (void)linkedInAuthorizationControllerCanceled:(LIRDLinkedInAuthorizationController *)controller;

@end

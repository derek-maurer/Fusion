//
//  RDLinkedInEngineDelegate.h
//  LinkedInClientLibrary
//
//  Created by Sixten Otto on 6/2/11.
//  Copyright 2011 Results Direct. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LIRDLinkedInTypes.h"

@class LIRDLinkedInEngine;
@class LIOAToken;

@protocol LIRDLinkedInEngineDelegate <NSObject>

@optional

- (void)linkedInEngineAccessToken:(LIRDLinkedInEngine *)engine setAccessToken:(LIOAToken *)token;
- (LIOAToken *)linkedInEngineAccessToken:(LIRDLinkedInEngine *)engine;

- (void)linkedInEngine:(LIRDLinkedInEngine *)engine requestSucceeded:(LIRDLinkedInConnectionID *)identifier withResults:(id)results;
- (void)linkedInEngine:(LIRDLinkedInEngine *)engine requestFailed:(LIRDLinkedInConnectionID *)identifier withError:(NSError *)error;

@end

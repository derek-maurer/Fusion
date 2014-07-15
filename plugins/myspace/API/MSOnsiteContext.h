//
//  MSOnsiteContext.h
//  MySpaceID
//
//  Copyright MySpace, Inc. 2010. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSSecurityContext.h"
#import "OAMutableURLRequest.h"
#import "OAConsumer.h"

@interface MSOnsiteContext : MSSecurityContext {
	OAMutableURLRequest *request;
	OAConsumer *consumer;
}

+ (MSOnsiteContext*) contextWithConsumerKey:(NSString*) consumerKey consumerSecret:(NSString*) consumerSecret urlScheme:(NSString *) urlScheme;

@end

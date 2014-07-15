//
//  OAToken+storage.h
//  LinkedInClientLibrary
//
//  Created by Sixten Otto on 6/2/11.
//  Copyright 2011 Results Direct. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LIOAToken.h"

@class LIOAToken;


@interface LIOAToken (OAToken_RDLinkedIn_storage)

+ (LIOAToken *)rd_tokenWithUserDefaultsUsingServiceProviderName:(NSString *)provider prefix:(NSString *)prefix;

+ (void)rd_clearUserDefaultsUsingServiceProviderName:(NSString *)provider prefix:(NSString *)prefix;

- (void)rd_storeInUserDefaultsWithServiceProviderName:(NSString *)provider prefix:(NSString *)prefix;

@end

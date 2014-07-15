//
//  OAToken.m
//  OAuthConsumer
//
//  Created by Jon Crosby on 10/19/07.
//  Copyright 2007 Kaboomerang LLC. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
//  Back-ported to obj-c 1.x by George Fletcher


#import "OAToken.h"

@interface OAToken()
@property (copy) NSString* key;
@property (copy) NSString* secret;
@property (retain) NSDictionary* fields;
@end


@implementation OAToken

@synthesize key;
@synthesize secret;
@synthesize fields;

- (void) dealloc {
    self.key = nil;
    self.secret = nil;
    self.fields = nil;

    [super dealloc];
}


- (id) init {
    if ((self = [super init])) {
        self.key = @"";
        self.secret = @"";
    }

    return self;
}


- (id) initWithKey:(NSString*) key_
            secret:(NSString*) secret_ {
    if ((self = [super init])) {
        self.key = key_;
        self.secret = secret_;
    }

    return self;
}


- (id) initWithHTTPResponseBody:(NSString*) body {
    if ((self = [super init])) {
        NSArray* pairs = [body componentsSeparatedByString:@"&"];
        NSMutableDictionary* map = [NSMutableDictionary dictionary];

        for (NSString* pair in pairs) {
            NSArray* elements = [pair componentsSeparatedByString:@"="];

            if (elements.count >= 2) {
                NSString* urlKey = [elements objectAtIndex:0];
                NSString* value = [elements objectAtIndex:1];

                if ([urlKey isEqual:@"oauth_token"]) {
                    [self setKey:value];
                } else if ([urlKey isEqual:@"oauth_token_secret"]) {
                    [self setSecret:value];
                }

                [map setObject:value forKey:urlKey];
            }
        }

        self.fields = map;
    }

    return self;
}


+ (OAToken*) tokenWithKey:(NSString*) key secret:(NSString*) secret {
    return [[OAToken alloc] initWithKey:key secret:secret];
}


+ (OAToken*) tokenWithHTTPResponseBody:(NSString*) body {
    return [[[OAToken alloc] initWithHTTPResponseBody:body] autorelease];
}

@end
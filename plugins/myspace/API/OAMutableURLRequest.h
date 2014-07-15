//
//  OAMutableURLRequest.h
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

#import "OAConsumer.h"
#import "OAToken.h";

@interface OAMutableURLRequest : NSMutableURLRequest {
@private
    OAConsumer* consumer;
    OAToken* token;
    NSString* realm;
    NSString* signature;
    NSString* nonce;
    NSString* timestamp;
}

@property (retain) OAConsumer* consumer;
@property (retain) OAToken* token;
@property (copy) NSString* realm;
@property (copy) NSString* signature;
@property (copy) NSString* nonce;
@property (copy) NSString* timestamp;

- (id) initWithURL:(NSURL*) url_ consumer:(OAConsumer*) consumer_ token:(OAToken*) token_ realm:(NSString*) realm_;

+ (OAMutableURLRequest*) requestWithURL:(NSURL*) url consumer:(OAConsumer*) consumer token:(OAToken*) token realm:(NSString*) realm;

- (void)prepare;

@end


//
//  OAServiceTicket.m
//  OAuthConsumer
//
//  Created by Jon Crosby on 11/5/07.
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


#import "OAServiceTicket.h"
#import "OAMutableURLRequest.h"

@interface OAServiceTicket()
@property (retain) OAMutableURLRequest* request;
@property (retain) NSURLResponse* response;
@property BOOL succeeded;
@end

@implementation OAServiceTicket

@synthesize request, response, succeeded;

- (void) dealloc {
    self.request = nil;
    self.response = nil;

    [super dealloc];
}


- (id) initWithRequest:(OAMutableURLRequest*) request_
              response:(NSURLResponse*) response_
             succeeded:(BOOL) succeeded_ {
    if ((self = [super init])) {
        self.request = request_;
        self.response = response_;
        self.succeeded = succeeded_;
    }

    return self;
}


+ (OAServiceTicket*) ticketWithRequest:(OAMutableURLRequest*) request
                              response:(NSURLResponse*) response
                             succeeded:(BOOL) succeeded {
    return [[[OAServiceTicket alloc] initWithRequest:request response:response succeeded:succeeded] autorelease];
}

@end
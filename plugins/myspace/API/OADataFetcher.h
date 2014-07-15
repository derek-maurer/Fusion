//
//  OADataFetcher.h
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

#include "OAMutableURLRequest.h"
#include "MSSecurityContext.h"

@interface OADataFetcher : NSObject {
	NSURLConnection*  _connection;
	NSMutableData* _receivedData;
	OAMutableURLRequest* _request;
	NSURLResponse* _response;
	id<OAResponseDelegate> _delegate;
	BOOL _makeAsync;
}

@property (nonatomic, retain) NSURLResponse *_response;
//@property (nonatomic, assign) OAMutableURLRequest* _request;
@property (nonatomic, assign) id<OAResponseDelegate> _delegate;

- (void) fetchDataWithRequest:(OAMutableURLRequest*) request
                     delegate:(id) delegate didFinishSelector:(SEL) didFinishSelector didFailSelector:(SEL) didFailSelector 
					makeAsync:(BOOL) makeAsync;


@end
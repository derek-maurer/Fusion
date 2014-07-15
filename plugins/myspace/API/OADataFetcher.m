//
//  OADataFetcher.m
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


#import "OADataFetcher.h"
#import "OAMutableURLRequest.h"
#import "OAServiceTicket.h"
#import "MSSecurityContext.h"

@implementation OADataFetcher
@synthesize _response;
//@synthesize _request;
@synthesize _delegate;

- (void) fetchDataWithRequest:(OAMutableURLRequest*) request
                     delegate:(id) delegate didFinishSelector:(SEL) didFinishSelector didFailSelector:(SEL) didFailSelector 
					makeAsync:(BOOL) makeAsync{
	
	_delegate = [delegate retain];
	_makeAsync	 = makeAsync;
	_request = [request retain];
    [request prepare];

    NSURLResponse* response = nil;
    NSError* error = nil;
	NSData* responseData;
	
	NSLog(@"Request URL: %@",[_request URL]);

	@try
	{
		if(_makeAsync){
		
			_connection = [[NSURLConnection alloc] initWithRequest:_request delegate:self startImmediately:YES];
			if (_connection == nil) {
				/* inform the user that the connection failed */
				/*NSString *message = NSLocalizedString (@"Unable to initiate request.", 
													   @"NSURLConnection initialization method failed.");
				//NSLog(@"%@", message);*/
			}
		}
		else
		{
		
           responseData   = [NSURLConnection sendSynchronousRequest:_request
                                                  returningResponse:&response
					error:&error];
			
			if (error != nil) {
				OAServiceTicket* ticket =
				[OAServiceTicket ticketWithRequest:request
										  response:response
										 succeeded:NO];
				
				[_delegate performSelector:didFailSelector
							   withObject:ticket
							   withObject:error];
				
			} else {
				OAServiceTicket* ticket =
				[OAServiceTicket ticketWithRequest:request
										  response:response
										 succeeded:[(NSHTTPURLResponse*)response statusCode] < 400];
				
				[_delegate performSelector:didFinishSelector
							   withObject:ticket
							   withObject:responseData];
				 
			}
		 
		}
	}
	@catch (NSException *exception) {
		//NSLog(@"Caught %@%@", [exception name], [exception reason]);
	}
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// NSURLConnectionDelegate

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response {
	//NSLog(@"%@", @"didReceiveResponse");
	_receivedData = [[NSMutableData alloc]init];
	_response = [response retain];
	//NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)_response;
	//NSLog(@"%d", [httpResponse statusCode]);
}

-(void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data {
	//NSLog(@"%@", @"didReceiveData");
	[_receivedData appendData:data];
}

- (NSCachedURLResponse*)connection:(NSURLConnection*)connection
				 willCacheResponse:(NSCachedURLResponse*)cachedResponse {
		//NSLog(@"%@", @"cachedResponse");
	return nil;
}

-(void)connectionDidFinishLoading:(NSURLConnection*)connection {
	//NSLog(@"%@", @"connectionDidFinishLoading");

	NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)_response;
	//NSLog(@"%d", [httpResponse statusCode]);
        OAServiceTicket* ticket =
        [OAServiceTicket ticketWithRequest:_request
                                  response:_response
                                 succeeded:[httpResponse statusCode] < 400];
	if ([_delegate respondsToSelector:@selector(apiTicket:didFinishWithData:)]) {    
		[_delegate apiTicket:ticket didFinishWithData:_receivedData];
	}
	[_receivedData release];
	_receivedData = nil;
	[_connection release];
	_connection = nil;
}

- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error {  
	//NSLog(@"%@", @"didFailWithError");

	OAServiceTicket* ticket =
	[OAServiceTicket ticketWithRequest:_request
							  response:_response
							 succeeded:NO];
	
	if ([_delegate respondsToSelector:@selector(apiTicket:didFailWithError:)]) {    
		[_delegate apiTicket:ticket didFinishWithError:error];
	}
	
	[_receivedData release];
	_receivedData = nil;
	[_connection release];
	_connection = nil;
}

- (void) dealloc
{
	[_response release];
	[_request release];
	[_delegate release];
	[_connection release];
	[super	dealloc];
}

@end
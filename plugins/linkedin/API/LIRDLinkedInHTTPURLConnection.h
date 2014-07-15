//
//  RDLinkedInHTTPURLConnection.h
//  LinkedInClientLibrary
//
//  Created by Sixten Otto on 12/30/09.
//  Copyright 2010 Results Direct. All rights reserved.
//
//  Significant inspiration and code from MGTwitterEngine by Matt Gemmell
//  <http://mattgemmell.com/source#mgtwitterengine>
//

#import <Foundation/Foundation.h>

#import "LIRDLinkedInTypes.h"


@interface LIRDLinkedInHTTPURLConnection : NSURLConnection {
  NSURLRequest*           rdRequest;
  NSMutableData*          rdData;
  LIRDLinkedInConnectionID* rdIdentifier;
}

@property (nonatomic, readonly) LIRDLinkedInConnectionID* identifier;
@property (nonatomic, readonly) NSURLRequest* request;

- (NSData *)data;
- (void)appendData:(NSData *)data;
- (void)resetData;

@end

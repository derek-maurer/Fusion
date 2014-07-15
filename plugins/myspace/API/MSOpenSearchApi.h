//
//  MSOpenSearchApi.h
//  MySpaceID.Demo
//
//  Copyright MySpace, Inc. 2010. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSSecurityContext.h"

@interface MSOpenSearchApi : NSObject<OAResponseDelegate> {
	MSSecurityContext *context;
	NSData *responseData;
	NSInteger responseStatusCode;
	NSHTTPURLResponse *httpResponse;
	NSString *methodName;
}

@property (nonatomic, assign) MSSecurityContext* context;
@property (nonatomic, assign) NSData* responseData;
@property (nonatomic, assign) NSInteger responseStatusCode;
@property (nonatomic, assign) NSHTTPURLResponse *httpResponse;
@property (nonatomic, assign) NSString *methodName;

+ (MSOpenSearchApi*) apiWithContext:(MSSecurityContext*) context;

#pragma mark --People Search--
-(NSString*) searchPeople:(NSString*)searchTerms;
-(NSString*) searchPeople:(NSString*)searchTerms queryParameters:(NSMutableDictionary*)queryParameters;
-(NSString*) searchPeople:(NSString*)searchTerms format:(NSString*)format count:(NSString*)count startPage:(NSString*)startPage
				 searchBy:(NSString*)searchBy gender:(NSString*)gender hasPhoto:(NSString*)hasPhoto minAge:(NSString*)minAge maxAge:(NSString*)maxAge
				 location:(NSString*)location distance:(NSString*)distance latitude:(NSString*)latitude longitude:(NSString*)longitude culture:(NSString*)culture
			  countryCode:(NSString*)countryCode;

#pragma mark --Image Search--
-(NSString*) searchImages:(NSString*)searchTerms;
-(NSString*) searchImages:(NSString*)searchTerms queryParameters:(NSMutableDictionary*)queryParameters;
-(NSString*) searchImages:(NSString*)searchTerms format:(NSString*)format count:(NSString*)count startPage:(NSString*)startPage
				  culture:(NSString*)culture sortBy:(NSString*)sortBy sortOrder:(NSString*)sortOrder;

#pragma mark --Video Search--
-(NSString*) searchVideos:(NSString*)searchTerms;
-(NSString*) searchVideos:(NSString*)searchTerms queryParameters:(NSMutableDictionary*)queryParameters;
-(NSString*) searchVideos:(NSString*)searchTerms format:(NSString*)format count:(NSString*)count startPage:(NSString*)startPage
				  culture:(NSString*)culture tag:(NSString*)tag videoMode:(NSString*)videoMode;


#pragma mark --Helper Methods--
- (NSMutableDictionary*) makeQueryDictionary:(NSString*)format count:(NSString*)count startPage:(NSString*)startPage
									searchBy:(NSString*)searchBy gender:(NSString*)gender hasPhoto:(NSString*)hasPhoto minAge:(NSString*)minAge maxAge:(NSString*)maxAge
									location:(NSString*)location distance:(NSString*)distance latitude:(NSString*)latitude longitude:(NSString*)longitude culture:(NSString*)culture
								 countryCode:(NSString*)countryCode sortBy:(NSString*)sortBy sortOrder:(NSString*)sortOrder tag:(NSString*)tag videoMode:(NSString*)videoMode;
- (NSString*) makeOpenSearchRequest:(NSString*)uri queryParameters:(NSDictionary*)queryParams requestMethod:(NSString*)requestMethod
				 requestBody:(NSData*)requestBody contentType:(NSString*)contentType;


@end

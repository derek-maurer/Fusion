//
//  Pastie.h
//  Paste
//
//  Created by Grant Paul on 7/5/10.
//  Copyright 2010 Xuzz Productions, LLC. All rights reserved.
// 

#import <Foundation/Foundation.h>

@protocol HSPastieDelegate;

@interface HSPastie : NSObject {
	id<HSPastieDelegate> delegate;
}

@property (nonatomic, assign) id<HSPastieDelegate> delegate;

+ (NSDictionary *)languages;
- (NSString *)submitWithText:(NSString*)text makePrivate:(BOOL)makePrivate language:(NSInteger)language;
- (void)beginSubmissionWithText:(NSString *)text makePrivate:(BOOL)makePrivate language:(NSInteger)language;
- (void)beginSubmissionWithText:(NSString *)text makePrivate:(BOOL)makePrivate;
- (void)beginSubmissionWithText:(NSString *)text;

@end

@protocol HSPastieDelegate <NSObject>
@optional
- (void)submissionCompletedWithURL:(NSURL *)url;
- (void)submissionFailedWithError:(NSError *)error;
@end

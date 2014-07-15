//This is just a copy of HSPastie, but renamed to please the binaries...

#import <Foundation/Foundation.h>

@protocol HSTweakPastieDelegate;

@interface HSTweakPastie : NSObject {
	id<HSTweakPastieDelegate> delegate;
}

@property (nonatomic, assign) id<HSTweakPastieDelegate> delegate;

+ (NSDictionary *)languages;
- (NSString *)submitWithText:(NSString*)text makePrivate:(BOOL)makePrivate language:(NSInteger)language;
- (void)beginSubmissionWithText:(NSString *)text makePrivate:(BOOL)makePrivate language:(NSInteger)language;
- (void)beginSubmissionWithText:(NSString *)text makePrivate:(BOOL)makePrivate;
- (void)beginSubmissionWithText:(NSString *)text;

@end

@protocol HSTweakPastieDelegate <NSObject>
@optional
- (void)submissionCompletedWithURL:(NSURL *)url;
- (void)submissionFailedWithError:(NSError *)error;
@end

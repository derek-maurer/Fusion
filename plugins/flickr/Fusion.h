#import <CoreLocation/CoreLocation.h>

@protocol FusionPluginDelegate <NSObject>
@optional
//This method will post a message to an alert view that gets shown after all post are completed.
//PLEASE use this method instead of using UIAlertView!!!
- (void)postMessage:(NSString*)message;
//********YOU MUST CALL THIS METHOD WHEN POST IS COMPLETE***********//
- (void)postComplete;
@end

@protocol FusionViewDelegate <NSObject>
@optional
//This method will close the your view.
- (void)closeView;
@end

@protocol FusionView <NSObject>
@required
- (id)initWithData:(NSDictionary *)data location:(CLLocation *)location andDelegate:(id<FusionViewDelegate>)delegate;
//You should return your view with this method.
- (id)view;
//This method will get called when the user hits 'send'. 
//If this method returns yes, your view will be shown before the message is sent.
- (BOOL)shouldAppearBeforePost;
@optional
- (void)viewWillAppear;
- (void)viewDidAppear;
- (void)viewWillDisappear;
- (void)viewDidDisappear;
//This method will tell you the size of the view. NOTE, you 
//cannot (shouldn't) set the size of the view! Set it to whatever you please upon initialization,
//but once -(id)view is called, do NOT set the size of the view.
- (void)viewUpdatedWithFrame:(CGRect)frame;
- (void)willAnimateRotationToInterfaceOrientation:(int)orientation withDuration:(double)duration;
//This method will be called when the user taps the 'Add Location' button.
- (void)locationButtonTappedOnWithLocation:(CLLocation*)location;
//This method will be called when the user removes the added location.
- (void)locationButtonTappedOff;
@end

@protocol FusionPlugin <NSObject>
@required
+ (int)maxCharacterCount;
- (id)initWithMessage:(NSString *)message images:(NSArray *)images location:(CLLocation *)location andDelegate:(id<FusionPluginDelegate>)delegate;
@end

@protocol FusionQuickReply <NSObject>
@required
- (id)initWithNotificationContext:(NSDictionary*)context;
- (BOOL)supportsQuickReplyWithNotificationContext:(NSDictionary*)context;
@end


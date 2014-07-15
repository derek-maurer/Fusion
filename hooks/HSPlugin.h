#import "Fusion.h"

@protocol FusionPluginDelegate <NSObject>
@optional
- (void)postMessage:(NSString*)message;
@end

@protocol FusionViewDelegate <NSObject>
@optional
- (void)closeView;
@end

@interface HSPluginClass : NSObject {}
- (id)initWithMessage:(NSString *)message images:(NSArray *)images urls:(NSArray *)urls location:(CLLocation *)location andDelegate:(id<FusionPluginDelegate>)delegate;
@end

@interface HSPluginViewClass : NSObject {}
- (id)initWithData:(NSDictionary*)data location:(CLLocation*)location andDelegate:(id<FusionViewDelegate>)delegate;
- (BOOL)shouldAppearBeforePost;
- (void)locationButtonTappedOnWithLocation:(CLLocation*)location;
- (void)locationButtonTappedOff;
@end

@interface HSQuickReplyClass : NSObject
- (id)initWithNotificationContext:(NSDictionary*)context;
- (BOOL)supportsQuickReplyWithNotificationContext:(NSDictionary*)context;
@end

@interface HSPlugin : NSObject <FusionViewDelegate, FusionPluginDelegate> {
    NSBundle *bundle;
    NSString *plugin;
    NSString *messageString;
    NSMutableDictionary *data;
    UIButton *closeButton;
    HSPluginViewClass *viewController;
    NSDictionary *quickReplyContext;
}
@property (nonatomic, retain) HSPluginViewClass *viewController;
@property (nonatomic, retain) UIButton *closeButton;
@property (nonatomic, retain) NSBundle *bundle;
@property (nonatomic, retain) NSString *plugin;
@property (nonatomic, assign) id controller;
- (id)initWithPath:(NSString *)p andData:(NSDictionary *)dict;
- (id)initWithPath:(NSString *)p andQuickReplyContext:(NSDictionary*)context;
- (BOOL)load;
- (NSString *)serviceName;
- (CLLocation *)location;
- (NSDictionary *)locationDictionary;
- (void)postMessage:(NSString *)message;
- (BOOL)locationSelected;
- (BOOL)requiresUI;
- (BOOL)supportsQuickReplyWithNotificationContext:(NSDictionary*)context;
- (void)locationButtonTapped:(BOOL)on;
- (id)pluginViewController;
- (NSDictionary *)parsedData;
@end

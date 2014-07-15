#import "Fusion.h"
#import "HSPastie.h"

/*********************************************************************/
/*This class is the same as HSPlugin, but with some minor differences, it's just renamed to please the binaries! :)*/
/*********************************************************************/

@protocol FusionPluginDelegate <NSObject>
@optional
- (void)postMessage:(NSString*)message;
@end

@protocol FusionViewDelegate <NSObject>
@optional
- (void)closeView;
@end

@interface HSPluginClass : NSObject {}
+ (int)maxCharacterCount;
- (id)initWithMessage:(NSString *)message images:(NSArray *)images location:(CLLocation *)location andDelegate:(id<FusionPluginDelegate>)delegate;
@end

@interface HSPluginViewClass : NSObject {}
- (id)initWithData:(NSDictionary*)data location:(CLLocation*)location andDelegate:(id<FusionViewDelegate>)delegate;
- (BOOL)shouldAppearBeforePost;
- (void)locationButtonTappedOnWithLocation:(CLLocation*)location;
- (void)locationButtonTappedOff;
@end

@interface HSConPlugin : NSObject <FusionViewDelegate, FusionPluginDelegate> {
    NSBundle *bundle;
    NSString *plugin;
    NSString *messageString;
    NSMutableDictionary *data;
    UIButton *closeButton;
    HSPluginViewClass *viewController;
}
@property (nonatomic, retain) HSPluginViewClass *viewController;
@property (nonatomic, retain) UIButton *closeButton;
@property (nonatomic, retain) NSBundle *bundle;
@property (nonatomic, retain) NSString *plugin;
@property (nonatomic, assign) id controller;
- (id)initWithPath:(NSString *)p andData:(NSDictionary *)dict;
- (BOOL)load;
- (NSString *)fullText;
- (NSString *)fullTextWithPastie:(NSString *)url andLength:(int)length;
- (NSString *)serviceName;
- (void)postComplete;
- (CLLocation *)location;
- (NSDictionary *)locationDictionary;
- (void)postMessage:(NSString *)message;
- (BOOL)locationSelected;
- (BOOL)requiresUI;
- (void)locationButtonTapped:(BOOL)on;
- (id)pluginViewController;
- (NSDictionary *)parsedData;
@end

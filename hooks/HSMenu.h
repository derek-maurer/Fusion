#import "HSButton.h"
#import "HSFrame.h"
#import "HSPluginView.h"

@interface HSMenu : UIScrollView {
	NSString *path;
	NSMutableArray *plugins;
    NSMutableArray *buttons;
    NSMutableArray *pluginViews;
    UIImageView *pluginImageView;
    id target;
    UIControlEvents controlEvents;
    BOOL pluginWindowOpen;
    id tweakDelegate;
    UIView *pluginSuperView;
}
@property (nonatomic, assign) BOOL pluginWindowOpen;
@property (nonatomic, retain) UIButton *sendButton;
@property (nonatomic, retain) id tweakDelegate;
@property (nonatomic, retain) NSMutableArray *pluginViews;
@property (nonatomic, assign) CGRect superFrame;
@property (nonatomic, retain) NSString *path;
@property (nonatomic, retain) UIView *pluginSuperView;
- (id)initWithFrame:(CGRect)frame;
- (void)reload;
- (void)load;
- (void)buttonPushed:(HSButton *)btn;
- (BOOL)twitterSelected;
- (BOOL)pluginEnabledWithPath:(NSString *)p;
- (void)rotateToOrientation:(int)orientation withDuration:(double)duration;
- (NSArray *)pluginsRequireUIAttention;
- (void)showPluginUIs:(NSArray*)plugs;
- (NSDictionary *)insertSpecifiersInPlugin:(NSString *)p;
- (void)showNextPluginView;
- (NSMutableDictionary*)parseAttachments:(NSMutableDictionary*)data;
- (NSArray *)bundles;
- (NSArray *)selectedButtons;
- (NSArray *)organizeArray:(NSArray *)array;
- (void)showViewForPlugin:(HSButton *)button;
- (void)closeWindow:(id)sender;
- (void)locationButtonTappedOn:(BOOL)on;
- (void)pluginViewDidAppear;
- (void)pluginViewWillAppear;
- (void)pluginViewDidDisappear;
- (void)pluginViewWillDisappear;
- (void)pluginViewFrameUpdated:(CGRect)frame;
@end

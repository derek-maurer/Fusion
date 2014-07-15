#import "Fusion.h"
#import "HSPlugin.h"
#import "HSButton.h"

@interface HSPluginView : UIView {
	id pluginView;
	id pluginViewController;
	HSButton *button;
	HSPlugin *plugin;
    UIButton *closeButton;
	UILabel *textLabel;
    id menu;
}
@property (nonatomic, retain) id pluginViewController;
@property (nonatomic, assign) id menu;
@property (nonatomic, retain) HSPlugin *plugin;
@property (nonatomic, retain) HSButton *button;

- (id)initWithPlugin:(HSPlugin *)p andButton:(HSButton *)b andFrame:(CGRect)frame;
- (void)reload;
@end

@interface HSPluginObject : NSObject
- (id)view;
@end
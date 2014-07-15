#import "Fusion.h"

@interface HSButton : UIButton {
	BOOL userSelected;
	NSString *pluginPath;
    UIImageView *check;
    int indexOnPage;
    float xCor;
    int page;
}
@property (nonatomic, assign) int indexOnPage;
@property (nonatomic, assign) int page;
@property (nonatomic, assign) float xCor;
@property (nonatomic, assign) BOOL userSelected;
@property (nonatomic, retain) NSString *pluginPath;
- (id)initWithPath:(NSString *)_plugin andFrame:(CGRect)frame;
- (void)setUserSelected:(BOOL)selected;
- (void)performSetup;
- (BOOL)autoSelection;
- (BOOL)siriSelection;
@end
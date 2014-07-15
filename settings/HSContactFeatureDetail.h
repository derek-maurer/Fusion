#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CPDistributedMessagingCenter.h>
#import <CommonCrypto/CommonDigest.h>

@interface HSContactFeatureDetail : UIViewController {
    UIView *view;
    UILabel *longLabel;
    UILabel *shortLabel;
    UITextField *name;
    UITextField *shortDes;
    UITextView *longDes;
    UIButton *button;
    UIButton *closeButton;
    UIScrollView *scrollView;
    NSMutableDictionary *feature;
    BOOL addingNew;
}
@property (nonatomic, assign) BOOL addingNew;
@property (nonatomic, retain) NSMutableDictionary *feature;
- (void)textFieldDone:(UITextField *)tField;
- (void)setNavigationTitle:(NSString *)navigationTitle;
- (NSString *)SHA1:(NSString*)input;
@end
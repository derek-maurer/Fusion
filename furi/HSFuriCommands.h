#import "SiriObjects.h"
#import <substrate.h>
#import <SpringBoard/SBAssistantController.h>
#import <Twitter/TWTweetComposeViewController.h>
#import <Twitter/TWTweetSheetAttachment.h>
#import <objc/runtime.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <AssetsLibrary/ALAssetsFilter.h>
#import <AssetsLibrary/ALAssetsGroup.h>
#import <AssetsLibrary/ALAssetRepresentation.h>
#import "ArrayValue.h"

typedef enum {
    HSPostTypeUpdateStatus,
    HSPostTypeUpdateStatusCustom,
    HSPostTypeUpdateStatusSayingCustom,
    HSPostTypeUpdateStatusPhoto,
    HSPostTyepLatestPhoto,
    HSPostTypeLatestPhotoToNetwork,
    HSPostTypeLatestPhotoCustom,
    HSPostTypeLatestPhotoCaptionCustom,
    HSPostTypeLatestPhotoCaptionCustomToNetwork,
    HSPostTypePostStatus,
    HSPostTypePostStatusCustom,
    HSPostTypePostStatusToNetworkCustom,
    HSPostTypePostStatusToNetworkSayingCustom,
    HSPostTypePostStatusPhotoCustom,
    HSPostTypePostStatusPhotoCustomNetwork,
    HSPostTypePostStatusPhoto,
    HSPostTypePostStatusPhotoToNetwork,
    HSPostTypePostStatusPhotoWithCaption,
    HSPostTypePostStatusPhotoCaption,
    HSPostTypePostStatusSayingCustom,
    HSPostTypeNone
} PostType;

@interface HSFuriCommands : NSObject<SECommand> {
}

-(BOOL)handleSpeech:(NSString*)text tokens:(NSArray*)tokens tokenSet:(NSSet*)tokenset context:(id<SEContext>)ctx;
- (void)showTweetSheetWithText:(NSString *)text shouldUploadPhoto:(BOOL)uploadPhoto;
- (PostType)getPostTypeForValuesInTokens:(NSArray *)tokens;
- (NSMutableArray *)servicesPaths:(NSMutableArray *)services;
- (void)selectServices:(NSMutableArray *)services;
@end
// vim:ft=objc

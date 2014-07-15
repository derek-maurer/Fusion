#import <UIKit/UIKit.h>
#import <Twitter/TWTweetComposeViewController.h>
#import <Twitter/TWTweetSheetAttachment.h>
#include <dlfcn.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#import <objc/runtime.h>
#import <Twitter/TWTweetSheetLocationAssembly.h>
#import <Twitter/TWTweetComposeViewController-TWTweetComposeViewControllerMentionAdditions.h>
#import <Twitter/TWStatus.h>
#import <Twitter/TWUserRecord.h>
#import <Twitter/TWDSession.h>
#import <QuartzCore/QuartzCore.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CPDistributedMessagingCenter.h>
#import <AudioToolbox/AudioToolbox.h>
#import <SpringBoard/SBAssistantController.h>
#import <Accounts/ACAccount.h>
#import <Accounts/ACAccountCredential.h>
#import "substrate.h"

#define HSLog(fmt, ...) { NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.homeschooldev.fusionsettings.plist"];if ([dict objectForKey:@"Debug"] && [[dict objectForKey:@"Debug"] boolValue]) { NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__,__LINE__,##__VA_ARGS__);} }
#define HSAlert(fmt, ...) { NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.homeschooldev.fusionsettings.plist"];if ([dict objectForKey:@"Debug"] && [[dict objectForKey:@"Debug"] boolValue]) { UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%s [Line %d] ", __PRETTY_FUNCTION__,__LINE__] message:[NSString stringWithFormat:fmt,##__VA_ARGS__] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]; [alert show]; [alert release];} }

@interface TWDSession(fusion)
- (NSString *)fullTextWithPastie:(NSString *)url length:(int)length andMessage:(NSString *)message;
- (void)uploadPhotos:(NSArray *)images;
@end

@interface TwitterPlugin : NSObject
- (id)initWithData:(NSDictionary *)data andActiveAccount:(ACAccount*)account;
@end
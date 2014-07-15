TARGET_CXX=clang
ARCHS=armv7

include theos/makefiles/common.mk

BUNDLE_NAME = Instagram InstagramPrefs
Instagram_FILES = API/IGComment.m \
				API/IGImage.m \
				API/IGLocation.m \
				API/IGMedia.m \
				API/IGMetadata.m \
				API/IGPagination.m \
				API/IGReachability.m \
				API/IGSubscription.m \
				API/IGTag.m \
				API/IGUser.m \
				API/InstagramEngine.m \
				API/InstagramLoginDelegate.m \
				API/JSONKit.m \
				API/MKNetworkEngine.m \
				API/MKNetworkOperation.m \
				API/Notification.m \
				API/NRGramKit.m \
				API/NSAlert+MKNetworkKitAdditions.m \
				API/NSData+Base64.m \
				API/NSDate+RFC1123.m \
				API/NSDictionary+RequestEncoding.m \
				API/NSString+MKNetworkKitAdditions.m \
				API/UIAlertView+MKNetworkKitAdditions.m \
				Instagram.m \
				InstagramView.m
Instagram_CFLAGS = -fobjc-arc
Instagram_FRAMEWORKS = UIKit CoreLocation SystemConfiguration Security
Instagram_INSTALL_PATH = /Library/Application Support/Fusion/Plugins

InstagramPrefs_FILES = API/IGComment.m \
					API/IGImage.m \
					API/IGLocation.m \
					API/IGMedia.m \
					API/IGMetadata.m \
					API/IGPagination.m \
					API/IGReachability.m \
					API/IGSubscription.m \
					API/IGTag.m \
					API/IGUser.m \
					API/InstagramEngine.m \
					API/InstagramLoginDelegate.m \
					API/JSONKit.m \
					API/MKNetworkEngine.m \
					API/MKNetworkOperation.m \
					API/Notification.m \
					API/NRGramKit.m \
					API/NSAlert+MKNetworkKitAdditions.m \
					API/NSData+Base64.m \
					API/NSDate+RFC1123.m \
					API/NSDictionary+RequestEncoding.m \
					API/NSString+MKNetworkKitAdditions.m \
					API/UIAlertView+MKNetworkKitAdditions.m \
					InstagramPrefs.m
InstagramPrefs_CFLAGS = -fobjc-arc
InstagramPrefs_INSTALL_PATH = /Library/Application Support/Fusion/Plugins/Instagram.bundle
InstagramPrefs_FRAMEWORKS = UIKit SystemConfiguration Security
InstagramPrefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

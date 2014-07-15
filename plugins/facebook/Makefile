include theos/makefiles/common.mk

BUNDLE_NAME = FacebookPlugin FacebookPluginPrefs
FacebookPlugin_FILES = API/Facebook.m API/FBRequest.m \
					API/FBLoginDialog.m \
					API/FBDialog.m \
					API/SBJSON.m \
					API/SBJsonBase.m \
					API/SBJsonWriter.m \
					API/SBJsonParser.m \
					API/NSObject+SBJSON.m \
					API/NSString+SBJSON.m \
					FacebookPlugin.m \
					HSFacebookPluginView.m \
					HSFacebookQuickReply.m
FacebookPlugin_FRAMEWORKS = UIKit \
						CoreGraphics \
						CoreLocation \
						CoreFoundation \
						QuartzCore
FacebookPlugin_INSTALL_PATH = /Library/Application Support/Fusion/Plugins

FacebookPluginPrefs_FILES = API/Facebook.m \
						API/FBRequest.m \
						API/FBLoginDialog.m \
						API/FBDialog.m \
						API/SBJSON.m \
						API/SBJsonBase.m \
						API/SBJsonWriter.m \
						API/SBJsonParser.m \
						API/NSObject+SBJSON.m \
						API/NSString+SBJSON.m \
						HSFacebookPhotoAlbums.m \
						FacebookPluginPrefs.m \
						HSFacebookActivation.m
FacebookPluginPrefs_INSTALL_PATH = /Library/Application Support/Fusion/Plugins/FacebookPlugin.bundle
FacebookPluginPrefs_FRAMEWORKS = UIKit CoreGraphics
FacebookPluginPrefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

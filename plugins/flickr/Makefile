include theos/makefiles/common.mk

BUNDLE_NAME = Flickr FlickrPrefs
Flickr_FILES = Flickr.m
Flickr_FRAMEWORKS = UIKit CoreLocation
Flickr_INSTALL_PATH = /Library/Application Support/Fusion/Plugins

FlickrPrefs_FILES = FlickrPrefs.m HSNSData+Base64.m HSNSString+URLEncodeString.m HSPluginFlickrActivation.m HSPluginFlickrLogin.m
FlickrPrefs_INSTALL_PATH = /Library/Application Support/Fusion/Plugins/Flickr.bundle
FlickrPrefs_FRAMEWORKS = UIKit 
FlickrPrefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

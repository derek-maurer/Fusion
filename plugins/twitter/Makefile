include theos/makefiles/common.mk

BUNDLE_NAME = TwitterPluginPrefs TwitterPlugin

TwitterPlugin_FILES = TwitterPlugin.m TwitterQuickReply.m
TwitterPlugin_INSTALL_PATH = /Library/Application Support/Fusion/Plugins
TwitterPlugin_FRAMEWORKS = UIKit CoreLocation

TwitterPluginPrefs_FILES = TwitterPluginPrefs.m
TwitterPluginPrefs_INSTALL_PATH = /Library/Application Support/Fusion/Plugins/TwitterPlugin.bundle
TwitterPluginPrefs_FRAMEWORKS = UIKit
TwitterPluginPrefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

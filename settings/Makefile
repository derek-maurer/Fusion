include theos/makefiles/common.mk

BUNDLE_NAME = FusionSettings
FusionSettings_FILES = HSSwitch.m HSFusionSettings.m HSFusionSiriController.m HSFusionLegal.m HSPluginSettings.m HSTableCell.m HSQuickCompose.m HSSoundSettings.m HSFusionInfo.m HSExtrasController.m HSWebViewer.m HSNowPlayingEditor.m HSStringEditor.m HSTweetButtonLocationFiles.m HSTweetButtonLocationFiles.m HSTweetButtonLocationEditor.m HSTweetButtonLocation.m HSTweetButtonEditor.m HSContactBugsController.m HSContactFeatureController.m HSContactFeatureDetail.m HSContactController.m HSContactBugDetail.m HSPhotoUploadsController.m HSFlickrActivation.m HSNSData+Base64.m HSNSString+URLEncodeString.m HSFlickrLogin.m
FusionSettings_INSTALL_PATH = /Library/PreferenceBundles
FusionSettings_FRAMEWORKS = UIKit CoreGraphics
FusionSettings_PRIVATE_FRAMEWORKS = Preferences AppSupport AudioToolbox MessageUI

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/fusionsettings.plist$(ECHO_END)

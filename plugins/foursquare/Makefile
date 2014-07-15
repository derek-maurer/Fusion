include theos/makefiles/common.mk

BUNDLE_NAME = FoursquarePlugin FoursquarePluginPrefs
FoursquarePlugin_FILES = FoursquarePlugin.m HSFoursquarePluginView.m API/Foursquare2.m API/HRRestModel.m API/HRRequestOperation.m API/HRBase64.m API/HRFormatJSON.m API/HRFormatXML.m API/HROperationQueue.m API/DDXMLDocument.m API/DDXMLNode.m API/DDXMLElement.m API/HRGlobal.m API/SBJSON.m API/SBJsonBase.m API/SBJsonWriter.m API/SBJsonParser.m API/NSDictionary+ParamUtils.m API/NSObject+InvocationUtils.m API/NSObject+SBJSON.m API/NSString+EscapingUtils.m API/NSString+SBJSON.m API/NSStringAdditions.m API/BZFoursquare.m API/BZFoursquareRequest.m
FoursquarePlugin_OBJCFLAGS = -I"/usr/include/libxml2" -F"/usr/include/libxml2"
FoursquarePlugin_LDFLAGS=-lxml2
FoursquarePlugin_FRAMEWORKS = UIKit CoreGraphics CoreLocation MobileCoreServices
FoursquarePlugin_INSTALL_PATH = /Library/Application Support/Fusion/Plugins

FoursquarePluginPrefs_FILES = FoursquarePluginPrefs.m HSFoursquareLogin.m HSFoursquareActivation.m API/Foursquare2.m API/HRRestModel.m API/HRRequestOperation.m API/HRBase64.m API/HRFormatJSON.m API/HRFormatXML.m API/HROperationQueue.m API/DDXMLDocument.m API/DDXMLNode.m API/DDXMLElement.m API/HRGlobal.m API/SBJSON.m API/SBJsonBase.m API/SBJsonWriter.m API/SBJsonParser.m API/NSDictionary+ParamUtils.m API/NSObject+InvocationUtils.m API/NSObject+SBJSON.m API/NSString+EscapingUtils.m API/NSString+SBJSON.m API/NSStringAdditions.m
FoursquarePluginPrefs_OBJCFLAGS = -I"/usr/include/libxml2" -F"/usr/include/libxml2"
FoursquarePluginPrefs_LDFLAGS=-lxml2
FoursquarePluginPrefs_INSTALL_PATH = /Library/Application Support/Fusion/Plugins/FoursquarePlugin.bundle
FoursquarePluginPrefs_FRAMEWORKS = UIKit
FoursquarePluginPrefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk
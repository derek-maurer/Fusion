include theos/makefiles/common.mk

BUNDLE_NAME = linkedinplugin linkedinpluginPrefs
linkedinplugin_FILES = API/Base64Transcoder.c \
					API/hmac.c \
					API/LINSMutableURLRequest+Parameters.m \
					API/LINSString+URLEncoding.m \
					API/LINSURL+Base.m \
					API/LIOAAsynchronousDataFetcher.m \
					API/LIOAConsumer.m \
					API/LIOADataFetcher.m \
					API/LIOAHMAC_SHA1SignatureProvider.m \
					API/LIOAMutableURLRequest.m \
					API/LIOAPlaintextSignatureProvider.m \
					API/LIOARequestParameter.m \
					API/LIOAServiceTicket.m \
					API/LIOAToken.m \
					API/LIOAToken+storage.m \
					API/LIRDLinkedInAuthorizationController.m \
					API/LIRDLinkedInEngine.m \
					API/LIRDLinkedInHTTPURLConnection.m \
					API/LIRDLinkedInRequestBuilder.m \
					API/LIRDLinkedInResponseParser.m \
					API/sha1.c \
					HSLinkedInPlugin.m
linkedinplugin_FRAMEWORKS = UIKit CoreLocation Security CoreGraphics
linkedinplugin_OBJCFLAGS = -I$(SDKROOT)/usr/include/libxml2 -F$(SDKROOT)/usr/include/libxml2
linkedinplugin_LDFLAGS = -lxml2
linkedinplugin_INSTALL_PATH = /Library/Application Support/Fusion/Plugins

linkedinpluginPrefs_FILES =	API/Base64Transcoder.c \
						API/hmac.c \
						API/LINSMutableURLRequest+Parameters.m \
						API/LINSString+URLEncoding.m \
						API/LINSURL+Base.m \
						API/LIOAAsynchronousDataFetcher.m \
						API/LIOAConsumer.m \
						API/LIOADataFetcher.m \
						API/LIOAHMAC_SHA1SignatureProvider.m \
						API/LIOAMutableURLRequest.m \
						API/LIOAPlaintextSignatureProvider.m \
						API/LIOARequestParameter.m \
						API/LIOAServiceTicket.m \
						API/LIOAToken.m \
						API/LIOAToken+storage.m \
						API/LIRDLinkedInAuthorizationController.m \
						API/LIRDLinkedInEngine.m \
						API/LIRDLinkedInHTTPURLConnection.m \
						API/LIRDLinkedInRequestBuilder.m \
						API/LIRDLinkedInResponseParser.m \
						API/sha1.c \
						HSLinkedInActivation.m \
						HSLinkedInPluginPrefs.m
linkedinpluginPrefs_INSTALL_PATH = /Library/Application Support/Fusion/Plugins/linkedinplugin.bundle
linkedinpluginPrefs_OBJCFLAGS = -I$(SDKROOT)/usr/include/libxml2 -F$(SDKROOT)/usr/include/libxml2
linkedinpluginPrefs_LDFLAGS = -lxml2
linkedinpluginPrefs_FRAMEWORKS = UIKit Security CoreGraphics
linkedinpluginPrefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

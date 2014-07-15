include theos/makefiles/common.mk

TWEAK_NAME = Fusion FusionActivator
Fusion_FILES = TwitPic/http/ASICloudFilesCDNRequest.m \
			TwitPic/http/ASICloudFilesContainer.m \
			TwitPic/http/ASICloudFilesContainerRequest.m \
			TwitPic/http/ASICloudFilesContainerXMLParserDelegate.m \
			TwitPic/http/ASICloudFilesObject.m \
			TwitPic/http/ASICloudFilesObjectRequest.m \
			TwitPic/http/ASICloudFilesRequest.m \
			TwitPic/http/ASINetworkQueue.m \
			TwitPic/http/ASIHTTPRequest.m \
			TwitPic/http/ASIFormDataRequest.m \
			TwitPic/http/ASIDownloadCache.m \
			TwitPic/oauthconsumer/NSString+URLEncoding.m \
			TwitPic/http/ASIS3Bucket.m \
			TwitPic/http/ASIS3ObjectRequest.m \
			TwitPic/http/ASIS3BucketObject.m \
			TwitPic/http/ASIS3BucketRequest.m \
			TwitPic/http/ASIS3Request.m \
			TwitPic/http/ASIS3ServiceRequest.m \
			TwitPic/http/ASIWebPageRequest.m \
			TwitPic/oauthconsumer/NSURL+Base.m \
			TwitPic/oauthconsumer/NSMutableURLRequest+Parameters.m \
			TwitPic/oauthconsumer/OAConsumer.m \
			TwitPic/oauthconsumer/OARequestHeader.m \
			TwitPic/TOUCHJSON/CJSONDeserializer.m \
			TwitPic/oauthconsumer/OAToken.m \
			TwitPic/oauthconsumer/OATokenManager.m \
			TwitPic/http/ASIDataDecompressor.m \
			TwitPic/http/ASIAuthenticationDialog.m \
			TwitPic/http/Reachability.m \
			TwitPic/http/ASIDataCompressor.m \
			TwitPic/http/ASIInputStream.m \
			TwitPic/oauthconsumer/OAHMAC_SHA1SignatureProvider.m \
			TwitPic/oauthconsumer/OAAttachment.m \
			TwitPic/oauthconsumer/OAMutableURLRequest.m \
			TwitPic/oauthconsumer/OAPlaintextSignatureProvider.m \
			TwitPic/oauthconsumer/OAProblem.m \
			TwitPic/oauthconsumer/OAServiceTicket.m \
			TwitPic/oauthconsumer/OADataFetcher.m \
			TwitPic/oauthconsumer/OACall.m \
			TwitPic/oauthconsumer/OARequestParameter.m \
			TwitPic/TOUCHJSON/CJSONScanner.m \
			TwitPic/TOUCHJSON/CJSONSerialization.m \
			TwitPic/TOUCHJSON/CJSONSerializedData.m \
			TwitPic/TOUCHJSON/CJSONSerializer.m \
			TwitPic/TOUCHJSON/CDataScanner.m \
			TwitPic/TOUCHJSON/CFilteringJSONSerializer.m \
			TwitPic/TOUCHJSON/CJSONScanner.m \
			TwitPic/TOUCHJSON/CDataScanner_Extensions.m \
			TwitPic/TOUCHJSON/CJSONDeserializer_BlocksExtensions.m \
			TwitPic/TOUCHJSON/NSDictionary_JSONExtensions.m \
			TwitPic/oauthconsumer/hmac.c \
			TwitPic/oauthconsumer/sha1.c \
			TwitPic/oauthconsumer/Base64Transcoder.c \
			TwitPic/GSTwitPicEngine.m \
			HSTweakPastie.m \
			DRM.mm \
			FusionController.xm \
			FusionHooks.xm \
			HSMenu.m \
			HSFrame.m \
			HSButton.m \
			HSPlugin.m \
			HSPluginView.m \
			HSReachability.m
Fusion_OBJCFLAGS = -I$(THEOS_PROJECT_DIR) -F$(THEOS_PROJECT_DIR) -ITwitPic/oauthconsumer -FTwitPic/oauthconsumer -ITwitPic/http -FTwitPic/http -ITwitPic/TOUCHJSON -FTwitPic/TOUCHJSON -I/usr/include/libxml2 -F/usr/include/libxml2
Fusion_LDFLAGS = -lz -lxml2 -lactivator 
Fusion_FRAMEWORKS = UIKit \
				CoreGraphics \
				CoreLocation \
				Foundation \
				QuartzCore \
				SystemConfiguration \
				MobileCoreServices \
				CoreGraphics \
				CFNetwork \
				Accounts \
				MediaPlayer \
				Security \
				AudioToolbox \
				AssetsLibrary
Fusion_PRIVATE_FRAMEWORKS = AppSupport

FusionActivator_FILES = FusionActivator.xm
FusionActivator_FRAMEWORKS = UIKit
FusionActivator_LDFLAGS = -lactivator

#Daemon...
TOOL_NAME = fusiond
fusiond_FILES = FusionServer.m ArrayValue.m HSPastie.m HSConPlugin.m HSFusiond.m Flickr/HSFlickr.m Flickr/LFHTTPRequest.m Flickr/LFSiteReachability.m Flickr/NSData+LFHTTPFormExtensions.m Flickr/ObjectiveFlickr.m Flickr/OFUtilities.m Flickr/OFXMLMapper.m HSPluginController.m
fusiond_OBJCFLAGS = -I$(THEOS_PROJECT_DIR) -F$(THEOS_PROJECT_DIR)
fusiond_FRAMEWORKS = CoreFoundation Foundation UIKit CoreGraphics AudioToolbox CoreLocation SystemConfiguration CFNetwork
fusiond_PRIVATE_FRAMEWORKS = AppSupport

include $(THEOS_MAKE_PATH)/tool.mk
include $(THEOS_MAKE_PATH)/tweak.mk


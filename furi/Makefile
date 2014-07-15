include theos/makefiles/common.mk

BUNDLE_NAME = Furi
Furi_BUNDLE_EXTENSION = assistantExtension
Furi_FILES = HSFuri.mm HSFuriCommands.xm ArrayValue.m
Furi_INSTALL_PATH = /Library/AssistantExtensions
Furi_FRAMEWORKS = UIKit CoreGraphics Twitter AssetsLibrary

include $(THEOS_MAKE_PATH)/bundle.mk

after-install::
	install.exec "killall -9 SpringBoard"

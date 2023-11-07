export TARGET = iphone:clang:14.5:14.5
INSTALL_TARGET_PROCESSES = SpringBoard
ARCHS = arm64 arm64e
GO_EASY_ON_ME = 1
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LowerNotifs

LowerNotifs_FILES = Tweak.x
LowerNotifs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += lowernotifsprefs
include $(THEOS_MAKE_PATH)/aggregate.mk

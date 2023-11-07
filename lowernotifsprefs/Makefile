export TARGET = iphone:clang:14.5:14.5
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = LowerNotifsPrefs

LowerNotifsPrefs_FILES = LNPRootListController.m
LowerNotifsPrefs_FRAMEWORKS = UIKit
LowerNotifsPrefs_PRIVATE_FRAMEWORKS = Preferences
LowerNotifsPrefs_INSTALL_PATH = /Library/PreferenceBundles
LowerNotifsPrefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

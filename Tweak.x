#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <rootless.h>

@interface NCNotificationListView : UIScrollView
@end

@interface CSNotificationAdjunctListViewController : UIViewController
@end

@interface NCNotificationStructuredListViewController : UIViewController
@property (nonatomic, strong, readwrite) NCNotificationListView *masterListView;
@end

@interface CSMainPageContentViewController
-(id)_mainPageView;
@end

@interface CSQuickActionsView : UIView
@end

@interface CSAdjunctListView : UIView
@end

@interface CSAdjunctItemView : UIView
@end

NSMutableDictionary* mainPreferenceDict;
BOOL isTweakEnabled;
CGFloat maxNotifHeightPoint;
CSQuickActionsView *quickActionsView = nil;
BOOL isCreateBlurLine;
BOOL isQuickButtonsFade;
BOOL maxNotifZero = NO;

//UIView *sectionListView = nil;
#define GENERAL_PREFS ROOT_PATH_NS(@"/var/mobile/Library/Preferences/com.0xkuj.lowernotifprefs.plist")
#define CONSTANT_PADDING_FROM_TOP 180
#define CONSTANT_PADDING_FROM_BOTTOM 80

static void loadPrefs() {
    mainPreferenceDict = nil;
    mainPreferenceDict = [[NSMutableDictionary alloc] initWithContentsOfFile:GENERAL_PREFS];
    isTweakEnabled = [mainPreferenceDict objectForKey:@"isTweakEnabled"] ? [[mainPreferenceDict objectForKey:@"isTweakEnabled"] boolValue] : YES;
	if ([mainPreferenceDict objectForKey:@"maxPointNotifications"] != nil) {
		maxNotifHeightPoint = [[mainPreferenceDict objectForKey:@"maxPointNotifications"] floatValue];
	} else {
		maxNotifHeightPoint = 0.0f;
	}
	isCreateBlurLine = [mainPreferenceDict objectForKey:@"isCreateBlurLine"] ? [[mainPreferenceDict objectForKey:@"isCreateBlurLine"] boolValue] : YES;
    isQuickButtonsFade = [mainPreferenceDict objectForKey:@"isQuickButtonsFade"] ? [[mainPreferenceDict objectForKey:@"isQuickButtonsFade"] boolValue] : YES;

}

@interface LNPScrollView : UIScrollView 
@property (nonatomic, strong) UIVisualEffectView *blurEffectView;
- (instancetype)initWithMasterListView:(NCNotificationListView *)masterListView maxNotificationHeight:(CGFloat)maxNotifHeightPoint;
- (void)createAndAddBlurredLineViewForScrollView;
@end

@implementation LNPScrollView
- (instancetype)initWithMasterListView:(NCNotificationListView *)masterListView maxNotificationHeight:(CGFloat)maxNotifHeightPoint {
    self = [super initWithFrame:CGRectMake(0, maxNotifHeightPoint, masterListView.frame.size.width, masterListView.frame.size.height - maxNotifHeightPoint)];
    return self;
}

- (void)createAndAddBlurredLineViewForScrollView {
    UIBezierPath *roundedPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.frame.size.width, 10) byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = roundedPath.CGPath;
    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
    self.blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    self.blurEffectView.frame = CGRectMake(0, -1, self.frame.size.width, 10); // Change the height as needed
    self.blurEffectView.layer.mask = shapeLayer;
	self.blurEffectView.alpha = 0;
	[self addSubview:self.blurEffectView];
    return;
}

- (void)toggleBlurEffectIfNeeded:(CGFloat)contentOffsetY {
    if (contentOffsetY >= 20 && self.blurEffectView.alpha == 0) {
        [UIView transitionWithView:self.blurEffectView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
			if (isCreateBlurLine) {
				self.blurEffectView.alpha = 1;
			}
			if (quickActionsView != nil && isQuickButtonsFade) {
				quickActionsView.alpha = 0;
			}
        } completion:nil];
    } else if (contentOffsetY < 20 && self.blurEffectView.alpha == 1) {
        [UIView transitionWithView:self.blurEffectView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
			if (isCreateBlurLine) {
            	self.blurEffectView.alpha = 0;
			}
			if (quickActionsView != nil && isQuickButtonsFade) {
				quickActionsView.alpha = 1;
			}	
        } completion:nil];
    }
}

// this doesnt work well when i spread out notifications. it will need to go even deeper in the tree and i dont like it.
// - (void)fadeNotificationBox:(NSArray *)subviewsOfNotification offset:(CGFloat)contentOffsetY {
// 	for (int i = subviewsOfNotification.count-1; i >= 0; i--) {
// 		UIView* firstIterationObj = subviewsOfNotification[i];
// 		if ([firstIterationObj isKindOfClass:NSClassFromString(@"NCNotificationListView")]) {
// 			for (int j = firstIterationObj.subviews.count-1; j >= 0; j--) {
// 				UIView* secondIterationObj = firstIterationObj.subviews[j];
// 				if ([secondIterationObj isKindOfClass:NSClassFromString(@"NCNotificationListView")]) {
// 					//start hiding according to offset.
// 					CGFloat isFrameShouldDis = 0;
// 					if (secondIterationObj.frame.size.height <= 135) {
// 						isFrameShouldDis = 80;
// 					} else if (secondIterationObj.frame.size.height > 135 && secondIterationObj.frame.size.height < 160) {
// 						isFrameShouldDis = 40;
// 					} else if (secondIterationObj.frame.size.height >= 160) {
// 						isFrameShouldDis = 20;
// 					} 

// 					if (contentOffsetY >= 5) {
// 						secondIterationObj.hidden = YES;
// 						break;	
// 					} else {
// 						secondIterationObj.hidden = NO;
// 						break;
// 					}
// 				}
// 			}
// 		}
// 	}
// }
@end

LNPScrollView *lnpScrollView = nil;

%group tweakEnabledGroup
%hook UIView
- (void)setFrame:(CGRect)arg1 {
	if ([self isKindOfClass:NSClassFromString(@"CSAdjunctListView")]) {
		CGRect stam = CGRectMake(arg1.origin.x, arg1.origin.y+maxNotifHeightPoint, arg1.size.width, arg1.size.height);
		%orig(stam);
		return;
	}
	%orig(arg1);
}
%end

%hook CSQuickActionsViewController
- (id)quickActionsViewIfLoaded {
	CSQuickActionsView *orig = %orig;
	if (orig != nil) {
		quickActionsView = orig;
	}
	return orig;
}
%end

%hook CSCombinedListViewController
-(UIEdgeInsets)_listViewDefaultContentInsets {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		lnpScrollView.delegate = (id<UIScrollViewDelegate>)self;
	});

    UIEdgeInsets orig = %orig;
    orig.top -= CONSTANT_PADDING_FROM_TOP;
    return orig;
}

-(id)notificationListViewController {
	NCNotificationStructuredListViewController *orig = %orig;
	orig.masterListView.frame = CGRectMake(orig.masterListView.frame.origin.x, orig.masterListView.frame.origin.y, orig.masterListView.frame.size.width ,[[UIScreen mainScreen] bounds].size.height - maxNotifHeightPoint - CONSTANT_PADDING_FROM_BOTTOM);
	return orig;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	%orig;
	[lnpScrollView toggleBlurEffectIfNeeded:scrollView.contentOffset.y];
	//[lnpScrollView fadeNotificationBox:lnpScrollView.subviews[0].subviews offset:scrollView.contentOffset.y];
}
%end

%hook NCNotificationStructuredListViewController
- (void)viewDidLoad {
    %orig;
	lnpScrollView = [[LNPScrollView alloc] initWithMasterListView:self.masterListView maxNotificationHeight:maxNotifHeightPoint];
	[self.masterListView removeFromSuperview];
	[lnpScrollView addSubview:self.masterListView];
	[lnpScrollView createAndAddBlurredLineViewForScrollView];
	[self.view addSubview:lnpScrollView];
}
%end
%end

%ctor {
    loadPrefs();
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.0xkuj.lowernotifprefs.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	if (isTweakEnabled && maxNotifHeightPoint > 0.0) {
		%init(tweakEnabledGroup)
	}
}
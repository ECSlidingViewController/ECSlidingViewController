//
//  ECSlidingViewController.m
//  ECSlidingViewController
//
//  Created by Michael Enriquez on 1/23/12.
//  Copyright (c) 2012 EdgeCase. All rights reserved.
//

#import "ECSlidingViewController.h"

NSString *const ECSlidingViewUnderRightWillAppear    = @"ECSlidingViewUnderRightWillAppear";
NSString *const ECSlidingViewUnderLeftWillAppear     = @"ECSlidingViewUnderLeftWillAppear";
NSString *const ECSlidingViewUnderLeftWillDisappear  = @"ECSlidingViewUnderLeftWillDisappear";
NSString *const ECSlidingViewUnderRightWillDisappear = @"ECSlidingViewUnderRightWillDisappear";
NSString *const ECSlidingViewTopDidAnchorLeft        = @"ECSlidingViewTopDidAnchorLeft";
NSString *const ECSlidingViewTopDidAnchorRight       = @"ECSlidingViewTopDidAnchorRight";
NSString *const ECSlidingViewTopWillReset            = @"ECSlidingViewTopWillReset";
NSString *const ECSlidingViewTopDidReset             = @"ECSlidingViewTopDidReset";

@interface ECSlidingViewController ()

@property (nonatomic, strong) UIView *topViewSnapshot;
@property (nonatomic, assign) CGFloat initialTouchPositionX;
@property (nonatomic, assign) CGFloat initialHorizontalCenter;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *snapshotPanGesture;
@property (nonatomic, strong) UITapGestureRecognizer *resetTapGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *topViewSnapshotPanGesture;
@property (nonatomic, assign) BOOL underLeftShowing;
@property (nonatomic, assign) BOOL underRightShowing;
@property (nonatomic, assign) BOOL topViewIsOffScreen;

- (void)setup;
- (NSUInteger)autoResizeToFillScreen;
- (UIView *)topView;
- (UIView *)underLeftView;
- (UIView *)underRightView;
- (void)adjustLayout;
- (void)updateTopViewHorizontalCenterWithRecognizer:(UIPanGestureRecognizer *)recognizer;
- (void)updateTopViewHorizontalCenter:(CGFloat)newHorizontalCenter;
- (void)topViewHorizontalCenterWillChange:(CGFloat)newHorizontalCenter;
- (void)topViewHorizontalCenterDidChange:(CGFloat)newHorizontalCenter;
- (void)addTopViewSnapshot;
- (void)removeTopViewSnapshot;
- (CGFloat)anchorRightTopViewCenter;
- (CGFloat)anchorLeftTopViewCenter;
- (CGFloat)resettedCenter;
- (CGRect)fullViewBounds;
- (void)underLeftWillAppear;
- (void)underRightWillAppear;
- (void)topDidReset;
- (BOOL)topViewHasFocus;
- (void)updateUnderLeftLayout;
- (void)updateUnderRightLayout;

@end

@implementation UIViewController(SlidingViewExtension)

- (ECSlidingViewController *)slidingViewController
{
    UIViewController *viewController = self.parentViewController ? self.parentViewController : self.presentingViewController;
    while (! (viewController == nil || [viewController isKindOfClass:[ECSlidingViewController class]])) {
        viewController = viewController.parentViewController ?: viewController.presentingViewController;
    }
    return (ECSlidingViewController *)viewController;
}

@end

@implementation ECSlidingViewController

- (id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.shouldAllowPanningPastAnchor = YES;
    self.shouldAllowUserInteractionsWhenAnchored = NO;
    self.shouldAddPanGestureRecognizerToTopViewSnapshot = NO;
    self.shouldAdjustChildViewHeightForStatusBar = NO;
    self.resetTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetTopView)];
    _panGesture          = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(updateTopViewHorizontalCenterWithRecognizer:)];
    self.resetTapGesture.enabled = NO;
    self.resetStrategy = ECTapping | ECPanning;
    self.panningVelocityXThreshold = 100;

    self.topViewSnapshot = [[UIView alloc] initWithFrame:CGRectZero];
    [self.topViewSnapshot setAutoresizingMask:self.autoResizeToFillScreen];
    [self.topViewSnapshot addGestureRecognizer:self.resetTapGesture];
}

- (void)setTopViewController:(UIViewController *)theTopViewController
{
    CGRect topViewFrame = _topViewController ? _topViewController.view.frame : [self fullViewBounds];

    [self removeTopViewSnapshot];
    [_topViewController.view removeFromSuperview];
    [_topViewController willMoveToParentViewController:nil];
    [_topViewController removeFromParentViewController];

    _topViewController = theTopViewController;

    [self addChildViewController:self.topViewController];
    [self.topViewController didMoveToParentViewController:self];

    [_topViewController.view setAutoresizingMask:self.autoResizeToFillScreen];
    [_topViewController.view setFrame:topViewFrame];
    _topViewController.view.layer.shadowOffset = CGSizeZero;
    _topViewController.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:[self fullViewBounds]].CGPath;

    [self.view insertSubview:_topViewController.view belowSubview:self.statusBarBackgroundView];
    self.topViewSnapshot.frame = self.topView.bounds;
}

- (void)setUnderLeftViewController:(UIViewController *)theUnderLeftViewController
{
    [_underLeftViewController.view removeFromSuperview];
    [_underLeftViewController willMoveToParentViewController:nil];
    [_underLeftViewController removeFromParentViewController];

    _underLeftViewController = theUnderLeftViewController;

    if (_underLeftViewController) {
        [self addChildViewController:self.underLeftViewController];
        [self.underLeftViewController didMoveToParentViewController:self];

        [self updateUnderLeftLayout];
    }
}

- (void)setUnderRightViewController:(UIViewController *)theUnderRightViewController
{
    [_underRightViewController.view removeFromSuperview];
    [_underRightViewController willMoveToParentViewController:nil];
    [_underRightViewController removeFromParentViewController];

    _underRightViewController = theUnderRightViewController;

    if (_underRightViewController) {
        [self addChildViewController:self.underRightViewController];
        [self.underRightViewController didMoveToParentViewController:self];

        [self updateUnderRightLayout];
    }
}

- (void)setUnderLeftWidthLayout:(ECViewWidthLayout)underLeftWidthLayout
{
    if (underLeftWidthLayout == ECVariableRevealWidth && self.anchorRightPeekAmount <= 0.0f) {
        [NSException raise:@"Invalid Width Layout" format:@"anchorRightPeekAmount must be set"];
    } else if (underLeftWidthLayout == ECFixedRevealWidth && self.anchorRightRevealAmount <= 0.0f) {
        [NSException raise:@"Invalid Width Layout" format:@"anchorRightRevealAmount must be set"];
    }
    _underLeftWidthLayout = underLeftWidthLayout;
}

- (void)setUnderRightWidthLayout:(ECViewWidthLayout)underRightWidthLayout
{
    if (underRightWidthLayout == ECVariableRevealWidth && self.anchorLeftPeekAmount <= 0.0f) {
        [NSException raise:@"Invalid Width Layout" format:@"anchorLeftPeekAmount must be set"];
    } else if (underRightWidthLayout == ECFixedRevealWidth && self.anchorLeftRevealAmount <= 0.0f) {
        [NSException raise:@"Invalid Width Layout" format:@"anchorLeftRevealAmount must be set"];
    }
    _underRightWidthLayout = underRightWidthLayout;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self adjustLayout];
    self.topView.layer.shadowOffset = CGSizeZero;
    self.topView.layer.shadowPath = [UIBezierPath bezierPathWithRect:[self fullViewBounds]].CGPath;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    self.topView.layer.shadowPath = nil;
    self.topView.layer.shouldRasterize = YES;

    if (! [self topViewHasFocus]) {
        [self removeTopViewSnapshot];
    }

    [self adjustLayout];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    self.topView.layer.shadowPath = [UIBezierPath bezierPathWithRect:[self fullViewBounds]].CGPath;
    self.topView.layer.shouldRasterize = NO;

    if (! [self topViewHasFocus]) {
        [self addTopViewSnapshot];
    }
}

- (void)setResetStrategy:(ECResetStrategy)theResetStrategy
{
    _resetStrategy = theResetStrategy;
    if (_resetStrategy & ECTapping) {
        self.resetTapGesture.enabled = YES;
    } else {
        self.resetTapGesture.enabled = NO;
    }
}

- (void)adjustLayout
{
    self.topViewSnapshot.frame = self.topView.bounds;

    if ([self underRightShowing] && ! [self topViewIsOffScreen]) {
        [self updateUnderRightLayout];
        self.topViewController.view.frame = [self fullViewBounds];
        [self updateTopViewHorizontalCenter:self.anchorLeftTopViewCenter];

    } else if ([self underRightShowing] && [self topViewIsOffScreen]) {
        [self updateUnderRightLayout];
        self.topViewController.view.frame = [self fullViewBounds];
        [self updateTopViewHorizontalCenter:-self.resettedCenter];

    } else if ([self underLeftShowing] && ! [self topViewIsOffScreen]) {
        [self updateUnderLeftLayout];
        self.topViewController.view.frame = [self fullViewBounds];
        [self updateTopViewHorizontalCenter:self.anchorRightTopViewCenter];

    } else if ([self underLeftShowing] && [self topViewIsOffScreen]) {
        [self updateUnderLeftLayout];
        self.topViewController.view.frame = [self fullViewBounds];
        [self updateTopViewHorizontalCenter:CGRectGetWidth(self.view.bounds) + self.resettedCenter];

    } else {
        self.topViewController.view.frame = [self fullViewBounds];
    }
}

- (void)updateTopViewHorizontalCenterWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
    CGPoint currentTouchPoint     = [recognizer locationInView:self.view];
    CGFloat currentTouchPositionX = currentTouchPoint.x;

    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.initialTouchPositionX = currentTouchPositionX;
        self.initialHorizontalCenter = self.topView.center.x;

    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat panAmount = self.initialTouchPositionX - currentTouchPositionX;
        CGFloat newCenterPosition = self.initialHorizontalCenter - panAmount;

        if ((newCenterPosition < self.resettedCenter && (self.anchorLeftTopViewCenter == NSNotFound || self.underRightViewController == nil)) ||
            (newCenterPosition > self.resettedCenter && (self.anchorRightTopViewCenter == NSNotFound || self.underLeftViewController == nil))) {
            newCenterPosition = self.resettedCenter;
        }

        BOOL newCenterPositionIsOutsideAnchor = (self.anchorLeftTopViewCenter != NSNotFound && newCenterPosition < self.anchorLeftTopViewCenter) ||
        (self.anchorRightTopViewCenter != NSNotFound && self.anchorRightTopViewCenter < newCenterPosition);

        if ((newCenterPositionIsOutsideAnchor && self.shouldAllowPanningPastAnchor) || !newCenterPositionIsOutsideAnchor) {
            [self topViewHorizontalCenterWillChange:newCenterPosition];
            [self updateTopViewHorizontalCenter:newCenterPosition];
            [self topViewHorizontalCenterDidChange:newCenterPosition];
        }

    } else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        CGPoint currentVelocityPoint = [recognizer velocityInView:self.view];
        CGFloat currentVelocityX     = currentVelocityPoint.x;
        BOOL viewIsPastAnchor = (self.anchorLeftTopViewCenter != NSNotFound && self.topView.layer.position.x <= self.anchorLeftTopViewCenter) ||
        (self.anchorRightTopViewCenter != NSNotFound && self.topView.layer.position.x >= self.anchorRightTopViewCenter);

        if ([self underLeftShowing] && (viewIsPastAnchor || currentVelocityX > self.panningVelocityXThreshold)) {
            [self anchorTopViewTo:ECRight];
        } else if ([self underRightShowing] && (viewIsPastAnchor || -currentVelocityX > self.panningVelocityXThreshold)) {
            [self anchorTopViewTo:ECLeft];
        } else {
            [self resetTopView];
        }
    }
}

- (UIView *)statusBarBackgroundView
{
    if (! _statusBarBackgroundView) {
        CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;

        if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
            CGFloat width = CGRectGetHeight(statusBarFrame);
            CGFloat height = CGRectGetWidth(statusBarFrame);
            statusBarFrame.size.width = width;
            statusBarFrame.size.height = height;
        }

        _statusBarBackgroundView = [[UIView alloc] initWithFrame:statusBarFrame];
        _statusBarBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        _statusBarBackgroundView.userInteractionEnabled = NO;
        [self.view addSubview:_statusBarBackgroundView];
    }
    return _statusBarBackgroundView;
}

- (UIPanGestureRecognizer *)panGesture
{
    return _panGesture;
}

- (void)anchorTopViewTo:(ECSide)side
{
    [self anchorTopViewTo:side animations:nil onComplete:nil];
}

- (void)anchorTopViewTo:(ECSide)side animations:(void (^)())animations onComplete:(void (^)())complete
{
    CGFloat newCenter = self.topView.center.x;

    if (side == ECLeft) {
        newCenter = self.anchorLeftTopViewCenter;
    } else if (side == ECRight) {
        newCenter = self.anchorRightTopViewCenter;
    }

    [self topViewHorizontalCenterWillChange:newCenter];

    [UIView animateWithDuration:0.25f animations:^{
        if (animations) animations();
        [self updateTopViewHorizontalCenter:newCenter];
    } completion:^(BOOL finished) {
        [self updateTopViewHorizontalCenter:newCenter];
        if (_resetStrategy & ECPanning) {
            self.panGesture.enabled = YES;
        } else {
            self.panGesture.enabled = NO;
        }
        if (complete) complete();
        UIView *view = nil;
        if (side == ECLeft) {
            view = self.underRightView;
        } else if (side == ECRight) {
            view = self.underLeftView;
        }
        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, view);
        _topViewIsOffScreen = NO;
        [self addTopViewSnapshot];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *key = (side == ECLeft) ? ECSlidingViewTopDidAnchorLeft : ECSlidingViewTopDidAnchorRight;
            [[NSNotificationCenter defaultCenter] postNotificationName:key object:self userInfo:nil];
        });
    }];
}

- (void)anchorTopViewOffScreenTo:(ECSide)side
{
    [self anchorTopViewOffScreenTo:side animations:nil onComplete:nil];
}

- (void)anchorTopViewOffScreenTo:(ECSide)side animations:(void(^)())animations onComplete:(void(^)())complete
{
    CGFloat newCenter = self.topView.center.x;

    if (side == ECLeft) {
        newCenter = -self.resettedCenter;
    } else if (side == ECRight) {
        newCenter = CGRectGetWidth(self.view.bounds) + self.resettedCenter;
    }

    [self topViewHorizontalCenterWillChange:newCenter];

    [UIView animateWithDuration:0.25f animations:^{
        if (animations) animations();
        [self updateTopViewHorizontalCenter:newCenter];
    } completion:^(BOOL finished) {
        [self updateTopViewHorizontalCenter:newCenter];
        if (complete) complete();
        UIView *view = nil;
        if (side == ECLeft) {
            view = self.underRightView;
        } else if (side == ECRight) {
            view = self.underLeftView;
        }
        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, view);
        _topViewIsOffScreen = YES;
        [self addTopViewSnapshot];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *key = (side == ECLeft) ? ECSlidingViewTopDidAnchorLeft : ECSlidingViewTopDidAnchorRight;
            [[NSNotificationCenter defaultCenter] postNotificationName:key object:self userInfo:nil];
        });
    }];
}

- (void)resetTopView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:ECSlidingViewTopWillReset object:self userInfo:nil];
    });
    [self resetTopViewWithAnimations:nil onComplete:nil];
}

- (void)resetTopViewWithAnimations:(void(^)())animations onComplete:(void(^)())complete
{
    [self topViewHorizontalCenterWillChange:self.resettedCenter];

    [UIView animateWithDuration:0.25f animations:^{
        if (animations) animations();
        [self updateTopViewHorizontalCenter:self.resettedCenter];
    } completion:^(BOOL finished) {
        [self updateTopViewHorizontalCenter:self.resettedCenter];
        if (complete) complete();
        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, self.topView);
        [self topViewHorizontalCenterDidChange:self.resettedCenter];
    }];
}

- (NSUInteger)autoResizeToFillScreen
{
    return (UIViewAutoresizingFlexibleWidth |
            UIViewAutoresizingFlexibleHeight |
            UIViewAutoresizingFlexibleTopMargin |
            UIViewAutoresizingFlexibleBottomMargin |
            UIViewAutoresizingFlexibleLeftMargin |
            UIViewAutoresizingFlexibleRightMargin);
}

- (UIView *)topView
{
    return self.topViewController.view;
}

- (UIView *)underLeftView
{
    return self.underLeftViewController.view;
}

- (UIView *)underRightView
{
    return self.underRightViewController.view;
}

- (void)updateTopViewHorizontalCenter:(CGFloat)newHorizontalCenter
{
    CGPoint center = self.topView.center;
    center.x = newHorizontalCenter;
    self.topView.layer.position = center;
    self.topViewSnapshot.frame = self.topView.frame;
    if (self.topViewCenterMoved) self.topViewCenterMoved(newHorizontalCenter);
}

- (void)topViewHorizontalCenterWillChange:(CGFloat)newHorizontalCenter
{
    CGPoint center = self.topView.center;

	if (center.x >= self.resettedCenter && newHorizontalCenter == self.resettedCenter) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[[NSNotificationCenter defaultCenter] postNotificationName:ECSlidingViewUnderLeftWillDisappear object:self userInfo:nil];
		});
	}

	if (center.x <= self.resettedCenter && newHorizontalCenter == self.resettedCenter) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[[NSNotificationCenter defaultCenter] postNotificationName:ECSlidingViewUnderRightWillDisappear object:self userInfo:nil];
		});
	}

    if (center.x <= self.resettedCenter && newHorizontalCenter > self.resettedCenter) {
        [self underLeftWillAppear];
    } else if (center.x >= self.resettedCenter && newHorizontalCenter < self.resettedCenter) {
        [self underRightWillAppear];
    }
}

- (void)topViewHorizontalCenterDidChange:(CGFloat)newHorizontalCenter
{
    if (newHorizontalCenter == self.resettedCenter) {
        [self topDidReset];
    }
}

- (void)addTopViewSnapshot
{
    if (! self.topViewSnapshot.superview && !self.shouldAllowUserInteractionsWhenAnchored) {

        if (self.shouldAddPanGestureRecognizerToTopViewSnapshot) {
            self.snapshotPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(updateTopViewHorizontalCenterWithRecognizer:)];
            [self.topViewSnapshot addGestureRecognizer:self.snapshotPanGesture];
        }

        self.topViewSnapshot.frame = self.topView.frame;
        [self.view addSubview:self.topViewSnapshot];
        self.topView.userInteractionEnabled = NO;
    }
}

- (void)removeTopViewSnapshot
{
    if (self.topViewSnapshot.superview) {
        self.topViewSnapshotPanGesture = nil;
        self.snapshotPanGesture = nil;
        [self.topViewSnapshot removeFromSuperview];
        self.topView.userInteractionEnabled = YES;
    }
}

- (CGFloat)anchorRightTopViewCenter
{
    if (self.anchorRightPeekAmount) {
        return CGRectGetWidth(self.view.bounds) + self.resettedCenter - self.anchorRightPeekAmount;

    } else if (self.anchorRightRevealAmount) {
        return self.resettedCenter + self.anchorRightRevealAmount;

    } else {
        return NSNotFound;
    }
}

- (CGFloat)anchorLeftTopViewCenter
{
    if (self.anchorLeftPeekAmount) {
        return -self.resettedCenter + self.anchorLeftPeekAmount;

    } else if (self.anchorLeftRevealAmount) {
        return -self.resettedCenter + (CGRectGetWidth(self.view.bounds) - self.anchorLeftRevealAmount);

    } else {
        return NSNotFound;
    }
}

- (CGFloat)resettedCenter
{
    return (CGRectGetWidth(self.view.bounds) / 2.0f);
}

- (CGRect)fullViewBounds
{
    CGFloat statusBarHeight = 0.0f;

    /**
     Enable legacy screen height support if we are running on an SDK prior to iOS 7
     and thus does not support the backgroundRefreshStatus selector on
     UIApplication, which was introduced in iOS 7
     */
    UIApplication *sharedApplication = [UIApplication sharedApplication];
    BOOL legacyScreenHeightEnabled = ![sharedApplication respondsToSelector:@selector(backgroundRefreshStatus)];

    if (self.shouldAdjustChildViewHeightForStatusBar || legacyScreenHeightEnabled) {
        statusBarHeight = sharedApplication.statusBarFrame.size.height;
        if (UIInterfaceOrientationIsLandscape(sharedApplication.statusBarOrientation)) {
            statusBarHeight = sharedApplication.statusBarFrame.size.width;
        }
    }

    CGRect bounds = [UIScreen mainScreen].bounds;

    if (UIInterfaceOrientationIsLandscape(sharedApplication.statusBarOrientation)) {
        CGFloat height = CGRectGetWidth(bounds);
        CGFloat width  = CGRectGetHeight(bounds);
        bounds.size.height = height;
        bounds.size.width  = width;
    }

    if (! legacyScreenHeightEnabled) {
        // In iOS <= 6.1 the container view is already offset below the status bar.
        // so no need to offset it if we use shouldAdjustChildViewHeightForStatusBar in iOS 7+.
        bounds.origin.y += statusBarHeight;
    }

    bounds.size.height -= statusBarHeight;

    return bounds;
}

- (void)underLeftWillAppear
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:ECSlidingViewUnderLeftWillAppear object:self userInfo:nil];
    });
    [self.underRightView removeFromSuperview];
    [self updateUnderLeftLayout];
    [self.view insertSubview:self.underLeftView belowSubview:self.topView];
    _underLeftShowing  = YES;
    _underRightShowing = NO;
}

- (void)underRightWillAppear
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:ECSlidingViewUnderRightWillAppear object:self userInfo:nil];
    });
    [self.underLeftView removeFromSuperview];
    [self updateUnderRightLayout];
    [self.view insertSubview:self.underRightView belowSubview:self.topView];
    _underLeftShowing  = NO;
    _underRightShowing = YES;
}

- (void)topDidReset
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:ECSlidingViewTopDidReset object:self userInfo:nil];
    });
    [self.topView removeGestureRecognizer:self.resetTapGesture];
    [self removeTopViewSnapshot];
    self.panGesture.enabled = YES;
    [self.underRightView removeFromSuperview];
    [self.underLeftView removeFromSuperview];
    _underLeftShowing   = NO;
    _underRightShowing  = NO;
    _topViewIsOffScreen = NO;
}

- (BOOL)topViewHasFocus
{
    return !_underLeftShowing && !_underRightShowing && !_topViewIsOffScreen;
}

- (void)updateUnderLeftLayout
{
    if (self.underLeftWidthLayout == ECFullWidth) {
        [self.underLeftView setAutoresizingMask:self.autoResizeToFillScreen];
        [self.underLeftView setFrame:[self fullViewBounds]];

    } else if (self.underLeftWidthLayout == ECVariableRevealWidth && !self.topViewIsOffScreen) {
        CGRect frame = [self fullViewBounds];
        frame.size.width -= self.anchorRightPeekAmount;
        self.underLeftView.frame = frame;

    } else if (self.underLeftWidthLayout == ECFixedRevealWidth) {
        CGRect frame = [self fullViewBounds];
        frame.size.width = self.anchorRightRevealAmount;
        self.underLeftView.frame = frame;

    } else {
        [NSException raise:@"Invalid Width Layout" format:@"underLeftWidthLayout must be a valid ECViewWidthLayout"];
    }
}

- (void)updateUnderRightLayout
{
    if (self.underRightWidthLayout == ECFullWidth) {
        [self.underRightViewController.view setAutoresizingMask:self.autoResizeToFillScreen];
        self.underRightView.frame = [self fullViewBounds];

    } else if (self.underRightWidthLayout == ECVariableRevealWidth) {
        CGRect frame = [self fullViewBounds];
        CGFloat newLeftEdge = 0.0f;
        CGFloat newWidth = CGRectGetWidth(frame);

        if (! self.topViewIsOffScreen) {
            newLeftEdge = self.anchorLeftPeekAmount;
            newWidth   -= self.anchorLeftPeekAmount;
        }

        frame.origin.x   = newLeftEdge;
        frame.size.width = newWidth;
        self.underRightView.frame = frame;

    } else if (self.underRightWidthLayout == ECFixedRevealWidth) {
        CGRect frame = [self fullViewBounds];

        CGFloat newLeftEdge = CGRectGetWidth(frame) - self.anchorLeftRevealAmount;
        CGFloat newWidth = self.anchorLeftRevealAmount;

        frame.origin.x   = newLeftEdge;
        frame.size.width = newWidth;
        self.underRightView.frame = frame;

    } else {
        [NSException raise:@"Invalid Width Layout" format:@"underRightWidthLayout must be a valid ECViewWidthLayout"];
    }
}

@end

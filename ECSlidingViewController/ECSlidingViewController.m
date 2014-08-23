// ECSlidingViewController.m
// ECSlidingViewController 2
//
// Copyright (c) 2013, Michael Enriquez (http://enriquez.me)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "ECSlidingViewController.h"

#import "ECSlidingAnimationController.h"
#import "ECSlidingInteractiveTransition.h"
#import "ECSlidingSegue.h"

@interface ECSlidingViewController()
@property (nonatomic, assign) ECSlidingViewControllerOperation currentOperation;
@property (nonatomic, strong) ECSlidingAnimationController *defaultAnimationController;
@property (nonatomic, strong) ECSlidingInteractiveTransition *defaultInteractiveTransition;
@property (nonatomic, strong) id<UIViewControllerAnimatedTransitioning> currentAnimationController;
@property (nonatomic, strong) id<UIViewControllerInteractiveTransitioning> currentInteractiveTransition;
@property (nonatomic, strong) UIView *gestureView;
@property (nonatomic, strong) NSMapTable *customAnchoredGesturesViewMap;
@property (nonatomic, assign) CGFloat currentAnimationPercentage;
@property (nonatomic, assign) BOOL preserveLeftPeekAmount;
@property (nonatomic, assign) BOOL preserveRightPeekAmount;
@property (nonatomic, assign) BOOL transitionWasCancelled;
@property (nonatomic, assign) BOOL isAnimated;
@property (nonatomic, assign) BOOL isInteractive;
@property (nonatomic, assign) BOOL transitionInProgress;
@property (nonatomic, copy) void (^animationComplete)();
@property (nonatomic, copy) void (^coordinatorAnimations)(id<UIViewControllerTransitionCoordinatorContext>context);
@property (nonatomic, copy) void (^coordinatorCompletion)(id<UIViewControllerTransitionCoordinatorContext>context);
@property (nonatomic, copy) void (^coordinatorInteractionEnded)(id<UIViewControllerTransitionCoordinatorContext>context);
- (void)setup;

- (void)moveTopViewToPosition:(ECSlidingViewControllerTopViewPosition)position animated:(BOOL)animated onComplete:(void(^)())complete;
- (CGRect)topViewCalculatedFrameForPosition:(ECSlidingViewControllerTopViewPosition)position;
- (CGRect)underLeftViewCalculatedFrameForTopViewPosition:(ECSlidingViewControllerTopViewPosition)position;
- (CGRect)underRightViewCalculatedFrameForTopViewPosition:(ECSlidingViewControllerTopViewPosition)position;
- (CGRect)frameFromDelegateForViewController:(UIViewController *)viewController
                             topViewPosition:(ECSlidingViewControllerTopViewPosition)topViewPosition;
- (ECSlidingViewControllerOperation)operationFromPosition:(ECSlidingViewControllerTopViewPosition)fromPosition
                                               toPosition:(ECSlidingViewControllerTopViewPosition)toPosition;
- (void)animateOperation:(ECSlidingViewControllerOperation)operation;
- (BOOL)operationIsValid:(ECSlidingViewControllerOperation)operation;
- (void)beginAppearanceTransitionForOperation:(ECSlidingViewControllerOperation)operation;
- (void)endAppearanceTransitionForOperation:(ECSlidingViewControllerOperation)operation isCancelled:(BOOL)canceled;
- (UIViewController *)viewControllerWillAppearForSuccessfulOperation:(ECSlidingViewControllerOperation)operation;
- (UIViewController *)viewControllerWillDisappearForSuccessfulOperation:(ECSlidingViewControllerOperation)operation;
- (void)updateTopViewGestures;
@end

@implementation ECSlidingViewController

@synthesize topViewController=_topViewController;
@synthesize underLeftViewController=_underLeftViewController;
@synthesize underRightViewController=_underRightViewController;

#pragma mark - Constructors

+ (instancetype)slidingWithTopViewController:(UIViewController *)topViewController {
    return [[self alloc] initWithTopViewController:topViewController];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setup];
    }
    
    return self;
}

- (instancetype)initWithTopViewController:(UIViewController *)topViewController {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        self.topViewController = topViewController;
    }
    
    return self;
}

- (void)setup {
    self.anchorLeftPeekAmount    = 44;
    self.anchorRightRevealAmount = 276;
    _currentTopViewPosition = ECSlidingViewControllerTopViewPositionCentered;
    self.transitionInProgress = NO;
}

#pragma mark - UIViewController

- (void)awakeFromNib {
    if (self.topViewControllerStoryboardId) {
        self.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:self.topViewControllerStoryboardId];
    }
    
    if (self.underLeftViewControllerStoryboardId) {
        self.underLeftViewController = [self.storyboard instantiateViewControllerWithIdentifier:self.underLeftViewControllerStoryboardId];
    }
    
    if (self.underRightViewControllerStoryboardId) {
        self.underRightViewController = [self.storyboard instantiateViewControllerWithIdentifier:self.underRightViewControllerStoryboardId];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.topViewController) [NSException raise:@"Missing topViewController"
                                             format:@"Set the topViewController before loading ECSlidingViewController"];
    self.topViewController.view.frame = [self topViewCalculatedFrameForPosition:self.currentTopViewPosition];
    [self.view addSubview:self.topViewController.view];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.topViewController beginAppearanceTransition:YES animated:animated];
    
    if (self.currentTopViewPosition == ECSlidingViewControllerTopViewPositionAnchoredLeft) {
        [self.underRightViewController beginAppearanceTransition:YES animated:animated];
    } else if (self.currentTopViewPosition == ECSlidingViewControllerTopViewPositionAnchoredRight) {
        [self.underLeftViewController beginAppearanceTransition:YES animated:animated];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.topViewController endAppearanceTransition];
    
    if (self.currentTopViewPosition == ECSlidingViewControllerTopViewPositionAnchoredLeft) {
        [self.underRightViewController endAppearanceTransition];
    } else if (self.currentTopViewPosition == ECSlidingViewControllerTopViewPositionAnchoredRight) {
        [self.underLeftViewController endAppearanceTransition];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.topViewController beginAppearanceTransition:NO animated:animated];
    
    if (self.currentTopViewPosition == ECSlidingViewControllerTopViewPositionAnchoredLeft) {
        [self.underRightViewController beginAppearanceTransition:NO animated:animated];
    } else if (self.currentTopViewPosition == ECSlidingViewControllerTopViewPositionAnchoredRight) {
        [self.underLeftViewController beginAppearanceTransition:NO animated:animated];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.topViewController endAppearanceTransition];
    
    if (self.currentTopViewPosition == ECSlidingViewControllerTopViewPositionAnchoredLeft) {
        [self.underRightViewController endAppearanceTransition];
    } else if (self.currentTopViewPosition == ECSlidingViewControllerTopViewPositionAnchoredRight) {
        [self.underLeftViewController endAppearanceTransition];
    }
}

- (void)viewDidLayoutSubviews {
    if (self.currentOperation == ECSlidingViewControllerOperationNone) {
        self.gestureView.frame = [self topViewCalculatedFrameForPosition:self.currentTopViewPosition];
        self.topViewController.view.frame = [self topViewCalculatedFrameForPosition:self.currentTopViewPosition];
        self.underLeftViewController.view.frame = [self underLeftViewCalculatedFrameForTopViewPosition:self.currentTopViewPosition];
        self.underRightViewController.view.frame = [self underRightViewCalculatedFrameForTopViewPosition:self.currentTopViewPosition];
    }
}

- (BOOL)shouldAutorotate {
    return self.currentOperation == ECSlidingViewControllerOperationNone;
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods {
    return NO;
}

- (BOOL)shouldAutomaticallyForwardRotationMethods {
    return YES;
}

- (UIStoryboardSegue *)segueForUnwindingToViewController:(UIViewController *)toViewController fromViewController:(UIViewController *)fromViewController identifier:(NSString *)identifier {
    if ([self.underLeftViewController isMemberOfClass:[toViewController class]] || [self.underRightViewController isMemberOfClass:[toViewController class]]) {
        ECSlidingSegue *unwindSegue = [[ECSlidingSegue alloc] initWithIdentifier:identifier source:fromViewController destination:toViewController];
        [unwindSegue setValue:@YES forKey:@"isUnwinding"];
        return unwindSegue;
    } else {
        return [super segueForUnwindingToViewController:toViewController fromViewController:fromViewController identifier:identifier];
    }
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    if (self.currentTopViewPosition == ECSlidingViewControllerTopViewPositionCentered) {
        return self.topViewController;
    } else if (self.currentTopViewPosition == ECSlidingViewControllerTopViewPositionAnchoredLeft) {
        return self.underRightViewController;
    } else if (self.currentTopViewPosition == ECSlidingViewControllerTopViewPositionAnchoredRight) {
        return self.underLeftViewController;
    } else {
        return nil;
    }
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    if (self.currentTopViewPosition == ECSlidingViewControllerTopViewPositionCentered) {
        return self.topViewController;
    } else if (self.currentTopViewPosition == ECSlidingViewControllerTopViewPositionAnchoredLeft) {
        return self.underRightViewController;
    } else if (self.currentTopViewPosition == ECSlidingViewControllerTopViewPositionAnchoredRight) {
        return self.underLeftViewController;
    } else {
        return nil;
    }
}

- (id<UIViewControllerTransitionCoordinator>)transitionCoordinator {
    if (!self.transitionInProgress){
        return [super transitionCoordinator];
    }
    return self;
}

#pragma mark - Properties

- (void)setTopViewController:(UIViewController *)topViewController {
    UIViewController *oldTopViewController = _topViewController;
    
    [oldTopViewController.view removeFromSuperview];
    [oldTopViewController willMoveToParentViewController:nil];
    [oldTopViewController beginAppearanceTransition:NO animated:NO];
    [oldTopViewController removeFromParentViewController];
    [oldTopViewController endAppearanceTransition];
    
    _topViewController = topViewController;
    
    if (_topViewController) {
        [self addChildViewController:_topViewController];
        [_topViewController didMoveToParentViewController:self];
        
        if ([self isViewLoaded]) {
            [_topViewController beginAppearanceTransition:YES animated:NO];
            [self.view addSubview:_topViewController.view];
            [_topViewController endAppearanceTransition];
        }
    }
}

- (void)setUnderLeftViewController:(UIViewController *)underLeftViewController {
    UIViewController *oldUnderLeftViewController = _underLeftViewController;
    
    [oldUnderLeftViewController.view removeFromSuperview];
    [oldUnderLeftViewController willMoveToParentViewController:nil];
    [oldUnderLeftViewController beginAppearanceTransition:NO animated:NO];
    [oldUnderLeftViewController removeFromParentViewController];
    [oldUnderLeftViewController endAppearanceTransition];
    
    _underLeftViewController = underLeftViewController;
    
    if (_underLeftViewController) {
        [self addChildViewController:_underLeftViewController];
        [_underLeftViewController didMoveToParentViewController:self];
    }
}

- (void)setUnderRightViewController:(UIViewController *)underRightViewController {
    UIViewController *oldUnderRightViewController = _underRightViewController;
    
    [oldUnderRightViewController.view removeFromSuperview];
    [oldUnderRightViewController willMoveToParentViewController:nil];
    [oldUnderRightViewController beginAppearanceTransition:NO animated:NO];
    [oldUnderRightViewController removeFromParentViewController];
    [oldUnderRightViewController endAppearanceTransition];
    
    _underRightViewController = underRightViewController;
    
    if (_underRightViewController) {
        [self addChildViewController:_underRightViewController];
        [_underRightViewController didMoveToParentViewController:self];
    }
}

- (void)setAnchorLeftPeekAmount:(CGFloat)anchorLeftPeekAmount {
    _anchorLeftPeekAmount   = anchorLeftPeekAmount;
    _anchorLeftRevealAmount = CGFLOAT_MAX;
    self.preserveLeftPeekAmount = YES;
}

- (void)setAnchorLeftRevealAmount:(CGFloat)anchorLeftRevealAmount {
    _anchorLeftRevealAmount = anchorLeftRevealAmount;
    _anchorLeftPeekAmount   = CGFLOAT_MAX;
    self.preserveLeftPeekAmount = NO;
}

- (void)setAnchorRightPeekAmount:(CGFloat)anchorRightPeekAmount {
    _anchorRightPeekAmount   = anchorRightPeekAmount;
    _anchorRightRevealAmount = CGFLOAT_MAX;
    self.preserveRightPeekAmount = YES;
}

- (void)setAnchorRightRevealAmount:(CGFloat)anchorRightRevealAmount {
    _anchorRightRevealAmount = anchorRightRevealAmount;
    _anchorRightPeekAmount   = CGFLOAT_MAX;
    self.preserveRightPeekAmount = NO;
}

- (void)setDefaultTransitionDuration:(NSTimeInterval)defaultTransitionDuration {
    self.defaultAnimationController.defaultTransitionDuration = defaultTransitionDuration;
}

- (CGFloat)anchorLeftPeekAmount {
    if (_anchorLeftPeekAmount == CGFLOAT_MAX && _anchorLeftRevealAmount != CGFLOAT_MAX) {
        return CGRectGetWidth(self.view.bounds) - _anchorLeftRevealAmount;
    } else if (_anchorLeftPeekAmount != CGFLOAT_MAX && _anchorLeftRevealAmount == CGFLOAT_MAX) {
        return _anchorLeftPeekAmount;
    } else {
        return CGFLOAT_MAX;
    }
}

- (CGFloat)anchorLeftRevealAmount {
    if (_anchorLeftRevealAmount == CGFLOAT_MAX && _anchorLeftPeekAmount != CGFLOAT_MAX) {
        return CGRectGetWidth(self.view.bounds) - _anchorLeftPeekAmount;
    } else if (_anchorLeftRevealAmount != CGFLOAT_MAX && _anchorLeftPeekAmount == CGFLOAT_MAX) {
        return _anchorLeftRevealAmount;
    } else {
        return CGFLOAT_MAX;
    }
}

- (CGFloat)anchorRightPeekAmount {
    if (_anchorRightPeekAmount == CGFLOAT_MAX && _anchorRightRevealAmount != CGFLOAT_MAX) {
        return CGRectGetWidth(self.view.bounds) - _anchorRightRevealAmount;
    } else if (_anchorRightPeekAmount != CGFLOAT_MAX && _anchorRightRevealAmount == CGFLOAT_MAX) {
        return _anchorRightPeekAmount;
    } else {
        return CGFLOAT_MAX;
    }
}

- (CGFloat)anchorRightRevealAmount {
    if (_anchorRightRevealAmount == CGFLOAT_MAX && _anchorRightPeekAmount != CGFLOAT_MAX) {
        return CGRectGetWidth(self.view.bounds) - _anchorRightPeekAmount;
    } else if (_anchorRightRevealAmount != CGFLOAT_MAX && _anchorRightPeekAmount == CGFLOAT_MAX) {
        return _anchorRightRevealAmount;
    } else {
        return CGFLOAT_MAX;
    }
}

- (ECSlidingAnimationController *)defaultAnimationController {
    if (_defaultAnimationController) return _defaultAnimationController;
    
    _defaultAnimationController = [[ECSlidingAnimationController alloc] init];
    
    return _defaultAnimationController;
}

- (ECSlidingInteractiveTransition *)defaultInteractiveTransition {
    if (_defaultInteractiveTransition) return _defaultInteractiveTransition;
    
    _defaultInteractiveTransition = [[ECSlidingInteractiveTransition alloc] initWithSlidingViewController:self];
    _defaultInteractiveTransition.animationController = self.defaultAnimationController;
    
    return _defaultInteractiveTransition;
}

- (UIView *)gestureView {
    if (_gestureView) return _gestureView;
    
    _gestureView = [[UIView alloc] initWithFrame:CGRectZero];
    
    return _gestureView;
}

- (NSMapTable *)customAnchoredGesturesViewMap {
    if (_customAnchoredGesturesViewMap) return _customAnchoredGesturesViewMap;
    
    _customAnchoredGesturesViewMap = [NSMapTable mapTableWithKeyOptions:NSMapTableWeakMemory valueOptions:NSMapTableWeakMemory];
    
    return _customAnchoredGesturesViewMap;
}

- (UITapGestureRecognizer *)resetTapGesture {
    if (_resetTapGesture) return _resetTapGesture;
    
    _resetTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetTopViewAnimated:)];
    
    return _resetTapGesture;
}

- (UIPanGestureRecognizer *)panGesture {
    if (_panGesture) return _panGesture;
    
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(detectPanGestureRecognizer:)];
    
    return _panGesture;
}

#pragma mark - Public

- (void)anchorTopViewToRightAnimated:(BOOL)animated {
    [self anchorTopViewToRightAnimated:animated onComplete:nil];
}

- (void)anchorTopViewToLeftAnimated:(BOOL)animated {
    [self anchorTopViewToLeftAnimated:animated onComplete:nil];
}

- (void)resetTopViewAnimated:(BOOL)animated {
    [self resetTopViewAnimated:animated onComplete:nil];
}

- (void)anchorTopViewToRightAnimated:(BOOL)animated onComplete:(void (^)())complete {
    [self moveTopViewToPosition:ECSlidingViewControllerTopViewPositionAnchoredRight animated:animated onComplete:complete];
}

- (void)anchorTopViewToLeftAnimated:(BOOL)animated onComplete:(void (^)())complete {
    [self moveTopViewToPosition:ECSlidingViewControllerTopViewPositionAnchoredLeft animated:animated onComplete:complete];
}

- (void)resetTopViewAnimated:(BOOL)animated onComplete:(void(^)())complete {
    [self moveTopViewToPosition:ECSlidingViewControllerTopViewPositionCentered animated:animated onComplete:complete];
}

#pragma mark - Private

- (void)moveTopViewToPosition:(ECSlidingViewControllerTopViewPosition)position animated:(BOOL)animated onComplete:(void(^)())complete {
    self.isAnimated = animated;
    self.animationComplete = complete;
    [self.view endEditing:YES];
    ECSlidingViewControllerOperation operation = [self operationFromPosition:self.currentTopViewPosition toPosition:position];
    [self animateOperation:operation];
}

- (CGRect)topViewCalculatedFrameForPosition:(ECSlidingViewControllerTopViewPosition)position {
    CGRect frameFromDelegate = [self frameFromDelegateForViewController:self.topViewController
                                                        topViewPosition:position];
    if (!CGRectIsInfinite(frameFromDelegate)) return frameFromDelegate;
    
    CGRect containerViewFrame = self.view.bounds;
    
    if (!(self.topViewController.edgesForExtendedLayout & UIRectEdgeTop)) {
        CGFloat topLayoutGuideLength = [self.topLayoutGuide length];
        containerViewFrame.origin.y     = topLayoutGuideLength;
        containerViewFrame.size.height -= topLayoutGuideLength;
    }
    
    if (!(self.topViewController.edgesForExtendedLayout & UIRectEdgeBottom)) {
        CGFloat bottomLayoutGuideLength = [self.bottomLayoutGuide length];
        containerViewFrame.size.height -= bottomLayoutGuideLength;
    }
    
    switch(position) {
        case ECSlidingViewControllerTopViewPositionCentered:
            return containerViewFrame;
        case ECSlidingViewControllerTopViewPositionAnchoredLeft:
            containerViewFrame.origin.x = -self.anchorLeftRevealAmount;
            return containerViewFrame;
        case ECSlidingViewControllerTopViewPositionAnchoredRight:
            containerViewFrame.origin.x = self.anchorRightRevealAmount;
            return containerViewFrame;
        default:
            return CGRectZero;
    }
}

- (CGRect)underLeftViewCalculatedFrameForTopViewPosition:(ECSlidingViewControllerTopViewPosition)position {
    CGRect frameFromDelegate = [self frameFromDelegateForViewController:self.underLeftViewController
                                                        topViewPosition:position];
    if (!CGRectIsInfinite(frameFromDelegate)) return frameFromDelegate;
    
    CGRect containerViewFrame = self.view.bounds;
    
    if (!(self.underLeftViewController.edgesForExtendedLayout & UIRectEdgeTop)) {
        CGFloat topLayoutGuideLength    = [self.topLayoutGuide length];
        containerViewFrame.origin.y     = topLayoutGuideLength;
        containerViewFrame.size.height -= topLayoutGuideLength;
    }
    
    if (!(self.underLeftViewController.edgesForExtendedLayout & UIRectEdgeBottom)) {
        CGFloat bottomLayoutGuideLength = [self.bottomLayoutGuide length];
        containerViewFrame.size.height -= bottomLayoutGuideLength;
    }
    
    if (!(self.underLeftViewController.edgesForExtendedLayout & UIRectEdgeRight)) {
        containerViewFrame.size.width = self.anchorRightRevealAmount;
    }
    
    return containerViewFrame;
}

- (CGRect)underRightViewCalculatedFrameForTopViewPosition:(ECSlidingViewControllerTopViewPosition)position {
    CGRect frameFromDelegate = [self frameFromDelegateForViewController:self.underRightViewController
                                                        topViewPosition:position];
    if (!CGRectIsInfinite(frameFromDelegate)) return frameFromDelegate;
    
    CGRect containerViewFrame = self.view.bounds;
    
    if (!(self.underRightViewController.edgesForExtendedLayout & UIRectEdgeTop)) {
        CGFloat topLayoutGuideLength    = [self.topLayoutGuide length];
        containerViewFrame.origin.y     = topLayoutGuideLength;
        containerViewFrame.size.height -= topLayoutGuideLength;
    }
    
    if (!(self.underRightViewController.edgesForExtendedLayout & UIRectEdgeBottom)) {
        CGFloat bottomLayoutGuideLength = [self.bottomLayoutGuide length];
        containerViewFrame.size.height -= bottomLayoutGuideLength;
    }
    
    if (!(self.underRightViewController.edgesForExtendedLayout & UIRectEdgeLeft)) {
        containerViewFrame.origin.x   = self.anchorLeftPeekAmount;
        containerViewFrame.size.width = self.anchorLeftRevealAmount;
    }
    
    return containerViewFrame;
}

- (CGRect)frameFromDelegateForViewController:(UIViewController *)viewController
                             topViewPosition:(ECSlidingViewControllerTopViewPosition)topViewPosition {
    CGRect frame = CGRectInfinite;
    
    if ([(NSObject *)self.delegate respondsToSelector:@selector(slidingViewController:layoutControllerForTopViewPosition:)]) {
        id<ECSlidingViewControllerLayout> layoutController = [self.delegate slidingViewController:self
                                                               layoutControllerForTopViewPosition:topViewPosition];
        
        if (layoutController) {
            frame = [layoutController slidingViewController:self
                                     frameForViewController:viewController
                                            topViewPosition:topViewPosition];
        }
    }
    
    return frame;
}

- (ECSlidingViewControllerOperation)operationFromPosition:(ECSlidingViewControllerTopViewPosition)fromPosition
                                               toPosition:(ECSlidingViewControllerTopViewPosition)toPosition {
    if (fromPosition == ECSlidingViewControllerTopViewPositionCentered &&
        toPosition   == ECSlidingViewControllerTopViewPositionAnchoredLeft) {
        return ECSlidingViewControllerOperationAnchorLeft;
    } else if (fromPosition == ECSlidingViewControllerTopViewPositionCentered &&
               toPosition   == ECSlidingViewControllerTopViewPositionAnchoredRight) {
        return ECSlidingViewControllerOperationAnchorRight;
    } else if (fromPosition == ECSlidingViewControllerTopViewPositionAnchoredLeft &&
               toPosition   == ECSlidingViewControllerTopViewPositionCentered) {
        return ECSlidingViewControllerOperationResetFromLeft;
    } else if (fromPosition == ECSlidingViewControllerTopViewPositionAnchoredRight &&
               toPosition   == ECSlidingViewControllerTopViewPositionCentered) {
        return ECSlidingViewControllerOperationResetFromRight;
    } else {
        return ECSlidingViewControllerOperationNone;
    }
}

- (void)animateOperation:(ECSlidingViewControllerOperation)operation {
    if (![self operationIsValid:operation]){
        _isInteractive = NO;
        return;
    }
    if (self.transitionInProgress) return;

    self.view.userInteractionEnabled = NO;
    
    self.transitionInProgress = YES;
    
    self.currentOperation = operation;
    
    if ([(NSObject *)self.delegate respondsToSelector:@selector(slidingViewController:animationControllerForOperation:topViewController:)]) {
        self.currentAnimationController = [self.delegate slidingViewController:self
                                               animationControllerForOperation:operation
                                                             topViewController:self.topViewController];
        
        if ([(NSObject *)self.delegate respondsToSelector:@selector(slidingViewController:interactionControllerForAnimationController:)]) {
            self.currentInteractiveTransition = [self.delegate slidingViewController:self
                                         interactionControllerForAnimationController:self.currentAnimationController];
        } else {
            self.currentInteractiveTransition = nil;
        }
    } else {
        self.currentAnimationController = nil;
    }
    
    if (self.currentAnimationController) {
        if (self.currentInteractiveTransition) {
            _isInteractive = YES;
        } else {
            self.defaultInteractiveTransition.animationController = self.currentAnimationController;
            self.currentInteractiveTransition = self.defaultInteractiveTransition;
        }
    } else {
        self.currentAnimationController = self.defaultAnimationController;
        
        self.defaultInteractiveTransition.animationController = self.currentAnimationController;
        self.currentInteractiveTransition = self.defaultInteractiveTransition;
    }
    
    [self beginAppearanceTransitionForOperation:operation];
    
    [self.defaultAnimationController setValue:self.coordinatorAnimations forKey:@"coordinatorAnimations"];
    [self.defaultAnimationController setValue:self.coordinatorCompletion forKey:@"coordinatorCompletion"];
    [self.defaultInteractiveTransition setValue:self.coordinatorInteractionEnded forKey:@"coordinatorInteractionEnded"];
    
    if ([self isInteractive]) {
        [self.currentInteractiveTransition startInteractiveTransition:self];
    } else {
        [self.currentAnimationController animateTransition:self];
    }
}

- (BOOL)operationIsValid:(ECSlidingViewControllerOperation)operation {
    if (self.currentTopViewPosition == ECSlidingViewControllerTopViewPositionAnchoredLeft) {
        if (operation == ECSlidingViewControllerOperationResetFromLeft) return YES;
    } else if (self.currentTopViewPosition == ECSlidingViewControllerTopViewPositionAnchoredRight) {
        if (operation == ECSlidingViewControllerOperationResetFromRight) return YES;
    } else if (self.currentTopViewPosition == ECSlidingViewControllerTopViewPositionCentered) {
        if (operation == ECSlidingViewControllerOperationAnchorLeft  && self.underRightViewController) return YES;
        if (operation == ECSlidingViewControllerOperationAnchorRight && self.underLeftViewController)  return YES;
    }
    
    return NO;
}

- (void)beginAppearanceTransitionForOperation:(ECSlidingViewControllerOperation)operation {
    UIViewController *viewControllerWillAppear    = [self viewControllerWillAppearForSuccessfulOperation:operation];
    UIViewController *viewControllerWillDisappear = [self viewControllerWillDisappearForSuccessfulOperation:operation];
    
    [viewControllerWillAppear    beginAppearanceTransition:YES animated:_isAnimated];
    [viewControllerWillDisappear beginAppearanceTransition:NO animated:_isAnimated];
}

- (void)endAppearanceTransitionForOperation:(ECSlidingViewControllerOperation)operation isCancelled:(BOOL)canceled {
    UIViewController *viewControllerWillAppear    = [self viewControllerWillAppearForSuccessfulOperation:operation];
    UIViewController *viewControllerWillDisappear = [self viewControllerWillDisappearForSuccessfulOperation:operation];
    
    if (canceled) {
        [viewControllerWillDisappear beginAppearanceTransition:YES animated:_isAnimated];
        [viewControllerWillDisappear endAppearanceTransition];
        [viewControllerWillAppear beginAppearanceTransition:NO animated:_isAnimated];
        [viewControllerWillAppear endAppearanceTransition];
    } else {
        [viewControllerWillDisappear endAppearanceTransition];
        [viewControllerWillAppear endAppearanceTransition];
    }
}

- (UIViewController *)viewControllerWillAppearForSuccessfulOperation:(ECSlidingViewControllerOperation)operation {
    UIViewController *viewControllerWillAppear = nil;
    
    if (operation == ECSlidingViewControllerOperationAnchorLeft) {
        viewControllerWillAppear = self.underRightViewController;
    } else if (operation == ECSlidingViewControllerOperationAnchorRight) {
        viewControllerWillAppear = self.underLeftViewController;
    }
    
    return viewControllerWillAppear;
}

- (UIViewController *)viewControllerWillDisappearForSuccessfulOperation:(ECSlidingViewControllerOperation)operation {
    UIViewController *viewControllerWillDisappear = nil;
    
    if (operation == ECSlidingViewControllerOperationResetFromLeft) {
        viewControllerWillDisappear = self.underRightViewController;
    } else if (operation == ECSlidingViewControllerOperationResetFromRight) {
        viewControllerWillDisappear = self.underLeftViewController;
    }
    
    return viewControllerWillDisappear;
}

- (void)updateTopViewGestures {
    BOOL topViewIsAnchored = self.currentTopViewPosition == ECSlidingViewControllerTopViewPositionAnchoredLeft ||
                             self.currentTopViewPosition == ECSlidingViewControllerTopViewPositionAnchoredRight;
    UIView *topView = self.topViewController.view;

    if (topViewIsAnchored) {
        if (self.topViewAnchoredGesture & ECSlidingViewControllerAnchoredGestureDisabled) {
            topView.userInteractionEnabled = NO;
        } else {
            self.gestureView.frame = topView.frame;

            if (self.topViewAnchoredGesture & ECSlidingViewControllerAnchoredGesturePanning &&
                ![self.customAnchoredGesturesViewMap objectForKey:self.panGesture]) {
                [self.customAnchoredGesturesViewMap setObject:self.panGesture.view forKey:self.panGesture];
                [self.panGesture.view removeGestureRecognizer:self.panGesture];
                [self.gestureView addGestureRecognizer:self.panGesture];
                if (!self.gestureView.superview) [self.view insertSubview:self.gestureView aboveSubview:topView];
            }

            if (self.topViewAnchoredGesture & ECSlidingViewControllerAnchoredGestureTapping &&
                ![self.customAnchoredGesturesViewMap objectForKey:self.resetTapGesture]) {
                [self.gestureView addGestureRecognizer:self.resetTapGesture];
                if (!self.gestureView.superview) [self.view insertSubview:self.gestureView aboveSubview:topView];
            }
            
            if (self.topViewAnchoredGesture & ECSlidingViewControllerAnchoredGestureCustom) {
                for (UIGestureRecognizer *gesture in self.customAnchoredGestures) {
                    if (![self.customAnchoredGesturesViewMap objectForKey:gesture]) {
                        [self.customAnchoredGesturesViewMap setObject:gesture.view forKey:gesture];
                        [gesture.view removeGestureRecognizer:gesture];
                        [self.gestureView addGestureRecognizer:gesture];
                    }
                }
                if (!self.gestureView.superview) [self.view insertSubview:self.gestureView aboveSubview:topView];
            }
        }
    } else {
        self.topViewController.view.userInteractionEnabled = YES;
        [self.gestureView removeFromSuperview];
        for (UIGestureRecognizer *gesture in self.customAnchoredGestures) {
            UIView *originalView = [self.customAnchoredGesturesViewMap objectForKey:gesture];
            if ([originalView isDescendantOfView:self.topViewController.view]) {
                [originalView addGestureRecognizer:gesture];
            }
        }
        if ([self.customAnchoredGesturesViewMap objectForKey:self.panGesture]) {
            UIView *view = [self.customAnchoredGesturesViewMap objectForKey:self.panGesture];
            if ([view isDescendantOfView:self.topViewController.view]) {
                [view addGestureRecognizer:self.panGesture];
            }
        }
        [self.customAnchoredGesturesViewMap removeAllObjects];
    }
}

#pragma mark - UIPanGestureRecognizer action

- (void)detectPanGestureRecognizer:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self.view endEditing:YES];
        _isInteractive = YES;
    }
    
    [self.defaultInteractiveTransition updateTopViewHorizontalCenterWithRecognizer:recognizer];
    _isInteractive = NO;
}

#pragma mark - UIViewControllerTransitionCoordinatorContext

- (BOOL)initiallyInteractive {
    return _isAnimated && _isInteractive;
}

- (BOOL)isCancelled {
    return _transitionWasCancelled;
}

- (NSTimeInterval)transitionDuration {
    return [self.currentAnimationController transitionDuration:self];
}

- (CGFloat)percentComplete {
    return self.currentAnimationPercentage;
}

- (CGFloat)completionVelocity {
    return 1.0;
}

- (UIViewAnimationCurve)completionCurve {
    return UIViewAnimationCurveLinear;
}

#pragma mark - UIViewControllerContextTransitioning and UIViewControllerTransitionCoordinatorContext

- (UIView *)containerView {
    return self.view;
}

- (BOOL)isAnimated {
    return _isAnimated;
}

- (BOOL)isInteractive {
    return _isInteractive;
}

- (BOOL)transitionWasCancelled {
    return _transitionWasCancelled;
}

- (UIModalPresentationStyle)presentationStyle {
    return UIModalPresentationCustom;
}

- (void)updateInteractiveTransition:(CGFloat)percentComplete {
    self.currentAnimationPercentage = percentComplete;
}

- (void)finishInteractiveTransition {
    _transitionWasCancelled = NO;
}

- (void)cancelInteractiveTransition {
    _transitionWasCancelled = YES;
}

- (void)completeTransition:(BOOL)didComplete {
    if (self.currentOperation == ECSlidingViewControllerOperationNone) return;
    
    if ([self transitionWasCancelled]) {
        if (self.currentOperation == ECSlidingViewControllerOperationAnchorLeft) {
            _currentTopViewPosition = ECSlidingViewControllerTopViewPositionCentered;
        } else if (self.currentOperation == ECSlidingViewControllerOperationAnchorRight) {
            _currentTopViewPosition = ECSlidingViewControllerTopViewPositionCentered;
        } else if (self.currentOperation == ECSlidingViewControllerOperationResetFromLeft) {
            _currentTopViewPosition = ECSlidingViewControllerTopViewPositionAnchoredLeft;
        } else if (self.currentOperation == ECSlidingViewControllerOperationResetFromRight) {
            _currentTopViewPosition = ECSlidingViewControllerTopViewPositionAnchoredRight;
        }
    } else {
        if (self.currentOperation == ECSlidingViewControllerOperationAnchorLeft) {
            _currentTopViewPosition = ECSlidingViewControllerTopViewPositionAnchoredLeft;
        } else if (self.currentOperation == ECSlidingViewControllerOperationAnchorRight) {
            _currentTopViewPosition = ECSlidingViewControllerTopViewPositionAnchoredRight;
        } else if (self.currentOperation == ECSlidingViewControllerOperationResetFromLeft) {
            _currentTopViewPosition = ECSlidingViewControllerTopViewPositionCentered;
        } else if (self.currentOperation == ECSlidingViewControllerOperationResetFromRight) {
            _currentTopViewPosition = ECSlidingViewControllerTopViewPositionCentered;
        }
    }
    
    if ([self.currentAnimationController respondsToSelector:@selector(animationEnded:)]) {
        [self.currentAnimationController animationEnded:didComplete];
    }
    
    if (self.animationComplete) self.animationComplete();
    self.animationComplete = nil;
    
    [self updateTopViewGestures];
    [self endAppearanceTransitionForOperation:self.currentOperation isCancelled:[self transitionWasCancelled]];
    
    _transitionWasCancelled          = NO;
    _isInteractive                   = NO;
    self.coordinatorAnimations       = nil;
    self.coordinatorCompletion       = nil;
    self.coordinatorInteractionEnded = nil;
    self.currentAnimationPercentage  = 0;
    self.currentOperation            = ECSlidingViewControllerOperationNone;
    self.transitionInProgress        = NO;
    self.view.userInteractionEnabled = YES;
    [UIViewController attemptRotationToDeviceOrientation];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (UIViewController *)viewControllerForKey:(NSString *)key {
    if ([key isEqualToString:ECTransitionContextTopViewControllerKey]) {
        return self.topViewController;
    } else if ([key isEqualToString:ECTransitionContextUnderLeftControllerKey]) {
        return self.underLeftViewController;
    } else if ([key isEqualToString:ECTransitionContextUnderRightControllerKey]) {
        return self.underRightViewController;
    }
    
    if (self.currentOperation == ECSlidingViewControllerOperationAnchorLeft) {
        if (key == UITransitionContextFromViewControllerKey) return self.topViewController;
        if (key == UITransitionContextToViewControllerKey)   return self.underRightViewController;
    } else if (self.currentOperation == ECSlidingViewControllerOperationAnchorRight) {
        if (key == UITransitionContextFromViewControllerKey) return self.topViewController;
        if (key == UITransitionContextToViewControllerKey)   return self.underLeftViewController;
    } else if (self.currentOperation == ECSlidingViewControllerOperationResetFromLeft) {
        if (key == UITransitionContextFromViewControllerKey) return self.underRightViewController;
        if (key == UITransitionContextToViewControllerKey)   return self.topViewController;
    } else if (self.currentOperation == ECSlidingViewControllerOperationResetFromRight) {
        if (key == UITransitionContextFromViewControllerKey) return self.underLeftViewController;
        if (key == UITransitionContextToViewControllerKey)   return self.topViewController;
    }
    
    return nil;
}

- (CGRect)initialFrameForViewController:(UIViewController *)vc {
    if (self.currentOperation == ECSlidingViewControllerOperationAnchorLeft) {
        if ([vc isEqual:self.topViewController]) return [self topViewCalculatedFrameForPosition:ECSlidingViewControllerTopViewPositionCentered];
    } else if (self.currentOperation == ECSlidingViewControllerOperationAnchorRight) {
        if ([vc isEqual:self.topViewController]) return [self topViewCalculatedFrameForPosition:ECSlidingViewControllerTopViewPositionCentered];
    } else if (self.currentOperation == ECSlidingViewControllerOperationResetFromLeft) {
        if ([vc isEqual:self.topViewController])        return [self topViewCalculatedFrameForPosition:ECSlidingViewControllerTopViewPositionAnchoredLeft];
        if ([vc isEqual:self.underRightViewController]) return [self underRightViewCalculatedFrameForTopViewPosition:ECSlidingViewControllerTopViewPositionAnchoredLeft];
    } else if (self.currentOperation == ECSlidingViewControllerOperationResetFromRight) {
        if ([vc isEqual:self.topViewController])        return [self topViewCalculatedFrameForPosition:ECSlidingViewControllerTopViewPositionAnchoredRight];
        if ([vc isEqual:self.underLeftViewController])  return [self underLeftViewCalculatedFrameForTopViewPosition:ECSlidingViewControllerTopViewPositionAnchoredRight];
    }
    
    return CGRectZero;
}

- (CGRect)finalFrameForViewController:(UIViewController *)vc {
    if (self.currentOperation == ECSlidingViewControllerOperationAnchorLeft) {
        if (vc == self.topViewController)        return [self topViewCalculatedFrameForPosition:ECSlidingViewControllerTopViewPositionAnchoredLeft];
        if (vc == self.underRightViewController) return [self underRightViewCalculatedFrameForTopViewPosition:ECSlidingViewControllerTopViewPositionAnchoredLeft];
    } else if (self.currentOperation == ECSlidingViewControllerOperationAnchorRight) {
        if (vc == self.topViewController) return [self topViewCalculatedFrameForPosition:ECSlidingViewControllerTopViewPositionAnchoredRight];
        if (vc == self.underLeftViewController)  return [self underLeftViewCalculatedFrameForTopViewPosition:ECSlidingViewControllerTopViewPositionAnchoredRight];
    } else if (self.currentOperation == ECSlidingViewControllerOperationResetFromLeft) {
        if (vc == self.topViewController) return [self topViewCalculatedFrameForPosition:ECSlidingViewControllerTopViewPositionCentered];
    } else if (self.currentOperation == ECSlidingViewControllerOperationResetFromRight) {
        if (vc == self.topViewController) return [self topViewCalculatedFrameForPosition:ECSlidingViewControllerTopViewPositionCentered];
    }
    
    return CGRectZero;
}

#pragma mark - UIViewControllerTransitionCoordinator

- (BOOL)animateAlongsideTransition:(void(^)(id<UIViewControllerTransitionCoordinatorContext>context))animation
                        completion:(void(^)(id<UIViewControllerTransitionCoordinatorContext>context))completion {
    self.coordinatorAnimations = animation;
    self.coordinatorCompletion = completion;
    return YES;
}

- (BOOL)animateAlongsideTransitionInView:(UIView *)view
                               animation:(void(^)(id<UIViewControllerTransitionCoordinatorContext>context))animation
                              completion:(void(^)(id<UIViewControllerTransitionCoordinatorContext>context))completion {
    self.coordinatorAnimations = animation;
    self.coordinatorCompletion = completion;
    return YES;
}

- (void)notifyWhenInteractionEndsUsingBlock:(void(^)(id<UIViewControllerTransitionCoordinatorContext>context))handler {
    self.coordinatorInteractionEnded = handler;
}

@end

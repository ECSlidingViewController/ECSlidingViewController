//
//  MEDynamicTransition.m
//  TransitionFun
//
//  Created by Michael Enriquez on 10/31/13.
//  Copyright (c) 2013 Mike Enriquez. All rights reserved.
//

#import "MEDynamicTransition.h"
#import "ECSlidingAnimationController.h"

@interface MEDynamicTransition ()
@property (nonatomic, assign) ECSlidingViewController *slidingViewController;
@property (nonatomic, assign) id<UIViewControllerContextTransitioning> transitionContext;
@property (nonatomic, strong) id<UIViewControllerAnimatedTransitioning> animationController;
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIDynamicItemBehavior *itemBehavior;
@property (nonatomic, strong) UICollisionBehavior *collisionBehavior;
@property (nonatomic, strong) UIAttachmentBehavior *attachmentBehavior;
@property (nonatomic, strong) UIPushBehavior *pushBehavior;
@property (nonatomic, strong) UIGravityBehavior *gravityBehavior;
@property (nonatomic, strong) UIDynamicBehavior *compositeBehavior;
@property (nonatomic, assign) BOOL positiveLeftToRight;
@property (nonatomic, assign) BOOL isPanningRight;
@property (nonatomic, assign) CGFloat fullWidth;
@property (nonatomic, assign) CGFloat currentPercentage;
@property (nonatomic, assign) CGRect initialTopViewFrame;
@end

@implementation MEDynamicTransition

- (id)initWithSlidingViewController:(ECSlidingViewController *)slidingViewController {
    self = [super init];
    if (self) {
        self.slidingViewController = slidingViewController;
        self.animationController   = [[ECSlidingAnimationController alloc] init];
    }
    
    return self;
}

#pragma mark - Properties

- (UIPanGestureRecognizer *)panGesture {
    if (_panGesture) return _panGesture;
    
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    
    return _panGesture;
}

- (id<UIViewControllerAnimatedTransitioning>)animationController {
    if (_animationController) return _animationController;
    
    _animationController = [[ECSlidingAnimationController alloc] init];
    
    return _animationController;
}

- (UIDynamicAnimator *)animator {
    if (_animator) return _animator;
    
    _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.slidingViewController.view];
    _animator.delegate = self;
    
    return _animator;
}

- (UIDynamicItemBehavior *)itemBehavior {
    if (_itemBehavior) return _itemBehavior;
    
    _itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.slidingViewController.topViewController.view]];
    _itemBehavior.allowsRotation = NO;
    _itemBehavior.density = 10;
    
    return _itemBehavior;
}

- (UICollisionBehavior *)collisionBehavior {
    if (_collisionBehavior) return _collisionBehavior;
    
    _collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[self.slidingViewController.topViewController.view]];
    
    CGFloat containerHeight = self.slidingViewController.view.bounds.size.height;
    CGFloat containerWidth  = self.slidingViewController.view.bounds.size.width;
    CGFloat revealAmount    = self.slidingViewController.anchorRightRevealAmount;
    
    [_collisionBehavior addBoundaryWithIdentifier:@"LeftEdge" fromPoint:CGPointMake(0, 0) toPoint:CGPointMake(0, containerHeight)];
    [_collisionBehavior addBoundaryWithIdentifier:@"RightEdge" fromPoint:CGPointMake(revealAmount + containerWidth, 0) toPoint:CGPointMake(revealAmount + containerWidth, containerHeight)];

    return _collisionBehavior;
}

- (UIAttachmentBehavior *)attachmentBehavior {
    if (_attachmentBehavior) return _attachmentBehavior;
    
    _attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:self.slidingViewController.topViewController.view attachedToAnchor:CGPointZero];
    _attachmentBehavior.damping   = 1.0;
    _attachmentBehavior.frequency = 3.5;
    _attachmentBehavior.length    = 0;
    
    return _attachmentBehavior;
}

- (UIPushBehavior *)pushBehavior {
    if (_pushBehavior) return _pushBehavior;
    
    _pushBehavior = [[UIPushBehavior alloc] initWithItems:@[self.slidingViewController.topViewController.view] mode:UIPushBehaviorModeInstantaneous];
    
    return _pushBehavior;
}

- (UIGravityBehavior *)gravityBehavior {
    if (_gravityBehavior) return _gravityBehavior;
    
    _gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[self.slidingViewController.topViewController.view]];
    
    return _gravityBehavior;
}

- (UIDynamicBehavior *)compositeBehavior {
    if (_compositeBehavior) return _compositeBehavior;
    
    _compositeBehavior = [[UIDynamicBehavior alloc] init];
    [_compositeBehavior addChildBehavior:self.collisionBehavior];
    [_compositeBehavior addChildBehavior:self.attachmentBehavior];
    [_compositeBehavior addChildBehavior:self.pushBehavior];
//    [_compositeBehavior addChildBehavior:self.gravityBehavior];
//    [_compositeBehavior addChildBehavior:self.itemBehavior];
    
    return _compositeBehavior;
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return [self.animationController transitionDuration:transitionContext];
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    [self.animationController animateTransition:transitionContext];
}

#pragma mark - UIViewControllerInteractiveTransitioning

- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    self.transitionContext = transitionContext;
    
    UIViewController *topViewController = [transitionContext viewControllerForKey:ECTransitionContextTopViewControllerKey];
    CGFloat finalLeftEdge = CGRectGetMinX([transitionContext finalFrameForViewController:topViewController]);
    CGFloat initialLeftEdge = CGRectGetMinX([transitionContext initialFrameForViewController:topViewController]);
    CGFloat fullWidth = fabsf(finalLeftEdge - initialLeftEdge);
    
    self.positiveLeftToRight = initialLeftEdge < finalLeftEdge;
    self.fullWidth           = fullWidth;
    self.currentPercentage   = 0;
    
    
}

#pragma mark - UIPanGestureRecognizer action

- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer {
    UIView *topView       = self.slidingViewController.topViewController.view;
    CGFloat translationX  = [recognizer translationInView:self.slidingViewController.view].x;
    CGFloat velocityX     = [recognizer velocityInView:self.slidingViewController.view].x;
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan: {
            BOOL isMovingRight = velocityX > 0;
            
            CALayer *presentationLayer = (CALayer *)topView.layer.presentationLayer;
            self.initialTopViewFrame = presentationLayer.frame;
            
            if (self.slidingViewController.currentTopViewPosition == ECSlidingViewControllerTopViewPositionCentered && isMovingRight) {
                [self.slidingViewController anchorTopViewToRightAnimated:YES];
            } else if (self.slidingViewController.currentTopViewPosition == ECSlidingViewControllerTopViewPositionCentered && !isMovingRight) {
                [self.slidingViewController anchorTopViewToLeftAnimated:YES];
            } else if (self.slidingViewController.currentTopViewPosition == ECSlidingViewControllerTopViewPositionAnchoredLeft) {
                [self.slidingViewController resetTopViewAnimated:YES];
            } else if (self.slidingViewController.currentTopViewPosition == ECSlidingViewControllerTopViewPositionAnchoredRight) {
                [self.slidingViewController resetTopViewAnimated:YES];
            }
            
            break;
        }
        case UIGestureRecognizerStateChanged: {
            _collisionBehavior = nil;
            _attachmentBehavior = nil;
            _pushBehavior = nil;
            _compositeBehavior = nil;
            _animator = nil;
            
            CGRect topViewInitialFrame = self.initialTopViewFrame;
            topViewInitialFrame.origin.x += translationX;
            topView.frame = topViewInitialFrame;
            
            if (!self.positiveLeftToRight) translationX = translationX * -1.0;
            CGFloat percentComplete = (translationX / self.fullWidth);
            if (percentComplete < 0) percentComplete = 0;
            if (percentComplete > 100) percentComplete = 100;
            [self.transitionContext updateInteractiveTransition:percentComplete];
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            self.isPanningRight = velocityX > 0;
            
            CGFloat containerWidth = self.slidingViewController.view.bounds.size.width;
            CGFloat revealAmount   = self.slidingViewController.anchorRightRevealAmount;
            
            CGPoint anchorPoint = self.isPanningRight ? CGPointMake((containerWidth / 2) + revealAmount, topView.center.y) : CGPointMake((containerWidth / 2), topView.center.y);
            
            [self.animator updateItemUsingCurrentState:self.slidingViewController.topViewController.view];
            
            self.attachmentBehavior.anchorPoint = anchorPoint;
            
            self.gravityBehavior.angle = self.isPanningRight ? 0 : M_PI;
            self.gravityBehavior.magnitude = 1;
            
            self.pushBehavior.angle = 0; // velocity may be negative
            self.pushBehavior.magnitude = velocityX;
            self.pushBehavior.active = YES;
            
            [self.animator addBehavior:self.compositeBehavior];
            
            break;
        }
        default:
            break;
    }
}

#pragma mark - UIDynamicAnimatorDelegate

- (void)dynamicAnimatorDidPause:(UIDynamicAnimator*)animator {
    if ((self.isPanningRight && self.positiveLeftToRight) || (!self.isPanningRight && !self.positiveLeftToRight)) {
        [self.transitionContext finishInteractiveTransition];
    } else if ((self.isPanningRight && !self.positiveLeftToRight) || (!self.isPanningRight && self.positiveLeftToRight)) {
        [self.transitionContext cancelInteractiveTransition];
    }
    
    _collisionBehavior = nil;
    _attachmentBehavior = nil;
    _pushBehavior = nil;
    _compositeBehavior = nil;
    _animator = nil;
    
    [self.transitionContext completeTransition:YES];
}

@end

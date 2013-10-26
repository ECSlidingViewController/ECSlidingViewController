//
//  ECSlidingInteractiveTransition.m
//  ECSlidingViewController
//
//  Created by Michael Enriquez on 10/13/13.
//  Copyright (c) 2013 Mike Enriquez. All rights reserved.
//

#import "ECSlidingInteractiveTransition.h"
#import "ECSlidingViewController.h"
#import "ECSlidingConstants.h"

@interface ECSlidingInteractiveTransition ()
@property (nonatomic, assign) id<UIViewControllerContextTransitioning>transitionContext;
@property (nonatomic, assign) id<UIViewControllerAnimatedTransitioning> animationController;
@property (nonatomic, assign) BOOL positiveLeftToRight;
@property (nonatomic, assign) CGFloat fullWidth;
@property (nonatomic, assign) CGFloat currentPercentage;
- (void)updateInteractiveTransition:(CGFloat)percentComplete;
- (void)cancelInteractiveTransition;
- (void)finishInteractiveTransition;
@end

@implementation ECSlidingInteractiveTransition

#pragma mark - Constructors

- (id)initWithTransitionContext:(id<UIViewControllerContextTransitioning>)transitionContext
            animationController:(id<UIViewControllerAnimatedTransitioning>)animationController {
    self = [super init];
    if (self) {
        self.transitionContext   = transitionContext;
        self.animationController = animationController;
    }
    
    return self;
}

#pragma mark - UIViewControllerInteractiveTransitioning

- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *topViewController = [transitionContext viewControllerForKey:ECTransitionContextTopViewControllerKey];
    CGFloat finalLeftEdge = CGRectGetMinX([transitionContext finalFrameForViewController:topViewController]);
    CGFloat initialLeftEdge = CGRectGetMinX([transitionContext initialFrameForViewController:topViewController]);
    CGFloat fullWidth = fabsf(finalLeftEdge - initialLeftEdge);

    self.positiveLeftToRight = initialLeftEdge < finalLeftEdge;
    self.fullWidth           = fullWidth;
    self.currentPercentage   = 0;
    
    [self.animationController animateTransition:transitionContext];
}

#pragma mark - Properties

- (UIPanGestureRecognizer *)panGestureRecognizer {
    if (_panGestureRecognizer) return _panGestureRecognizer;
    
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                    action:@selector(updateTopViewHorizontalCenterWithRecognizer:)];
    
    return _panGestureRecognizer;
}

#pragma mark - UIPanGestureRecognizer action

- (void)updateTopViewHorizontalCenterWithRecognizer:(UIPanGestureRecognizer *)recognizer {
    UIView *referenceView = [self.transitionContext containerView];
    UIViewController *topViewController = [self.transitionContext viewControllerForKey:ECTransitionContextTopViewControllerKey];
    ECSlidingViewController *slidingViewController = topViewController.slidingViewController;
    CGFloat translationX  = [recognizer translationInView:referenceView].x;
    CGFloat velocityX     = [recognizer velocityInView:referenceView].x;

    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan: {
            BOOL isMovingRight = velocityX > 0;
            
            if (slidingViewController.currentTopViewPosition == ECSlidingViewControllerTopViewPositionCentered && isMovingRight) {
                [slidingViewController anchorTopViewToRightAnimated:YES];
            } else if (slidingViewController.currentTopViewPosition == ECSlidingViewControllerTopViewPositionCentered && !isMovingRight) {
                [slidingViewController anchorTopViewToLeft:YES];
            } else if (slidingViewController.currentTopViewPosition == ECSlidingViewControllerTopViewPositionAnchoredLeft) {
                [slidingViewController resetTopViewAnimated:YES];
            } else if (slidingViewController.currentTopViewPosition == ECSlidingViewControllerTopViewPositionAnchoredRight) {
                [slidingViewController resetTopViewAnimated:YES];
            }

            [self updateInteractiveTransition:0.0];
            
            break;
        }
        case UIGestureRecognizerStateChanged: {
            if (!self.positiveLeftToRight) translationX = translationX * -1.0;
            CGFloat percentComplete = (translationX / self.fullWidth);
            if (percentComplete < 0) percentComplete = 0;
            [self updateInteractiveTransition:percentComplete];
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            BOOL isPanningRight = velocityX > 0;
            
            if (isPanningRight && self.positiveLeftToRight) {
                [self finishInteractiveTransition];
            } else if (isPanningRight && !self.positiveLeftToRight) {
                [self cancelInteractiveTransition];
            } else if (!isPanningRight && self.positiveLeftToRight) {
                [self cancelInteractiveTransition];
            } else if (!isPanningRight && !self.positiveLeftToRight) {
                [self finishInteractiveTransition];
            }
            
            break;
        }
        default:
            break;
    }
}

#pragma mark - Private

- (void)updateInteractiveTransition:(CGFloat)percentComplete {
    [self.transitionContext updateInteractiveTransition:percentComplete];
    self.currentPercentage = percentComplete;
}

- (void)cancelInteractiveTransition {
    [self.transitionContext cancelInteractiveTransition];
}

- (void)finishInteractiveTransition {
    [self.transitionContext finishInteractiveTransition];
}

@end

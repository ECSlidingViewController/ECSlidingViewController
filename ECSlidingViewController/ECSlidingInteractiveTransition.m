//
//  ECSlidingInteractiveTransition.m
//  ECSlidingViewController
//
//  Created by Michael Enriquez on 10/13/13.
//  Copyright (c) 2013 Mike Enriquez. All rights reserved.
//

#import "ECSlidingInteractiveTransition.h"
#import "ECSlidingConstants.h"

@interface ECSlidingInteractiveTransition ()
@property (nonatomic, assign) ECSlidingViewController *slidingViewController;
@property (nonatomic, assign) BOOL positiveLeftToRight;
@property (nonatomic, assign) CGFloat fullWidth;
@property (nonatomic, assign) CGFloat currentPercentage;
@end

@implementation ECSlidingInteractiveTransition

#pragma mark - Constructors

- (id)initWithSlidingViewController:(ECSlidingViewController *)slidingViewController {
    self = [super init];
    if (self) {
        self.slidingViewController = slidingViewController;
    }
    
    return self;
}

#pragma mark - UIViewControllerInteractiveTransitioning

- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    [super startInteractiveTransition:transitionContext];
    
    UIViewController *topViewController = [transitionContext viewControllerForKey:ECTransitionContextTopViewControllerKey];
    CGFloat finalLeftEdge = CGRectGetMinX([transitionContext finalFrameForViewController:topViewController]);
    CGFloat initialLeftEdge = CGRectGetMinX([transitionContext initialFrameForViewController:topViewController]);
    CGFloat fullWidth = fabsf(finalLeftEdge - initialLeftEdge);

    self.positiveLeftToRight = initialLeftEdge < finalLeftEdge;
    self.fullWidth           = fullWidth;
    self.currentPercentage   = 0;
}

#pragma mark - UIPanGestureRecognizer action

- (void)updateTopViewHorizontalCenterWithRecognizer:(UIPanGestureRecognizer *)recognizer {
    CGFloat translationX  = [recognizer translationInView:self.slidingViewController.view].x;
    CGFloat velocityX     = [recognizer velocityInView:self.slidingViewController.view].x;

    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan: {
            BOOL isMovingRight = velocityX > 0;

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

@end

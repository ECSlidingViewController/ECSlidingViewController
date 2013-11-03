//
//  MEZoomAnimationController.m
//  TransitionFun
//
//  Created by Michael Enriquez on 10/30/13.
//  Copyright (c) 2013 Mike Enriquez. All rights reserved.
//

#import "MEZoomAnimationController.h"

@implementation MEZoomAnimationController

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.25;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *topViewController = [transitionContext viewControllerForKey:ECTransitionContextTopViewControllerKey];
    UIViewController *underLeftViewController  = [transitionContext viewControllerForKey:ECTransitionContextUnderLeftControllerKey];
    UIView *containerView = [transitionContext containerView];
    CGRect topViewInitialFrame = [transitionContext initialFrameForViewController:topViewController];
    CGRect topViewFinalFrame   = [transitionContext finalFrameForViewController:topViewController];
    
    UIView *topView = topViewController.view;
    
    underLeftViewController.view.layer.transform = CATransform3DIdentity;
    
    if (self.operation == ECSlidingViewControllerOperationAnchorRight) {
        underLeftViewController.view.alpha = 0;
        
        topView.frame = topViewInitialFrame;
        underLeftViewController.view.frame = [transitionContext initialFrameForViewController:underLeftViewController];
        
        [containerView insertSubview:underLeftViewController.view belowSubview:topView];
        
        underLeftViewController.view.layer.transform = CATransform3DMakeScale(1.25, 1.25, 1);
        
        NSTimeInterval duration = [self transitionDuration:transitionContext];
        [UIView animateWithDuration:duration animations:^{
            CGFloat scaleFactor = 0.75;
            
            underLeftViewController.view.alpha = 1;
            underLeftViewController.view.layer.transform = CATransform3DIdentity;
            
            topView.layer.transform = CATransform3DMakeScale(scaleFactor, scaleFactor, 1);
            topView.layer.position = CGPointMake(topViewFinalFrame.origin.x + ((topView.layer.bounds.size.width * scaleFactor) / 2), topView.layer.position.y);
        } completion:^(BOOL finished) {
            if ([transitionContext transitionWasCancelled]) {
                topView.layer.transform = CATransform3DIdentity;
                topView.frame = topViewInitialFrame;
            }
            
            [transitionContext completeTransition:finished];
        }];
    } else if (self.operation == ECSlidingViewControllerOperationResetFromRight) {
        underLeftViewController.view.layer.transform = CATransform3DIdentity;
        
        NSTimeInterval duration = [self transitionDuration:transitionContext];
        [UIView animateWithDuration:duration animations:^{
            underLeftViewController.view.alpha = 0;
            underLeftViewController.view.layer.transform = CATransform3DMakeScale(1.25, 1.25, 1);
            
            topView.layer.transform = CATransform3DIdentity;
            topView.layer.position = [transitionContext containerView].center;
        } completion:^(BOOL finished) {
            if ([transitionContext transitionWasCancelled]) {
                CGFloat scaleFactor = 0.75;
                
                underLeftViewController.view.alpha = 1;
                underLeftViewController.view.layer.transform = CATransform3DMakeScale(1, 1, 1);
                
                topView.layer.transform = CATransform3DMakeScale(scaleFactor, scaleFactor, 1);
                topView.layer.position = CGPointMake(topViewInitialFrame.origin.x + ((topView.layer.bounds.size.width * scaleFactor) / 2), topView.layer.position.y);
            } else {
                underLeftViewController.view.layer.transform = CATransform3DIdentity;
                underLeftViewController.view.alpha = 1;
                [underLeftViewController.view removeFromSuperview];
            }
            
            [transitionContext completeTransition:finished];
        }];
    }
}

#pragma mark - ECSlidingViewControllerLayout

- (CGRect)slidingViewController:(ECSlidingViewController *)slidingViewController
         frameForViewController:(UIViewController *)viewController
                topViewPosition:(ECSlidingViewControllerTopViewPosition)topViewPosition {
    if (topViewPosition == ECSlidingViewControllerTopViewPositionAnchoredRight && viewController == slidingViewController.topViewController) {
        CGRect frame = slidingViewController.view.frame;
        frame.origin.x = slidingViewController.anchorRightRevealAmount;
        frame.size.width  = frame.size.width  * 0.75;
        frame.size.height = frame.size.height * 0.75;
        frame.origin.y = (slidingViewController.view.frame.size.height - frame.size.height) / 2;
        
        return frame;
    } else {
        return CGRectInfinite;
    }
}

@end

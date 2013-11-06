// MEZoomAnimationController.m
// TransitionFun
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

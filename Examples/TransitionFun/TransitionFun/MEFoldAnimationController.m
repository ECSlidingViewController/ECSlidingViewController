// MEFoldAnimationController.m
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


#import "MEFoldAnimationController.h"
#import "ECSlidingViewController.h"

@interface MEFoldAnimationController ()
- (void)foldLayers:(CALayer *)leftSide rightSide:(CALayer *)rightSide;
- (void)unfoldLayers:(CALayer *)leftSide rightSide:(CALayer *)rightSide;
@end

@implementation MEFoldAnimationController

#pragma mark - ECSlidingViewControllerDelegate

- (id<UIViewControllerAnimatedTransitioning>)slidingViewController:(ECSlidingViewController *)slidingViewController
                                   animationControllerForOperation:(ECSlidingViewControllerOperation)operation
                                                 topViewController:(UIViewController *)topViewController {
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.25;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *topViewController = [transitionContext viewControllerForKey:ECTransitionContextTopViewControllerKey];
    UIViewController *toViewController  = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView      = [transitionContext containerView];
    CGRect topViewInitialFrame = [transitionContext initialFrameForViewController:topViewController];
    CGRect topViewFinalFrame   = [transitionContext finalFrameForViewController:topViewController];
    CGFloat revealWidth;
    BOOL isResetting = NO;
    
    topViewController.view.frame = topViewInitialFrame;
    
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -0.002;
    containerView.layer.sublayerTransform = transform;

    UIViewController *underViewController;
    
    if (topViewController == toViewController) {
        underViewController = [transitionContext viewControllerForKey:ECTransitionContextUnderLeftControllerKey];
        revealWidth = [transitionContext initialFrameForViewController:topViewController].origin.x;
        isResetting = YES;
    } else {
        underViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        revealWidth = [transitionContext finalFrameForViewController:topViewController].origin.x;
        isResetting = NO;
    }

    CGRect underViewFrame;
    
    CGRect underViewInitialFrame = [transitionContext initialFrameForViewController:underViewController];
    CGRect underViewFinalFrame   = [transitionContext finalFrameForViewController:underViewController];
    
    if (CGRectIsEmpty(underViewInitialFrame)) {
        underViewFrame = underViewFinalFrame;
    } else {
        underViewFrame = underViewInitialFrame;
    }
    
    UIView *underView = underViewController.view;
    
    underView.frame = underViewFrame;
    [underView removeFromSuperview];

    CGFloat underViewHalfwayPoint = revealWidth / 2;
    CGRect leftSideFrame = CGRectMake(0, 0, underViewHalfwayPoint, underView.bounds.size.height);
    CGRect rightSideFrame = CGRectMake(underViewHalfwayPoint, 0, underViewHalfwayPoint, underView.bounds.size.height);
    
    UIView *leftSideView = [underView resizableSnapshotViewFromRect:leftSideFrame
                                                 afterScreenUpdates:YES
                                                      withCapInsets:UIEdgeInsetsZero];
    UIView *rightSideView = [underView resizableSnapshotViewFromRect:rightSideFrame
                                                  afterScreenUpdates:YES
                                                       withCapInsets:UIEdgeInsetsZero];
    
    leftSideView.layer.anchorPoint = CGPointMake(0, 0.5);
    leftSideView.frame = leftSideFrame;
    
    rightSideView.layer.frame       = rightSideFrame;
    rightSideView.layer.anchorPoint = CGPointMake(1, 0);
    
    if (isResetting) {
        [self unfoldLayers:leftSideView.layer rightSide:rightSideView.layer];
    } else {
        [self foldLayers:leftSideView.layer rightSide:rightSideView.layer];
    }
    
    [containerView.layer insertSublayer:leftSideView.layer below:topViewController.view.layer];
    [containerView.layer insertSublayer:rightSideView.layer below:topViewController.view.layer];
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    [UIView animateWithDuration:duration animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        
        topViewController.view.frame = topViewFinalFrame;
        
        if (isResetting) {
            [self foldLayers:leftSideView.layer rightSide:rightSideView.layer];
        } else {
            [self unfoldLayers:leftSideView.layer rightSide:rightSideView.layer];
        }
    } completion:^(BOOL finished) {
        containerView.layer.sublayerTransform = CATransform3DIdentity;
        [leftSideView removeFromSuperview];
        [rightSideView removeFromSuperview];

        BOOL topViewReset = (isResetting && ![transitionContext transitionWasCancelled]) || (!isResetting && [transitionContext transitionWasCancelled]);
        
        if ([transitionContext transitionWasCancelled]) {
            topViewController.view.frame = [transitionContext initialFrameForViewController:topViewController];
        } else {
            topViewController.view.frame = [transitionContext finalFrameForViewController:topViewController];
        }
        
        if (topViewReset) {
            [underView removeFromSuperview];
        } else {
            if ([transitionContext transitionWasCancelled]) {
                underView.frame = [transitionContext initialFrameForViewController:underViewController];
            } else {
                underView.frame = [transitionContext finalFrameForViewController:underViewController];
            }
            [containerView insertSubview:underView belowSubview:topViewController.view];
        }
        
        [transitionContext completeTransition:finished];
    }];
}

#pragma mark - Private

- (void)foldLayers:(CALayer *)leftSide rightSide:(CALayer *)rightSide {
    leftSide.transform = CATransform3DMakeRotation(M_PI_2, 0.0, 1.0, 0.0);
    
    rightSide.position  = CGPointMake(0, 0);
    rightSide.transform = CATransform3DMakeRotation(-M_PI_2, 0.0, 1.0, 0.0);
}

- (void)unfoldLayers:(CALayer *)leftSide rightSide:(CALayer *)rightSide {
    leftSide.transform = CATransform3DMakeRotation(0, 0.0, 1.0, 0.0);
    
    rightSide.position  = CGPointMake(rightSide.bounds.size.width * 2, 0);
    rightSide.transform = CATransform3DMakeRotation(0, 0.0, 1.0, 0.0);
}

@end

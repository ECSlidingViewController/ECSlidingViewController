// ECSlidingAnimationController.m
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

#import "ECSlidingAnimationController.h"
#import "ECSlidingConstants.h"

@interface ECSlidingAnimationController ()
@property (nonatomic, copy) void (^coordinatorAnimations)(id<UIViewControllerTransitionCoordinatorContext>context);
@property (nonatomic, copy) void (^coordinatorCompletion)(id<UIViewControllerTransitionCoordinatorContext>context);
@end

@implementation ECSlidingAnimationController

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    if (_defaultTransitionDuration) {
        return _defaultTransitionDuration;
    } else {
        return 0.25;
    }
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *topViewController = [transitionContext viewControllerForKey:ECTransitionContextTopViewControllerKey];
    UIViewController *toViewController  = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    CGRect topViewInitialFrame = [transitionContext initialFrameForViewController:topViewController];
    CGRect topViewFinalFrame   = [transitionContext finalFrameForViewController:topViewController];
    
    topViewController.view.frame = topViewInitialFrame;
    
    if (topViewController != toViewController) {
        CGRect toViewFinalFrame = [transitionContext finalFrameForViewController:toViewController];
        toViewController.view.frame = toViewFinalFrame;
        [containerView insertSubview:toViewController.view belowSubview:topViewController.view];
    }
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    [UIView animateWithDuration:duration animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        if (self.coordinatorAnimations) self.coordinatorAnimations((id<UIViewControllerTransitionCoordinatorContext>)transitionContext);
        topViewController.view.frame = topViewFinalFrame;
    } completion:^(BOOL finished) {
        if ([transitionContext transitionWasCancelled]) {
            topViewController.view.frame = [transitionContext initialFrameForViewController:topViewController];
        }
        
        if (self.coordinatorCompletion) self.coordinatorCompletion((id<UIViewControllerTransitionCoordinatorContext>)transitionContext);
        [transitionContext completeTransition:finished];
    }];
}

@end

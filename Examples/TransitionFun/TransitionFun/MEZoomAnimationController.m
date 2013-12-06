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

static CGFloat const MEZoomAnimationScaleFactor = 0.75;

@interface MEZoomAnimationController ()
@property (nonatomic, assign) ECSlidingViewControllerOperation operation;
- (CGRect)topViewAnchoredRightFrame:(ECSlidingViewController *)slidingViewController;
- (void)topViewStartingState:(UIView *)topView containerFrame:(CGRect)containerFrame;
- (void)topViewAnchorRightEndState:(UIView *)topView anchoredFrame:(CGRect)anchoredFrame;
- (void)underLeftViewStartingState:(UIView *)underLeftView containerFrame:(CGRect)containerFrame;
- (void)underLeftViewEndState:(UIView *)underLeftView;
@end

@implementation MEZoomAnimationController

#pragma mark - ECSlidingViewControllerDelegate

- (id<UIViewControllerAnimatedTransitioning>)slidingViewController:(ECSlidingViewController *)slidingViewController
                                   animationControllerForOperation:(ECSlidingViewControllerOperation)operation
                                                 topViewController:(UIViewController *)topViewController {
    self.operation = operation;
    return self;
}

- (id<ECSlidingViewControllerLayout>)slidingViewController:(ECSlidingViewController *)slidingViewController
                        layoutControllerForTopViewPosition:(ECSlidingViewControllerTopViewPosition)topViewPosition {
    return self;
}

#pragma mark - ECSlidingViewControllerLayout

- (CGRect)slidingViewController:(ECSlidingViewController *)slidingViewController
         frameForViewController:(UIViewController *)viewController
                topViewPosition:(ECSlidingViewControllerTopViewPosition)topViewPosition {
    if (topViewPosition == ECSlidingViewControllerTopViewPositionAnchoredRight && viewController == slidingViewController.topViewController) {
        return [self topViewAnchoredRightFrame:slidingViewController];
    } else {
        return CGRectInfinite;
    }
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.25;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *topViewController = [transitionContext viewControllerForKey:ECTransitionContextTopViewControllerKey];
    UIViewController *underLeftViewController  = [transitionContext viewControllerForKey:ECTransitionContextUnderLeftControllerKey];
    UIView *containerView = [transitionContext containerView];
    
    UIView *topView = topViewController.view;
    topView.frame = containerView.bounds;
    
    underLeftViewController.view.layer.transform = CATransform3DIdentity;
    
    if (self.operation == ECSlidingViewControllerOperationAnchorRight) {
        [containerView insertSubview:underLeftViewController.view belowSubview:topView];
        
        [self topViewStartingState:topView containerFrame:containerView.bounds];
        [self underLeftViewStartingState:underLeftViewController.view containerFrame:containerView.bounds];

        NSTimeInterval duration = [self transitionDuration:transitionContext];
        [UIView animateWithDuration:duration animations:^{
            [self underLeftViewEndState:underLeftViewController.view];
            [self topViewAnchorRightEndState:topView anchoredFrame:[transitionContext finalFrameForViewController:topViewController]];
        } completion:^(BOOL finished) {
            if ([transitionContext transitionWasCancelled]) {
                underLeftViewController.view.frame = [transitionContext finalFrameForViewController:underLeftViewController];
                underLeftViewController.view.alpha = 1;
                [self topViewStartingState:topView containerFrame:containerView.bounds];
            }
            
            [transitionContext completeTransition:finished];
        }];
    } else if (self.operation == ECSlidingViewControllerOperationResetFromRight) {
        [self topViewAnchorRightEndState:topView anchoredFrame:[transitionContext initialFrameForViewController:topViewController]];
        [self underLeftViewEndState:underLeftViewController.view];

        NSTimeInterval duration = [self transitionDuration:transitionContext];
        [UIView animateWithDuration:duration animations:^{
            [self underLeftViewStartingState:underLeftViewController.view containerFrame:containerView.bounds];
            [self topViewStartingState:topView containerFrame:containerView.bounds];
        } completion:^(BOOL finished) {
            if ([transitionContext transitionWasCancelled]) {
                [self underLeftViewEndState:underLeftViewController.view];
                [self topViewAnchorRightEndState:topView anchoredFrame:[transitionContext initialFrameForViewController:topViewController]];
            } else {
                underLeftViewController.view.alpha = 1;
                underLeftViewController.view.layer.transform = CATransform3DIdentity;
                [underLeftViewController.view removeFromSuperview];
            }
            
            [transitionContext completeTransition:finished];
        }];
    }
}

#pragma mark - Private

- (CGRect)topViewAnchoredRightFrame:(ECSlidingViewController *)slidingViewController {
    CGRect frame = slidingViewController.view.bounds;
    
    frame.origin.x    = slidingViewController.anchorRightRevealAmount;
    frame.size.width  = frame.size.width  * MEZoomAnimationScaleFactor;
    frame.size.height = frame.size.height * MEZoomAnimationScaleFactor;
    frame.origin.y    = (slidingViewController.view.bounds.size.height - frame.size.height) / 2;
    
    return frame;
}

- (void)topViewStartingState:(UIView *)topView containerFrame:(CGRect)containerFrame {
    topView.layer.transform = CATransform3DIdentity;
    topView.layer.position  = CGPointMake(containerFrame.size.width / 2, containerFrame.size.height / 2);
}

- (void)topViewAnchorRightEndState:(UIView *)topView anchoredFrame:(CGRect)anchoredFrame {
    topView.layer.transform = CATransform3DMakeScale(MEZoomAnimationScaleFactor, MEZoomAnimationScaleFactor, 1);
    topView.frame = anchoredFrame;
    topView.layer.position  = CGPointMake(anchoredFrame.origin.x + ((topView.layer.bounds.size.width * MEZoomAnimationScaleFactor) / 2), topView.layer.position.y);
}

- (void)underLeftViewStartingState:(UIView *)underLeftView containerFrame:(CGRect)containerFrame {
    underLeftView.alpha = 0;
    underLeftView.frame = containerFrame;
    underLeftView.layer.transform = CATransform3DMakeScale(1.25, 1.25, 1);
}

- (void)underLeftViewEndState:(UIView *)underLeftView {
    underLeftView.alpha = 1;
    underLeftView.layer.transform = CATransform3DIdentity;
}

@end

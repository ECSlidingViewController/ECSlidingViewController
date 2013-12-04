// MEDynamicTransition.m
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

#import "MEDynamicTransition.h"
#import "ECSlidingAnimationController.h"

@interface MEDynamicTransition ()
@property (nonatomic, strong) ECSlidingAnimationController *defaultAnimationController;
@property (nonatomic, strong) NSMutableArray *leftEdgeQueue;
@property (nonatomic, assign) id<UIViewControllerContextTransitioning> transitionContext;
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UICollisionBehavior *collisionBehavior;
@property (nonatomic, strong) UIGravityBehavior *gravityBehavior;
@property (nonatomic, strong) UIPushBehavior *pushBehavior;
@property (nonatomic, strong) UIDynamicItemBehavior *topViewBehavior;
@property (nonatomic, strong) UIDynamicBehavior *compositeBehavior;
@property (nonatomic, assign) BOOL positiveLeftToRight;
@property (nonatomic, assign) BOOL isPanningRight;
@property (nonatomic, assign) BOOL isInteractive;
@property (nonatomic, assign) CGFloat fullWidth;
@property (nonatomic, assign) CGRect initialTopViewFrame;
@end

@implementation MEDynamicTransition

#pragma mark - ECSlidingViewControllerDelegate

- (id<UIViewControllerAnimatedTransitioning>)slidingViewController:(ECSlidingViewController *)slidingViewController
                                   animationControllerForOperation:(ECSlidingViewControllerOperation)operation
                                                 topViewController:(UIViewController *)topViewController {
    return self.defaultAnimationController;
}

- (id<UIViewControllerInteractiveTransitioning>)slidingViewController:(ECSlidingViewController *)slidingViewController
                          interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>)animationController {
    self.slidingViewController = slidingViewController;
    return self;
}

#pragma mark - Properties

- (ECSlidingAnimationController *)defaultAnimationController {
    if (_defaultAnimationController) return _defaultAnimationController;
    
    _defaultAnimationController = [[ECSlidingAnimationController alloc] init];
    
    return _defaultAnimationController;
}

- (NSMutableArray *)leftEdgeQueue {
    if (_leftEdgeQueue) return _leftEdgeQueue;
    
    _leftEdgeQueue = [NSMutableArray arrayWithCapacity:5];
    
    return _leftEdgeQueue;
}

- (UIDynamicAnimator *)animator {
    if (_animator) return _animator;
    
    _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.slidingViewController.view];
    _animator.delegate = self;
    [_animator updateItemUsingCurrentState:self.slidingViewController.topViewController.view];
    
    return _animator;
}

- (UICollisionBehavior *)collisionBehavior {
    if (_collisionBehavior) return _collisionBehavior;
    
    _collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[self.slidingViewController.topViewController.view]];
    
    CGFloat containerHeight = self.slidingViewController.view.bounds.size.height;
    CGFloat containerWidth  = self.slidingViewController.view.bounds.size.width;
    CGFloat revealAmount    = self.slidingViewController.anchorRightRevealAmount;
    
    [_collisionBehavior addBoundaryWithIdentifier:@"LeftEdge" fromPoint:CGPointMake(-1, 0) toPoint:CGPointMake(-1, containerHeight)];
    [_collisionBehavior addBoundaryWithIdentifier:@"RightEdge" fromPoint:CGPointMake(revealAmount + containerWidth + 1, 0) toPoint:CGPointMake(revealAmount + containerWidth + 1, containerHeight)];

    return _collisionBehavior;
}

- (UIGravityBehavior *)gravityBehavior {
    if (_gravityBehavior) return _gravityBehavior;
    
    _gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[self.slidingViewController.topViewController.view]];
    
    return _gravityBehavior;
}

- (UIPushBehavior *)pushBehavior {
    if (_pushBehavior) return _pushBehavior;
    
    _pushBehavior = [[UIPushBehavior alloc] initWithItems:@[self.slidingViewController.topViewController.view] mode:UIPushBehaviorModeInstantaneous];
    
    return _pushBehavior;
}

- (UIDynamicItemBehavior *)topViewBehavior {
    if (_topViewBehavior) return _topViewBehavior;
    
    UIView *topView = self.slidingViewController.topViewController.view;
    _topViewBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[topView]];
    // the density ranges from 1 to 5 for iPad to iPhone
    _topViewBehavior.density = 908800 / (topView.bounds.size.width * topView.bounds.size.height);
    _topViewBehavior.elasticity = 0;
    _topViewBehavior.resistance = 1;
    
    return _topViewBehavior;
}

- (UIDynamicBehavior *)compositeBehavior {
    if (_compositeBehavior) return _compositeBehavior;
    
    _compositeBehavior = [[UIDynamicBehavior alloc] init];
    [_compositeBehavior addChildBehavior:self.collisionBehavior];
    [_compositeBehavior addChildBehavior:self.gravityBehavior];
    [_compositeBehavior addChildBehavior:self.pushBehavior];
    [_compositeBehavior addChildBehavior:self.topViewBehavior];
    __weak typeof(self)weakSelf = self;
    _compositeBehavior.action = ^{
        // stop the dynamic animation when the value of the left edge is the same 5 times in a row.
        NSNumber *leftEdge = [NSNumber numberWithFloat:weakSelf.slidingViewController.topViewController.view.frame.origin.x];
        [weakSelf.leftEdgeQueue insertObject:leftEdge atIndex:0];
        if (weakSelf.leftEdgeQueue.count == 6) [weakSelf.leftEdgeQueue removeLastObject];
        
        if (weakSelf.leftEdgeQueue.count == 5 &&
            ((NSArray *)[weakSelf.leftEdgeQueue valueForKeyPath:@"@distinctUnionOfObjects.self"]).count == 1) {
            [weakSelf.animator removeAllBehaviors];
        }
    };
    
    return _compositeBehavior;
}

#pragma mark - UIViewControllerInteractiveTransitioning

- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    self.transitionContext = transitionContext;
    
    UIViewController *topViewController = [transitionContext viewControllerForKey:ECTransitionContextTopViewControllerKey];
    topViewController.view.userInteractionEnabled = NO;
    
    if (_isInteractive) {
        UIViewController *underViewController = [transitionContext viewControllerForKey:ECTransitionContextUnderLeftControllerKey];
        CGRect underViewInitialFrame = [transitionContext initialFrameForViewController:underViewController];
        CGRect underViewFinalFrame   = [transitionContext finalFrameForViewController:underViewController];
        UIView *containerView = [transitionContext containerView];
        CGFloat finalLeftEdge = CGRectGetMinX([transitionContext finalFrameForViewController:topViewController]);
        CGFloat initialLeftEdge = CGRectGetMinX([transitionContext initialFrameForViewController:topViewController]);
        CGFloat fullWidth = fabsf(finalLeftEdge - initialLeftEdge);
        
        CGRect underViewFrame;
        if (CGRectIsEmpty(underViewInitialFrame)) {
            underViewFrame = underViewFinalFrame;
        } else {
            underViewFrame = underViewInitialFrame;
        }
        
        underViewController.view.frame = underViewFrame;
        
        [containerView insertSubview:underViewController.view belowSubview:topViewController.view];
        
        self.positiveLeftToRight = initialLeftEdge < finalLeftEdge;
        self.fullWidth           = fullWidth;
    } else {
        [self.defaultAnimationController animateTransition:transitionContext];
    }
}

#pragma mark - UIPanGestureRecognizer action

- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer {
    if ([self.animator isRunning]) return;
    
    UIView *topView       = self.slidingViewController.topViewController.view;
    CGFloat translationX  = [recognizer translationInView:self.slidingViewController.view].x;
    CGFloat velocityX     = [recognizer velocityInView:self.slidingViewController.view].x;

    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan: {
            BOOL isMovingRight = velocityX > 0;
            
            CALayer *presentationLayer = (CALayer *)topView.layer.presentationLayer;
            self.initialTopViewFrame = presentationLayer.frame;

            _isInteractive = YES;
            
            if (self.slidingViewController.currentTopViewPosition == ECSlidingViewControllerTopViewPositionCentered && isMovingRight && self.slidingViewController.underLeftViewController) {
                [self.slidingViewController anchorTopViewToRightAnimated:YES];
            } else if (self.slidingViewController.currentTopViewPosition == ECSlidingViewControllerTopViewPositionCentered && !isMovingRight && self.slidingViewController.underRightViewController) {
                [self.slidingViewController anchorTopViewToLeftAnimated:YES];
            } else if (self.slidingViewController.currentTopViewPosition == ECSlidingViewControllerTopViewPositionAnchoredLeft) {
                [self.slidingViewController resetTopViewAnimated:YES];
            } else if (self.slidingViewController.currentTopViewPosition == ECSlidingViewControllerTopViewPositionAnchoredRight) {
                [self.slidingViewController resetTopViewAnimated:YES];
            } else {
                _isInteractive = NO;
            }
            
            break;
        }
        case UIGestureRecognizerStateChanged: {
            if (!_isInteractive) return;
            
            CGRect topViewInitialFrame = self.initialTopViewFrame;
            CGFloat newLeftEdge = topViewInitialFrame.origin.x + translationX;
            
            if (newLeftEdge < 0) {
                newLeftEdge = 0;
            } else if (newLeftEdge > self.slidingViewController.anchorRightRevealAmount) {
                newLeftEdge = self.slidingViewController.anchorRightRevealAmount;
            }
            
            topViewInitialFrame.origin.x = newLeftEdge;
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
            if (!_isInteractive) return;
            
            _isInteractive = NO;
            
            self.isPanningRight = velocityX > 0;
            
            self.gravityBehavior.gravityDirection = self.isPanningRight ? CGVectorMake(2, 0) : CGVectorMake(-2, 0);
            
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
    [self.animator removeAllBehaviors];
    
    _collisionBehavior = nil;
    _topViewBehavior = nil;
    _pushBehavior = nil;
    _gravityBehavior = nil;
    _compositeBehavior = nil;
    _animator = nil;
    
    self.slidingViewController.topViewController.view.userInteractionEnabled = YES;
    UIViewController *topViewController = [self.transitionContext viewControllerForKey:ECTransitionContextTopViewControllerKey];
    if ((self.isPanningRight && self.positiveLeftToRight) || (!self.isPanningRight && !self.positiveLeftToRight)) {
        topViewController.view.frame = [self.transitionContext finalFrameForViewController:topViewController];
        [self.transitionContext finishInteractiveTransition];
    } else if ((self.isPanningRight && !self.positiveLeftToRight) || (!self.isPanningRight && self.positiveLeftToRight)) {
        topViewController.view.frame = [self.transitionContext initialFrameForViewController:topViewController];
        [self.transitionContext cancelInteractiveTransition];
    }
    
    [self.transitionContext completeTransition:YES];
}

@end

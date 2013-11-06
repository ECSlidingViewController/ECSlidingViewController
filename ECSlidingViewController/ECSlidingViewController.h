// ECSlidingViewController.h
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ECSlidingConstants.h"

@class ECSlidingViewController;

@protocol ECSlidingViewControllerLayout <NSObject>
- (CGRect)slidingViewController:(ECSlidingViewController *)slidingViewController
         frameForViewController:(UIViewController *)viewController
                topViewPosition:(ECSlidingViewControllerTopViewPosition)topViewPosition;
@end

@protocol ECSlidingViewControllerDelegate
- (id<UIViewControllerAnimatedTransitioning>)slidingViewController:(ECSlidingViewController *)slidingViewController
                                   animationControllerForOperation:(ECSlidingViewControllerOperation)operation
                                                 topViewController:(UIViewController *)topViewController;
- (id<UIViewControllerInteractiveTransitioning>)slidingViewController:(ECSlidingViewController *)slidingViewController
                          interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>)animationController;
- (id<ECSlidingViewControllerLayout>)slidingViewController:(ECSlidingViewController *)slidingViewController
                        layoutControllerForTopViewPosition:(ECSlidingViewControllerTopViewPosition)topViewPosition;
@end

@interface ECSlidingViewController : UIViewController <UIViewControllerContextTransitioning,
                                                       UIViewControllerTransitionCoordinator,
                                                       UIViewControllerTransitionCoordinatorContext> {
    CGFloat _anchorLeftPeekAmount;
    CGFloat _anchorLeftRevealAmount;
    CGFloat _anchorRightPeekAmount;
    CGFloat _anchorRightRevealAmount;
    UIPanGestureRecognizer *_panGesture;
    UITapGestureRecognizer *_resetTapGesture;
}

@property (nonatomic, assign) id<ECSlidingViewControllerDelegate> delegate;
@property (nonatomic, strong) UIViewController *topViewController;
@property (nonatomic, strong) UIViewController *underLeftViewController;
@property (nonatomic, strong) UIViewController *underRightViewController;
@property (nonatomic, assign) CGFloat anchorLeftPeekAmount;
@property (nonatomic, assign) CGFloat anchorLeftRevealAmount;
@property (nonatomic, assign) CGFloat anchorRightPeekAmount;
@property (nonatomic, assign) CGFloat anchorRightRevealAmount;
@property (nonatomic, assign) ECSlidingViewControllerAnchoredGesture topViewAnchoredGesture;
@property (nonatomic, assign, readonly) ECSlidingViewControllerTopViewPosition currentTopViewPosition;
@property (nonatomic, strong, readonly) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong, readonly) UITapGestureRecognizer *resetTapGesture;
@property (nonatomic, strong) NSArray *customAnchoredGestures;

@property (nonatomic, strong) NSString *topViewControllerStoryboardId;
@property (nonatomic, strong) NSString *underLeftViewControllerStoryboardId;
@property (nonatomic, strong) NSString *underRightViewControllerStoryboardId;

- (id)initWithTopViewController:(UIViewController *)topViewController;
- (void)anchorTopViewToRightAnimated:(BOOL)animated;
- (void)anchorTopViewToRightAnimated:(BOOL)animated onComplete:(void (^)())complete;
- (void)anchorTopViewToLeftAnimated:(BOOL)animated;
- (void)anchorTopViewToLeftAnimated:(BOOL)animated onComplete:(void (^)())complete;
- (void)resetTopViewAnimated:(BOOL)animated;
- (void)resetTopViewAnimated:(BOOL)animated onComplete:(void(^)())complete;

@end
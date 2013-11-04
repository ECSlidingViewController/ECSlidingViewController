//
//  ECSlidingViewController.h
//  ECSlidingViewController
//
//  Created by Michael Enriquez on 10/11/13.
//  Copyright (c) 2013 Mike Enriquez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ECSlidingConstants.h"
#import "ECSlidingAnimationController.h"
#import "ECSlidingInteractiveTransition.h"

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

/** UIViewController extension */
@interface UIViewController(SlidingViewExtension)
/** Convience method for getting access to the ECSlidingViewController instance */
- (ECSlidingViewController *)slidingViewController;
@end
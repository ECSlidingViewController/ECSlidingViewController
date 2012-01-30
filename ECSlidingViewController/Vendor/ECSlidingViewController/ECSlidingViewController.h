//
//  ECSlidingViewController.h
//  ECSlidingViewController
//
//  Created by Michael Enriquez on 1/23/12.
//  Copyright (c) 2012 EdgeCase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage+ImageWithUIView.h"

/** @constant ECSide side of screen */
typedef enum {
  /** Left side of screen */
  ECLeft,
  /** Right side of screen */
  ECRight
} ECSide;

/** @constant ECResetStrategy top view behavior while anchored. */
typedef enum {
  /** No reset strategy will be used */
  ECNone = 0,
  /** Tapping the top view will reset it */
  ECTapping = 1 << 0,
  /** Panning will be enabled on the top view. If it is panned and released towards the reset position it will reset, otherwise it will slide towards the anchored position. */
  ECPanning = 1 << 1
} ECResetStrategy;

/** ECSlidingViewController is a view controller container that presents its child view controllers in two layers. The top layer can be panned to reveal the layers below it. */
@interface ECSlidingViewController : UIViewController

/** Returns the view controller that will be visible when the top view is slide to the right.
  
 This view controller is typically a menu or top-level view that switches out the top view controller.
 */
@property (nonatomic, strong) UIViewController *underLeftViewController;

/** Returns the view controller that will be visible when the top view is slide to the left.

 This view controller is typically a supplemental view to the top view.
 */
@property (nonatomic, strong) UIViewController *underRightViewController;

/** Returns the top view controller.
 
 This is the main view controller that is presented above the other view controllers.
 */
@property (nonatomic, strong) UIViewController *topViewController;

/** Returns the number of points the top view is visible when the top view is anchored to the left side.
 
 This value is fixed after rotation. If the number of points to reveal needs to be fixed, use anchorLeftRevealAmount.
 
 @see anchorLeftRevealAmount
 */
@property (nonatomic, unsafe_unretained) CGFloat anchorLeftPeekAmount;

/** Returns the number of points the top view is visible when the top view is anchored to the right side.
 
 This value is fixed after rotation. If the number of points to reveal needs to be fixed, use anchorRightRevealAmount.
 
 @see anchorRightRevealAmount
 */
@property (nonatomic, unsafe_unretained) CGFloat anchorRightPeekAmount;

/** Returns the number of points the under right view is visible when the top view is anchored to the left side.
 
 This value is fixed after rotation. If the number of points to peek needs to be fixed, use anchorLeftPeekAmount.
 
 @see anchorLeftPeekAmount
 */
@property (nonatomic, unsafe_unretained) CGFloat anchorLeftRevealAmount;

/** Returns the number of points the under left view is visible when the top view is anchored to the right side.
 
 This value is fixed after rotation. If the number of points to peek needs to be fixed, use anchorRightPeekAmount.
 
 @see anchorRightPeekAmount
 */
@property (nonatomic, unsafe_unretained) CGFloat anchorRightRevealAmount;

/** Specifies if the user should be able to interact with the top view when it is anchored.
 
 By default, this is set to NO
 */
@property (nonatomic, unsafe_unretained) BOOL shouldAllowUserInteractionsWhenAnchored;

/** Returns the strategy for resetting the top view when it is anchored.
 
 By default, this is set to ECPanning | ECTapping to allow both panning and tapping to reset the top view.
 
 If this is set to ECNone, then there must be a custom way to reset the top view otherwise it will stay anchored.
 */
@property (nonatomic, unsafe_unretained) ECResetStrategy resetStrategy;

/** Returns a horizontal panning gesture for moving the top view.
 
 This is typically added to the top view or a top view's navigation bar.
 */
- (UIPanGestureRecognizer *)panGesture;

/** Slides the top view in the direction of the specified side.
 
 A peek amount or reveal amount must be set for the given side. The top view will anchor to one of those specified values.
 
 @param side The side for the top view to slide towards.
 @param animations Perform changes to properties that will be animated while top view is moved off screen. Can be nil.
 @param onComplete Executed after the animation is completed. Can be nil.
 */
- (void)anchorTopViewTo:(ECSide)side animations:(void(^)())animations onComplete:(void(^)())complete;

/** Slides the top view off of the screen in the direction of the specified side.
 
 @param side The side for the top view to slide off the screen towards.
 @param animations Perform changes to properties that will be animated while top view is moved off screen. Can be nil.
 @param onComplete Executed after the animation is completed. Can be nil.
 */
- (void)anchorTopViewOffScreenTo:(ECSide)side animations:(void(^)())animations onComplete:(void(^)())complete;

/** Slides the top view back to the center. */
- (void)resetTopView;

@end

/** UIViewController extension */
@interface UIViewController(SlidingViewExtension)
/** Convience method for getting access to the ECSlidingViewController instance */
- (ECSlidingViewController *)slidingViewController;
@end
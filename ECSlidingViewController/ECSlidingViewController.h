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

/**
 The `ECSlidingViewControllerLayout` protocol is adopted by an object that specifies a custom layout for the child view controllers.
 */
@protocol ECSlidingViewControllerLayout <NSObject>

/**
 Called when the sliding view controller needs to update the child views in response to a rotation or bounds change.
 
 @param slidingViewController The sliding view controller that needs to update its layout.
 @param viewController The view controller that needs a layout update.
 @param topViewPosition The position of the top view.
 
 @return A frame for the given view controller at the given top view position. Return `CGRectInfinite` to use the default layout.
 */
- (CGRect)slidingViewController:(ECSlidingViewController *)slidingViewController
         frameForViewController:(UIViewController *)viewController
                topViewPosition:(ECSlidingViewControllerTopViewPosition)topViewPosition;
@end

/**
 The `ECSlidingViewControllerDelegate` protocol is adopted by an object that may customize a sliding view controller's animation transition, interactive transition, or the layout of the child views.
 */
@protocol ECSlidingViewControllerDelegate

@optional
/**
 Called to allow the delegate to return a non-interactive animator object for use during a transition.
 
 Returning an object will disable the sliding view controller's `transitionCoordinator` animation and completion callbacks.
 
 @param slidingViewController The sliding view controller that is being transitioned.
 @param operation The type of transition that is occuring. See `ECSlidingViewControllerOperation` for a list of possible values.
 @param topViewController
 
 @return The animator object responsible for managing the transition animations, or nil if you want to use the standard sliding view controller transitions. The object you return must conform to the `UIViewControllerAnimatedTransitioning` protocol.
 */
- (id<UIViewControllerAnimatedTransitioning>)slidingViewController:(ECSlidingViewController *)slidingViewController
                                   animationControllerForOperation:(ECSlidingViewControllerOperation)operation
                                                 topViewController:(UIViewController *)topViewController;

/**
 Called to allow the delegate to return an interactive animator object for use during a transition.
 
 Returning an object will disable the sliding view controller's `transitionCoordinator` block given to `notifyWhenInteractionEndsUsingBlock:`
 
 @param slidingViewController The sliding view controller that is being transitioned.
 @param animationController The non-interactive animator object. This will be the same object that is returned from `slidingViewController:animationController:topViewController`.
 
 @return The animator object responsible for managing the interactive transition, or nil if you want to use the standard sliding view controller transitions. The object you return must conform to the `UIViewControllerInteractiveTransitioning` protocol.
 */
- (id<UIViewControllerInteractiveTransitioning>)slidingViewController:(ECSlidingViewController *)slidingViewController
                          interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>)animationController;

/**
 Called to allow the delegate to return a layout object to customize the layout of a sliding view controller's child views.
 
 @param slidingViewController The sliding view controller whose layout needs updated.
 @param topViewPosition The position of the top view.
 
 @return The layout object responsible for managing the layout, or nil if you want to use the standard sliding view controller layout. The object you return must conform to the `ECSlidingViewControllerLayout` protocol.
 */
- (id<ECSlidingViewControllerLayout>)slidingViewController:(ECSlidingViewController *)slidingViewController
                        layoutControllerForTopViewPosition:(ECSlidingViewControllerTopViewPosition)topViewPosition;
@end

/**
 `ECSlidingViewController` is a view controller container that manages a layered interface. The top layer anchors to the left or right side of the container while revealing the layer underneath it. This is most commonly known as the "Side Menu", "Slide Out", "Hamburger Menu/Drawer/Sidebar", etc...
 
 The top layer and the layers underneath it can be any `UIViewController`. You provide the top layer by specifying a `topViewController`. Anchoring the top layer to the right will reveal the `underLeftViewController`. Likewise, to the left it will reveal the `underRightViewController`. These view controllers may be changed at anytime, and it is common to do so.
 
 There is no interface provided for anchoring the top layer, but there are methods and a gesture available for doing so. The `topViewController` will typically have a button to animate an anchoring and/or attach the provided `panGesture` to do it interactively.
 */

@interface ECSlidingViewController : UIViewController <UIViewControllerContextTransitioning,
                                                       UIViewControllerTransitionCoordinator,
                                                       UIViewControllerTransitionCoordinatorContext> {
    @private
    CGFloat _anchorLeftPeekAmount;
    CGFloat _anchorLeftRevealAmount;
    CGFloat _anchorRightPeekAmount;
    CGFloat _anchorRightRevealAmount;
    UIPanGestureRecognizer *_panGesture;
    UITapGestureRecognizer *_resetTapGesture;
                                                           
    @protected
    UIViewController *_topViewController;
    UIViewController *_underLeftViewController;
    UIViewController *_underRightViewController;
}


///----------------------------------------
/// @name Creating Sliding View Controllers
///----------------------------------------

/**
 Creates and returns a sliding view controller with the given `topViewController`.
 
 @param topViewController The view controller that will be displayed when sliding view controller loads.
 
 @return A sliding view controller with the given `topViewController`.
 */
+ (instancetype)slidingWithTopViewController:(UIViewController *)topViewController;

/**
 Initializes and returns a newly created sliding view controller.
 
 @param topViewController The view controller that will be displayed when sliding view controller loads.
 
 @return The initialized sliding view controller.
 */
- (instancetype)initWithTopViewController:(UIViewController *)topViewController;


///------------------------------------
/// @name Managing the View Controllers
///------------------------------------

/**
 The main view controller that anchors to the left or right side of the container.
 */
@property (nonatomic, strong) UIViewController *topViewController;

/**
 The view controller that is revealed when the top view anchors to the right side of the container.
 */
@property (nonatomic, strong) UIViewController *underLeftViewController;

/**
 The view controller that is revealed when the top view anchors to the left side of the container.
 */
@property (nonatomic, strong) UIViewController *underRightViewController;


///-----------------------------
/// @name Configuring the Layout
///-----------------------------

/**
 The fixed distance between the left side of the container and the right edge of the top view when the top view is anchored to the left. This value remains constant duration rotation or bound changes. Setting this value will automatically calculate `anchorLeftRevealAmount`. This value is not set by default, therefore it is variable and dependent upon the default value of `anchorLeftRevealAmount`.
 
 @see anchorLeftRevealAmount
 */
@property (nonatomic, assign) CGFloat anchorLeftPeekAmount;

/**
 The fixed distance between the right edge of the top view and the right side of the container when the top view is anchored to the left. This value remains constant duration rotation or bound changes. Setting this value will automatically calculate `anchorLeftPeekAmount`. This is set to 44.0 by default.
 
 @see anchorLeftPeekAmount
 */
@property (nonatomic, assign) CGFloat anchorLeftRevealAmount;

/**
 The fixed distance between the left edge of the top view and the right side of the container when the top view is anchored to the right. This value remains constant duration rotation or bound changes. Setting this value will automatically calculate `anchorRightRevealAmount`. This value si not set by default, therefore it is variable and dependent upon the default value of `anchorRightRevealAmount`.
 
 @see anchorRightRevealAmount
 */
@property (nonatomic, assign) CGFloat anchorRightPeekAmount;

/**
 The fixed distance between the left side of the container and the left edge of the top view when the top view is anchored to the right. This value remains constant duration rotation or bound changes. Setting this value will automatically calculate `anchorRightPeekAmount`. This is set to 276.0 by default.
 
 @see anchorRightPeekAmount
 */
@property (nonatomic, assign) CGFloat anchorRightRevealAmount;


///---------------------------
/// @name Moving the Top Layer
///---------------------------

/**
 Anchors the `topViewController`'s view to the right side of the container to reveal the `underLeftViewController`'s view.
 
 @param animated Specify `YES` to animate the transition or `NO` if you do not want the transition to be animated.
 */
- (void)anchorTopViewToRightAnimated:(BOOL)animated;

/**
 Anchors the `topViewController`'s view to the right side of the container to reveal the `underLeftViewController`'s view.
 
 @param animated Specify `YES` to animate the transition or `NO` if you do not want the transition to be animated.
 @param complete A completion handler.
 */
- (void)anchorTopViewToRightAnimated:(BOOL)animated onComplete:(void (^)())complete;

/**
 Anchors the `topViewController`'s view to the left side of the container to reveal the `underRightViewController`'s view.
 
 @param animated Specify `YES` to animate the transition or `NO` if you do not want the transition to be animated.
 */
- (void)anchorTopViewToLeftAnimated:(BOOL)animated;

/**
 Anchors the `topViewController`'s view to the left side of the container to reveal the `underRightViewController`'s view.
 
 @param animated Specify `YES` to animate the transition or `NO` if you do not want the transition to be animated.
 @param complete A completion handler.
 */
- (void)anchorTopViewToLeftAnimated:(BOOL)animated onComplete:(void (^)())complete;

/**
 Resets the `topViewController`'s view's position to the middle. Completely covers any view that was underneath it.
 
 @param animated Specify `YES` to animate the transition or `NO` if you do not want the transition to be animated.
 */
- (void)resetTopViewAnimated:(BOOL)animated;

/**
 Resets the `topViewController`'s view's position to the middle. Completely covers any view that was underneath it.
 
 @param animated Specify `YES` to animate the transition or `NO` if you do not want the transition to be animated.
 @param complete A completion handler.
 */
- (void)resetTopViewAnimated:(BOOL)animated onComplete:(void(^)())complete;


///--------------------------------------
/// @name User Defined Runtime Attributes
///--------------------------------------

/**
 The Storyboard identifier of a view controller to be used as the `topViewController`. Set this using the Identity Inspector for the sliding view controller instance in Storyboards.
 */
@property (nonatomic, strong) NSString *topViewControllerStoryboardId;

/**
 The Storyboard identifier of a view controller to be used as the `underLeftViewController`. Set this using the Identity Inspector for the sliding view controller instance in Storyboards.
 */
@property (nonatomic, strong) NSString *underLeftViewControllerStoryboardId;

/**
 The Storyboard identifier of a view controller to be used as the `underRightViewController`. Set this using the Identity Inspector for the sliding view controller instance in Storyboards.
 */
@property (nonatomic, strong) NSString *underRightViewControllerStoryboardId;


///-----------------------------------
/// @name Customizing Default Behavior
///-----------------------------------

/**
 The delegate that provides objects to customizing the transition animation, transition interaction, or layout of the child view controllers. See the `ECSlidingViewControllerDelegate` protocol for more information.
 */
@property (nonatomic, assign) id<ECSlidingViewControllerDelegate> delegate;

/**
 A mask of gestures/behaviors indicating how you want the top view to act while it is in the anchored position. Useful for customizing how you want your users to reset the top view. The default is `ECSlidingViewControllerAnchoredGestureNone`.
 */
@property (nonatomic, assign) ECSlidingViewControllerAnchoredGesture topViewAnchoredGesture;

/**
 The current position of the top view.
 */
@property (nonatomic, assign, readonly) ECSlidingViewControllerTopViewPosition currentTopViewPosition;

/**
 The gesture that triggers the default interactive transition for a horizontal swipe. This is typically added to the top view or one of the top view's subviews.
 */
@property (nonatomic, strong, readonly) UIPanGestureRecognizer *panGesture;

/**
 The gesture that triggers the top view to reset. Useful for resetting the top view when in the anchored position.
 */
@property (nonatomic, strong, readonly) UITapGestureRecognizer *resetTapGesture;

/**
 Gestures used on the top view while it is in the reset position. This is only used when the `topViewAnchoredGesture` property contains the  `ECSlidingViewControllerAnchoredGestureCustom` option.
 */
@property (nonatomic, strong) NSArray *customAnchoredGestures;

/**
 The default duration of the view transition.
 */
@property (nonatomic, assign) NSTimeInterval defaultTransitionDuration;

@end

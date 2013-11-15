// ECSlidingConstants.h
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

#ifndef ECSlidingViewController_ECSlidingConstants_h
#define ECSlidingViewController_ECSlidingConstants_h

/**
 Identifies the view controller that is the sliding view controller's `topViewController`. Pass this as an argument to `viewControllerForKey:` on an object that conforms to `UIViewControllerContextTransitioning`.
 */
static NSString *const ECTransitionContextTopViewControllerKey = @"ECTransitionContextTopViewControllerKey";

/**
 Identifies the view controller that is the sliding view controller's `underLeftViewController`. Pass this as an argument to `viewControllerForKey:` on an object that conforms to `UIViewControllerContextTransitioning`.
 */
static NSString *const ECTransitionContextUnderLeftControllerKey = @"ECTransitionContextUnderLeftControllerKey";

/**
 Identifies the view controller that is the sliding view controller's `underRightViewController`. Pass this as an argument to `viewControllerForKey:` on an object that conforms to `UIViewControllerContextTransitioning`.
 */
static NSString *const ECTransitionContextUnderRightControllerKey = @"ECTransitionContextUnderRightControllerKey";

/**
 These constants define the type of sliding view controller transitions that can occur.
 */
typedef NS_ENUM(NSInteger, ECSlidingViewControllerOperation) {
    /** The top view is not moving. */
    ECSlidingViewControllerOperationNone,
    /** The top view is moving from center to left. */
    ECSlidingViewControllerOperationAnchorLeft,
    /** The top view is moving from center to right. */
    ECSlidingViewControllerOperationAnchorRight,
    /** The top view is moving from left to center. */
    ECSlidingViewControllerOperationResetFromLeft,
    /** The top view is moving from right to center. */
    ECSlidingViewControllerOperationResetFromRight
};

/**
 These constants define the position of a sliding view controller's top view.
 */
typedef NS_ENUM(NSInteger, ECSlidingViewControllerTopViewPosition) {
    /** The top view is on anchored to the left */
    ECSlidingViewControllerTopViewPositionAnchoredLeft,
    /** The top view is on anchored to the right */
    ECSlidingViewControllerTopViewPositionAnchoredRight,
    /** The top view is centered */
    ECSlidingViewControllerTopViewPositionCentered
};

/**
 Options for gestures/behaviors given to a top view while it is anchored to the left or right.
 
 All the options except `ECSlidingViewControllerAnchoredGestureNone` will create a transparent view that is placed above the top view when it is anchored. This transparent view will block all gestures that are on the top view. Choose a combination of `ECSlidingViewControllerAnchoredGesturePanning`, `ECSlidingViewControllerAnchoredGestureTapping`, and `ECSlidingViewControllerAnchoredGestureCustom` to temporarily add gestures to the transparent view.
 */
typedef NS_OPTIONS(NSInteger, ECSlidingViewControllerAnchoredGesture) {
    /** Nothing is done to the top view while it is anchored. */
    ECSlidingViewControllerAnchoredGestureNone     = 0,
    /** The sliding view controller's `panGesture` is made available while the top view is anchored. This option is only relevant for transitions that use the default interactive transition. It is also only used if the sliding view controller's `panGesture` is enabled and added to a view. */
    ECSlidingViewControllerAnchoredGesturePanning  = 1 << 0,
    /** The sliding view controller's `resetTapGesture` is made available while the top view is anchored. */
    ECSlidingViewControllerAnchoredGestureTapping  = 1 << 1,
    /** Any gestures set on the sliding view controller's `customAnchoredGestures` property are made available while the top view is anchored. These gestures are temporarily removed from their current view. */
    ECSlidingViewControllerAnchoredGestureCustom   = 1 << 2,
    /** All user interactions on the top view are disabled when anchored. This takes precedence when combined with any other option. */
    ECSlidingViewControllerAnchoredGestureDisabled = 1 << 3
};

#endif

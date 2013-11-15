// ECPercentDrivenInteractiveTransition.h
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

/**
 Used to create a percent-driven interactive transition. Analogous to `UIPercentDrivenInteractiveTransition` except that it is compatible with `ECSlidingViewController`.
 
 See `ECSlidingInteractiveTransition` as an example subclass that uses a panning gesture to drive the percentage.
 
 You can subclass `ECPercentDrivenInteractiveTransition`, but if you do so you must start each of your method overrides with a call to the super implementation of the method.
 */
@interface ECPercentDrivenInteractiveTransition : NSObject <UIViewControllerInteractiveTransitioning>

/**
 The animator object that will be percent-driven. The animation will be triggered when the interactive transition is triggered, but instead of playing from start to finish it will be controlled by the calls to `updateInteractiveTransition:`, `cancelInteractiveTransition`, and `finishInteractiveTransition`.
 */
@property (nonatomic, strong) id<UIViewControllerAnimatedTransitioning> animationController;

/**
 The amount of the transition (specified as a percentage of the overall duration) that is complete.
 
 The value in this property reflects the last value passed to the `updateInteractiveTransition:` method.
 */
@property (nonatomic, assign, readonly) CGFloat percentComplete;

/**
 Updates the completion percentage of the transition. In general terms, this method is used to "scrub the playhead" of the animation defined by the `animationController`.
 
 While tracking user events, your code should call this method regularly to update the current progress toward completing the transition. If, during tracking, the interactions cross a threshold that you consider signifies the completion or cancellation of the transition, stop tracking events and call the finishInteractiveTransition or cancelInteractiveTransition method.
 */
- (void)updateInteractiveTransition:(CGFloat)percentComplete;

/**
 Causes the animation defined by the `animationController` to play from current `percentComplete` to zero percent. You must call this method or `finishInteractiveTransition` at some point during the interaction to ensure everything ends in a consistent state.
 */
- (void)cancelInteractiveTransition;

/**
 Causes the animation defined by the `animationController` to play from current `percentComplete` to 100 percent. You must call this method or `cancelInteractiveTransition` at some point during the interaction to ensure everything ends in a consistent state.
 */
- (void)finishInteractiveTransition;
@end

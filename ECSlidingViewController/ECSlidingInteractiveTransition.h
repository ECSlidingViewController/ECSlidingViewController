// ECSlidingInteractiveTransition.h
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
#import "ECPercentDrivenInteractiveTransition.h"
#import "ECSlidingViewController.h"

@class ECSlidingViewController;

/**
 Used internally by `ECSlidingViewController` as the default interactive transition. It uses the sliding view controller's `panGesture` to do a percent driven interaction transition. In most cases, developers will not need to use this class for anything, but it provides a good example of how to implement a percent driven transition with a gesture.
 
 Custom animation transitions take advantage of this interaction without having to create an instance of this class and returning it from the sliding view controller's delegate method `slidingViewController:interactionControllerForAnimationController:animationController:`. The sliding view controller's `panGesture` can be used to drive the custom animation.
 
 The initial direction of the panning determines the type of operation that is triggered. The reveal width represents 100 percent, and the panning distance determines values in-between the reveal width.
 */
@interface ECSlidingInteractiveTransition : ECPercentDrivenInteractiveTransition
- (id)initWithSlidingViewController:(ECSlidingViewController *)slidingViewController;
- (void)updateTopViewHorizontalCenterWithRecognizer:(UIPanGestureRecognizer *)recognizer;
@end

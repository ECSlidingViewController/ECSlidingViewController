# TransitionFun

Have fun with transitions with TransitionFun! This is a universal app that has an under left view and supports portrait and landscape modes. Select a transition from the table and trigger it by tapping the menu button or swiping the top view. Another thing to test out is the gestures when the top view is anchored. You can tap or pan the top view to reset it, and you cannot interact with the top view.

![gif](http://github.com/edgecase/ECSlidingViewController/wiki/readme-assets/TransitionFun.gif)

## How it's Made

There is a lot of plumbing in the project for setting up the table and changing the sliding view controller's delegate. We'll point out some of the more interesting parts here.

### Cached Top View Controllers

You'll notice that the transitions view controller table will remember the previously selected transition when switching between the it and the settings view controller. This is accomplished by caching the transitions view controller in the menu.

The sliding view controller is initialized in storyboards with the transitions view controller set as the `topViewController` and the menu view controller set as the `underLeftViewController`. We want to keep a reference to the transitions view controller from the menu view controller, so in `viewDidLoad:`

```objc
// self.transitionsNavigationController will keep a strong reference
self.transitionsNavigationController = (UINavigationController *)self.slidingViewController.topViewController;
```

When the user selects "Settings", we'll change the `topViewController`. In `tableView:didSelectRowAtIndexPath:`

```objc
self.slidingViewController.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MESettingsNavigationController"];
```

The `topViewController` is now replaced with a new instance of the settings view controller. We still have a reference to the transitions view controller that we kept in `viewDidLoad:`, so we can use that instance again when the user selects "Transitions"

```objc
self.slidingViewController.topViewController = self.transitionsNavigationController;
```

This replaces the settings view controller, but since we don't care about losing its state we'll let that instance be released by the system.

Re-using the same instance will prevent it from losing state. It's your responsibility to decide if a view controller should be cached or not while balancing memory usage.

### Custom Transitions

The `METransitionsViewController` is a bit more complex than your view controller would need to be to customize a transition. The important thing to see is that each custom transition is implemented in its own object that conforms to `ECSlidingViewControllerDelegate`. This cleans the view controller up and is better for reusability, and for this project it makes it easy to switch between transitions by changing the delegate.

```objc
id<ECSlidingViewControllerDelegate> transition = // some custom transition object
self.slidingViewController.delegate = transition;
```

`METransitionsViewController` is also responsible for setting up the gestures for itself. `ECSlidingViewController` doesn't make any assumptions as to how you want to trigger a transition, therefore you are responsible setting this up. The example sets the gestures up when a transition is selected.

```objc
if ([transitionName isEqualToString:METransitionNameDynamic]) {
    MEDynamicTransition *dynamicTransition = (MEDynamicTransition *)transition;
    dynamicTransition.slidingViewController = self.slidingViewController;

    self.slidingViewController.topViewAnchoredGesture = ECSlidingViewControllerAnchoredGestureTapping | ECSlidingViewControllerAnchoredGestureCustom;
    self.slidingViewController.customAnchoredGestures = @[self.dynamicTransitionPanGesture];
    [self.navigationController.view removeGestureRecognizer:self.slidingViewController.panGesture];
    [self.navigationController.view addGestureRecognizer:self.dynamicTransitionPanGesture];
} else {
    self.slidingViewController.topViewAnchoredGesture = ECSlidingViewControllerAnchoredGestureTapping | ECSlidingViewControllerAnchoredGesturePanning;
    self.slidingViewController.customAnchoredGestures = @[];
    [self.navigationController.view removeGestureRecognizer:self.dynamicTransitionPanGesture];
    [self.navigationController.view addGestureRecognizer:self.slidingViewController.panGesture];
}
```

Similar code is done in `MESettingsViewController` to add the relevant gesture to itself.

The `MEDynamicTransition` is an interactive transition, so it has its own way of triggering a transition with a pan gesture. The code above switches between using the default pan gesture and the dynamic transition pan gesture.

We're using the `topViewAnchoredGesture` property to select which gestures to use when the top view is anchored. For the dynamic transition we want to use the tap gesture and the dynamic panning gesture to reset the top view. The other case uses the default interactive transition pan gesture and a tap gesture for resetting.

Each custom transition conforms to the `ECSlidingViewControllerDelegate`. This allows the transition to decide if it wants to customize the animation, interaction, or layout.

#### Default

There is no object for the default transition.

```objc
self.slidingViewController.delegate = nil;
```

Setting the delegate to `nil` will use the default transition. The default animation is implemented in the `ECSlidingAnimationController` class and the default interaction is implemented in `ECSlidingInteractiveTransition`. See those classes to see how the default transition works.

#### Fold

The Fold transition only customizes the animation, so in addition to `ECSlidingViewControllerDelegate` it also conforms to `UIViewControllerAnimatedTransitioning`.

The default interactive transition is used with the Fold transition. This is done automatically by `ECSlidingViewController`, so nothing is done to make this happen. The only thing we have to do is make sure our sliding view controller's `panGesture` is on our top view somewhere. This gives our Fold animation a percent-driven interaction for free.

#### Zoom

The Zoom transition customizes the animation and layout. It conforms to `ECSlidingViewControllerDelegate`, `UIViewControllerAnimatedTransitioning`, and `ECSlidingViewControllerLayout`.

Similar to the Fold transition, the Zoom transition uses the default interactive transition.

The layout needs to be customized because the animation can start or end with a top view frame that `ECSlidingViewController` doesn't expect. We are not respecting the initial/final frames the `UIViewControllerContextTransitioning` object gives us, so we may get undesired results when the container changes bounds or rotates. The Zoom transition customizes the layout for the top view in an anchored right position, and it falls back on the defaults for everything else.

#### UIKit Dynamics

This is an interactive transition that uses UIKit Dynamics. The top view will bounce off the sides. The amount of bouncing depends on how fast the user throws the top view.

The non-interactive portion uses the default animation by maintaining an instance of `ECSlidingAnimationController` internally. If a transition is triggered outside the pan gesture, the default animation is animated in `startInteractiveTransition:`.

The transition is triggered by the pan gesture in `handlePanGesture:`. We anchor or reset the top view depending on which way we are swiping and where the top view's current position:

```objc
case UIGestureRecognizerStateBegan: {
    if (self.slidingViewController.currentTopViewPosition == ECSlidingViewControllerTopViewPositionCentered && isMovingRight && self.slidingViewController.underLeftViewController) {
        [self.slidingViewController anchorTopViewToRightAnimated:YES];
    } else if (self.slidingViewController.currentTopViewPosition == ECSlidingViewControllerTopViewPositionCentered && !isMovingRight && self.slidingViewController.underRightViewController) {
        [self.slidingViewController anchorTopViewToLeftAnimated:YES];
    } else if (self.slidingViewController.currentTopViewPosition == ECSlidingViewControllerTopViewPositionAnchoredLeft) {
        [self.slidingViewController resetTopViewAnimated:YES];
    } else if (self.slidingViewController.currentTopViewPosition == ECSlidingViewControllerTopViewPositionAnchoredRight) {
        [self.slidingViewController resetTopViewAnimated:YES];
    }

    break;
}
```

Since we return a non-nil object as an interactive transition object in `slidingViewController:interactionControllerForAnimationController:`, our `startInteractiveTransition:` will get called when we trigger the transition with a anchor or reset call. The `startInteractiveTransition:` method sets up the state based on the transition context and the pan gesture continues to the changed state:

```objc
case UIGestureRecognizerStateChanged: {
    CGRect topViewInitialFrame = self.initialTopViewFrame;
    CGFloat newLeftEdge = topViewInitialFrame.origin.x + translationX;

    if (newLeftEdge < 0) {
        newLeftEdge = 0;
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
```

The top view's frame is updated to follow the user's finger. The transition context is updated with the percentage, but this has no effect since we're not doing a percent driven transition.

When the user stops the panning is when UIKit Dynamics takes over updating the top view frame.

```objc
case UIGestureRecognizerStateEnded:
case UIGestureRecognizerStateCancelled: {
    self.isPanningRight = velocityX > 0;

    self.gravityBehavior.gravityDirection = self.isPanningRight ? CGVectorMake(2, 0) : CGVectorMake(-2, 0);

    self.pushBehavior.angle = 0; // velocity may be negative
    self.pushBehavior.magnitude = velocityX;
    self.pushBehavior.active = YES;

    [self.animator addBehavior:self.compositeBehavior];

    break;
}
```

This guide won't get into the specifics of how to use UIKit Dynamics, but you can see that we have a gravity and push behavior that depends on the speed and direction the user throws the top view.

At this point, our `UIDynamicAnimator` object takes over and updates the top view frame. We need to know when it is done so that we can tell our transition context that we finished or cancelled the transition. We are the delegate of the `UIDynamicAnimator` so we can implement `dynamicAnimatorDidPause:` to know when the dynamic animator is done.

```objc
- (void)dynamicAnimatorDidPause:(UIDynamicAnimator*)animator {
    if ((self.isPanningRight && self.positiveLeftToRight) || (!self.isPanningRight && !self.positiveLeftToRight)) {
        [self.transitionContext finishInteractiveTransition];
    } else if ((self.isPanningRight && !self.positiveLeftToRight) || (!self.isPanningRight && self.positiveLeftToRight)) {
        [self.transitionContext cancelInteractiveTransition];
    }

    [self.transitionContext completeTransition:YES];
}
```

The transition is finished if we ended our interaction in the direction we started. Otherwise it is cancelled. We call `completeTransition:` to let the transition context know we're done transitioning.

## MIT License

Copyright (c) 2013 Michael Enriquez (http://enriquez.me)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

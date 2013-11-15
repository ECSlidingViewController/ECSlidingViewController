# LayoutDemo

This app has a view controller on both the left and right sides. It supports rotation and is a universal app. Run it on the iPhone or iPad. Rotate it with the top view anchored to see how the layout is updated. You can swipe the top view to the left or right or tap on the buttons to trigger a transition.

![gif](http://github.com/edgecase/ECSlidingViewController/wiki/readme-assets/LayoutDemo.gif)

## How it's Made

All the code to accomplish this is in MEAppDelegate's `application:didFinishLaunchingWithOptions:`. You would normally create subclasses of the view controllers and keep your app delegate clean, but the focus of this example is to show how to configure a sliding view controller.

The interesting part of the code is how the layout is configured.

### Anchored Layout

The following is a snippet from this app:

```objc
self.slidingViewController.anchorRightPeekAmount  = 100.0;
self.slidingViewController.anchorLeftRevealAmount = 250.0;
```

If you anchor the top view to the right side then rotate the device you'll notice that the top view stays "peeking" by 100 points. If you anchor to the left side and rotate, you'll notice the "revealed" portion stays at a fixed 250 points. This is the difference between "peek" and "reveal".

### Under View Layout

The under views in this example are configured to extend their tops and bottoms to the top and bottom edge of the container. The sides are configured to extend to the edge of the screen to where the top view is anchored.

This is done using the `edgesForExtendedLayout` property on `UIViewController`. The `underLeftViewController` is configured like this:

```objc
underLeftViewController.edgesForExtendedLayout = UIRectEdgeTop | UIRectEdgeBottom | UIRectEdgeLeft;
```

We extend the edges to the top bottom and left. The `underRightViewController` looks like this:

```objc
underRightViewController.edgesForExtendedLayout = UIRectEdgeTop | UIRectEdgeBottom | UIRectEdgeRight;
```

The edges are extended to the top bottom and right side.

If we extended all of the edges, the view will be the same size of the container. It would be partially covered by the top view when anchored.

If we removed `UIRectEdgeTop` in this example, then the top of the view will be placed below the status bar.

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

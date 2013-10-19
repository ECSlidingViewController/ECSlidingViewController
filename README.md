# ECSlidingViewController

`ECSlidingViewController` is a view controller container for iOS that presents its child view controllers in two layers. It provides functionality for sliding the top view to reveal the views underneath it. This functionality is inspired by the Path 2.0 and Facebook iPhone apps.

<iframe src="http://player.vimeo.com/video/35959384?title=0&amp;byline=0&amp;portrait=0" width="400" height="300" frameborder="0" webkitAllowFullScreen mozallowfullscreen allowFullScreen></iframe><p><a href="http://vimeo.com/35959384">ECSlidingViewController Demo</a> from <a href="http://vimeo.com/user5026288">EdgeCase</a> on <a href="http://vimeo.com">Vimeo</a>.</p>

This project is an example app that showcases the uses for `ECSlidingViewController`. This app uses storyboards, but it is not required.


## Features

* Panning gesture to move top view can be set on any `UIView`. It is most likely a navigation bar or the whole top view itself.
* Configurable anchor positions, with automatic adjustments for orientation change. See "Anchor Position Geometry" section below.
* There are no assumptions about the size and layout of the views under the top view. See the `underLeftWidthLayout` and `underRightWidthLayout` properties if you need a common layout.
* The child views can be changed at anytime.
* Child view controllers can be an instance of `UIViewController` or any subclass of `UIViewController` including `UINavigationController` and `UITabBarController`.
* iPad support.
* VoiceOver support.
* See [ECSlidingViewController/Vendor/ECSlidingViewController/ECSlidingViewController.h](https://github.com/edgecase/ECSlidingViewController/blob/master/ECSlidingViewController/Vendor/ECSlidingViewController/ECSlidingViewController.h) for options and configuration.

## Requirements

* iOS 5
* ARC

## Getting Started

This section will walk through of a simplified version of the included example app. You'll see how to setup the top view that can be panned to the right side to reveal the under left view.

### Include ECSlidingViewController into your project

You'll need these two files:

* ECSlidingViewController/Vendor/ECSlidingViewController/ECSlidingViewController.h
* ECSlidingViewController/Vendor/ECSlidingViewController/ECSlidingViewController.m

OR - you can use [CocoaPods](http://cocoapods.org/). Add the following line to your Podspec:

    pod 'ECSlidingViewController', '~> 1.3.1'

### Setup storyboards and set the topViewController

Add a UIViewController to your storyboards and set the subclass to `ECSlidingViewController`.  Then, you'll need to configure the instance of this view controller by setting a `topViewController`

	  ECSlidingViewController *slidingViewController = (ECSlidingViewController *)self.window.rootViewController;
	  
	  slidingViewController.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FirstTop"];

In this example, we can get a reference to the `ECSlidingViewController` instance then, we set the `topViewController` with an instance of a `UIViewController` subclass called `FirstTopViewController` that is identified as "FirstTop".

### Configure the topViewController

The top view controller is responsible for two things:

* Setting the view controllers underneath it.
* Adding the `panGesture` to a `UIView`.

To do these, you must first add an `#import "ECSlidingViewController.h"` to the `FirstTopViewController` header. Then in the implementation you'll have access to a category on `UIViewController` called `slidingViewController`.  This the top-level instance of the `ECSlidingViewController` container.  With this instance, you can set the view controllers underneath the top view and add panning.

Below is the `viewWillAppear:` method for `FirstTopViewController`.

	- (void)viewWillAppear:(BOOL)animated
	{
	  [super viewWillAppear:animated];
	  
	  if (![self.slidingViewController.underLeftViewController isKindOfClass:[MenuViewController class]]) {
	    self.slidingViewController.underLeftViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
	  }
	  
	  [self.view addGestureRecognizer:self.slidingViewController.panGesture];
	  [self.slidingViewController setAnchorRightRevealAmount:280.0f];
	}

The above code will conditionally set the `underLeftViewController` if it is not already there. Then, it adds the gesture recognizer to the top view. The last line of code specifies the top view's anchor position on the right side.

## Anchor Position Geometry

There are four properties related to anchor positions. They are a combination of left, right, reveal amount, and peek amount. The diagrams below demonstrate the difference between peek and reveal.

* anchorLeftPeekAmount
* anchorRightPeekAmount
* anchorLeftRevealAmount
* anchorRightRevealAmount

Below is an example of the anchorRightPeekAmount set:

![anchorRightPeekAmount example](http://dl.dropbox.com/u/10937237/peek.png)

Below is an example of the anchorRightRevealAmount set:

![anchorRightRevealAmount example](http://dl.dropbox.com/u/10937237/reveal.png)

## Top View Shadow

`ECSlidingViewController` handles the shadowOffset, shadowPath, and their rotations for you automatically.  The following code in your top view controller will add a shadow:

    - (void)viewWillAppear:(BOOL)animated
    {
      [super viewWillAppear:animated];

	  self.view.layer.shadowOpacity = 0.75f;
	  self.view.layer.shadowRadius = 10.0f;
	  self.view.layer.shadowColor = [UIColor blackColor].CGColor;
	}

## MIT License
Copyright (C) 2013 EdgeCase

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

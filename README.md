# ECSlidingViewController 2

`ECSlidingViewController` is a view controller container that manages a layered interface. The top layer anchors to the left or right side of the container while revealing the layer underneath it. This is most commonly known as the "Side Menu", "Slide Out", "Hamburger Menu/Drawer/Sidebar", etc...

![iPhone and iPad Mini screenshots](http://i.imgur.com/WBHYZUf.png)

Supports all screen sizes and orientations.

## Features

The philosophy behind `ECSlidingViewController` is to provide simple defaults while being customizable. It may not work or look the way you want out of the box, but it doesn't get in the way when customizing it.

### Well Behaved View Controller Container

Your view controllers will receive the appropriate view life cycle and rotation methods at the right time. Their layouts will be appropriately updated on rotation or bound changes while respecting their `edgesForExtendedLayout` property. This means you have control over how your view controllers position themselves under or below the status bar, navigation bar, or any other container that sets a `topLayoutGuide`.

`ECSlidingViewController` tries its best to feel like it is a part of the `UIKit` view controller container family, and it works when nesting any combination of them together.

### Storyboards Support

Basic configuration can be done by using [User Defined Runtime Attributes](http://twoshotsofcocoa.com/?p=70). `ECSlidingViewController` comes with a custom segue and supports unwind segues for transitioning between view controllers.

This feature is optional and everything can be done programmatically if you wanted. Just like any other view controller container, you will most likely use Storyboards with some programmatic customizations.

### Custom Transitions

If the default sliding animation or swiping interaction to move the top view doesn't suit your needs, then you can customize them by providing your own.

Custom transitions use the new protocols introduced in iOS 7 while exposing an API similar to the API that the UIKit containers expose for custom transitions. You should feel right at home if you are familiar with the custom transition API in iOS 7.

## Requirements

* iOS 7
* Xcode 5

**Note**: For iOS 5-7 support, `ECSlidingViewController` version 1.x is [available on this branch](https://github.com/ECSlidingViewController/ECSlidingViewController/tree/1.x).

## Installation

Install with [CocoaPods](http://cocoapods.org) by adding the following to your Podfile:

``` ruby
platform :ios, '7.0'
pod 'ECSlidingViewController', '~> 2.0.3'
```

**Note**: We follow http://semver.org for versioning the public API.

Or copy the `ECSlidingViewController/` directory from this repo into your project.

## Documentation

### Header Files

The public API is documented in the header files. It will automatically show up in Xcode 5's quick help, or you can view it online:

[ECSlidingViewController Reference at cocoadocs.org](http://cocoadocs.org/docsets/ECSlidingViewController/)

### Sample Code

A good way to learn how to use `ECSlidingViewController` is to go through the example apps in `Examples.xcworkspace`. Each example has a README with an explanation of how things are done.

* [BasicMenu](Examples/BasicMenu/). Complete example using Storyboards with minimal code.
* [LayoutDemo](Examples/LayoutDemo/). This is a universal app showcasing the layout.
* [TransitionFun](Examples/TransitionFun). See how custom transitions are done.

**Note**: There is a problem with the simulator flashing the animation when cancelling an interactive transition. This does NOT happen on the device.

### Wiki

The wiki contains guides that go into more detail on how to use specific features of `ECSlidingViewController`.

[ECSlidingViewController Wiki Homepage](http://github.com/ECSlidingViewController/ECSlidingViewController/wiki)

## Getting Help

If you need help using `ECSlidingViewController`, please post a question on [StackOverflow with the "ECSlidingViewController" tag](http://stackoverflow.com/questions/ask?tags=ecslidingviewcontroller). Also, the more context you can provide (such as sample projects) the easier it will be for you to get help.

If you think you found a problem with `ECSlidingViewController`, please [post an issue](https://github.com/ECSlidingViewController/ECSlidingViewController/issues). A sample project or fork of any of the examples demonstrating the problem will help us fix the issue more quickly.

## Credits

Created and maintained by [Mike Enriquez](http://enriquez.me).

[Neo Innovation](http://neo.com) (formerly known as EdgeCase) for allowing Mike to work on `ECSlidingViewController` on company time during its inception. He is no longer with the company, but continues to maintain the project.

And... to those of you who [contributed changes](https://github.com/ECSlidingViewController/ECSlidingViewController/graphs/contributors) or [reported issues](https://github.com/ECSlidingViewController/ECSlidingViewController/issues).

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

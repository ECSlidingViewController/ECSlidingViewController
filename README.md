# ECSlidingViewController 2

`ECSlidingViewController` is a view controller container that manages a layered interface. The top layer anchors to the left or right side of the container while revealing the layer underneath it. This is most commonly known as the "Side Menu", "Slide Out", "Hamburger Menu/Drawer/Sidebar", etc...

![iPhone and iPad Mini screenshots](http://github.com/edgecase/ECSlidingViewController/wiki/readme-assets/readme-hero.png)

Supports all screen sizes and orientations.

## Features

### Well Behaved View Controller Container

Your view controllers will receive the appropriate view life cycle and rotation methods at the right time. Their layouts will be appropriately updated on rotation or bound changes while respecting their `edgesForExtendedLayout` property. This means you have control over how your view controllers position themselves under or below the status bar, navigation bar, or any other container that sets a `topLayoutGuide`.

`ECSlidingViewController` tries its best to feel like it is a part of the `UIKit` view controller container family, and it works when nesting any combination of them together.

### Storyboards Support

Basic configuration can be done by using [User Defined Runtime Attributes](http://twoshotsofcocoa.com/?p=70). `ECSlidingViewController` comes with a custom segue and supports unwind segues for transitioning between view controllers.

This feature is optional and everything can be done programmatically if you wanted. Just like any other view controller container, you will most likely use Storyboards with some programmatic customizations.

### Custom Transitions

If the default sliding animation or swiping interaction to move the top view doesn't suit your needs, then you can customize them.

Custom transitions use the new protocols introduced in iOS 7 while exposing an API similar to the API that the UIKit containers expose for custom transitions. You should feel right at home if you are familiar with the custom transition API in iOS 7.

## Requirements

* iOS 7
* Xcode 5

## Installation

Install with [CocoaPods](http://cocoapods.org) by adding the following to your Podfile:

``` ruby
platform :ios, '7.0'
pod 'ECSlidingViewController', '~> 2.0'
```

**Note**: We follow http://semver.org for versioning the API.

Or copy the `ECSlidingViewController/` directory from this repo into your project.

## Example Workspace Projects

A good way to learn how to use `ECSlidingViewController` is to go through the example apps in Examples.xcworkspace. Each example has a README with an explanation of how things are done.

* [BasicMenu](Examples/BasicMenu/). Complete example using Storyboards with minimal code.
* [LayoutDemo](Examples/LayoutDemo/). This is a universal app showcasing the layout.
* [TransitionFun](Examples/TransitionFun). See how custom transitions are done.

**Note**: There is a problem with the simulator flashing the animation when cancelling an interactive transition. This does NOT happen on the device.

## Credits

Created and maintained by [Mike Enriquez](http://enriquez.me).

[Neo Innovation](http://neo.com) (formerly known as EdgeCase) for allowing Mike to work on `ECSlidingViewController` on company time during its inception. He is no longer with the company, but continues to maintain the project.

And... to those of you who [contributed changes](https://github.com/edgecase/ECSlidingViewController/graphs/contributors) or [reported issues](https://github.com/edgecase/ECSlidingViewController/issues).

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

# ECSlidingViewController 2

`ECSlidingViewController` is a view controller container that manages a layered interface. The top layer anchors to the left or right side of the container while revealing the layer underneath it. This is most commonly known as the "Side Menu" or "Slide Out" as seen in the Path or Facebook iOS apps.

## Features

### Well Behaved View Controller Container

Your view controllers will receive the appropriate view lifecycle and rotation methods at the right time. Their layouts will be appropriately updated on rotation or bound changes while respecting their `edgesForExtendedLayout` property.

This allows you to use `ECSlidingViewController` in a similar fashion you would use a `UINavigationController`, `UITabBarController`, `UIPageViewController`, etc...

### Storyboards Support

`ECSlidingViewController` provides KVC compliant properties for setting user defined runtime attributes in Storyboards. Do your configuration in Storyboards, and use the built in segue with minimal code.

This feature is optional and everything can be done programmatically if you wanted. Just like any other view controller container, you will most likely use Storyboards with some programmatic customizations.

### Custom Transitions

Custom transitions use the new protocols introduced in iOS 7 while exposing an API similar to the API that the UIKit containers expose for custom transitions. You should feel right at home if you are familiar with the custom transition API in iOS 7.

## Requirements

* iOS 7
* Xcode 5

## Installation

Install with [Cocoapods](http://cocoapods.org) by adding the following to your Podfile:

``` ruby
pod 'ECSlidingViewController', '~> 2.0'
```

Or copy the `ECSlidingViewController/` directory from this repo into your project.

## Example Workspace Projects

A good way to learn how to use `ECSlidingViewController` is to go through the example apps in [Examples.xcworkspace](http://github.com/edgecase/ECSlidingViewController/blob/master/Examples.xcworkspace)

* BasicMenu. Complete example using Storyboards with minimal code.
* LayoutDemo. This is a universal app showcasing the layout.
* TransitionFun. See how custom transitions are done.

## Credits

Created and maintained by [Mike Enriquez](http://enriquez.me).

[Neo Innovation](http://neo.com) (formerly known as EdgeCase) for allowing Mike to work on `ECSlidingViewController` on company time during its inception. He is no longer with the company, but continues to maintain the project.

And... to those of you who [contributed changes](https://github.com/edgecase/ECSlidingViewController/graphs/contributors) or [reported issues](https://github.com/edgecase/ECSlidingViewController/issues).

## MIT License

Copyright (c) 2013 Mike Enriquez

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

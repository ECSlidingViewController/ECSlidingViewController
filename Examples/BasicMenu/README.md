# BasicMenu

This app consists of three screens: Home, Settings, and Menu. Tapping the menu button anchors the top view to the right to show the menu. From there, you can tap on Home or Settings to reset the top view to the middle while changing the top view controller. This example is also a good representation of the defaults used with `ECSlidingViewController`.

![gif](http://github.com/edgecase/ECSlidingViewController/wiki/readme-assets/BasicMenu.gif)

## How it's Made

This was made almost entirely in Storyboards except for the unwind segue. It may be difficult to see how the view controllers are related. This guide will show you where to look.

### ECSlidingViewController Container

Select the sliding view controller in the Storyboard and show the identity inspector (COMMAND-OPTION-3). You should see the following:

![Sliding View Controller Identity Inspector](http://github.com/edgecase/ECSlidingViewController/wiki/readme-assets/sliding-vc-attributes.png)

The sliding view controller needs to know which view controllers to load initially when itself is loaded. This is done in the "User Defined Runtime Attributes". We set the `topViewControllerStoryboardId` to the string value "HomeNavigationController". This will set the sliding view controller's `topViewController` to a view controller in Storyboard with the Storyboard ID "HomeNavigationController". The same thing is done to set the `underLeftViewController` to the "MenuViewController"

You should be able to find the navigation controller with the Storyboard ID "HomeNavigationController" and the table view controller with the Storyboard ID "MenuViewController".

### MenuViewController

The menu view controller is a simple table with two static rows. Each row has a sliding segue to a view controller. Click on either segue and show the attributes inspector (COMMAND-OPTION-4). You'll see that we're using a custom segue with the class `ECSlidingSegue`.

![Sliding Segue Attributes Inspector](http://github.com/edgecase/ECSlidingViewController/wiki/readme-assets/sliding-segue-attributes.png)

Sliding segues call the `resetTopViewAnimated:` method on the sliding view controller after setting the `topViewController` to the destination view controller. In this case, our segue from the "Home" row to the "HomeNavigationController" will set the `topViewController` to the navigation controller and then reset the top view. Same thing for the "Settings" row.

Note that the menu view controller has a custom subclass called `MEMenuViewController`. This class simply defines the unwind segue: `unwindToMenuViewController:`. We will be using this to unwind from the current top view controller to the menu.

### Unwind Segue

Both the Home and Settings view controllers have a menu button which causes the top view to slide to the right and show the menu. This is accomplished with an unwind segue. Make this connection by CTRL-dragging from the menu button down to the green exit symbol. Select `unwindToMenuViewController:` to unwind to the menu.

![Unwind Segue](http://github.com/edgecase/ECSlidingViewController/wiki/readme-assets/unwind-segue.png)

The unwind segue will detect that the current `underLeftViewController` instance is of the same type as the destination of the unwind segue. This will trigger a `anchorTopViewToRightAnimated:` on the sliding view controller. If the current under right view controller was the same type as the destination, then it will trigger an anchor to the left side instead.

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

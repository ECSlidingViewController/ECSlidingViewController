// ECSlidingSegue.h
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
 A sliding segue will transition a sliding view controller from an anchored position to a reset position. A common use for this is to segue from one of the under view controllers to a top view controller.
 */
@interface ECSlidingSegue : UIStoryboardSegue

/**
 Determines whether the destination view controller should replace the top view controller. This value can be set by casting a `UIStoryboardSegue` to a `ECSlidingSegue` in your view controller's `prepareForSegue:sender:` method.
 
 If set to `NO`, the top view controller will be replaced with an instance of the segue's destination view controller. If set to `YES`, the top view controller will not be replaced, and the existing top view controller will be used. Setting this to `YES` is useful for caching the top view controller and keeping its current state. The default value is `NO`.
 */
@property (nonatomic, assign) BOOL skipSettingTopViewController;
@end

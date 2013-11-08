// ECSlidingSegue.m
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

#import "ECSlidingSegue.h"

#import "UIViewController+ECSlidingViewController.h"

@interface ECSlidingSegue ()
/** Used internally by ECSlidingViewController */
@property (nonatomic, assign) BOOL isUnwinding;
@end

@implementation ECSlidingSegue

- (id)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination {
    self = [super initWithIdentifier:identifier source:source destination:destination];
    if (self) {
        self.isUnwinding = NO;
        self.skipSettingTopViewController = NO;
    }
    
    return self;
}

- (void)perform {
    ECSlidingViewController *slidingViewController = [[self sourceViewController] slidingViewController];
    UIViewController *destinationViewController    = [self destinationViewController];
    
    if (self.isUnwinding) {
        if ([slidingViewController.underLeftViewController isMemberOfClass:[destinationViewController class]]) {
            [slidingViewController anchorTopViewToRightAnimated:YES];
        } else if ([slidingViewController.underRightViewController isMemberOfClass:[destinationViewController class]]) {
            [slidingViewController anchorTopViewToLeftAnimated:YES];
        }
    } else {
        if (!self.skipSettingTopViewController) {
            slidingViewController.topViewController = destinationViewController;
        }
        
        [slidingViewController resetTopViewAnimated:YES];
    }
}

@end

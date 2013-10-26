//
//  ECSlidingSegue.m
//  ECSlidingViewController
//
//  Created by Michael Enriquez on 10/23/13.
//  Copyright (c) 2013 Mike Enriquez. All rights reserved.
//

#import "ECSlidingSegue.h"
#import "ECSlidingViewController.h"

@implementation ECSlidingSegue

- (void)perform {
    ECSlidingViewController *slidingViewController = [[self sourceViewController] slidingViewController];
    UIViewController *destinationViewController    = [self destinationViewController];
    
    slidingViewController.topViewController = destinationViewController;
    [slidingViewController resetTopViewAnimated:YES];
}

@end

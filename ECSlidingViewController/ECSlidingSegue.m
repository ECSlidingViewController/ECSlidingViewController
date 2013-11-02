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

- (id)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination {
    self = [super initWithIdentifier:identifier source:source destination:destination];
    if (self) {
        self.skipSettingTopViewController = NO;
    }
    
    return self;
}

- (void)perform {
    ECSlidingViewController *slidingViewController = [[self sourceViewController] slidingViewController];
    UIViewController *destinationViewController    = [self destinationViewController];
    
    if (!self.skipSettingTopViewController) {
        slidingViewController.topViewController = destinationViewController;
    }
    
    [slidingViewController resetTopViewAnimated:YES];
}

@end

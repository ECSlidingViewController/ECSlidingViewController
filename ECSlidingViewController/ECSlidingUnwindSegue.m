//
//  ECSlidingUnwindSegue.m
//  
//
//  Created by Michael Enriquez on 11/1/13.
//
//

#import "ECSlidingUnwindSegue.h"
#import "ECSlidingViewController.h"

@implementation ECSlidingUnwindSegue

- (void)perform {
    ECSlidingViewController *slidingViewController = [[self sourceViewController] slidingViewController];
    UIViewController *destinationViewController    = [self destinationViewController];
    
    if ([slidingViewController.underLeftViewController isMemberOfClass:[destinationViewController class]]) {
        [slidingViewController anchorTopViewToRightAnimated:YES];
    } else if ([slidingViewController.underRightViewController isMemberOfClass:[destinationViewController class]]) {
        [slidingViewController anchorTopViewToLeftAnimated:YES];
    }
}

@end

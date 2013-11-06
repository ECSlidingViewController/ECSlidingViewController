//
//  UIViewController+ECSlidingViewController.m
//  
//
//  Created by Mike Enriquez on 11/6/13.
//
//

#import "UIViewController+ECSlidingViewController.h"

@implementation UIViewController (ECSlidingViewController)

- (ECSlidingViewController *)slidingViewController {
    UIViewController *viewController = self.parentViewController ? self.parentViewController : self.presentingViewController;
    while (!(viewController == nil || [viewController isKindOfClass:[ECSlidingViewController class]])) {
        viewController = viewController.parentViewController ? viewController.parentViewController : viewController.presentingViewController;
    }
    
    return (ECSlidingViewController *)viewController;
}

@end

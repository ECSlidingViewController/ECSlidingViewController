//
//  NavigationTopViewController.m
//  ECSlidingViewController
//
//  Created by Michael Enriquez on 2/13/12.
//  Copyright (c) 2012 EdgeCase. All rights reserved.
//

#import "NavigationTopViewController.h"

@implementation NavigationTopViewController

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  UIStoryboard *storyboard;
  
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
    storyboard = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
  } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    storyboard = [UIStoryboard storyboardWithName:@"iPad" bundle:nil];
  }
  
  if (![self.slidingViewController.underLeftViewController isKindOfClass:[MenuViewController class]]) {
    self.slidingViewController.underLeftViewController  = [storyboard instantiateViewControllerWithIdentifier:@"Menu"];
  }
  
  if (![self.slidingViewController.underRightViewController isKindOfClass:[UnderRightViewController class]]) {
    self.slidingViewController.underRightViewController = [storyboard instantiateViewControllerWithIdentifier:@"UnderRight"];
  }
  
  [self.view addGestureRecognizer:self.slidingViewController.panGesture];
}

@end

//
//  SecondTopViewController.m
//  ECSlidingViewController
//
//  Created by Michael Enriquez on 1/23/12.
//  Copyright (c) 2012 EdgeCase. All rights reserved.
//

#import "SecondTopViewController.h"

@implementation SecondTopViewController

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  if (![self.slidingViewController.underLeftViewController isKindOfClass:[MenuViewController class]]) {
    self.slidingViewController.underLeftViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
  }
  self.slidingViewController.underRightViewController = nil;
  self.slidingViewController.anchorLeftPeekAmount     = 0;
  self.slidingViewController.anchorLeftRevealAmount   = 0;
  
  [self.view addGestureRecognizer:self.slidingViewController.panGesture];
}

- (IBAction)revealMenu:(id)sender
{
  [self.slidingViewController anchorTopViewTo:ECRight];
}

@end

//
//  ThirdTopViewController.m
//  ECSlidingViewController
//
//  Created by Michael Enriquez on 1/23/12.
//  Copyright (c) 2012 EdgeCase. All rights reserved.
//

#import "ThirdTopViewController.h"

@implementation ThirdTopViewController

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [self.view addGestureRecognizer:self.slidingViewController.panGesture];
  self.slidingViewController.underRightViewController = nil;
}

- (IBAction)revealMenu:(id)sender
{
  [self.slidingViewController anchorToRight];
}

@end

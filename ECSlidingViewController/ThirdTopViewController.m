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
  [self.slidingViewController enablePanningInDirection:ECSlideLeft forView:self.view peekAmount:40.0f];
  [self.slidingViewController enablePanningInDirection:ECSlideRight forView:self.view peekAmount:40.0f];
  self.slidingViewController.underRightViewController = nil;
}

- (IBAction)revealMenu:(id)sender
{
  [self.slidingViewController slideInDirection:ECSlideRight peekAmount:40.0f onComplete:nil];
}

@end

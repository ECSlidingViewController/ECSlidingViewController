//
//  FirstTopViewController.m
//  ECSlidingViewController
//
//  Created by Michael Enriquez on 1/23/12.
//  Copyright (c) 2012 EdgeCase. All rights reserved.
//

#import "FirstTopViewController.h"

@implementation FirstTopViewController

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  self.view.layer.shadowOffset = CGSizeZero;
  self.view.layer.shadowOpacity = 0.75f;
  self.view.layer.shadowRadius = 10.0f;
  self.view.layer.shadowColor = [UIColor blackColor].CGColor;
  self.view.clipsToBounds = NO;
  
  [self.slidingViewController enablePanningInDirection:ECSlideLeft forView:self.view peekAmount:40.0f];
  [self.slidingViewController enablePanningInDirection:ECSlideRight forView:self.view peekAmount:40.0f];
  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
  self.slidingViewController.underRightViewController = [storyboard instantiateViewControllerWithIdentifier:@"UnderRight"];
}

- (IBAction)revealMenu:(id)sender
{
  [self.slidingViewController slideInDirection:ECSlideRight peekAmount:40.0f onComplete:nil];
}

- (IBAction)revealUnderRight:(id)sender
{
  [self.slidingViewController slideInDirection:ECSlideLeft peekAmount:40.0f onComplete:nil];
}

@end
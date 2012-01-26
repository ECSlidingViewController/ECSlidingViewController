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
  self.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.view.layer.bounds].CGPath;
  self.view.clipsToBounds = NO;
  
  [self.slidingViewController enablePanningInDirection:ECSlideLeft forView:self.view peekAmount:40.0f];
  [self.slidingViewController enablePanningInDirection:ECSlideRight forView:self.view peekAmount:40.0f];
  
  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
  self.slidingViewController.underRightViewController = [storyboard instantiateViewControllerWithIdentifier:@"UnderRight"];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
  // if going from portrait to landscape or landscape to portrait
  if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation) != UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
    // adjust peek amount
    if ([self.slidingViewController underLeftShowing] && UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
      [self.slidingViewController jumpToPeekAmount:26.0f inDirection:ECSlideRight];
    } else if ([self.slidingViewController underLeftShowing] && UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
      [self.slidingViewController jumpToPeekAmount:60.0f inDirection:ECSlideRight];
    } else if ([self.slidingViewController underRightShowing] && UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
      [self.slidingViewController jumpToPeekAmount:26.0f inDirection:ECSlideLeft];
    } else if ([self.slidingViewController underRightShowing] && UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
      [self.slidingViewController jumpToPeekAmount:60.0f inDirection:ECSlideLeft];
    }
  }
  
  self.view.layer.shadowPath = nil;
  self.view.layer.shouldRasterize = YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
  if ([self.slidingViewController underLeftShowing]) {
    [self.slidingViewController jumpToPeekAmount:40.0f inDirection:ECSlideRight];
  } else if ([self.slidingViewController underRightShowing]) {
    [self.slidingViewController jumpToPeekAmount:40.0f inDirection:ECSlideLeft];
  }
  
  self.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.view.layer.bounds].CGPath;
  self.view.layer.shouldRasterize = NO;
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
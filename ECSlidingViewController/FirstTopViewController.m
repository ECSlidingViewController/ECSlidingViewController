//
//  FirstTopViewController.m
//  ECSlidingViewController
//
//  Created by Michael Enriquez on 1/23/12.
//  Copyright (c) 2012 EdgeCase. All rights reserved.
//

#import "FirstTopViewController.h"

@interface FirstTopViewController()
@property (nonatomic, unsafe_unretained) CGFloat peekRight;
@property (nonatomic, unsafe_unretained) CGFloat peekLeft;
@end

@implementation FirstTopViewController
@synthesize peekRight;
@synthesize peekLeft;

- (void)viewDidLoad
{
  self.peekRight = 40.0f;
  self.peekLeft  = 40.0f;
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  self.view.layer.shadowOffset = CGSizeZero;
  self.view.layer.shadowOpacity = 0.75f;
  self.view.layer.shadowRadius = 10.0f;
  self.view.layer.shadowColor = [UIColor blackColor].CGColor;
  self.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.view.layer.bounds].CGPath;
  self.view.clipsToBounds = NO;
  
  [self.slidingViewController enablePanningInDirection:ECSlideLeft forView:self.view peekAmount:self.peekLeft];
  [self.slidingViewController enablePanningInDirection:ECSlideRight forView:self.view peekAmount:self.peekRight];
  
  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
  self.slidingViewController.underRightViewController = [storyboard instantiateViewControllerWithIdentifier:@"UnderRight"];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
  if ([self.slidingViewController underLeftShowing] && ![self.slidingViewController topViewIsOffScreen]) {
    [self.slidingViewController jumpToPeekAmount:self.peekRight inDirection:ECSlideRight];
  } else if ([self.slidingViewController underRightShowing] && ![self.slidingViewController topViewIsOffScreen]) {
    [self.slidingViewController jumpToPeekAmount:self.peekLeft inDirection:ECSlideLeft];
  } else if ([self.slidingViewController underLeftShowing] && [self.slidingViewController topViewIsOffScreen]) {
    [self.slidingViewController jumpToPeekAmount:0 inDirection:ECSlideRight];
  } else if ([self.slidingViewController underRightShowing] && [self.slidingViewController topViewIsOffScreen]) {
    [self.slidingViewController jumpToPeekAmount:0 inDirection:ECSlideLeft];
  }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
  self.view.layer.shadowPath = nil;
  self.view.layer.shouldRasterize = YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
  self.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.view.layer.bounds].CGPath;
  self.view.layer.shouldRasterize = NO;
}

- (IBAction)revealMenu:(id)sender
{
  [self.slidingViewController slideInDirection:ECSlideRight peekAmount:self.peekRight onComplete:nil];
}

- (IBAction)revealUnderRight:(id)sender
{
  [self.slidingViewController slideInDirection:ECSlideLeft peekAmount:self.peekLeft onComplete:nil];
}

@end
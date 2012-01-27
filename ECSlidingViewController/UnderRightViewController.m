//
//  UnderRightViewController.m
//  ECSlidingViewController
//
//  Created by Michael Enriquez on 1/23/12.
//  Copyright (c) 2012 EdgeCase. All rights reserved.
//

#import "UnderRightViewController.h"

@interface UnderRightViewController()
@property (nonatomic, unsafe_unretained) CGFloat peekAmount;
- (void)updateLayoutForOrientation:(UIInterfaceOrientation)orientation;
@end

@implementation UnderRightViewController
@synthesize peekAmount;

- (void)viewDidLoad
{
  self.peekAmount = 40.0f;
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [self updateLayoutForOrientation:self.interfaceOrientation];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
  [self updateLayoutForOrientation:toInterfaceOrientation];
}

- (void)updateLayoutForOrientation:(UIInterfaceOrientation)orientation
{
  if (UIInterfaceOrientationIsLandscape(orientation)) {
    CGRect frame = self.view.frame;
    frame.origin.x = self.peekAmount;
    frame.size.width = [UIScreen mainScreen].bounds.size.height - self.peekAmount;
    self.view.frame = frame;
  } else if (UIInterfaceOrientationIsPortrait(orientation)) {
    CGRect frame = self.view.frame;
    frame.origin.x = self.peekAmount;
    frame.size.width = [UIScreen mainScreen].bounds.size.width - self.peekAmount;
    self.view.frame = frame;
  }
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
  [self.slidingViewController slideInDirection:ECSlideLeft peekAmount:0.0f onComplete:nil];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
  [self.slidingViewController slideInDirection:ECSlideLeft peekAmount:self.peekAmount onComplete:nil];
}

@end

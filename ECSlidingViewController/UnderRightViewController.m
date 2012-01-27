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
@property (nonatomic, unsafe_unretained) BOOL isSearching;
- (void)updateLayoutForOrientation:(UIInterfaceOrientation)orientation;
@end

@implementation UnderRightViewController
@synthesize peekAmount;
@synthesize isSearching;

- (void)viewDidLoad
{
  self.peekAmount  = 40.0f;
  self.isSearching = NO;
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
  CGRect frame = self.view.frame;
  CGFloat newLeftEdge;
  CGFloat newWidth;
  
  if (UIInterfaceOrientationIsLandscape(orientation)) {
    newWidth = [UIScreen mainScreen].bounds.size.height;
  } else if (UIInterfaceOrientationIsPortrait(orientation)) {
    newWidth = [UIScreen mainScreen].bounds.size.width;
  }
  
  if (self.isSearching) {
    newLeftEdge = 0;
  } else {
    newLeftEdge = self.peekAmount;
    newWidth   -= self.peekAmount;
  }
  
  frame.origin.x = newLeftEdge;
  frame.size.width = newWidth;
  
  self.view.frame = frame;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
  [UIView animateWithDuration:0.25f animations:^{
    CGRect frame = self.view.frame;
    frame.origin.x = 0.0f;
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
      frame.size.width = [UIScreen mainScreen].bounds.size.height;
    } else if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
      frame.size.width = [UIScreen mainScreen].bounds.size.width;
    }
    self.view.frame = frame;
  }];
  [self.slidingViewController slideInDirection:ECSlideLeft peekAmount:-1.0f onComplete:nil];
  self.isSearching = YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
  [UIView animateWithDuration:0.25f animations:^{
    CGRect frame = self.view.frame;
    frame.origin.x = self.peekAmount;
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
      frame.size.width = [UIScreen mainScreen].bounds.size.height - self.peekAmount;
    } else if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
      frame.size.width = [UIScreen mainScreen].bounds.size.width - self.peekAmount;
    }
    self.view.frame = frame;
  }];
  [self.slidingViewController slideInDirection:ECSlideLeft peekAmount:self.peekAmount onComplete:nil];
  self.isSearching = NO;
}

@end

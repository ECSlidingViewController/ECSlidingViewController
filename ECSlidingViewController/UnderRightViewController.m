//
//  UnderRightViewController.m
//  ECSlidingViewController
//
//  Created by Michael Enriquez on 1/23/12.
//  Copyright (c) 2012 EdgeCase. All rights reserved.
//

#import "UnderRightViewController.h"

@interface UnderRightViewController()
@property (nonatomic, unsafe_unretained) CGFloat peekLeftAmount;
@property (nonatomic, unsafe_unretained) BOOL isSearching;
- (void)updateLayoutForOrientation:(UIInterfaceOrientation)orientation;
@end

@implementation UnderRightViewController
@synthesize peekLeftAmount;
@synthesize isSearching;

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.peekLeftAmount = 40.0f;
  self.isSearching = NO;
  [self.slidingViewController setAnchorLeftPeekAmount:self.peekLeftAmount];
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
    newLeftEdge = self.peekLeftAmount;
    newWidth   -= self.peekLeftAmount;
  }
  
  frame.origin.x = newLeftEdge;
  frame.size.width = newWidth;
  
  self.view.frame = frame;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
  [self.slidingViewController anchorTopViewOffScreenTo:ECLeft animations:^{
    CGRect frame = self.view.frame;
    frame.origin.x = 0.0f;
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
      frame.size.width = [UIScreen mainScreen].bounds.size.height;
    } else if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
      frame.size.width = [UIScreen mainScreen].bounds.size.width;
    }
    self.view.frame = frame;
  } onComplete:^{
    self.isSearching = YES;
  }];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
  [self.slidingViewController anchorTopViewTo:ECLeft animations:^{
    CGRect frame = self.view.frame;
    frame.origin.x = self.peekLeftAmount;
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
      frame.size.width = [UIScreen mainScreen].bounds.size.height - self.peekLeftAmount;
    } else if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
      frame.size.width = [UIScreen mainScreen].bounds.size.width - self.peekLeftAmount;
    }
    self.view.frame = frame;
  } onComplete:^{
    self.isSearching = NO;
  }];
}

@end

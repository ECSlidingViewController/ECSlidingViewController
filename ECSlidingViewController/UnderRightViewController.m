//
//  UnderRightViewController.m
//  ECSlidingViewController
//
//  Created by Michael Enriquez on 1/23/12.
//  Copyright (c) 2012 EdgeCase. All rights reserved.
//

#import "UnderRightViewController.h"

@interface UnderRightViewController()
@property (nonatomic, assign) CGFloat peekLeftAmount;
@end

@implementation UnderRightViewController
@synthesize peekLeftAmount;

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.peekLeftAmount = 40.0f;
  [self.slidingViewController setAnchorLeftPeekAmount:self.peekLeftAmount];
  self.slidingViewController.underRightWidthLayout = ECVariableRevealWidth;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
  [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
  [self.slidingViewController anchorTopViewOffScreenTo:ECLeft animations:^{
    CGRect frame = self.view.frame;
    frame.origin.x = 0.0f;
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
      frame.size.width = [UIScreen mainScreen].bounds.size.height;
      frame.size.height = [UIScreen mainScreen].bounds.size.width;
    } else if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
      frame.size.width = [UIScreen mainScreen].bounds.size.width;
      frame.size.height = [UIScreen mainScreen].bounds.size.height;
    }
    self.view.frame = frame;
  } onComplete:nil];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
  [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
  [self.slidingViewController anchorTopViewTo:ECLeft animations:^{
    CGRect frame = self.view.frame;
    frame.origin.x = self.peekLeftAmount;
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
      frame.size.width = [UIScreen mainScreen].bounds.size.height - self.peekLeftAmount;
    } else if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
      frame.size.width = [UIScreen mainScreen].bounds.size.width - self.peekLeftAmount;
    }
    self.view.frame = frame;
  } onComplete:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return nil;
}


@end

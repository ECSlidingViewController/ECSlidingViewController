//
//  UnderRightViewController.m
//  ECSlidingViewController
//
//  Created by Michael Enriquez on 1/23/12.
//  Copyright (c) 2012 EdgeCase. All rights reserved.
//

#import "UnderRightViewController.h"

@implementation UnderRightViewController

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
  [self.slidingViewController slideOffToLeftOnComplete:nil];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
  [self.slidingViewController anchorToLeft];
}

@end

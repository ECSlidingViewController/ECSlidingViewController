//
//  SecondTopViewController.m
//  ECSlidingViewController
//
//  Created by Michael Enriquez on 1/23/12.
//  Copyright (c) 2012 EdgeCase. All rights reserved.
//

#import "SecondTopViewController.h"

@implementation SecondTopViewController

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  if (![self.slidingViewController.underLeftViewController isKindOfClass:[MenuViewController class]]) {
    UIStoryboard *storyboard;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
      storyboard = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
      storyboard = [UIStoryboard storyboardWithName:@"iPad" bundle:nil];
    }
    
    self.slidingViewController.underLeftViewController = [storyboard instantiateViewControllerWithIdentifier:@"Menu"];
  }
  self.slidingViewController.underRightViewController = nil;
  self.slidingViewController.anchorLeftPeekAmount     = 0;
  self.slidingViewController.anchorLeftRevealAmount   = 0;
  
  [self.view addGestureRecognizer:self.slidingViewController.panGesture];
}

- (IBAction)revealMenu:(id)sender
{
  [self.slidingViewController anchorTopViewTo:ECRight animations:nil onComplete:nil];
}

@end

//
//  ECSlidingInteractiveTransition.h
//  ECSlidingViewController
//
//  Created by Michael Enriquez on 10/13/13.
//  Copyright (c) 2013 Mike Enriquez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECSlidingViewController.h"
#import "ECPercentDrivenInteractiveTransition.h"

@class ECSlidingViewController;

@interface ECSlidingInteractiveTransition : ECPercentDrivenInteractiveTransition
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
- (id)initWithSlidingViewController:(ECSlidingViewController *)slidingViewController;
@end

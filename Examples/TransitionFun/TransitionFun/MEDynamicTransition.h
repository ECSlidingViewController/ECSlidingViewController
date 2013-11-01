//
//  MEDynamicTransition.h
//  TransitionFun
//
//  Created by Michael Enriquez on 10/31/13.
//  Copyright (c) 2013 Mike Enriquez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ECSlidingViewController.h"
#import "ECPercentDrivenInteractiveTransition.h"

@interface MEDynamicTransition : NSObject <UIViewControllerAnimatedTransitioning,
                                           UIViewControllerInteractiveTransitioning,
                                           UIDynamicAnimatorDelegate>
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
- (id)initWithSlidingViewController:(ECSlidingViewController *)slidingViewController;
@end

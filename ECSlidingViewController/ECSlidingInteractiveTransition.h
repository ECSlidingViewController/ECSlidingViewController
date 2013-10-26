//
//  ECSlidingInteractiveTransition.h
//  ECSlidingViewController
//
//  Created by Michael Enriquez on 10/13/13.
//  Copyright (c) 2013 Mike Enriquez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ECSlidingInteractiveTransition : NSObject <UIViewControllerInteractiveTransitioning>
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
- (id)initWithTransitionContext:(id<UIViewControllerContextTransitioning>)transitionContext
            animationController:(id<UIViewControllerAnimatedTransitioning>)animationController;
@end

//
//  ECSlidingAnimationController.h
//  ECSlidingViewController
//
//  Created by Michael Enriquez on 10/12/13.
//  Copyright (c) 2013 Mike Enriquez. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ECSlidingAnimationController : NSObject <UIViewControllerAnimatedTransitioning>
@property (nonatomic, copy) void (^coordinatorAnimations)(id<UIViewControllerTransitionCoordinatorContext>context);
@property (nonatomic, copy) void (^coordinatorCompletion)(id<UIViewControllerTransitionCoordinatorContext>context);
@end

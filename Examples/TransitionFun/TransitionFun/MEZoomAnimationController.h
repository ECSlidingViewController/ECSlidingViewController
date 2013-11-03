//
//  MEZoomAnimationController.h
//  TransitionFun
//
//  Created by Michael Enriquez on 10/30/13.
//  Copyright (c) 2013 Mike Enriquez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ECSlidingViewController.h"

@interface MEZoomAnimationController : NSObject <UIViewControllerAnimatedTransitioning, ECSlidingViewControllerLayout>
@property (nonatomic, assign) ECSlidingViewControllerOperation operation;
@end

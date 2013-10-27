//
//  ECSlidingConstants.h
//  ECSlidingViewController
//
//  Created by Michael Enriquez on 10/14/13.
//  Copyright (c) 2013 Mike Enriquez. All rights reserved.
//

#ifndef ECSlidingViewController_ECSlidingConstants_h
#define ECSlidingViewController_ECSlidingConstants_h

static NSString *const ECTransitionContextTopViewControllerKey    = @"ECTransitionContextTopViewControllerKey";
static NSString *const ECTransitionContextUnderLeftControllerKey  = @"ECTransitionContextUnderLeftControllerKey";
static NSString *const ECTransitionContextUnderRightControllerKey = @"ECTransitionContextUnderRightControllerKey";

typedef NS_ENUM(NSInteger, ECSlidingViewControllerOperation) {
    ECSlidingViewControllerOperationNone,
    ECSlidingViewControllerOperationAnchorLeft,
    ECSlidingViewControllerOperationAnchorRight,
    ECSlidingViewControllerOperationResetFromLeft,
    ECSlidingViewControllerOperationResetFromRight
};

typedef NS_ENUM(NSInteger, ECSlidingViewControllerTopViewPosition) {
    ECSlidingViewControllerTopViewPositionAnchoredLeft,
    ECSlidingViewControllerTopViewPositionAnchoredRight,
    ECSlidingViewControllerTopViewPositionCentered
};

typedef NS_OPTIONS(NSUInteger, ECSlidingViewLayout) {
    ECSlidingViewLayoutDefault                 = 0,
    ECSlidingViewLayoutWidthFullContainer      = 1 << 0,
    ECSlidingViewLayoutWidthReveal             = 1 << 1,
    ECSlidingViewLayoutTopContainer            = 1 << 2,
    ECSlidingViewLayoutTopTopLayoutGuide       = 1 << 3,
    ECSlidingViewLayoutBottomContainer         = 1 << 4,
    ECSlidingViewLayoutBottomBottomLayoutGuide = 1 << 5
};

#endif

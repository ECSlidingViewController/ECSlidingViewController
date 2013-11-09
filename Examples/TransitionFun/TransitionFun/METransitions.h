//
//  METransitions.h
//  TransitionFun
//
//  Created by Mike Enriquez on 11/8/13.
//  Copyright (c) 2013 Mike Enriquez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ECSlidingViewController.h"

FOUNDATION_EXPORT NSString *const METransitionNameDefault;
FOUNDATION_EXPORT NSString *const METransitionNameFold;
FOUNDATION_EXPORT NSString *const METransitionNameZoom;
FOUNDATION_EXPORT NSString *const METransitionNameDynamic;

@interface METransitions : NSObject {
    NSArray *_all;
}

@property (nonatomic, strong, readonly) NSArray *all;
@end

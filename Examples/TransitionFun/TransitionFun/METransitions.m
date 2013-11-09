//
//  METransitions.m
//  TransitionFun
//
//  Created by Mike Enriquez on 11/8/13.
//  Copyright (c) 2013 Mike Enriquez. All rights reserved.
//

#import "METransitions.h"
#import "MEFoldAnimationController.h"
#import "MEZoomAnimationController.h"
#import "MEDynamicTransition.h"

NSString * const METransitionNameDefault = @"Default";
NSString * const METransitionNameFold    = @"Fold";
NSString * const METransitionNameZoom    = @"Zoom";
NSString * const METransitionNameDynamic = @"UIKit Dynamics";

@interface METransitions ()
@property (nonatomic, strong) MEFoldAnimationController *foldAnimationController;
@property (nonatomic, strong) MEZoomAnimationController *zoomAnimationController;
@property (nonatomic, strong) MEDynamicTransition *dynamicTransition;
@end

@implementation METransitions

#pragma mark - Public

- (NSArray *)all {
    if (_all) return _all;
    
    _all = @[@{ @"name" : METransitionNameDefault, @"transition" : [NSNull null] },
             @{ @"name" : METransitionNameFold,    @"transition" : self.foldAnimationController },
             @{ @"name" : METransitionNameZoom,    @"transition" : self.zoomAnimationController },
             @{ @"name" : METransitionNameDynamic, @"transition" : self.dynamicTransition }];
    
    return _all;
}

#pragma mark - Properties

- (MEFoldAnimationController *)foldAnimationController {
    if (_foldAnimationController) return _foldAnimationController;
    
    _foldAnimationController = [[MEFoldAnimationController alloc] init];
    
    return _foldAnimationController;
}

- (MEZoomAnimationController *)zoomAnimationController {
    if (_zoomAnimationController) return _zoomAnimationController;
    
    _zoomAnimationController = [[MEZoomAnimationController alloc] init];
    
    return _zoomAnimationController;
}

- (MEDynamicTransition *)dynamicTransition {
    if (_dynamicTransition) return _dynamicTransition;
    
    _dynamicTransition = [[MEDynamicTransition alloc] init];
    
    return _dynamicTransition;
}

@end

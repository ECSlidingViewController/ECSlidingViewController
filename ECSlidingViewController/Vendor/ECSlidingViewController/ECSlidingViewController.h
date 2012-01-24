//
//  ECSlidingViewController.h
//  ECSlidingViewController
//
//  Created by Michael Enriquez on 1/23/12.
//  Copyright (c) 2012 EdgeCase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage+UIImage_ImageWithUIView.h"

@interface ECSlidingViewController : UIViewController

@property (nonatomic, strong) UIViewController *underLeftViewController;
@property (nonatomic, strong) UIViewController *underRightViewController;
@property (nonatomic, strong) UIViewController *topViewController;
@property (nonatomic, unsafe_unretained) CGFloat anchorRightRevealAmount;
@property (nonatomic, unsafe_unretained) CGFloat anchorLeftRevealAmount;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

- (void)anchorToRight;
- (void)anchorToLeft;
- (void)reset;
- (void)replaceTopViewController:(UIViewController *)newTopViewController;

@end

@interface UIViewController(SlidingViewExtension)
- (ECSlidingViewController *)slidingViewController;
@end
//
//  ECSlidingViewController.h
//  ECSlidingViewController
//
//  Created by Michael Enriquez on 1/23/12.
//  Copyright (c) 2012 EdgeCase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage+UIImage_ImageWithUIView.h"

typedef enum {
  ECSlideLeft,
  ECSlideRight
} ECSlideDirection;

@interface ECSlidingViewController : UIViewController

@property (nonatomic, strong) UIViewController *underLeftViewController;
@property (nonatomic, strong) UIViewController *underRightViewController;
@property (nonatomic, strong) UIViewController *topViewController;

- (void)slideInDirection:(ECSlideDirection)slideDirection peekAmount:(CGFloat)peekAmount onComplete:(void(^)())completeBlock;
- (void)enablePanningInDirection:(ECSlideDirection)slideDirection forView:(UIView *)view peekAmount:(CGFloat)peekAmount;
- (void)jumpToPeekAmount:(CGFloat)peekAmount inDirection:(ECSlideDirection)direction;
- (void)reset;
- (BOOL)underLeftShowing;
- (BOOL)underRightShowing;
- (BOOL)topViewIsOffScreen;

@end

@interface UIViewController(SlidingViewExtension)
- (ECSlidingViewController *)slidingViewController;
@end
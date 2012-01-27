//
//  ECSlidingViewController.m
//  ECSlidingViewController
//
//  Created by Michael Enriquez on 1/23/12.
//  Copyright (c) 2012 EdgeCase. All rights reserved.
//

#import "ECSlidingViewController.h"

@interface ECSlidingViewController()

@property (nonatomic, unsafe_unretained) CGFloat rightSidePeekAmount;
@property (nonatomic, unsafe_unretained) CGFloat leftSidePeekAmount;
@property (nonatomic, strong) UIButton *topViewSnapshot;
@property (nonatomic, unsafe_unretained) CGFloat initialTouchPositionX;
@property (nonatomic, unsafe_unretained) CGFloat initialHoizontalCenter;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UITapGestureRecognizer *resetTapGesture;

- (NSUInteger)autoResizeToFillScreen;
- (UIView *)topView;
- (UIView *)underLeftView;
- (UIView *)underRightView;
- (void)updateTopViewHorizontalCenterWithRecognizer:(UIPanGestureRecognizer *)recognizer;
- (void)updateTopViewHorizontalCenter:(CGFloat)newHorizontalCenter;
- (void)topViewHorizontalCenterWillChange:(CGFloat)newHorizontalCenter;
- (void)topViewHorizontalCenterDidChange:(CGFloat)newHorizontalCenter;
- (void)addTopViewSnapshot;
- (void)removeTopViewSnapshot;
- (CGFloat)resettedCenter;
- (CGFloat)screenWidth;
- (CGFloat)screenWidthForOrientation:(UIInterfaceOrientation)orientation;
- (void)underLeftWillAppear;
- (void)underRightWillAppear;
- (void)topDidReset;

@end

@implementation UIViewController(SlidingViewExtension)

- (ECSlidingViewController *)slidingViewController
{
  UIViewController *viewController = self.parentViewController;
  while (!(viewController == nil || [viewController isKindOfClass:[ECSlidingViewController class]])) {
    viewController = viewController.parentViewController;
  }
  
  return (ECSlidingViewController *)viewController;
}

@end

@implementation ECSlidingViewController

// public properties
@synthesize underLeftViewController  = _underLeftViewController;
@synthesize underRightViewController = _underRightViewController;
@synthesize topViewController        = _topViewController;

// category properties
@synthesize leftSidePeekAmount;
@synthesize rightSidePeekAmount;
@synthesize topViewSnapshot;
@synthesize initialTouchPositionX;
@synthesize initialHoizontalCenter;
@synthesize panGesture;
@synthesize resetTapGesture;

- (void)setTopViewController:(UIViewController *)theTopViewController
{
  self.leftSidePeekAmount  = NSNotFound;
  self.rightSidePeekAmount = NSNotFound;
  
  [self removeTopViewSnapshot];
  [_topViewController.view removeFromSuperview];
  [_topViewController removeFromParentViewController];
  
  _topViewController = theTopViewController;
  [_topViewController.view setAutoresizingMask:self.autoResizeToFillScreen];
  [_topViewController.view setFrame:self.view.bounds];
  
  [self addChildViewController:self.topViewController];
  [self.topViewController didMoveToParentViewController:self];
  
  [self.view addSubview:_topViewController.view];
}

- (void)setUnderLeftViewController:(UIViewController *)theUnderLeftViewController
{
  [_underLeftViewController.view removeFromSuperview];
  [_underLeftViewController removeFromParentViewController];
  
  _underLeftViewController = theUnderLeftViewController;
  
  if (_underLeftViewController) {
    [_underLeftViewController.view setAutoresizingMask:self.autoResizeToFillScreen];
    [_underLeftViewController.view setFrame:self.view.bounds];
    
    [self addChildViewController:self.underLeftViewController];
    [self.underLeftViewController didMoveToParentViewController:self];
    
    [self.view insertSubview:_underLeftViewController.view atIndex:0];
  }
}

- (void)setUnderRightViewController:(UIViewController *)theUnderRightViewController
{
  [_underRightViewController.view removeFromSuperview];
  [_underRightViewController removeFromParentViewController];
  
  _underRightViewController = theUnderRightViewController;
  
  if (_underRightViewController) {
    [_underRightViewController.view setAutoresizingMask:self.autoResizeToFillScreen];
    [_underRightViewController.view setFrame:self.view.bounds];
    
    [self addChildViewController:self.underRightViewController];
    [self.underRightViewController didMoveToParentViewController:self];
    
    [self.view insertSubview:_underRightViewController.view atIndex:0];
  }
}

- (void)viewDidLoad
{
  self.resetTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reset)];
  self.panGesture      = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(updateTopViewHorizontalCenterWithRecognizer:)];
}

- (void)updateTopViewHorizontalCenterWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
  CGPoint currentTouchPoint     = [recognizer locationInView:self.view];
  CGFloat currentTouchPositionX = currentTouchPoint.x;
  
  if (recognizer.state == UIGestureRecognizerStateBegan) {
    self.initialTouchPositionX = currentTouchPositionX;
    self.initialHoizontalCenter = self.topView.center.x;
  } else if (recognizer.state == UIGestureRecognizerStateChanged) {
    CGFloat panAmount = self.initialTouchPositionX - currentTouchPositionX;
    CGFloat newCenterPosition = self.initialHoizontalCenter - panAmount;
    
    if ((newCenterPosition < self.resettedCenter && self.leftSidePeekAmount == NSNotFound) || (newCenterPosition > self.resettedCenter && self.rightSidePeekAmount == NSNotFound)) {
      newCenterPosition = self.resettedCenter;
    }
    
    [self topViewHorizontalCenterWillChange:newCenterPosition];
    [self updateTopViewHorizontalCenter:newCenterPosition];
    [self topViewHorizontalCenterDidChange:newCenterPosition];
  } else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
    CGPoint currentVelocityPoint = [recognizer velocityInView:self.view];
    CGFloat currentVelocityX     = currentVelocityPoint.x;
    
    if ([self underLeftShowing] && currentVelocityX > 100) {
      [self slideInDirection:ECSlideRight peekAmount:self.rightSidePeekAmount onComplete:nil];
    } else if ([self underRightShowing] && currentVelocityX < 100) {
      [self slideInDirection:ECSlideLeft peekAmount:self.leftSidePeekAmount onComplete:nil];
    } else {
      [self reset];
    }
  }
}

- (void)slideInDirection:(ECSlideDirection)slideDirection peekAmount:(CGFloat)peekAmount onComplete:(void(^)())completeBlock;
{
  CGFloat newCenter = self.topView.center.x;
  
  if (slideDirection == ECSlideLeft) {
    newCenter = -self.screenWidth + self.resettedCenter + peekAmount;
  } else if (slideDirection == ECSlideRight) {
    newCenter = self.screenWidth + self.resettedCenter - peekAmount;
  }
  
  [self topViewHorizontalCenterWillChange:newCenter];
  
  [UIView animateWithDuration:0.25f animations:^{
    [self jumpToPeekAmount:peekAmount inDirection:slideDirection];
  } completion:^(BOOL finished) {
    if (completeBlock) {
      completeBlock();
    }
  }];
}

- (void)enablePanningInDirection:(ECSlideDirection)slideDirection forView:(UIView *)view peekAmount:(CGFloat)peekAmount
{
  if (slideDirection == ECSlideLeft) {
    self.leftSidePeekAmount = peekAmount;
  } else if (slideDirection == ECSlideRight) {
    self.rightSidePeekAmount = peekAmount;
  }
  
  if (![[view gestureRecognizers] containsObject:self.panGesture]) {
    [view addGestureRecognizer:self.panGesture];
  }
}

- (void)jumpToPeekAmount:(CGFloat)peekAmount inDirection:(ECSlideDirection)slideDirection
{
  CGFloat newCenter = self.topView.center.x;
  
  if (slideDirection == ECSlideLeft) {
    newCenter = -self.screenWidth + self.resettedCenter + peekAmount;
  } else if (slideDirection == ECSlideRight) {
    newCenter = self.screenWidth + self.resettedCenter - peekAmount;
  }
  
  [self updateTopViewHorizontalCenter:newCenter];
}

- (void)reset
{
  [UIView animateWithDuration:0.25f animations:^{
    [self updateTopViewHorizontalCenter:self.resettedCenter];
  } completion:^(BOOL finished) {
    [self topViewHorizontalCenterDidChange:self.resettedCenter];
  }];
}

- (BOOL)underLeftShowing
{
  return self.topView.frame.origin.x > 0;
}

- (BOOL)underRightShowing
{
  return self.topView.frame.origin.x < 0;
}

- (BOOL)topViewIsOffScreen
{
  return self.topView.center.x <= -self.resettedCenter || self.topView.center.x >= self.screenWidth + self.resettedCenter;
}

- (NSUInteger)autoResizeToFillScreen
{
  return (UIViewAutoresizingFlexibleWidth |
          UIViewAutoresizingFlexibleHeight |
          UIViewAutoresizingFlexibleTopMargin |
          UIViewAutoresizingFlexibleBottomMargin |
          UIViewAutoresizingFlexibleLeftMargin |
          UIViewAutoresizingFlexibleRightMargin);
}

- (UIView *)topView
{
  return self.topViewController.view;
}

- (UIView *)underLeftView
{
  return self.underLeftViewController.view;
}

- (UIView *)underRightView
{
  return self.underRightViewController.view;
}

- (void)updateTopViewHorizontalCenter:(CGFloat)newHorizontalCenter
{
  CGPoint center = self.topView.center;
  center.x = newHorizontalCenter;
  self.topView.layer.position = center;
}

- (void)topViewHorizontalCenterWillChange:(CGFloat)newHorizontalCenter
{
  CGPoint center = self.topView.center;
  
  if (center.x <= self.resettedCenter && newHorizontalCenter > self.resettedCenter) {
    [self underLeftWillAppear];
  } else if (center.x >= self.resettedCenter && newHorizontalCenter < self.resettedCenter) {
    [self underRightWillAppear];
  }  
}

- (void)topViewHorizontalCenterDidChange:(CGFloat)newHorizontalCenter
{
  if (newHorizontalCenter == self.resettedCenter) {
    [self topDidReset];
  }
}

- (void)addTopViewSnapshot
{
  if (!self.topViewSnapshot.superview) {
    self.topViewSnapshot = [[UIButton alloc] initWithFrame:self.topView.bounds];
    [self.topViewSnapshot setImage:[UIImage imageWithUIView:self.topView] forState:(UIControlStateNormal | UIControlStateHighlighted | UIControlStateSelected)];
    [self.topView addSubview:self.topViewSnapshot];
  }
}

- (void)removeTopViewSnapshot
{
  if (self.topViewSnapshot.superview) {
    [self.topViewSnapshot removeFromSuperview];
  }
}

- (CGFloat)resettedCenter
{
  return ceil(self.screenWidth / 2);
}

- (CGFloat)screenWidth
{
  return [self screenWidthForOrientation:[UIApplication sharedApplication].statusBarOrientation];
}

- (CGFloat)screenWidthForOrientation:(UIInterfaceOrientation)orientation
{
  CGSize size = [UIScreen mainScreen].bounds.size;
  UIApplication *application = [UIApplication sharedApplication];
  if (UIInterfaceOrientationIsLandscape(orientation))
  {
    size = CGSizeMake(size.height, size.width);
  }
  if (application.statusBarHidden == NO)
  {
    size.height -= MIN(application.statusBarFrame.size.width, application.statusBarFrame.size.height);
  }
  return size.width;
}

- (void)underLeftWillAppear
{
  [self addTopViewSnapshot];
  [self.topView addGestureRecognizer:self.resetTapGesture];
  self.underRightView.hidden = YES;
  [self.underLeftViewController viewWillAppear:NO];
  self.underLeftView.hidden = NO;
}

- (void)underRightWillAppear
{
  [self addTopViewSnapshot];
  [self.topView addGestureRecognizer:self.resetTapGesture];
  self.underLeftView.hidden = YES;
  [self.underRightViewController viewWillAppear:NO];
  self.underRightView.hidden = NO;
}

- (void)topDidReset
{
  [self.topView removeGestureRecognizer:self.resetTapGesture];
  [self removeTopViewSnapshot];
}

@end

//
//  ECSlidingViewController.m
//  ECSlidingViewController
//
//  Created by Michael Enriquez on 1/23/12.
//  Copyright (c) 2012 EdgeCase. All rights reserved.
//

#import "ECSlidingViewController.h"

@interface ECSlidingViewController()

@property (nonatomic, strong) UIButton *topViewSnapshot;
@property (nonatomic, strong) UITapGestureRecognizer *resetTapGesture;
@property (nonatomic, unsafe_unretained) CGFloat initialTouchPositionX;
@property (nonatomic, unsafe_unretained) CGFloat initialLeftEdgePosition;

- (NSUInteger)autoResizeToFillScreen;
- (UIView *)topView;
- (UIView *)underLeftView;
- (UIView *)underRightView;
- (void)updateTopViewLeftEdgePosition:(CGFloat)position;
- (void)addTopViewSnapshot;
- (void)removeTopViewSnapshot;
- (CGFloat)screenWidth;
- (CGFloat)screenWidthForOrientation:(UIInterfaceOrientation)orientation;
- (BOOL)underLeftShowing;
- (BOOL)underRightShowing;

- (void)underLeftWillAppear;
- (void)underRightWillAppear;
- (void)topDidReset;

@end

@implementation UIViewController(SlidingViewExtension)

- (ECSlidingViewController *)slidingViewController
{
  UIViewController *viewController = self.parentViewController;
  while (!(viewController == nil || [viewController isMemberOfClass:[ECSlidingViewController class]])) {
    viewController = viewController.parentViewController;
  }
  
  return (ECSlidingViewController *)viewController;
}

@end

@implementation ECSlidingViewController
@synthesize underLeftViewController  = _underLeftViewController;
@synthesize underRightViewController = _underRightViewController;
@synthesize topViewController        = _topViewController;
@synthesize anchorRightRevealAmount;
@synthesize anchorLeftRevealAmount;
@synthesize topViewSnapshot;
@synthesize resetTapGesture;
@synthesize initialTouchPositionX;
@synthesize initialLeftEdgePosition;
@synthesize panGesture;

- (void)setTopViewController:(UIViewController *)theTopViewController
{
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
  self.panGesture      = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(updateTopViewLeftEdgePositionWithRecognizer:)];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
}

- (void)updateTopViewLeftEdgePositionWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
  CGPoint currentTouchPoint     = [recognizer locationInView:self.view];
  CGFloat currentTouchPositionX = currentTouchPoint.x;
  
  if (recognizer.state == UIGestureRecognizerStateBegan) {
    self.initialTouchPositionX = currentTouchPositionX;
    self.initialLeftEdgePosition = self.topView.frame.origin.x;
  } else if (recognizer.state == UIGestureRecognizerStateChanged) {
    CGFloat newLeftEdge = self.initialLeftEdgePosition + currentTouchPositionX - self.initialTouchPositionX;
    
    if ((!self.underLeftViewController && newLeftEdge > 0) || (!self.underRightViewController && newLeftEdge < 0)) {
      newLeftEdge = 0;
    }
    
    [self updateTopViewLeftEdgePosition:newLeftEdge];
  } else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
    CGPoint currentVelocityPoint = [recognizer velocityInView:self.view];
    CGFloat currentVelocityX     = currentVelocityPoint.x;
    
    if ([self underLeftShowing] && currentVelocityX > 100) {
      [self anchorToRight];
    } else if ([self underRightShowing] && currentVelocityX < 100) {
      [self anchorToLeft];
    } else {
      [self reset];
    }
  }
}

- (void)anchorToRight
{
  [UIView animateWithDuration:0.25f animations:^{
    [self updateTopViewLeftEdgePosition:self.anchorRightRevealAmount];
  }];
}

- (void)anchorToLeft
{
  [UIView animateWithDuration:0.25f animations:^{
    [self updateTopViewLeftEdgePosition:-self.anchorLeftRevealAmount];
  }];
}

- (void)reset
{
  [UIView animateWithDuration:0.25f animations:^{
    [self updateTopViewLeftEdgePosition:0];
  }];
}

- (void)slideOffToRightAndReplaceTopViewController:(UIViewController *)newTopViewController onComplete:(void(^)())completeBlock;
{
  [self slideOffToRightOnComplete:^{
    self.topViewController = newTopViewController;
    [self updateTopViewLeftEdgePosition:self.screenWidth];
    
    if (completeBlock) {
      completeBlock();
    }
  }];
}

- (void)slideOffToLeftAndReplaceTopViewController:(UIViewController *)newTopViewController onComplete:(void(^)())completeBlock;
{
  [self slideOffToLeftOnComplete:^{
    self.topViewController = newTopViewController;
    [self updateTopViewLeftEdgePosition:self.screenWidth];
    
    if (completeBlock) {
      completeBlock();
    }
  }];
}

- (void)slideOffToRightOnComplete:(void(^)())completeBlock;
{
  [UIView animateWithDuration:0.125f animations:^{
    [self updateTopViewLeftEdgePosition:self.screenWidth];
  } completion:^(BOOL finished) {
    if (completeBlock) {
      completeBlock();
    }
  }];
}

- (void)slideOffToLeftOnComplete:(void(^)())completeBlock;
{
  [UIView animateWithDuration:0.125f animations:^{
    [self updateTopViewLeftEdgePosition:-self.screenWidth];
  } completion:^(BOOL finished) {
    if (completeBlock) {
      completeBlock();
    }
  }];
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

- (void)updateTopViewLeftEdgePosition:(CGFloat)position
{
  CGRect frame = self.topView.frame;
  
  if (frame.origin.x <= 0 && position > 0) {
    [self underLeftWillAppear];
  } else if (frame.origin.x >= 0 && position < 0) {
    [self underRightWillAppear];
  }
  
  frame.origin.x = position;
  self.topView.frame = frame;
  
  if (position == 0) {
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

- (BOOL)underLeftShowing
{
  return self.topView.frame.origin.x > 0;
}

- (BOOL)underRightShowing
{
  return self.topView.frame.origin.x < 0;
}

- (void)underLeftWillAppear
{
  [self addTopViewSnapshot];
  [self.topView addGestureRecognizer:self.resetTapGesture];
  if (self.underRightViewController) {
    self.underRightView.hidden = YES;
  }
  self.underLeftView.hidden = NO;
}

- (void)underRightWillAppear
{
  [self addTopViewSnapshot];
  [self.topView addGestureRecognizer:self.resetTapGesture];
  if (self.underLeftViewController) {
    self.underLeftView.hidden = YES;
  }
  self.underRightView.hidden = NO;
}

- (void)topDidReset
{
  [self.topView removeGestureRecognizer:self.resetTapGesture];
  [self removeTopViewSnapshot];
}

@end

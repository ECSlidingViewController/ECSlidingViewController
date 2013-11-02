//
//  ECSlidingViewControllerTests.m
//  ECSlidingViewControllerTests
//
//  Created by Michael Enriquez on 10/26/13.
//  Copyright (c) 2013 Mike Enriquez. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ECSlidingViewController.h"

@interface ECSlidingViewControllerTests : XCTestCase
@property (nonatomic, strong) ECSlidingViewController *slidingViewController;
@property (nonatomic, strong) UIViewController *topViewController;
@property (nonatomic, strong) UIViewController *underLeftViewController;
@property (nonatomic, strong) UIViewController *underRightViewController;
@end

@implementation ECSlidingViewControllerTests

- (void)setUp {
    [super setUp];
    self.topViewController        = [[UIViewController alloc] init];
    self.underLeftViewController  = [[UIViewController alloc] init];
    self.underRightViewController = [[UIViewController alloc] init];
    self.slidingViewController    = [[ECSlidingViewController alloc] initWithTopViewController:self.topViewController];
    self.slidingViewController.view.frame = CGRectMake(0, 0, 320, 480);
}

- (void)tearDown {
    self.slidingViewController    = nil;
    self.topViewController        = nil;
    self.underLeftViewController  = nil;
    self.underRightViewController = nil;
    [super tearDown];
}

// Properties

- (void)testTopViewControllerProperty {
    XCTAssertEqualObjects(self.slidingViewController.topViewController, self.topViewController);
}

- (void)testUnderLeftViewControllerProperty {
    self.slidingViewController.underLeftViewController = self.underLeftViewController;
    XCTAssertEqualObjects(self.slidingViewController.underLeftViewController, self.underLeftViewController);
}

- (void)testUnderRightViewControllerProperty {
    self.slidingViewController.underRightViewController = self.underRightViewController;
    XCTAssertEqualObjects(self.slidingViewController.underRightViewController, self.underRightViewController);
}

// Top View Anchor Geometry

- (void)testAnchorDefaultValues {
    XCTAssertEqualWithAccuracy(self.slidingViewController.anchorLeftPeekAmount, 44.0, 0.01);
    XCTAssertEqualWithAccuracy(self.slidingViewController.anchorLeftRevealAmount, 276.0, 0.01);
    XCTAssertEqualWithAccuracy(self.slidingViewController.anchorRightPeekAmount, 44.0, 0.01);
    XCTAssertEqualWithAccuracy(self.slidingViewController.anchorRightRevealAmount, 276.0, 0.01);
}

- (void)testSettingAnchorLeftPeekAmount {
    self.slidingViewController.anchorLeftPeekAmount = 50.0;
    XCTAssertEqualWithAccuracy(self.slidingViewController.anchorLeftPeekAmount, 50.0, 0.01);
    XCTAssertEqualWithAccuracy(self.slidingViewController.anchorLeftRevealAmount, 270.0, 0.01);
}

- (void)testSettingAnchorLeftRevealAmount {
    self.slidingViewController.anchorLeftRevealAmount = 250.0;
    XCTAssertEqualWithAccuracy(self.slidingViewController.anchorLeftRevealAmount, 250.0, 0.01);
    XCTAssertEqualWithAccuracy(self.slidingViewController.anchorLeftPeekAmount, 70.0, 0.01);
}

- (void)testSettingAnchorRightPeekAmount {
    self.slidingViewController.anchorRightPeekAmount = 60.0;
    XCTAssertEqualWithAccuracy(self.slidingViewController.anchorRightPeekAmount, 60.0, 0.01);
    XCTAssertEqualWithAccuracy(self.slidingViewController.anchorRightRevealAmount, 260.0, 0.01);
}

- (void)testSettingAnchorRightRevealAmount {
    self.slidingViewController.anchorRightRevealAmount = 260.0;
    XCTAssertEqualWithAccuracy(self.slidingViewController.anchorRightRevealAmount, 260.0, 0.01);
    XCTAssertEqualWithAccuracy(self.slidingViewController.anchorRightPeekAmount, 60.0, 0.01);
}

// UIViewControllerContextTransitioning protocol

- (void)testViewControllerForKey {
    UIViewController *topViewController = [self.slidingViewController viewControllerForKey:ECTransitionContextTopViewControllerKey];
    XCTAssertEqualObjects(self.slidingViewController.topViewController, topViewController);
    
    UIViewController *underLeftViewController = [self.slidingViewController viewControllerForKey:ECTransitionContextUnderLeftControllerKey];
    XCTAssertEqualObjects(self.slidingViewController.underLeftViewController, underLeftViewController);
    
    UIViewController *underRightViewController = [self.slidingViewController viewControllerForKey:ECTransitionContextUnderRightControllerKey];
    XCTAssertEqual(self.slidingViewController.underRightViewController, underRightViewController);
}

- (void)testInitialFrameForViewControllerForTopView {
    self.slidingViewController.anchorLeftPeekAmount    = 50.0;
    self.slidingViewController.anchorRightRevealAmount = 200.0;
    
    CGRect expectedRect;
    
    // resetting from left should start anchored left.
    [self.slidingViewController setValue:[NSNumber numberWithInteger:ECSlidingViewControllerOperationResetFromLeft]
                                  forKey:@"currentOperation"];
    expectedRect = CGRectMake(-270, 0, 320, 480);
    XCTAssertEqual([self.slidingViewController initialFrameForViewController:self.topViewController], expectedRect);
    
    // resetting from right should start anchored right.
    [self.slidingViewController setValue:[NSNumber numberWithInteger:ECSlidingViewControllerOperationResetFromRight]
                                  forKey:@"currentOperation"];
    expectedRect = CGRectMake(200, 0, 320, 480);
    XCTAssertEqual([self.slidingViewController initialFrameForViewController:self.topViewController], expectedRect);
    
    // anchor left should start from center.
    [self.slidingViewController setValue:[NSNumber numberWithInteger:ECSlidingViewControllerOperationAnchorLeft]
                                  forKey:@"currentOperation"];
    expectedRect = CGRectMake(0, 0, 320, 480);
    XCTAssertEqual([self.slidingViewController initialFrameForViewController:self.topViewController], expectedRect);
    
    // anchor right should start from center.
    [self.slidingViewController setValue:[NSNumber numberWithInteger:ECSlidingViewControllerOperationAnchorRight]
                                  forKey:@"currentOperation"];
    expectedRect = CGRectMake(0, 0, 320, 480);
    XCTAssertEqual([self.slidingViewController initialFrameForViewController:self.topViewController], expectedRect);
}

- (void)testFinalFrameForViewControllerForTopView {
    self.slidingViewController.anchorLeftPeekAmount    = 50.0;
    self.slidingViewController.anchorRightRevealAmount = 200.0;
    
    CGRect expectedRect;
    
    // resetting from left should end at center
    [self.slidingViewController setValue:[NSNumber numberWithInteger:ECSlidingViewControllerOperationResetFromLeft]
                                  forKey:@"currentOperation"];
    expectedRect = CGRectMake(0, 0, 320, 480);
    XCTAssertEqual([self.slidingViewController finalFrameForViewController:self.topViewController], expectedRect);
    
    // resetting from right should end at center
    [self.slidingViewController setValue:[NSNumber numberWithInteger:ECSlidingViewControllerOperationResetFromRight]
                                  forKey:@"currentOperation"];
    expectedRect = CGRectMake(0, 0, 320, 480);
    XCTAssertEqual([self.slidingViewController finalFrameForViewController:self.topViewController], expectedRect);
    
    // anchor left should end anchored left
    [self.slidingViewController setValue:[NSNumber numberWithInteger:ECSlidingViewControllerOperationAnchorLeft]
                                  forKey:@"currentOperation"];
    expectedRect = CGRectMake(-270, 0, 320, 480);
    XCTAssertEqual([self.slidingViewController finalFrameForViewController:self.topViewController], expectedRect);
    
    // anchor right should end anchored right
    [self.slidingViewController setValue:[NSNumber numberWithInteger:ECSlidingViewControllerOperationAnchorRight]
                                  forKey:@"currentOperation"];
    expectedRect = CGRectMake(200, 0, 320, 480);
    XCTAssertEqual([self.slidingViewController finalFrameForViewController:self.topViewController], expectedRect);
}

- (void)testInitialFrameForViewControllerForUnderLeftView {
    self.slidingViewController.underLeftViewController = self.underLeftViewController;
    self.slidingViewController.anchorLeftPeekAmount    = 50.0;
    self.slidingViewController.anchorRightRevealAmount = 200.0;
    
    CGRect expectedRect;
    
    self.underLeftViewController.edgesForExtendedLayout = UIRectEdgeAll;
    
    // resetting from left should start at zero
    [self.slidingViewController setValue:[NSNumber numberWithInteger:ECSlidingViewControllerOperationResetFromLeft]
                                  forKey:@"currentOperation"];
    expectedRect = CGRectZero;
    XCTAssertEqual([self.slidingViewController initialFrameForViewController:self.underLeftViewController], expectedRect);
    
    // resetting from right should start at full width
    [self.slidingViewController setValue:[NSNumber numberWithInteger:ECSlidingViewControllerOperationResetFromRight]
                                  forKey:@"currentOperation"];
    expectedRect = CGRectMake(0, 0, 320, 480);
    XCTAssertEqual([self.slidingViewController initialFrameForViewController:self.underLeftViewController], expectedRect);
    
    // anchor left should start at zero
    [self.slidingViewController setValue:[NSNumber numberWithInteger:ECSlidingViewControllerOperationAnchorLeft]
                                  forKey:@"currentOperation"];
    expectedRect = CGRectZero;
    XCTAssertEqual([self.slidingViewController initialFrameForViewController:self.underLeftViewController], expectedRect);
    
    // anchor right should start at full width
    [self.slidingViewController setValue:[NSNumber numberWithInteger:ECSlidingViewControllerOperationAnchorRight]
                                  forKey:@"currentOperation"];
    expectedRect = CGRectMake(0, 0, 320, 480);
    XCTAssertEqual([self.slidingViewController initialFrameForViewController:self.underLeftViewController], expectedRect);
    
    self.underLeftViewController.edgesForExtendedLayout = UIRectEdgeTop | UIRectEdgeBottom | UIRectEdgeLeft;
    
    // resetting from right should start at reveal width
    [self.slidingViewController setValue:[NSNumber numberWithInteger:ECSlidingViewControllerOperationResetFromRight]
                                  forKey:@"currentOperation"];
    expectedRect = CGRectMake(0, 0, 200, 480);
    XCTAssertEqual([self.slidingViewController initialFrameForViewController:self.underLeftViewController], expectedRect);
}

- (void)testFinalFrameForViewControllerForUnderLeftView {
    self.slidingViewController.underLeftViewController = self.underLeftViewController;
    self.slidingViewController.anchorLeftPeekAmount    = 50.0;
    self.slidingViewController.anchorRightRevealAmount = 200.0;
    
    CGRect expectedRect;
    
    self.slidingViewController.underLeftViewController.edgesForExtendedLayout = UIRectEdgeAll;
    
    // resetting from left should end at zero
    [self.slidingViewController setValue:[NSNumber numberWithInteger:ECSlidingViewControllerOperationResetFromLeft]
                                  forKey:@"currentOperation"];
    expectedRect = CGRectZero;
    XCTAssertEqual([self.slidingViewController finalFrameForViewController:self.underLeftViewController], expectedRect);
    
    // resetting from right should end at zero
    [self.slidingViewController setValue:[NSNumber numberWithInteger:ECSlidingViewControllerOperationResetFromRight]
                                  forKey:@"currentOperation"];
    expectedRect = CGRectZero;
    XCTAssertEqual([self.slidingViewController finalFrameForViewController:self.underLeftViewController], expectedRect);
    
    // anchor left should end at zero
    [self.slidingViewController setValue:[NSNumber numberWithInteger:ECSlidingViewControllerOperationAnchorLeft]
                                  forKey:@"currentOperation"];
    expectedRect = CGRectZero;
    XCTAssertEqual([self.slidingViewController finalFrameForViewController:self.underLeftViewController], expectedRect);
    
    // anchor right should end at full width
    [self.slidingViewController setValue:[NSNumber numberWithInteger:ECSlidingViewControllerOperationAnchorRight]
                                  forKey:@"currentOperation"];
    expectedRect = CGRectMake(0, 0, 320, 480);
    XCTAssertEqual([self.slidingViewController finalFrameForViewController:self.underLeftViewController], expectedRect);
    
    self.slidingViewController.underLeftViewController.edgesForExtendedLayout = UIRectEdgeTop | UIRectEdgeBottom | UIRectEdgeLeft;
    
    // anchor right should end at reveal width
    [self.slidingViewController setValue:[NSNumber numberWithInteger:ECSlidingViewControllerOperationAnchorRight]
                                  forKey:@"currentOperation"];
    expectedRect = CGRectMake(0, 0, 200, 480);
    XCTAssertEqual([self.slidingViewController finalFrameForViewController:self.underLeftViewController], expectedRect);
}

- (void)testInitialFrameForViewControllerForUnderRightView {
    self.slidingViewController.underRightViewController = self.underRightViewController;
    self.slidingViewController.anchorLeftPeekAmount    = 50.0;
    self.slidingViewController.anchorRightRevealAmount = 200.0;
    
    CGRect expectedRect;
    
    self.slidingViewController.underRightViewController.edgesForExtendedLayout = UIRectEdgeAll;
    
    // resetting from left should start at full width
    [self.slidingViewController setValue:[NSNumber numberWithInteger:ECSlidingViewControllerOperationResetFromLeft]
                                  forKey:@"currentOperation"];
    expectedRect = CGRectMake(0, 0, 320, 480);
    XCTAssertEqual([self.slidingViewController initialFrameForViewController:self.underRightViewController], expectedRect);
    
    // resetting from right should start at zero
    [self.slidingViewController setValue:[NSNumber numberWithInteger:ECSlidingViewControllerOperationResetFromRight]
                                  forKey:@"currentOperation"];
    expectedRect = CGRectZero;
    XCTAssertEqual([self.slidingViewController initialFrameForViewController:self.underRightViewController], expectedRect);
    
    // anchor left should start at full width
    [self.slidingViewController setValue:[NSNumber numberWithInteger:ECSlidingViewControllerOperationAnchorLeft]
                                  forKey:@"currentOperation"];
    expectedRect = CGRectMake(0, 0, 320, 480);
    XCTAssertEqual([self.slidingViewController initialFrameForViewController:self.underRightViewController], expectedRect);
    
    // anchor right should start at zero
    [self.slidingViewController setValue:[NSNumber numberWithInteger:ECSlidingViewControllerOperationAnchorRight]
                                  forKey:@"currentOperation"];
    expectedRect = CGRectZero;
    XCTAssertEqual([self.slidingViewController initialFrameForViewController:self.underRightViewController], expectedRect);
    
    self.slidingViewController.underRightViewController.edgesForExtendedLayout = UIRectEdgeTop | UIRectEdgeBottom | UIRectEdgeRight;
    
    // resetting from left should start at reveal width
    [self.slidingViewController setValue:[NSNumber numberWithInteger:ECSlidingViewControllerOperationResetFromLeft]
                                  forKey:@"currentOperation"];
    expectedRect = CGRectMake(50, 0, 270, 480);
    XCTAssertEqual([self.slidingViewController initialFrameForViewController:self.underRightViewController], expectedRect);
}

- (void)testFinalFrameForViewControllerForUnderRightView {
    self.slidingViewController.underRightViewController = self.underRightViewController;
    self.slidingViewController.anchorLeftPeekAmount    = 50.0;
    self.slidingViewController.anchorRightRevealAmount = 200.0;
    
    CGRect expectedRect;
    
    self.slidingViewController.underRightViewController.edgesForExtendedLayout = UIRectEdgeAll;
    
    // resetting from left should end at zero
    [self.slidingViewController setValue:[NSNumber numberWithInteger:ECSlidingViewControllerOperationResetFromLeft]
                                  forKey:@"currentOperation"];
    expectedRect = CGRectZero;
    XCTAssertEqual([self.slidingViewController finalFrameForViewController:self.underRightViewController], expectedRect);
    
    // resetting from right should end at zero
    [self.slidingViewController setValue:[NSNumber numberWithInteger:ECSlidingViewControllerOperationResetFromRight]
                                  forKey:@"currentOperation"];
    expectedRect = CGRectZero;
    XCTAssertEqual([self.slidingViewController finalFrameForViewController:self.underRightViewController], expectedRect);
    
    // anchor left should end at full width
    [self.slidingViewController setValue:[NSNumber numberWithInteger:ECSlidingViewControllerOperationAnchorLeft]
                                  forKey:@"currentOperation"];
    expectedRect = CGRectMake(0, 0, 320, 480);
    XCTAssertEqual([self.slidingViewController finalFrameForViewController:self.underRightViewController], expectedRect);
    
    // anchor right should end at zero
    [self.slidingViewController setValue:[NSNumber numberWithInteger:ECSlidingViewControllerOperationAnchorRight]
                                  forKey:@"currentOperation"];
    expectedRect = CGRectZero;
    XCTAssertEqual([self.slidingViewController finalFrameForViewController:self.underRightViewController], expectedRect);
    
    self.slidingViewController.underRightViewController.edgesForExtendedLayout = UIRectEdgeTop | UIRectEdgeBottom | UIRectEdgeRight;
    
    // anchor left should end at reveal width
    [self.slidingViewController setValue:[NSNumber numberWithInteger:ECSlidingViewControllerOperationAnchorLeft]
                                  forKey:@"currentOperation"];
    expectedRect = CGRectMake(50, 0, 270, 480);
    XCTAssertEqual([self.slidingViewController finalFrameForViewController:self.underRightViewController], expectedRect);
}

// Loading Top View

- (void)testLoadView {
    UIView *view = self.slidingViewController.view;
    XCTAssertNotNil(view);
}

- (void)testLoadViewWithoutTopViewController {
    self.slidingViewController = [[ECSlidingViewController alloc] init];
    XCTAssertThrows(self.slidingViewController.view);
}

@end
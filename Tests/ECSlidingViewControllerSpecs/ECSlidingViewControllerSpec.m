// ECSlidingViewControllerSpec.m
// ECSlidingViewController
//
// Copyright (c) 2013, Michael Enriquez (http://enriquez.me)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "Kiwi.h"
#import "ECSlidingViewController.h"

SPEC_BEGIN(ECSlidingViewControllerSpec)

describe(@"ECSlidingViewController", ^{
    __block UIViewController *topViewController;
    __block UIViewController *underLeftViewController;
    __block UIViewController *underRightViewController;
    __block ECSlidingViewController *slidingViewController;
    
    beforeEach(^{
        topViewController        = [[UIViewController alloc] init];
        underLeftViewController  = [[UIViewController alloc] init];
        underRightViewController = [[UIViewController alloc] init];
        slidingViewController    = [ECSlidingViewController slidingWithTopViewController:topViewController];
        slidingViewController.underLeftViewController  = underLeftViewController;
        slidingViewController.underRightViewController = underRightViewController;
        
        slidingViewController.view.frame = CGRectMake(0, 0, 320, 480);
    });
    
    it(@"gets topViewController", ^{
        [[slidingViewController.topViewController should] equal:topViewController];
    });
    
    it(@"gets underLeftViewController", ^{
        [[slidingViewController.underLeftViewController should] equal:underLeftViewController];
    });
    
    it(@"gets underRightViewController", ^{
        [[slidingViewController.underRightViewController should] equal:underRightViewController];
    });
    
    it(@"gets default anchor amounts", ^{
        [[theValue(slidingViewController.anchorLeftPeekAmount) should] equal:@44.0];
        [[theValue(slidingViewController.anchorLeftRevealAmount) should] equal:@276.0];
        [[theValue(slidingViewController.anchorRightPeekAmount) should] equal:@44.0];
        [[theValue(slidingViewController.anchorRightRevealAmount) should] equal:@276.0];
    });
    
    it(@"sets anchorLeftPeekAmount", ^{
        slidingViewController.anchorLeftPeekAmount = 50.0;
        [[theValue(slidingViewController.anchorLeftPeekAmount) should] equal:@50.0];
        [[theValue(slidingViewController.anchorLeftRevealAmount) should] equal:@270.0];
    });
    
    it(@"sets anchorLeftRevealAmount", ^{
        slidingViewController.anchorLeftRevealAmount = 250.0;
        [[theValue(slidingViewController.anchorLeftRevealAmount) should] equal:@250.0];
        [[theValue(slidingViewController.anchorLeftPeekAmount) should] equal:@70.0];
    });
    
    it(@"sets anchorRightPeekAmount", ^{
        slidingViewController.anchorRightPeekAmount = 60.0;
        [[theValue(slidingViewController.anchorRightPeekAmount) should] equal:@60.0];
        [[theValue(slidingViewController.anchorRightRevealAmount) should] equal:@260.0];
    });
    
    it(@"sets anchorRightRevealAmount", ^{
        slidingViewController.anchorRightRevealAmount = 260.0;
        [[theValue(slidingViewController.anchorRightRevealAmount) should] equal:@260.0];
        [[theValue(slidingViewController.anchorRightPeekAmount) should] equal:@60.0];
    });
    
    it(@"loads the container view", ^{
        UIView *view = slidingViewController.view;
        [[view shouldNot] beNil];
    });
    
    it(@"throws an exception when attempting to load the container view without a topViewController", ^{
        slidingViewController = [[ECSlidingViewController alloc] init];
        [[theBlock(^{
            UIView *view = slidingViewController.view;
            [[view shouldNot] beNil];
        }) should] raise];
    });
    
    describe(@"viewControllerForKey:", ^{
        it(@"returns the topViewController", ^{
            [[[slidingViewController viewControllerForKey:ECTransitionContextTopViewControllerKey]
              should] equal:topViewController];
        });
        
        it(@"returns the underLeftViewController", ^{
            [[[slidingViewController viewControllerForKey:ECTransitionContextUnderLeftControllerKey]
              should] equal:underLeftViewController];
        });
        
        it(@"returns the underRightViewController", ^{
            [[[slidingViewController viewControllerForKey:ECTransitionContextUnderRightControllerKey]
              should] equal:underRightViewController];
        });
        
        context(@"reset from left operation", ^{
            beforeEach(^{
                [slidingViewController setValue:[NSNumber numberWithInteger:ECSlidingViewControllerOperationResetFromLeft]
                                         forKey:@"currentOperation"];
            });

            it(@"returns the underRightViewController", ^{
                [[[slidingViewController viewControllerForKey:UITransitionContextFromViewControllerKey]
                  should] equal:underRightViewController];
            });

            it(@"returns the topViewController", ^{
                [[[slidingViewController viewControllerForKey:UITransitionContextToViewControllerKey]
                  should] equal:topViewController];
            });
        });

        context(@"reset from right operation", ^{
            beforeEach(^{
                [slidingViewController setValue:[NSNumber numberWithInteger:ECSlidingViewControllerOperationResetFromRight]
                                         forKey:@"currentOperation"];
            });

            it(@"returns the underLeftViewController", ^{
                [[[slidingViewController viewControllerForKey:UITransitionContextFromViewControllerKey]
                  should] equal:underLeftViewController];
            });

            it(@"returns the topViewController", ^{
                [[[slidingViewController viewControllerForKey:UITransitionContextToViewControllerKey]
                  should] equal:topViewController];
            });
        });

        context(@"anchor right operation", ^{
            beforeEach(^{
                [slidingViewController setValue:[NSNumber numberWithInteger:ECSlidingViewControllerOperationAnchorRight]
                                         forKey:@"currentOperation"];
            });

            it(@"returns the topViewController", ^{
                [[[slidingViewController viewControllerForKey:UITransitionContextFromViewControllerKey]
                  should] equal:topViewController];
            });

            it(@"returns the underLeftViewController", ^{
                [[[slidingViewController viewControllerForKey:UITransitionContextToViewControllerKey]
                  should] equal:underLeftViewController];
            });
        });

        context(@"anchor left operation", ^{
            beforeEach(^{
                [slidingViewController setValue:[NSNumber numberWithInteger:ECSlidingViewControllerOperationAnchorLeft]
                                         forKey:@"currentOperation"];
            });

            it(@"returns the topViewController", ^{
                [[[slidingViewController viewControllerForKey:UITransitionContextFromViewControllerKey]
                  should] equal:topViewController];
            });

            it(@"returns the underRightViewController", ^{
                [[[slidingViewController viewControllerForKey:UITransitionContextToViewControllerKey]
                  should] equal:underRightViewController];
            });
        });
    });
    
    describe(@"initialFrameForViewController:", ^{
        beforeEach(^{
            slidingViewController.anchorLeftPeekAmount    = 50.0;
            slidingViewController.anchorRightRevealAmount = 200.0;
        });
        
        context(@"reset from left operation", ^{
            beforeEach(^{
                [slidingViewController setValue:[NSNumber numberWithInteger:ECSlidingViewControllerOperationResetFromLeft]
                                         forKey:@"currentOperation"];
            });
            
            it(@"starts the top view anchored left", ^{
                [[theValue([slidingViewController initialFrameForViewController:topViewController])
                  should] equal:theValue(CGRectMake(-270.0, 0, 320, 480))];
            });
            
            it(@"starts the under left view hidden", ^{
                [[theValue([slidingViewController initialFrameForViewController:underLeftViewController])
                  should] equal:theValue(CGRectZero)];
            });
            
            it(@"starts the under right view visible", ^{
                [[theValue([slidingViewController initialFrameForViewController:underRightViewController])
                  should] equal:theValue(CGRectMake(0, 0, 320, 480))];
            });
        });
        
        context(@"reset from right operation", ^{
            beforeEach(^{
                [slidingViewController setValue:[NSNumber numberWithInteger:ECSlidingViewControllerOperationResetFromRight]
                                         forKey:@"currentOperation"];
            });
            
            it(@"starts the top view anchored right", ^{
                [[theValue([slidingViewController initialFrameForViewController:topViewController])
                  should] equal:theValue(CGRectMake(200, 0, 320, 480))];
            });
            
            it(@"starts the under left view visible", ^{
                [[theValue([slidingViewController initialFrameForViewController:underLeftViewController])
                  should] equal:theValue(CGRectMake(0, 0, 320, 480))];
            });
            
            it(@"starts the under right view hidden", ^{
                [[theValue([slidingViewController initialFrameForViewController:underRightViewController])
                  should] equal:theValue(CGRectZero)];
            });
        });
        
        context(@"anchor right operation", ^{
            beforeEach(^{
                [slidingViewController setValue:[NSNumber numberWithInteger:ECSlidingViewControllerOperationAnchorRight]
                                         forKey:@"currentOperation"];
            });
            
            it(@"starts the top view centered", ^{
                [[theValue([slidingViewController initialFrameForViewController:topViewController])
                  should] equal:theValue(CGRectMake(0, 0, 320, 480))];
            });
            
            it(@"starts the under left view visible", ^{
                [[theValue([slidingViewController initialFrameForViewController:underLeftViewController])
                  should] equal:theValue(CGRectZero)];
            });
            
            it(@"starts the under right view hidden", ^{
                [[theValue([slidingViewController initialFrameForViewController:underRightViewController])
                  should] equal:theValue(CGRectZero)];
            });
        });
        
        context(@"anchor left operation", ^{
            beforeEach(^{
                [slidingViewController setValue:[NSNumber numberWithInteger:ECSlidingViewControllerOperationAnchorLeft]
                                         forKey:@"currentOperation"];
            });
            
            it(@"starts the top view centered", ^{
                [[theValue([slidingViewController initialFrameForViewController:topViewController])
                  should] equal:theValue(CGRectMake(0, 0, 320, 480))];
            });
            
            it(@"starts the under left view hidden", ^{
                [[theValue([slidingViewController initialFrameForViewController:underLeftViewController])
                  should] equal:theValue(CGRectZero)];
            });
            
            it(@"starts the under right view visible", ^{
                [[theValue([slidingViewController initialFrameForViewController:underRightViewController])
                  should] equal:theValue(CGRectZero)];
            });
        });
    });
    
    describe(@"finalFrameForViewController:", ^{
        beforeEach(^{
            slidingViewController.anchorLeftPeekAmount    = 50.0;
            slidingViewController.anchorRightRevealAmount = 200.0;
        });
        
        context(@"reset from left operation", ^{
            beforeEach(^{
                [slidingViewController setValue:[NSNumber numberWithInteger:ECSlidingViewControllerOperationResetFromLeft]
                                         forKey:@"currentOperation"];
            });
            
            it(@"ends the top view centered", ^{
                [[theValue([slidingViewController finalFrameForViewController:topViewController])
                  should] equal:theValue(CGRectMake(0, 0, 320, 480))];
            });
            
            it(@"ends the under left view hidden", ^{
                [[theValue([slidingViewController finalFrameForViewController:underLeftViewController])
                  should] equal:theValue(CGRectZero)];
            });
            
            it(@"ends the under right view hidden", ^{
                [[theValue([slidingViewController finalFrameForViewController:underRightViewController])
                  should] equal:theValue(CGRectZero)];
            });
        });
        
        context(@"reset from right operation", ^{
            beforeEach(^{
                [slidingViewController setValue:[NSNumber numberWithInteger:ECSlidingViewControllerOperationResetFromRight]
                                         forKey:@"currentOperation"];
            });
            
            it(@"ends the top view centered", ^{
                [[theValue([slidingViewController finalFrameForViewController:topViewController])
                  should] equal:theValue(CGRectMake(0, 0, 320, 480))];
            });
            
            it(@"ends the under left view hidden", ^{
                [[theValue([slidingViewController finalFrameForViewController:underLeftViewController])
                  should] equal:theValue(CGRectZero)];
            });
            
            it(@"ends the under right view hidden", ^{
                [[theValue([slidingViewController finalFrameForViewController:underRightViewController])
                  should] equal:theValue(CGRectZero)];
            });
        });
        
        context(@"anchor right operation", ^{
            beforeEach(^{
                [slidingViewController setValue:[NSNumber numberWithInteger:ECSlidingViewControllerOperationAnchorRight]
                                         forKey:@"currentOperation"];
            });
            
            it(@"ends the top view anchored right", ^{
                [[theValue([slidingViewController finalFrameForViewController:topViewController])
                  should] equal:theValue(CGRectMake(200, 0, 320, 480))];
            });
            
            it(@"ends the under left view visible", ^{
                [[theValue([slidingViewController finalFrameForViewController:underLeftViewController])
                  should] equal:theValue(CGRectMake(0, 0, 320, 480))];
            });
            
            it(@"ends the under right view hidden", ^{
                [[theValue([slidingViewController finalFrameForViewController:underRightViewController])
                  should] equal:theValue(CGRectZero)];
            });
        });
        
        context(@"anchor left operation", ^{
            beforeEach(^{
                [slidingViewController setValue:[NSNumber numberWithInteger:ECSlidingViewControllerOperationAnchorLeft]
                                         forKey:@"currentOperation"];
            });
            
            it(@"ends the top view anchored left", ^{
                [[theValue([slidingViewController finalFrameForViewController:topViewController])
                  should] equal:theValue(CGRectMake(-270, 0, 320, 480))];
            });
            
            it(@"ends the under left view hidden", ^{
                [[theValue([slidingViewController finalFrameForViewController:underLeftViewController])
                  should] equal:theValue(CGRectZero)];
            });
            
            it(@"ends the under right view visible", ^{
                [[theValue([slidingViewController finalFrameForViewController:underRightViewController])
                  should] equal:theValue(CGRectMake(0, 0, 320, 480))];
            });
        });
    });
});

SPEC_END
// METransitionsViewController.m
// TransitionFun
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

#import "METransitionsViewController.h"
#import "ECSlidingAnimationController.h"
#import "UIViewController+ECSlidingViewController.h"
#import "MEFoldAnimationController.h"
#import "MEZoomAnimationController.h"
#import "MEDynamicTransition.h"

static NSString *const METransitionDefault = @"Default";
static NSString *const METransitionFold = @"Fold";
static NSString *const METransitionZoom = @"Zoom";
static NSString *const METransitionUIDynamics = @"UI Dynamics";

@interface METransitionsViewController ()
@property (nonatomic, strong) NSArray *transitions;
@property (nonatomic, strong) ECSlidingAnimationController *slidingAnimationController;
@property (nonatomic, strong) MEFoldAnimationController *foldAnimationController;
@property (nonatomic, strong) MEZoomAnimationController *zoomAnimationController;
@property (nonatomic, strong) MEDynamicTransition *dynamicTransition;
@end

@implementation METransitionsViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.view addGestureRecognizer:self.slidingViewController.panGesture];
    self.slidingViewController.delegate = self;
    self.slidingViewController.topViewAnchoredGesture = ECSlidingViewControllerAnchoredGestureTapping | ECSlidingViewControllerAnchoredGesturePanning;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (![self.tableView indexPathForSelectedRow]) {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Properties

- (NSArray *)transitions {
    if (_transitions) return _transitions;
    
    _transitions = @[METransitionDefault, METransitionFold, METransitionZoom, METransitionUIDynamics];
    
    return _transitions;
}

- (ECSlidingAnimationController *)slidingAnimationController {
    if (_slidingAnimationController) return _slidingAnimationController;
    
    _slidingAnimationController = [[ECSlidingAnimationController alloc] init];
    
    return _slidingAnimationController;
}

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
    
    _dynamicTransition = [[MEDynamicTransition alloc] initWithSlidingViewController:self.slidingViewController];
    
    return _dynamicTransition;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.transitions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"TransitionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSString *transition = self.transitions[indexPath.row];
    
    cell.textLabel.text = transition;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *selection = self.transitions[indexPath.row];
    if ([selection isEqualToString:METransitionUIDynamics]) {
        self.slidingViewController.topViewAnchoredGesture = ECSlidingViewControllerAnchoredGestureTapping | ECSlidingViewControllerAnchoredGestureCustom;
        self.slidingViewController.customAnchoredGestures = @[self.dynamicTransition.panGesture];
        [self.navigationController.view removeGestureRecognizer:self.slidingViewController.panGesture];
        [self.navigationController.view addGestureRecognizer:self.dynamicTransition.panGesture];
    } else {
        self.slidingViewController.topViewAnchoredGesture = ECSlidingViewControllerAnchoredGestureTapping | ECSlidingViewControllerAnchoredGesturePanning;
        self.slidingViewController.customAnchoredGestures = @[];
        [self.navigationController.view removeGestureRecognizer:self.dynamicTransition.panGesture];
        [self.navigationController.view addGestureRecognizer:self.slidingViewController.panGesture];
    }
}

#pragma mark - ECSlidingViewControllerDelegate

- (id<UIViewControllerAnimatedTransitioning>)slidingViewController:(ECSlidingViewController *)slidingViewController
                                   animationControllerForOperation:(ECSlidingViewControllerOperation)operation
                                                 topViewController:(UIViewController *)topViewController {
    NSUInteger selectedIndex = [self.tableView indexPathForSelectedRow].row;
    NSString *transition = self.transitions[selectedIndex];
    id<UIViewControllerAnimatedTransitioning> animationController = nil;
    
    if ([transition isEqualToString:METransitionFold]) {
        animationController = self.foldAnimationController;
    } else if ([transition isEqualToString:METransitionZoom]) {
        self.zoomAnimationController.operation = operation;
        animationController = self.zoomAnimationController;
    } else if ([transition isEqualToString:METransitionUIDynamics]) {
        animationController = self.slidingAnimationController;
    } else {
        // Default
        animationController = nil;
    }

    return animationController;
}

- (id<UIViewControllerInteractiveTransitioning>)slidingViewController:(ECSlidingViewController *)slidingViewController
                          interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>)animationController {
    NSUInteger selectedIndex = [self.tableView indexPathForSelectedRow].row;
    NSString *transition = self.transitions[selectedIndex];
    id<UIViewControllerInteractiveTransitioning> interactiveTransition;
    
    if ([transition isEqualToString:METransitionFold]) {
        // The fold transition uses the default sliding interaction
        interactiveTransition = nil;
    } else if ([transition isEqualToString:METransitionZoom]) {
        // The shrink transition uses the default sliding interaction
        interactiveTransition = nil;
    } else if ([transition isEqualToString:METransitionUIDynamics]) {
        self.dynamicTransition.animationController = animationController;
        interactiveTransition = self.dynamicTransition;
    } else {
        // Default
        interactiveTransition = nil;
    }
    
    return interactiveTransition;
}

- (id<ECSlidingViewControllerLayout>)slidingViewController:(ECSlidingViewController *)slidingViewController layoutControllerForTopViewPosition:(ECSlidingViewControllerTopViewPosition)topViewPosition {
    NSUInteger selectedIndex = [self.tableView indexPathForSelectedRow].row;
    NSString *transition = self.transitions[selectedIndex];
    id<ECSlidingViewControllerLayout> layoutController = nil;
    
    if ([transition isEqualToString:METransitionZoom]) {
        layoutController = self.zoomAnimationController;
    }
    
    return layoutController;
}

- (IBAction)menuButtonTapped:(id)sender {
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
}

@end

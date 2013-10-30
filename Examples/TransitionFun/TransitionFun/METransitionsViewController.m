//
//  METransitionsViewController.m
//  TransitionFun
//
//  Created by Michael Enriquez on 10/27/13.
//  Copyright (c) 2013 Mike Enriquez. All rights reserved.
//

#import "METransitionsViewController.h"
#import "MEFoldAnimationController.h"

static NSString *const METransitionDefault = @"Default";
static NSString *const METransitionFold = @"Fold";
static NSString *const METransitionShrink = @"Shrink";
static NSString *const METransitionUIDynamics = @"UI Dynamics";

@interface METransitionsViewController ()
@property (nonatomic, strong) NSArray *transitions;
@property (nonatomic, strong) MEFoldAnimationController *foldAnimationController;
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
    
    _transitions = @[METransitionDefault, METransitionFold, METransitionShrink, METransitionUIDynamics];
    
    return _transitions;
}

- (MEFoldAnimationController *)foldAnimationController {
    if (_foldAnimationController) return _foldAnimationController;
    
    _foldAnimationController = [[MEFoldAnimationController alloc] init];
    
    return _foldAnimationController;
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

#pragma mark - ECSlidingViewControllerDelegate

- (id<UIViewControllerAnimatedTransitioning>)slidingViewController:(ECSlidingViewController *)slidingViewController
                                   animationControllerForOperation:(ECSlidingViewControllerOperation)operation
                                                 topViewController:(UIViewController *)topViewController {
    NSUInteger selectedIndex = [self.tableView indexPathForSelectedRow].row;
    NSString *transition = self.transitions[selectedIndex];
    id<UIViewControllerAnimatedTransitioning> animationController = nil;
    
    if ([transition isEqualToString:METransitionFold]) {
        animationController = self.foldAnimationController;
    } else if ([transition isEqualToString:METransitionShrink]) {
        
    } else if ([transition isEqualToString:METransitionUIDynamics]) {
        
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
    } else if ([transition isEqualToString:METransitionShrink]) {
        // The shrink transition uses the default sliding interaction
        interactiveTransition = nil;
    } else if ([transition isEqualToString:METransitionUIDynamics]) {
        
    } else {
        // Default
        interactiveTransition = nil;
    }
    
    return interactiveTransition;
}

- (IBAction)menuButtonTapped:(id)sender {
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
}

@end

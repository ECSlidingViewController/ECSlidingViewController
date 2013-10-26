//
//  MEHomeViewController.m
//  BasicMenu
//
//  Created by Michael Enriquez on 10/25/13.
//  Copyright (c) 2013 Mike Enriquez. All rights reserved.
//

#import "MEHomeViewController.h"
#import "ECSlidingViewController.h"

@interface MEHomeViewController ()

@end

@implementation MEHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)menuButtonTapped:(id)sender {
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
}

@end

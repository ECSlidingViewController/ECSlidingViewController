//
//  SampleTableViewController.h
//  ECSlidingViewController
//
//  Created by Michael Enriquez on 2/13/12.
//  Copyright (c) 2012 EdgeCase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECSlidingViewController.h"

@interface SampleTableViewController : UITableViewController <UITableViewDataSource, UITabBarControllerDelegate>
- (IBAction)revealMenu:(id)sender;
@end

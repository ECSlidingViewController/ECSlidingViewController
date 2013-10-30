//
//  METransitionsViewController.h
//  TransitionFun
//
//  Created by Michael Enriquez on 10/27/13.
//  Copyright (c) 2013 Mike Enriquez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECSlidingViewController.h"

@interface METransitionsViewController : UITableViewController <ECSlidingViewControllerDelegate>
- (IBAction)menuButtonTapped:(id)sender;
@end

//
//  SettingsViewController.h
//  LeaveATrace
//
//  Created by Ricky Brown on 12/23/13.
//  Copyright (c) 2013 15and50. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *titleText;
extern int screens;

@interface SettingsViewController : UITableViewController <UIAlertViewDelegate> {
    
    NSMutableArray *deleteTraces;
    
    BOOL option;
    
}

@property (copy) NSMutableArray *acountInfo;
@property (copy) NSMutableArray *acountInfoDetail;
@property (copy) NSMutableArray *actions;
@property (copy) NSMutableArray *info;

@end

//
//  tracesViewController.h
//  LeaveATrace
//
//  Created by Ricky Brown on 10/27/13.
//  Copyright (c) 2013 15and50. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

//Global variables
extern NSInteger traceObjectIdx;

@interface tracesViewController : UITableViewController {
    
    PFQuery *query;
        
    IBOutlet UIBarButtonItem *editButton;
    IBOutlet UIImageView *previewImage;
    IBOutlet UILabel *noTraces;
    IBOutlet UIActivityIndicatorView *loadingTraces;
    IBOutlet UIImageView *tutorialImage2;
    IBOutlet UINavigationController *TracesTitle;
    
}

@property (weak, nonatomic) IBOutlet UITableView *tracesTable;
@property (nonatomic, retain) UIActivityIndicatorView *sending;

//Actions
-(IBAction) draw:(id)sender;

//Methods for view
-(void) refreshView:(UIRefreshControl *)sender;
-(void) displayTraces;
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
-(NSIndexPath *) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath;
-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;

@end

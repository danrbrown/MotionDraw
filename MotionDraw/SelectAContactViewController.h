//
//  SelectAContactViewController.h
//  LeaveATrace
//
//  Created by Ricky Brown on 11/26/13.
//  Copyright (c) 2013 15and50. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CanvasViewController.h"
#import "CanvasViewController.h"

@interface SelectAContactViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate> {
    
    //Variables
    NSMutableArray *validContacts;
    NSString *userAccepted;
    NSString *userContact;
    PFQuery *query;
    BOOL checked;
    NSMutableArray *sendToArray;
    
    //Outlets
    IBOutlet UILabel *noSendTo;
    IBOutlet UIActivityIndicatorView *loadingValid;
    IBOutlet UIBarButtonItem *send;
    
}

@property (weak, nonatomic) IBOutlet UIButton *checkBox;
@property (strong,nonatomic) NSMutableArray *filteredArray;
@property IBOutlet UISearchBar *SearchBar;
@property (weak, nonatomic) IBOutlet UITableView *validContactsTable;
@property(nonatomic, assign) CanvasViewController *canvasViewController;
@property (strong, nonatomic) NSMutableArray *captureArray;
@property (nonatomic) double traceDrawSpeed;
@property (nonatomic, retain) NSString *textMessage;
@property (nonatomic) int xText;
@property (nonatomic) int yText;

//Actions
-(IBAction) cancel;

//Methods
-(void) displayValidContacts;
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView;
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
-(NSIndexPath *) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end

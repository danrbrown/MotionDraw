//----------------------------------------------------------------------------------
//
//  RequestsAndLogOutViewController.m
//  Checklists
//
//  Created by Ricky Brown on 10/26/13.
//  Copyright (c) 2013 Hollance. All rights reserved.
//
//  Purpose:
//
//----------------------------------------------------------------------------------

#import "RequestsAndLogOutViewController.h"
//#import "LeaveATraceRequest.h"
//#import "CanvasViewController.h"
#import "LoadTraces.h"
#import "AppDelegate.h"
#import "RequestCell.h"
#import <Parse/Parse.h>

@interface RequestsAndLogOutViewController ()

@end

@implementation RequestsAndLogOutViewController

@synthesize requestsTable; 

//----------------------------------------------------------------------------------
//
// Name:
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(void) viewDidLoad
{
    
    [self performSelector:@selector(displayRequests)];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    refreshControl.tintColor = [UIColor whiteColor];
    self.refreshControl = refreshControl;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveRequestsLoadedNotification:)
                                                 name:@"RequestsLoadedNotification"
                                               object:nil];
    
    UIFont *noFont = [UIFont fontWithName:@"PWSimpleHandwriting" size:20];
    
    noRequests.font = noFont;
    
}

//----------------------------------------------------------------------------------

-(void)viewDidAppear:(BOOL)animated
{
    if (!(APP).REQUESTS_DATA_LOADED)
    {
        
        [loadinfRequests startAnimating];
        noRequests.text = @"Loading requests";
        
    }
    else
    {
        
        [requestsTable reloadData];
        
        if ((APP).requestsArray.count == 0)
        {
            
            [loadinfRequests stopAnimating];
            noRequests.text = @"No requests right now";
            
        }
        else
        {
            
            [loadinfRequests stopAnimating];
            noRequests.text = @"";
            
        }
        
        [self displayBadgeCounts];
    
    }
    
}

//----------------------------------------------------------------------------------

- (void) receiveRequestsLoadedNotification:(NSNotification *) notification
{
    
    // [notification name] should always be @"RequestsLoadedNotification"
    // unless you use this method for observation of other notifications
    // as well.
    
    if ([[notification name] isEqualToString:@"RequestsLoadedNotification"])
    {
        
        noRequests.text = @"";
        
        [requestsTable reloadData];
        [self displayBadgeCounts];
        [loadinfRequests stopAnimating];
        
        if ((APP).requestsArray.count == 0)
        {
            
            noRequests.text = @"No requests right now";
            
        }
        
    }
    
}

//----------------------------------------------------------------------------------
//
// Name: displayCountUnopenedTraces
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(void) displayBadgeCounts
{
    
    NSString *countTracesBadge = [NSString stringWithFormat:@"%lu",(long)(APP).unopenedTraceCount];
    NSString *countFriendRequestsBadge = [NSString stringWithFormat:@"%lu",(long)(APP).friendRequestsCount];
    
    // Count of unopened Traces
    
    if ((APP).unopenedTraceCount == 0)
    {
        
        [[[[[self tabBarController] tabBar] items] objectAtIndex:0] setBadgeValue:nil];
        
    }
    else
    {
        
        [[[[[self tabBarController] tabBar] items] objectAtIndex:0] setBadgeValue:countTracesBadge];
        
    }
    
    // Count of Friend Requests
    
    if ((APP).friendRequestsCount == 0)
    {
        
        [[[[[self tabBarController] tabBar] items] objectAtIndex:3] setBadgeValue:nil];
        
    }
    else
    {
        
        [[[[[self tabBarController] tabBar] items] objectAtIndex:3] setBadgeValue:countFriendRequestsBadge];
        
    }
    
}

//----------------------------------------------------------------------------------
//
// Name:
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(void) refreshView:(UIRefreshControl *)sender
{
    
    LoadTraces *loadRequests = [[LoadTraces alloc] init];
    
    [loadRequests loadRequestsArray];
    
    [self displayRequests];
    [self displayBadgeCounts];
    
    [sender endRefreshing];
    
}

//----------------------------------------------------------------------------------
//
// Name:
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(void) displayRequests
{
    
    [requestsTable reloadData];
    
}

//----------------------------------------------------------------------------------
//
// Name:
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(IBAction) Accept:(id)sender
{
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    PFObject *tempObject = [(APP).requestsArray objectAtIndex:indexPath.row];
    
    NSString *name = [tempObject objectForKey:@"username"];
    
    // Insert the new row for the new friend relationship
    
    PFObject *newContact = [PFObject objectWithClassName:@"UserContact"];
    
    [newContact setObject:[PFUser currentUser].username forKey:@"username"];
    [newContact setObject:name forKey:@"contact"];
    [newContact setObject:@"YES" forKey:@"userAccepted"];
    
    (APP).friendRequestsCount--;
    
    [(APP).contactsArray insertObject:newContact atIndex:0];
    NSSortDescriptor *sort1 = [NSSortDescriptor sortDescriptorWithKey:@"contact" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    [(APP).contactsArray sortUsingDescriptors:[NSArray arrayWithObject:sort1]];
    
    [newContact saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (!succeeded)
        {

            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error accepting, please try again!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            
            [errorAlertView show];
            
        }

        [self performSelectorInBackground:@selector(sendPushAccptedFriendRequest:)
                               withObject:name];

        [newContact objectId];
       
    }];

    // Now update the existing row and set the boolean flat to YES

    query = [PFQuery queryWithClassName:@"UserContact"];
    
    [query whereKey:@"contact" equalTo:[[PFUser currentUser]username]];
    [query whereKey:@"username" equalTo:name];
    [query whereKey:@"userAccepted" equalTo:@"NO"];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * objects, NSError *error) {
        
        if (!error)
        {
            
            [objects setObject:@"YES" forKey:@"userAccepted"];
            [objects saveInBackground];
            
        }
        else
        {
           
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            
        }
        
    }];

    // Now delete the row out of the array and off the screen
    
    [(APP).requestsArray removeObjectAtIndex:indexPath.row];
    
    [requestsTable reloadData];
    [self displayBadgeCounts];
    
    if ((APP).requestsArray.count == 0)
    {
        
        [loadinfRequests stopAnimating];
        noRequests.text = @"No requests right now";
        
    }
    
    NSString *acceptedMessage = [NSString stringWithFormat:@"You are now friends with %@!", name];
    
    UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:acceptedMessage message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    
    [errorAlertView show];
    
}

//----------------------------------------------------------------------------------
//
// Name: sendPushToContact
//
// Purpose: Will send a push to a specifc user. It gets the Installation record
// for this user and then sends the push.
//
// To debug this incase it isn't working. There should be a row in the
// Installation object and the deviceToken should have a value (some long string).
// The 'user' field for that Installation record should be the 'objectId' in
// the User object for that user.
//
//----------------------------------------------------------------------------------

-(void) sendPushAccptedFriendRequest:(NSString *)friendAdded
{
    
    NSString *pushMessage = [NSString stringWithFormat:@"%@ accpted your Friend Request!", [PFUser currentUser].username];
    
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"username" equalTo:friendAdded];
    PFUser *user = (PFUser *)[userQuery getFirstObject];
    
    NSString *friendLoggedIn = [user objectForKey:@"LoggedIn"];
    
    if ([friendLoggedIn isEqualToString:@"Y"])
    {
        NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:pushMessage, @"alert",
                              @"Confirmed",@"msgType",
                              friendAdded, @"friend",nil];
        
        PFQuery *pushQuery = [PFInstallation query];
        [pushQuery whereKey:@"user" equalTo:user];
        
        PFPush *push = [[PFPush alloc] init];
        [push setQuery:pushQuery];
        [push setData:data];
        [push sendPushInBackground];
    }
    
}

//----------------------------------------------------------------------------------
//
// Name:
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(IBAction) Decline:(id)sender
{
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    PFObject *tempObject = [(APP).requestsArray objectAtIndex:indexPath.row];
    
    (APP).friendRequestsCount--;
    
    [tempObject deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (succeeded)
        {
            [(APP).requestsArray removeObjectAtIndex:indexPath.row];
            
            [requestsTable reloadData];
            
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:nil message:@"Why can't we all be friends?" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            
            [errorAlertView show];
            
        }
        
        if (error)
        {
            
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error declining, please try again." delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
            
            [errorAlertView show];
            
        }
        
    }];
    
}

//----------------------------------------------------------------------------------
//
// Name:
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
    
}

//----------------------------------------------------------------------------------
//
// Name:
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return (APP).requestsArray.count;
    
}

//----------------------------------------------------------------------------------
//
// Name:
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"RequestCell";
    
    RequestCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    PFObject *tempObject = [(APP).requestsArray objectAtIndex:indexPath.row];
    
    cell.cellTitle.text = [tempObject objectForKey:@"username"];
    
    UIFont *requestsFont = [UIFont fontWithName:@"PWSimpleHandwriting" size:24];
    
    cell.cellTitle.font = requestsFont;
    
    return cell;
    
}

//----------------------------------------------------------------------------------
//
// Name:
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(NSIndexPath *) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return nil;
    
}

@end

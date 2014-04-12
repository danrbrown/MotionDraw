//----------------------------------------------------------------------------------
//
//  tracesViewController.m
//  LeaveATrace
//
//  Created by Ricky Brown on 10/27/13.
//  Copyright (c) 2013 15and50. All rights reserved.
//
//  Purpose: this file of class tableView displays each
//  thread the user is involved in.
//
//----------------------------------------------------------------------------------

#import "tracesViewController.h"
//#import "ThreadViewController.h"
#import "traceCell.h"
//#import "FirstPageViewController.h"
//#import "CanvasViewController.h"
//#import "SelectAContactViewController.h"
#import "AppDelegate.h"
#import "LoadTraces.h"
#import <Parse/Parse.h>

//Global variables
UIImage *Threadimage;
NSData *data;
NSInteger traceObjectIdx;

@interface tracesViewController ()

@end

@implementation tracesViewController

@synthesize tracesTable,sending;

//----------------------------------------------------------------------------------
//
// Name: viewDidLoad
//
// Purpose: Openining method for this screen, where we allocate the traces array.
// We also call the method to display the traces for this user.
//
//----------------------------------------------------------------------------------

-(void) viewDidLoad
{
    
    [self performSelector:@selector(displayTraces)];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    refreshControl.tintColor = [UIColor whiteColor];
    self.refreshControl = refreshControl;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveTraceNotification:)
                                                 name:@"SendTraceNotification"
                                               object:nil];
    
    UIFont *noFont = [UIFont fontWithName:@"PWSimpleHandwriting" size:20];
    
    noTraces.font = noFont;
    
    NSUserDefaults *traceDefaults = [NSUserDefaults standardUserDefaults];
    NSString *tmpsawTut = [traceDefaults objectForKey:@"sawTut"];
    
    if ([tmpsawTut isEqual:@"NO"])
    {
        
        [tutorialImage2 setHidden:NO];
        
    }
    else
    {
        
        [tutorialImage2 setHidden:YES];
        
    }
    
}

//----------------------------------------------------------------------------------
//
// Name: viewDidAppear
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(void) viewDidAppear:(BOOL)animated
{

    if (!(APP).TRACES_DATA_LOADED)
    {
        
        [loadingTraces startAnimating];
        noTraces.text = @"Loading Traces";
        
    }
    else
    {
        [tracesTable reloadData];
        
        if ((APP).tracesArray.count == 0)
        {
            
            [loadingTraces stopAnimating];
            noTraces.text = @"You have no Traces";
            
        }
        else
        {
            
            [loadingTraces stopAnimating];
            noTraces.text = @"";
            
        }
        
        [self displayBadgeCounts];
        
    }
    
}

-(void) viewWillAppear:(BOOL)animated
{

    [tracesTable reloadData];
    [self displayBadgeCounts];
    
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

-(void) receiveTraceNotification:(NSNotification *) notification
{
    
    // [notification name] should always be @"SendTraceNotification"
    // unless you use this method for observation of other notifications
    // as well.
    
    if ([[notification name] isEqualToString:@"SendTraceNotification"])
    {

        noTraces.text = @"";

        [tracesTable reloadData];
        [self displayBadgeCounts];
        [loadingTraces stopAnimating];
        
        if ((APP).tracesArray.count == 0)
        {
        
            noTraces.text = @"You have no Traces";
            
        }

    }
    
}

//----------------------------------------------------------------------------------
//
// Name: draw
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(IBAction) draw:(id)sender
{
    
    [self.tabBarController setSelectedIndex:1];
    
}

//----------------------------------------------------------------------------------
//
// Name: refreshView
//
// Purpose: Method called if the user "pulls down" on the table view. We then call
// the method to display the traces.
//
//----------------------------------------------------------------------------------

-(void) refreshView:(UIRefreshControl *)sender
{
    
    LoadTraces *loadTraces = [[LoadTraces alloc] init];
    
    [loadTraces loadTracesArray];

    [self displayTraces];
    
    [sender endRefreshing];
    
}

//----------------------------------------------------------------------------------
//
// Name: displayTraces
//
// Purpose: This method queries the Parse database to get all the traces for this
// user. The traces are put in our array.
//
//----------------------------------------------------------------------------------

-(void) displayTraces
{
    
    [tracesTable reloadData];
    
}

//----------------------------------------------------------------------------------
//
// Name: tableView numberOfRowsInSection
//
// Purpose: Part of the standard tableview methods, this will return the number
// of rows for this section.
//
//----------------------------------------------------------------------------------

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return (APP).tracesArray.count;
    
}

//----------------------------------------------------------------------------------
//
// Name: tableView cellForRowAtIndexPath
//
// Purpose: This method is part of the process that displays all the traces. A trace
// can be originated from the user, or sent to the user. In either case we show
// the other person's name. So we have to do a little logic to determine if we show
// the "to" user or the "from" user.
//
//----------------------------------------------------------------------------------

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"traceItem";
    traceCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        
        cell = [[traceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    
    PFObject *traceObject = [(APP).tracesArray objectAtIndex:indexPath.row];

    NSString *tmpCurrentUser = [[PFUser currentUser]username];
    NSString *tmpFromUser = [traceObject objectForKey:@"fromUser"];
    NSString *tmpLastSentBy = [traceObject objectForKey:@"lastSentBy"];
    NSString *tmpStatus = [traceObject objectForKey:@"status"];
    NSString *tmpOpenedString;
    
    //-------------------------------------------------------------------------------
    // Determine what is displayed on the Title line.  Should always be the "other"
    // user (i.e. not the Current user.
    //-------------------------------------------------------------------------------
    
    if ([tmpCurrentUser isEqualToString:tmpFromUser])
    {
        
        cell.usernameTitle.text = [traceObject objectForKey:@"toUser"];
        
    }
    else
    {
        
        cell.usernameTitle.text = tmpFromUser;
        
    }
    
    //-------------------------------------------------------------------------------
    // Determine the status: Opened, sent, or blank (i.e. just the time)
    // Display the approiate image and set the appropriate text.
    //-------------------------------------------------------------------------------

    if ([tmpCurrentUser isEqualToString:tmpLastSentBy])  // Current user sent it
    {
        if ([tmpStatus isEqualToString:@"O"])  
        {
            
            cell.didNotOpenImage.image = [UIImage imageNamed:@"SentTrace.png"];
            cell.didNotOpenImage.frame = CGRectMake(8, 11, 45, 30);
            
            tmpOpenedString = @"- Opened";
            [cell.didNotOpenImage setHidden:NO];
            [cell.sending stopAnimating];
            
        }
        else
        {

            cell.didNotOpenImage.image = [UIImage imageNamed:@"SentNotOpened.png"];
            cell.didNotOpenImage.frame = CGRectMake(7, 12, 45, 28);
            
            if ([tmpStatus isEqualToString:@"P"])
            {
                
                tmpOpenedString = @"- Sending...";
                [cell.didNotOpenImage setHidden:YES];
                [cell.sending startAnimating];
                cell.userInteractionEnabled = NO;
                
                
            }
            else if ([tmpStatus isEqualToString:@"S"])
            {
                
                tmpOpenedString = @"- Sent";
                [cell.didNotOpenImage setHidden:NO];
                [cell.sending stopAnimating];
                cell.userInteractionEnabled = YES;
                
            }
            else if ([tmpStatus isEqualToString:@"D"])
            {
                
                tmpOpenedString = @"- Delivered";
                [cell.didNotOpenImage setHidden:NO];
                [cell.sending stopAnimating];
                
            }
            
        }
        
    }
    else  // Other user sent it
    {
        tmpOpenedString = @"";

        if ([tmpStatus isEqualToString:@"O"])
        {
            
            cell.didNotOpenImage.image = [UIImage imageNamed:@"OpenedTrace.png"];
            cell.didNotOpenImage.frame = CGRectMake(7, 8, 45, 38);
            
        }
        else
        {

            cell.didNotOpenImage.image = [UIImage imageNamed:@"NewTrace.png"];
            cell.didNotOpenImage.frame = CGRectMake(7, 12, 45, 30);
            
        }
        
    }
    
    //-------------------------------------------------------------------------------
    // Determine the display date. If the Trace happened today, then show only
    // the time. Otherwise show the entire date.
    //-------------------------------------------------------------------------------

    NSDate *updated = [traceObject objectForKey:@"lastSentByDateTime"];
    NSDate *currentdate = [NSDate date];
    
    NSDateFormatter *displayTimeFormat = [[NSDateFormatter alloc] init];
    NSDateFormatter *displayDayFormat = [[NSDateFormatter alloc] init];
    NSDateFormatter *displayDayAndTimeFormat = [[NSDateFormatter alloc] init];
 
    [displayTimeFormat setDateFormat:@"h:mm a"];
    [displayDayFormat setDateFormat:@"MM-dd-YYYY"];
    [displayDayAndTimeFormat setDateFormat:@"MMM dd, h:mm a"];
    
    NSString *tmpUpdatedDate = [NSString stringWithFormat:@"%@", [displayDayFormat stringFromDate:updated]];
    NSString *todaysDate = [NSString stringWithFormat:@"%@", [displayDayFormat stringFromDate:currentdate]];
    
    NSString *screenDate;
    NSString *combined;
    
    //-------------------------------------------------------------------------------
    // Set the string to be the full date or just the date & time
    //-------------------------------------------------------------------------------
    
    if ([tmpUpdatedDate isEqualToString:todaysDate])
    {
        
        screenDate = [NSString stringWithFormat:@"%@", [displayTimeFormat stringFromDate:updated]];
        
    }
    else
    {
        
        screenDate = [NSString stringWithFormat:@"%@", [displayDayAndTimeFormat stringFromDate:updated]];
        
    }
    
    //-------------------------------------------------------------------------------
    // Show the full date or just the date & time
    //-------------------------------------------------------------------------------

    if ([tmpCurrentUser isEqualToString:tmpLastSentBy])
    {
        
        combined = [NSString stringWithFormat:@"%@ %@", screenDate, tmpOpenedString];
        
    }
    else
    {
        
        combined = [NSString stringWithFormat:@"%@ %@", screenDate, tmpOpenedString];
        
    }
    
    cell.dateAndTimeLabel.text = combined;
    
    UIFont *titleFont = [UIFont fontWithName:@"PWSimpleHandwriting" size:20];
    UIFont *detailFont = [UIFont fontWithName:@"PWSimpleHandwriting" size:13];
    
    cell.usernameTitle.font = titleFont;
    cell.dateAndTimeLabel.font = detailFont;

    return cell;
    
}

//----------------------------------------------------------------------------------
//
// Name: tableView willSelectRowAtIndexPath
//
// Purpose: This will be called when the user selects a trace. We set our global
// variable based on the selection, and then we segue to the thread canvas screen.
//
//----------------------------------------------------------------------------------

-(NSIndexPath *) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    traceObjectIdx = indexPath.row;
    
    [self performSegueWithIdentifier:@"TraceThread" sender:self];
    
    return nil;
    
}

//----------------------------------------------------------------------------------
//
// Name: tableView commitEditingStyle
//
// Purpose: This method is used to delete a trace from the tableview. This will
// also update the array and trace accordingly.
//
//----------------------------------------------------------------------------------

-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    PFObject *tempObject = [(APP).tracesArray objectAtIndex:indexPath.row];
    NSString *tmpCurrentUser = [[PFUser currentUser]username];
    
    NSString *tmpFromUser = [tempObject objectForKey:@"fromUser"];
    NSString *tmpToUser = [tempObject objectForKey:@"toUser"];
    NSString *tmpTraceStatus = [tempObject objectForKey:@"status"];
    NSString *tmpLastSentBy = [tempObject objectForKey:@"lastSentBy"];
    
    if ([tmpCurrentUser isEqualToString:tmpFromUser])
        [tempObject setObject:@"NO"forKey:@"fromUserDisplay"];

    if ([tmpCurrentUser isEqualToString:tmpToUser])
        [tempObject setObject:@"NO"forKey:@"toUserDisplay"];
    
    //  See if the row should be deleted or updated. If both users deleted
    //  then delete from parse.  Else just update the delete flag
    
    NSString *tmpFromUserDisplay = [tempObject objectForKey:@"fromUserDisplay"];
    NSString *tmpToUserDisplay = [tempObject objectForKey:@"toUserDisplay"];
    
    if ([tmpFromUserDisplay isEqualToString:@"NO"] && [tmpToUserDisplay isEqualToString:@"NO"])
    {
        [tempObject deleteInBackground];
    }
    else
    {
        [tempObject saveInBackground];
    }
 
    [(APP).tracesArray removeObjectAtIndex:indexPath.row];
    if (![tmpCurrentUser isEqualToString:tmpLastSentBy])  // Not the current user sent it
    {
        if (((APP).unopenedTraceCount > 0) && ([tmpTraceStatus isEqualToString:@"D"]))
        {
            
            (APP).unopenedTraceCount--;
                        
            [self displayBadgeCounts];
            
        }
    }
    
    NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
    
    [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    

}

@end








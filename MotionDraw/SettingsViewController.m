//
//  SettingsViewController.m
//  LeaveATrace
//
//  Created by Ricky Brown on 12/23/13.
//  Copyright (c) 2013 15and50. All rights reserved.
//

#import "SettingsViewController.h"
//#import "FirstPageViewController.h"
//#import "DetialViewController.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>

NSString *titleText;
int screens;

@interface SettingsViewController ()

@end

@implementation SettingsViewController

//----------------------------------------------------------------------------------
//
// Name:
//
// Purpose:
//
//----------------------------------------------------------------------------------

- (void)viewDidLoad
{
    
    NSString *usernameString = [[PFUser currentUser] username];
    NSString *emailString = [[PFUser currentUser] email];
    NSDate *createdAt = [[PFUser currentUser] createdAt];
    
    NSDateFormatter *displayDayAndTimeFormat = [[NSDateFormatter alloc] init];
    [displayDayAndTimeFormat setDateFormat:@"MMM dd, YYYY h:mm a"];
    NSString *createdAtString = [NSString stringWithFormat:@"%@", [displayDayAndTimeFormat stringFromDate:createdAt]];
    
    self.acountInfo = [@[@"Username", @"Email", @"Leave A Trace user since", @"Traces sent", @"Traces received"] mutableCopy];
    
    self.acountInfoDetail = [@[usernameString, emailString, createdAtString, @"not working", @"not working"] mutableCopy];
    
    self.actions = [@[@"Log out", @"Clear my traces"] mutableCopy];
    
    self.info = [@[@"Support", @"Privacy policy", @"Terms of use"] mutableCopy];
    

    
}

//----------------------------------------------------------------------------------
//
// Name: getThreadTrace
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (section == 0)
    {
    
        return self.acountInfo.count;
    
    }
    else if (section == 1)
    {
    
        return self.actions.count;
    
    }
    else
    {
        
        return self.info.count;
        
    }
    
}

//----------------------------------------------------------------------------------
//
// Name: getThreadTrace
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 3;

}

//----------------------------------------------------------------------------------
//
// Name: getThreadTrace
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    if (section == 0)
    {
        
        return @"Acount";
    
    }
    else if (section == 1)
    {
    
        return @"Actions";
    
    }
    else
    {
        
        return @"Information";
        
    }
}

//----------------------------------------------------------------------------------
//
// Name: getThreadTrace
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    
    if (sectionTitle == nil) {
        return nil;
    }
    
    UILabel *label = [[UILabel alloc] init];
    
    if (section == 0)
    {
        
        label.frame = CGRectMake(20, 30, 320, 20);
    
    }
    else
    {
        
        label.frame = CGRectMake(20, 12, 320, 20);
        
    }
    
    UIFont *sectionFont = [UIFont fontWithName:@"PWSimpleHandwriting" size:19];
    
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.text = sectionTitle;
    label.font = sectionFont;
    
    UIView *view = [[UIView alloc] init];
    [view addSubview:label];
    
    return view;
    
}

//----------------------------------------------------------------------------------
//
// Name: getThreadTrace
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(NSIndexPath *) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 1 && indexPath.row == 0)
    {
        
        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:nil message:@"Do you really want to log out?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        
        [errorAlertView show];
        
    }

    if (indexPath.section == 1 && indexPath.row == 1)
    {
        
        PFObject *userTraces = [PFObject objectWithClassName:@"TracesObject"];
        [userTraces setObject:[PFUser currentUser].username forKey:@"fromUser"];
        
        [userTraces deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if (succeeded)
            {
                
                [self deleteMyTraces];
                
                UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:nil message:@"You cleared your traces." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                
                [errorAlertView show];
            
            }
            else
            {
                
                NSString *errorString = [[error userInfo] objectForKey:@"error"];
                UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:  errorString delegate:nil cancelButtonTitle:@"Ok"    otherButtonTitles:nil, nil];
                
                [errorAlertView show];
                
            }
            
        }];

    }
    
    if (indexPath.section == 2 && indexPath.row == 0)
    {
        
        [self performSegueWithIdentifier:@"showDetail" sender:self];
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        titleText = cell.textLabel.text;
        
        screens = 0;
        
    }
    
    if (indexPath.section == 2 && indexPath.row == 1)
    {
        
        [self performSegueWithIdentifier:@"showDetail" sender:self];
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        titleText = cell.textLabel.text;
        
        screens = 1;
        
    }
    
    if (indexPath.section == 2 && indexPath.row == 2)
    {
        
        [self performSegueWithIdentifier:@"showDetail" sender:self];
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        titleText = cell.textLabel.text;
        
        screens = 2;
        
    }
    
    return nil;
    
}

//----------------------------------------------------------------------------------
//
// Name: getThreadTrace
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
 
    if (buttonIndex == 1)
    {
        
        NSUserDefaults *traceDefaults = [NSUserDefaults standardUserDefaults];
        [traceDefaults setObject:@"" forKey:@"username"];
        //[traceDefaults setObject:@"" forKey:@"password"];
        [traceDefaults synchronize];
        
        (APP).tracesArray = nil;
        (APP).contactsArray = nil;
        (APP).requestsArray = nil;
        
        (APP).TRACES_DATA_LOADED = NO;
        (APP).CONTACTS_DATA_LOADED = NO;
        (APP).REQUESTS_DATA_LOADED = NO;
        
        [[PFUser currentUser] setObject:@"N" forKey:@"LoggedIn"];
        
        
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if (succeeded)
            {
                
                [PFUser logOut];
                
            }
            
        }];
        
        //[PFUser logOut];
        
        [self performSegueWithIdentifier:@"LogOutSuccesful" sender:self];
        
    }
    
}

//----------------------------------------------------------------------------------
//
// Name: getThreadTrace
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"settingsItem"];
    
    NSString *text;
    NSString *detail;
    
    if (indexPath.section == 0)
    {
        
        text = self.acountInfo[indexPath.row];
        detail = self.acountInfoDetail[indexPath.row];
    
    }
    else if (indexPath.section == 1)
    {
    
        text = self.actions[indexPath.row];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        
    }
    else
    {
        
        text = self.info[indexPath.row];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        
    }
    
    cell.textLabel.text = text;
    cell.detailTextLabel.text = detail;
    
    UIFont *titleFont = [UIFont fontWithName:@"PWSimpleHandwriting" size:18];
    UIFont *detailFont = [UIFont fontWithName:@"PWSimpleHandwriting" size:14];

    cell.textLabel.font = titleFont;
    cell.detailTextLabel.font = detailFont;
    
    return cell;

}

//----------------------------------------------------------------------------------
//
// Name: getThreadTrace
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(IBAction) done:(id)sender
{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

//----------------------------------------------------------------------------------
//
// Name: getThreadTrace
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(void) deleteMyTraces
{
    
    NSString *tmpCurrentUser = [[PFUser currentUser] username];
    NSInteger idx = 0;
    
    // First step is to make a copy of the array, zero out the counter, set the badge icon to blank
    
    NSMutableArray *deleteArray = [[NSMutableArray alloc] initWithArray:(APP).tracesArray];
    [(APP).tracesArray removeAllObjects];
    (APP).unopenedTraceCount = 0;
    [[[[[self tabBarController] tabBar] items] objectAtIndex:0] setBadgeValue:nil];
    
    // Then loop through the temporary array and delete one at a time. This may take some
    // time depending on the size of the array and the type of network connection.
    
    for (PFObject *obj in deleteArray)
    {
        
        NSString *tmpFromUser = [obj objectForKey:@"fromUser"];
        NSString *tmpToUser = [obj objectForKey:@"toUser"];
        
        if ([tmpCurrentUser isEqualToString:tmpFromUser])
            [obj setObject:@"NO" forKey:@"fromUserDisplay"];
        
        if ([tmpCurrentUser isEqualToString:tmpToUser])
            [obj setObject:@"NO" forKey:@"toUserDisplay"];
        
        //  See if the row should be deleted or updated. If both users deleted
        //  then delete from parse.  Else just update the delete flag
        
        NSString *tmpFromUserDisplay = [obj objectForKey:@"fromUserDisplay"];
        NSString *tmpToUserDisplay = [obj objectForKey:@"toUserDisplay"];
        
        if ([tmpFromUserDisplay isEqualToString:@"NO"] && [tmpToUserDisplay isEqualToString:@"NO"])
        {
            
            [obj deleteInBackground];
            
        }
        else
        {
            
            [obj saveInBackground];
                        
        }
        
        idx++;
        
    }
    
}

@end

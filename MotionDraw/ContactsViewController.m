//----------------------------------------------------------------------------------
//
//  ContactsViewController.m
//  LeaveATrace
//
//  Created by Ricky Brown on 10/26/13.
//  Copyright (c) 2013 15and50. All rights reserved.
//
//  Purpose: This file of class tableView displays each
//  contact associated with this user.
//
//----------------------------------------------------------------------------------

#import "ContactsViewController.h"
//#import "CanvasViewController.h"
//#import "AddItemViewController.h"
#import "AppDelegate.h"
#import "LeaveATraceItem.h"
#import "LoadTraces.h"
#import <Parse/Parse.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface ContactsViewController ()

@end

@implementation ContactsViewController

@synthesize contactsView;

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
    
    [self performSelector:@selector(displayContacts)];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    refreshControl.tintColor = [UIColor whiteColor];
    self.refreshControl = refreshControl;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveContactsLoadedNotification:)
                                                 name:@"ContactsLoadedNotification"
                                               object:nil];
    
    UIFont *noFont = [UIFont fontWithName:@"ComicRelief" size:20];
    
    noContacts.font = noFont;
    
    contactsFriends = [[NSMutableArray alloc] init];

    [self getAllContacts];
    
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
    
    if (!(APP).CONTACTS_DATA_LOADED)
    {
        
        [loadingFreinds startAnimating];
        noContacts.text = @"Loading Friends";
        
    }
    else
    {
        [contactsView reloadData];
        
        if ((APP).contactsArray.count == 0)
        {
            
            [loadingFreinds stopAnimating];
            noContacts.text = @"You have no friends?";
            
        }
        else
        {
            
            [loadingFreinds stopAnimating];
            noContacts.text = @"";
            
        }
        
        [self displayBadgeCounts];
    }

}

//----------------------------------------------------------------------------------

- (void) receiveContactsLoadedNotification:(NSNotification *) notification
{
    
    // [notification name] should always be @"ContactsLoadedNotification"
    // unless you use this method for observation of other notifications
    // as well.
    
    if ([[notification name] isEqualToString:@"ContactsLoadedNotification"])
    {
                
        noContacts.text = @"";
        
        [contactsView reloadData];
        [self displayBadgeCounts];
        [loadingFreinds stopAnimating];
        
        if ((APP).contactsArray.count == 0)
        {
            
            noContacts.text = @"You have no Friends";
            
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
// Name: displayContacts
//
// Purpose: This method retrieves the list of contacts for this user from Parse and
// displays them on the screen. It also loads up our array of contacts.
// DB - redo this method more efficiently by following the example in
// ThreadViewController.m
//
//----------------------------------------------------------------------------------

-(void) displayContacts
{
    
    [contactsView reloadData];
    
}

//----------------------------------------------------------------------------------
//
// Name: refreshView
//
// Purpose: This is called when the user "pulls down" to refresh the view.
// However this current version (12/1/2013) is not working.
//
//----------------------------------------------------------------------------------

-(void) refreshView:(UIRefreshControl *)sender
{
    
    LoadTraces *loadTraces = [[LoadTraces alloc] init];
    
    [loadTraces loadContactsArray];

    [self displayContacts];
    
    [sender endRefreshing];
    
}

//----------------------------------------------------------------------------------
//
// Name: configureCheckmarkForCell
//
// Purpose: Determines if the user is a 'friend' or if the request is still
// 'pending' and appends the appropriate text next to the contact name.
//
//----------------------------------------------------------------------------------

-(void) configureCheckmarkForCell:(UITableViewCell *)cell withChecklistItem:(NSString *)isAFriend
{
    
    cell.textLabel.enabled = YES;
    
    if ([isAFriend isEqualToString:@"NO"])
    {
        
        cell.detailTextLabel.text = @"Pending";
        cell.detailTextLabel.enabled = NO;
        cell.textLabel.enabled = NO;
        cell.userInteractionEnabled = NO;
        
    }
    else
    {
        
        cell.detailTextLabel.text = @"";
        cell.detailTextLabel.enabled = YES;
        cell.textLabel.enabled = YES;
        cell.userInteractionEnabled = YES;
        
    }
    
}

//----------------------------------------------------------------------------------
//
// Name: configureTextForCell withChecklistItem
//
// Purpose: Method is one of the many called for navigating around the tableview.
// This method updates a cell with a contact name.
//
//----------------------------------------------------------------------------------

-(void) configureTextForCell:(UITableViewCell *)cell withChecklistItem:(LeaveATraceItem *)item
{
    
    cell.textLabel.text = item.text;
    
}

//----------------------------------------------------------------------------------
//
// Name: tableView cellForRowAtIndexPath
//
// Purpose: Method is one of the many called for navigating around the tableview.
// This method updates a given cell on the table view.
//
//----------------------------------------------------------------------------------

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // break here
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChecklistItem"];
    
    NSString *text;
    
    if (indexPath.section == 0)
    {
        PFObject *item = [(APP).contactsArray objectAtIndex:indexPath.row];
        NSString *tmpUserContact = [item objectForKey:@"contact"];
        NSString *tmpUserAccepted = [item objectForKey:@"userAccepted"];
        
        text = tmpUserContact;
        
        [self configureCheckmarkForCell:cell withChecklistItem:tmpUserAccepted];
        UIFont *friendsFont = [UIFont fontWithName:@"ComicRelief" size:22];
        cell.textLabel.font = friendsFont;
        
    }
    else
    {
        text = contactsFriends[indexPath.row];
        cell.detailTextLabel.text = @"";
        UIFont *friendsFont = [UIFont fontWithName:@"ComicRelief" size:22];
        cell.textLabel.font = friendsFont;
    }
    
    cell.textLabel.text = text;
    
    return cell;
    
}

//----------------------------------------------------------------------------------
//
// Name: addItemViewControllerDidCancel
//
// Purpose: This is called if a user goes to add a new contact, but then hits
// cancel.
//
//----------------------------------------------------------------------------------

-(void) addItemViewControllerDidCancel:(AddItemViewController *)controller
{
    
    [self dismissViewControllerAnimated:NO completion:nil];
    
}

//----------------------------------------------------------------------------------
//
// Name: addItemViewController
//
// Purpose: This method is used when a user is adding a new contact. It will take
// the content from the pop-up screen and add it to our array. It also closes
// the pop-up screen and leaves the user on the tableview screen.
//
//----------------------------------------------------------------------------------

-(void) addItemViewController:(AddItemViewController *)controller didFinishAddingItem:(LeaveATraceItem *)item
{
    
    //  Need a better way to do this. Right now we're going to the database. But we really should simply
    //  add a PFObject to our array. How do you do this? DB
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [self displayContacts];

}

//----------------------------------------------------------------------------------
//
// Name:
//
// Purpose: Method is one of the many called for navigating around the tableview.
// This is used to display contacts from the database on the tableview. We called
// it 'noDismiss' because it's the same as the method above, but we're not
// dismissing a screen.
//
//----------------------------------------------------------------------------------

-(void) addItemViewControllerNoDismiss:(AddItemViewController *)controller didFinishAddingItem:(LeaveATraceItem *)item
{
    
    NSUInteger newRowIndex = [(APP).contactsArray count];
    
    [(APP).contactsArray addObject:item];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:newRowIndex inSection:0];
    
    NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
    
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    
}

//----------------------------------------------------------------------------------
//
// Name: prepareForSegue
//
// Purpose: Method to segue to the screen to add a new contact.
//
//----------------------------------------------------------------------------------

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:@"AddItem"])
    {
        
        UINavigationController *navigationController = segue.destinationViewController;
        AddItemViewController *controller = (AddItemViewController *)navigationController.topViewController;
        controller.delegate = self;
        controller.stuff = (APP).contactsArray;
    }
    
}

//----------------------------------------------------------------------------------
//
// Name: tableView willSelectRowAtIndexPath
//
// Purpose: Method is one of the many called for navigating around the tableview.
// We don't want any action to take place when the user touches a row, so we
// simply return nil.
//
//----------------------------------------------------------------------------------

-(NSIndexPath *) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    return nil;
    
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
    
    return 2;
    
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
        
        return (APP).contactsArray.count;
        
    }
    else
    {
        
        return contactsFriends.count;
        
    }
    
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
        
        return @"Friends";
        
    }
    else
    {
        
        return @"Contacts who have Leave A Trace";
        
    }
    
}


    
-(void) tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    
    // Background color
    view.tintColor = [UIColor colorWithHue:0.589815 saturation:1 brightness:1 alpha:1];
    
    // Text Color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor whiteColor]];
    
    // Another way to set the background color
    // Note: does not preserve gradient effect of original header
    // header.contentView.backgroundColor = [UIColor blackColor];
}
    
-(void) getAllContacts
{
    
    CFErrorRef *error = nil;
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    
    __block BOOL accessGranted = NO;
    
    if (ABAddressBookRequestAccessWithCompletion != NULL)
    {
        
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        
    }
    else
    {
        accessGranted = YES;
    }
    
    if (accessGranted) {
        
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
        ABRecordRef source = ABAddressBookCopyDefaultSource(addressBook);
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, source, kABPersonSortByFirstName);
        CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
        //NSMutableArray* items = [NSMutableArray arrayWithCapacity:nPeople];
        
        
        
        for (int i = 0; i < nPeople; i++)
        {
            
            ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
            
            // Get the first and the last name. Actually, copy their values using the person object and the appropriate
            // properties into two string variables equivalently.
            // Watch out the ABRecordCopyValue method below. Also, notice that we cast to NSString *.
            
            NSString *firstName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
            NSString *lastName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
            
            // Compose the full name.
            
            NSString *fullName = @"";
            
            // Before adding the first and the last name in the fullName string make sure that these values are filled in.
            
            if (firstName != nil)
            {
                
                fullName = [fullName stringByAppendingString:firstName];
                
            }
            if (lastName != nil)
            {
                
                fullName = [fullName stringByAppendingString:@" "];
                
                fullName = [fullName stringByAppendingString:lastName];
                
            }
            
            // The phone numbers and the e-mails are contact info that have multiple values.
            // For that reason we need to get them as arrays and not as single values as we did with the names above.
            // Watch out the ABMultiValueCopyArrayOfAllValues method that we use to copy the necessary data into our arrays.
            
            NSArray *phones = (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(ABRecordCopyValue(person, kABPersonPhoneProperty));
            NSArray *emails = (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(ABRecordCopyValue(person, kABPersonEmailProperty));
            
            // Create a temp array in which we'll add all the desired values.
            
            [contactsFriends addObject:fullName];
            
            // Make sure that the selected contact has one phone at least filled in.
            
            if ([phones count] > 0)
            {
                
                // We'll use the first phone number only here.
                // In a real app, it's up to you to play around with the returned values and pick the necessary value.
                [contactsFriends addObject:[phones objectAtIndex:0]];
                
            }
            else
            {
                
                [contactsFriends addObject:@"No phone number set"];
                
            }
            
            // Do the same for the e-mails.
            // Make sure that the selected contact has one email at least filled in.
            
            if ([emails count] > 0)
            {
                
                // We'll use the first email only here.
                [contactsFriends addObject:[emails objectAtIndex:0]];
                
            }
            else
            {
                
                [contactsFriends addObject:@"No e-mail was set"];
                
            }
            
        }
        
    }
    else
    {
        
        NSLog(@"Cannot fetch Contacts :( ");
        
    }
    
    NSLog(@"%@", contactsFriends);
    
}

@end





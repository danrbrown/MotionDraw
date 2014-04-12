//----------------------------------------------------------------------------------
//
//  AddItemViewController.m
//  Checklists
//
//  Created by Matthijs Hollemans on 03-06-12.
//  Copyright (c) 2012 Hollance. All rights reserved.
//
//  Purpose: This class is for the "pop-up" to add a new contact. The contact
//  entered by the user is validated to ensure that it already exists in our
//  database.
//
//----------------------------------------------------------------------------------


#import "AddItemViewController.h"
#import "LeaveATraceItem.h"
#import "AppDelegate.h"
#import "LoadTraces.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MessageUI.h>
#import <Parse/Parse.h>

@interface AddItemViewController ()

@end

@implementation AddItemViewController

@synthesize textField, doneBarButton, delegate, stuff, contacts;

//----------------------------------------------------------------------------------
//
// Name: viewDidLoad
//
// Purpose: First method to be called. Turn off autocorrection and
// turn off auto capitalization.
//
//----------------------------------------------------------------------------------

- (void) viewDidLoad
{
    
    textField.autocorrectionType = FALSE;
    
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    UIFont *textfieldFont = [UIFont fontWithName:@"PWSimpleHandwriting" size:23];
    textField.font = textfieldFont;
    
}

//----------------------------------------------------------------------------------
//
// Name: viewWillAppear
//
// Purpose: Called whenever the view is displayed.
//
//----------------------------------------------------------------------------------

- (void) viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
 
    [self.textField becomeFirstResponder];
    
}

-(IBAction) askFriend
{
    
    UIFont *titleFont = [UIFont fontWithName:@"Helvetica Neue" size:20];
    
    NSShadow* shadow = [NSShadow new];
    shadow.shadowOffset = CGSizeMake(0.0f, 0.0f);
    shadow.shadowColor = [UIColor clearColor];
    [[UINavigationBar appearance] setTitleTextAttributes: @{
                                                            NSForegroundColorAttributeName: [UIColor blackColor],
                                                            NSFontAttributeName:titleFont,
                                                            NSShadowAttributeName:shadow
                                                            }];
    
    contacts = [[ABPeoplePickerNavigationController alloc] init];

    [contacts setPeoplePickerDelegate:self];
    
    [self presentViewController:contacts animated:YES completion:nil];
    
}

-(void) peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    
    UIFont *titleFont = [UIFont fontWithName:@"PWSimpleHandwriting" size:26];
    
    NSShadow* shadow = [NSShadow new];
    shadow.shadowOffset = CGSizeMake(0.0f, 0.0f);
    shadow.shadowColor = [UIColor clearColor];
    [[UINavigationBar appearance] setTitleTextAttributes: @{
                                                            NSForegroundColorAttributeName: [UIColor yellowColor],
                                                            NSFontAttributeName:titleFont,
                                                            NSShadowAttributeName:shadow
                                                            }];
    
    [contacts dismissViewControllerAnimated:YES completion:nil];
    
}

-(BOOL) peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{

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
    
    info = [[NSMutableArray alloc] init];
    [info addObject:fullName];
    
    // Make sure that the selected contact has one phone at least filled in.
    
    if ([phones count] > 0)
    {
        
        // We'll use the first phone number only here.
        // In a real app, it's up to you to play around with the returned values and pick the necessary value.
        [info addObject:[phones objectAtIndex:0]];
        
    }
    else
    {
        
        [info addObject:@"No phone number set"];
        
    }
    
    // Do the same for the e-mails.
    // Make sure that the selected contact has one email at least filled in.
    
    if ([emails count] > 0)
    {
        
        // We'll use the first email only here.
        [info addObject:[emails objectAtIndex:0]];
        
    }
    else
    {
        
        [info addObject:@"No e-mail was set"];
        
    }
    
    if ([info[1]  isEqual: @"No phone number set"] && [info[2]  isEqual: @"No e-mail was set"]) //No number and no email
    {
        
        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Opps" message:[NSString stringWithFormat:@"There is no number or email set for %@", info[0]] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        
        [errorAlertView show];
        
    }
    else if (![info[1]  isEqual: @"No phone number set"] && [info[2]  isEqual: @"No e-mail was set"]) //Yes number no email
    {
        
        [contacts dismissViewControllerAnimated:YES completion:nil];
        
        [self performSelector:@selector(sendTheText) withObject:nil afterDelay:1.5];
        
    }
    else if ([info[1]  isEqual: @"No phone number set"] && ![info[2]  isEqual: @"No e-mail was set"]) //No number yes email
    {
        
        [contacts dismissViewControllerAnimated:YES completion:nil];
        
        [self performSelector:@selector(sendTheEmail) withObject:nil afterDelay:1.5];
        
    }
    else //Both number and email
    {
        
        [contacts dismissViewControllerAnimated:YES completion:nil];
        
        [self performSelector:@selector(sendTheText) withObject:nil afterDelay:1.5];
        
    }
    
    return NO;
    
}

-(void) sendTheText
{
    
    MFMessageComposeViewController *textMessage = [[MFMessageComposeViewController alloc] init];
    
    [textMessage setMessageComposeDelegate:self];
    
    if ([MFMessageComposeViewController canSendText])
    {
        
        [textMessage setRecipients:[NSArray arrayWithObjects:info[1], nil]];
        
        [textMessage setBody:@"Join Leave A Trace, the best drawing social media app out there!"];
        
        [self presentViewController:textMessage animated:YES completion:nil];
        
    }
    
}

-(void) sendTheEmail
{
    
    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
    
    [mailComposer setMailComposeDelegate:self];
    
    if ([MFMailComposeViewController canSendMail])
    {
        
        [mailComposer setToRecipients:[NSArray arrayWithObjects:info[2], nil]];
        
        [mailComposer setSubject:@"Leave A Trace"];
        
        [mailComposer setMessageBody:@"Join Leave A Trace, the best drawing social media app out there!" isHTML:NO];
        
        [self presentViewController:mailComposer animated:YES completion:nil];
        
    }
    
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    
    return NO;
    
}

-(void) messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

//----------------------------------------------------------------------------------
//
// Name: cancel
//
// Purpose: Method called if the user presses cancel on the pop-up. It simply
// closes the screen and returns to the contact list.
//
//----------------------------------------------------------------------------------

-(IBAction) cancel
{
    
    [self.delegate addItemViewControllerDidCancel:self];
    
}

//----------------------------------------------------------------------------------
//
// Name: done
//
// Purpose: Method called if the user presses Done on the pop-up. We first query
// Parse to make sure the user that was entered exists in the database and will give
// an error if it doesn't. Otherwise we entered the row in our database.
//
//----------------------------------------------------------------------------------
 
-(IBAction) done
{
    
    [loadingContact startAnimating];
    
    BOOL isDuplicate = NO;
    
    LeaveATraceItem *item = [[LeaveATraceItem alloc] init];
    item.text = self.textField.text;
    
    //---------------------------------------------------------
    //Check to see if the user is trying to insert him/herself
    //---------------------------------------------------------
    
    NSString *tmpCurrentUser = [[PFUser currentUser]username];
    
    if ([tmpCurrentUser isEqualToString:item.text])
    {
    
        [loadingContact stopAnimating];
        
        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"You can't add yourself as a friend... but I like the idea!" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        
        [errorAlertView show];
        
    }
    else
    {
        //---------------------------------------------------------
        // See if the contact is already in our array.
        // Thanks to co-founder 15 for figuring this out.
        //---------------------------------------------------------
        
        NSUInteger contactIndex;
        PFObject *tmpObject;
        NSString *tmpContact;
        
        for (contactIndex = 0; contactIndex < stuff.count; contactIndex++)
        {
            
            tmpObject = [stuff objectAtIndex:contactIndex];
            
            tmpContact = [tmpObject objectForKey:@"contact"];
            
            if ([tmpContact isEqualToString:item.text])
            {
                isDuplicate = YES;
                break;
            }
            
        }

        if (isDuplicate)
        {
            
            [loadingContact stopAnimating];
            
            NSString *errorString = [NSString stringWithFormat:@"%@ is already your friend!", self.textField.text];
            
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:errorString message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            
            [errorAlertView show];
            
        }
        else
        {
        
            //---------------------------------------------------------
            // Query to see if the person they're adding is a valid
            // LeaveATrace user.
            //---------------------------------------------------------

            item.userAccepted = @"NO";
    
            PFQuery *query= [PFUser query];
            [query whereKey:@"username" equalTo:item.text];
    
            [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        
                if (!error)
                {
                
                    //---------------------------------------------------------
                    // If they're valid, then add to database.
                    //---------------------------------------------------------

                    PFObject *userContact = [PFObject objectWithClassName:@"UserContact"];
                    [userContact setObject:[PFUser currentUser].username forKey:@"username"];
                    [userContact setObject:item.text forKey:@"contact"];
                    [userContact setObject:@"NO" forKey:@"userAccepted"];
                    [userContact setObject:@"" forKey:@"nickname"];

                    [(APP).contactsArray insertObject:userContact atIndex:0];
                    NSSortDescriptor *sort1 = [NSSortDescriptor sortDescriptorWithKey:@"contact" ascending:YES selector:@selector(caseInsensitiveCompare:)];
                    [(APP).contactsArray sortUsingDescriptors:[NSArray arrayWithObject:sort1]];
                    
                    [userContact saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
                        if (succeeded)
                        {
                            
                            [loadingContact stopAnimating];
                            
                            [self performSelectorInBackground:@selector(sendPushForFriendRequest:)
                                                   withObject:item.text];

                            [self.delegate addItemViewController:self didFinishAddingItem:item];
            
                        }
                        else
                        {
            
                            [loadingContact stopAnimating];
                            
                            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"There there was an error sending your request, please try again!" message:nil delegate:nil cancelButtonTitle:@"Ok"    otherButtonTitles:nil, nil];
                    
                            [errorAlertView show];
                        
                        }
                
                    }];
            
                }
                else
                {
            
                    [loadingContact stopAnimating];
            
                    UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"User not found!" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            
                    [errorAlertView show];
            
                }
        
            }];
        }
    }
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

-(void) sendPushForFriendRequest:(NSString *)friendToBeAdded
{
    
    LoadTraces *friendRequests = [[LoadTraces alloc] init];
    
    NSString *pushMessage = [NSString stringWithFormat:@"%@ sent you a Friend Request!", [PFUser currentUser].username];
    
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"username" equalTo:friendToBeAdded];
    PFUser *user = (PFUser *)[userQuery getFirstObject];
    
    NSString *friendLoggedIn = [user objectForKey:@"LoggedIn"];
    
    NSInteger friendTracesCount = [friendRequests countTracesForFriend:friendToBeAdded];
    NSInteger friendRequestsCount = [friendRequests countFriendRequestsForFriend:friendToBeAdded];
    NSInteger friendBadgeCount = friendTracesCount + friendRequestsCount;
    
    NSString *countTracesString = [NSString stringWithFormat:@"%li", (long)friendBadgeCount];

    if ([friendLoggedIn isEqualToString:@"Y"])
    {
        
        NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:pushMessage, @"alert",
                              countTracesString,@"badge",
                              @"Request",@"msgType",
                              friendToBeAdded, @"friend",nil];
                
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
// Name: tableView:willSelectRowAtIndexPath
//
// Purpose: The user can't "select" a row so we simply return nil if it's pressed.
//
//----------------------------------------------------------------------------------

-(NSIndexPath *) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    return nil;
    
}

//----------------------------------------------------------------------------------
//
// Name: textField:shouldChangeCharactersInRange
//
// Purpose: Method makes sure there's a value in the field.
//
//----------------------------------------------------------------------------------

-(BOOL) textField:(UITextField *)theTextField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    NSString *newText = [theTextField.text stringByReplacingCharactersInRange:range withString:string];
    
    self.doneBarButton.enabled = ([newText length] > 0);
    
    return YES;
    
}

@end

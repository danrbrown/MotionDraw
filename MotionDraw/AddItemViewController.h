//
//  AddItemViewController.h
//  Checklists
//
//  Created by Matthijs Hollemans on 03-06-12.
//  Copyright (c) 2012 Hollance. All rights reserved.
//

@class AddItemViewController;
@class LeaveATraceItem;
 
@protocol AddItemViewControllerDelegate <NSObject>
 
-(void) addItemViewControllerDidCancel:(AddItemViewController *)controller;
 
-(void) addItemViewController:(AddItemViewController *)controller didFinishAddingItem:(LeaveATraceItem *)item;
 
@end

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MessageUI.h>

@interface AddItemViewController : UITableViewController <UITextFieldDelegate, ABPeoplePickerNavigationControllerDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate> {
    
    IBOutlet UIActivityIndicatorView *loadingContact;
    IBOutlet UIButton *askButton;
    
    NSMutableArray *info;
    
}

//Propertys
@property (strong, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneBarButton;
@property (nonatomic, weak) id <AddItemViewControllerDelegate> delegate;
@property (nonatomic, weak) NSMutableArray *stuff;
@property (nonatomic, retain) ABPeoplePickerNavigationController *contacts;

//Actions
-(IBAction) cancel;
-(IBAction) done;
-(IBAction) askFriend;

//Methods
-(NSIndexPath *) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath;
-(BOOL) textField:(UITextField *)theTextField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
-(void) peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker;
-(BOOL) peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person;
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier;

@end

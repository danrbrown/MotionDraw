//
//  DetialViewController.m
//  LeaveATrace
//
//  Created by Ricky Brown on 2/3/14.
//  Copyright (c) 2014 15and50. All rights reserved.
//

#import "DetialViewController.h"
#import "SettingsViewController.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MessageUI.h>

@interface DetialViewController ()

@end

@implementation DetialViewController

- (void)viewDidLoad
{
    
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    self.title = titleText;
    
    supportText.editable = NO;
    
    if (screens == 0) //Support
    {
        
        [supportText setHidden:NO];
        [supportButton setHidden:NO];
        
        supportText.font = [UIFont fontWithName:@"PWSimpleHandwriting" size:18];
        
        [pdf setHidden:YES];
        
    }
    else if (screens == 1) //Privacy
    {
        
        [supportText setHidden:YES];
        [supportButton setHidden:YES];
        
        [pdf setHidden:NO];
        
        NSString *PrivacyPath = [[NSBundle mainBundle] pathForResource:@"Leave A Trace - Privacy Policy" ofType:@"pdf"];
        
        NSURL *url = [NSURL fileURLWithPath:PrivacyPath];
        
        NSURLRequest *requesest = [NSURLRequest requestWithURL:url];
        
        [pdf loadRequest:requesest];
        
    }
    else if (screens == 2) //Terms
    {
        
        [supportText setHidden:YES];
        [supportButton setHidden:YES];
        
        [pdf setHidden:NO];
        
        NSString *TermsPath = [[NSBundle mainBundle] pathForResource:@"Leave A Trace - Terms of Use" ofType:@"pdf"];
        
        NSURL *TermsURL = [NSURL fileURLWithPath:TermsPath];
        
        NSURLRequest *TermsRequesest = [NSURLRequest requestWithURL:TermsURL];
        
        [pdf loadRequest:TermsRequesest];
        
    }
    
}

-(IBAction)sendEmail:(id)sender
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
    
    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
    
    [mailComposer setMailComposeDelegate:self];
    
    if ([MFMailComposeViewController canSendMail])
    {
        
        [mailComposer setToRecipients:[NSArray arrayWithObjects:@"draw@15and50.com", nil]];
        
        [mailComposer setSubject:@"Leave A Trace"];
        
        [mailComposer setMessageBody:@"Dear Dan and Ricky,\n" isHTML:NO];
        
        [self presentViewController:mailComposer animated:YES completion:nil];
        
    }
    
}

-(void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
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
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

@end

//
//  ForgotPasswordViewController.m
//  LeaveATrace
//
//  Created by Daniel Brown on 2/16/14.
//  Copyright (c) 2014 15and50. All rights reserved.
//

#import "ForgotPasswordViewController.h"
#import <Parse/Parse.h>

@interface ForgotPasswordViewController ()

@end

@implementation ForgotPasswordViewController

-(void)viewDidLoad
{
    
    FusernameTextFeild.layer.cornerRadius = 7;
    
    FusernameTextFeild.autocorrectionType = UITextAutocorrectionTypeNo;
    FusernameTextFeild.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    FusernameTextFeild.delegate = self;
    
}

-(void)getUsersEmail:(NSString *)userName
{
    
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"username" equalTo:userName];
    PFUser *user = (PFUser *)[userQuery getFirstObject];
    
    if (userQuery.countObjects > 0)
    {
        
        NSString *usersEmail = [user objectForKey:@"email"];
        [PFUser requestPasswordResetForEmailInBackground:usersEmail];
        
        UIAlertView *success = [[UIAlertView alloc] initWithTitle:@"Check your email!" message:@"A email to reset your password has been sent" delegate:self cancelButtonTitle:@"close" otherButtonTitles:nil];
        
        [success show];
        
    }
    else
    {
        
        UIAlertView *userNotFound = [[UIAlertView alloc] initWithTitle:@"User not found!" message:nil delegate:self cancelButtonTitle:@"close" otherButtonTitles:nil];
        
        [userNotFound show];
        
    }

}

-(IBAction)resetPassword:(id)sender
{
    
    [self performSelectorInBackground:@selector(getUsersEmail:)
                           withObject:FusernameTextFeild.text];

    [FusernameTextFeild resignFirstResponder];
    
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    
    [FusernameTextFeild resignFirstResponder];
    
    [self resetPassword:nil];
    
    return NO;
    
}

-(IBAction) ReturnTextFeild:(UITapGestureRecognizer *)sender
{
    
    [FusernameTextFeild resignFirstResponder];
    
}

@end

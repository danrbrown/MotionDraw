//------------------------------------------------------------------
//
//  LoginViewController.m
//  Checklists
//
//  Created by Ricky Brown on 10/26/13.
//  Copyright (c) 2013 Hollance. All rights reserved.
//
//  Purpose: this file of class ViewController is the screen the
//  user can enter their username and password to log into the app.
//
//------------------------------------------------------------------

#import "LoginViewController.h"
//#import "CanvasViewController.h"
//#import "FirstPageViewController.h"
#import "LoadTraces.h"
#import <Parse/Parse.h>

@interface LoginViewController ()

@end

@implementation LoginViewController

@synthesize userNameTextField, passWordTextField;

//---------------------------------------------------------
//
// Name: viewDidLoad
//
// Purpose: when the screen shows up the two text fields
// are rounded on the corners, there is no auto correct,
// and it runs a method to bring the keyboard automatically
// after 0.4 seconds.
//
//---------------------------------------------------------

-(void) viewDidLoad
{
    
    
    userNameTextField.layer.cornerRadius = 7;
    passWordTextField.layer.cornerRadius = 7;
    
    self.passWordTextField.delegate = self;
    
    userNameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    userNameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    passWordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    passWordTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    [self performSelector:@selector(showKeyBoard) withObject:nil afterDelay:0.4];
    
    CGSize size = [[UIScreen mainScreen] bounds].size;
    
    if (size.height == 480)
    {
        
        loadingLogin.frame = CGRectMake(280, 132, loadingLogin.frame.size.width, loadingLogin.frame.size.height);
        
    }
    
    UIFont *textFont = [UIFont fontWithName:@"PWSimpleHandwriting" size:20];
    
    userNameTextField.font = textFont;
    passWordTextField.font = textFont;
    
}

//---------------------------------------------------------
//
// Name: showKeyBoard
//
// Purpose: Method to show the keyboard.
//
//---------------------------------------------------------

-(void) showKeyBoard
{
    
    [self.userNameTextField becomeFirstResponder];
    
}

//---------------------------------------------------------
//
// Name: closeKeyBoard
//
// Purpose: when the user touchs any free space on the
// the textfields close.
//
//---------------------------------------------------------

-(IBAction) closeKeyBoard:(UITapGestureRecognizer *)sender
{
    
    [self.userNameTextField resignFirstResponder];
    
    [self.passWordTextField resignFirstResponder];
    
}

//---------------------------------------------------------
//
// Name: textFieldShouldReturn
//
// Purpose: closes the text field on enter and will proceed
// to check in.
//
//---------------------------------------------------------

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    
    //DTRB
    
    [textField resignFirstResponder];
    
    return NO;
}

//---------------------------------------------------------
//
// Name: userLogInPressed
//
// Purpose: calls a method to log the person in.
//
//---------------------------------------------------------

-(IBAction) userLogInPressed:(id)sender
{
    
    [passWordTextField resignFirstResponder];
    
    [loadingLogin startAnimating];
    
    [self logingIn];
    
}

//-----------------------------------------------------------
//
// Name: logingIn
//
// Purpose: logs in the user, if he verified their email and
// the pasword is correct the user logs into the app, other-
// wise it will alert them whats wrong, and clear the
// password textfield. if something else not defined went
// wrong it will alert it of it. Also we refresh the user
// twice in case they verified their email during the
// login process.
//
//-----------------------------------------------------------

-(void) logingIn
{
    
    LoadTraces *loadTraces = [[LoadTraces alloc] init];
    
    NSUserDefaults *traceDefaults = [NSUserDefaults standardUserDefaults];
    
    [PFUser logInWithUsernameInBackground:self.userNameTextField.text password:self.passWordTextField.text block:^(PFUser *user, NSError *error) {
        
        if (user)
        {
            [[PFUser currentUser] setObject:@"Y" forKey:@"LoggedIn"];
            [[PFUser currentUser] saveInBackground];
            
            [traceDefaults setObject:self.userNameTextField.text forKey:@"username"];
            [traceDefaults synchronize];
            
            [loadingLogin stopAnimating];
            
            [loadTraces loadTracesArray];
            [loadTraces loadContactsArray];
            [loadTraces loadRequestsArray];
            
            [self performSegueWithIdentifier:@"LoginSuccesful" sender:self];
            
            [self textFieldShouldReturn:passWordTextField];
            
        }
        else
        {
            
            [loadingLogin stopAnimating];
            
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Try again" message:@"There was a error loging in" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            
            [errorAlertView show];
            
            passWordTextField.text = nil;
            
        }
        
    }];
    
}

@end


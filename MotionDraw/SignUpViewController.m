//-------------------------------------------------------
//
//  SignUpViewController.m
//  Checklists
//
//  Created by Ricky Brown on 10/26/13.
//  Copyright (c) 2013 Hollance. All rights reserved.
//
//  Purpose: this file of class ViewController is for
//  the user to sign up.
//
//-------------------------------------------------------

#import "SignUpViewController.h"
#import "LoadTraces.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>

@interface SignUpViewController ()

@end

@implementation SignUpViewController

@synthesize emailTextField ,userSignUpTextField, passwordSignUpTextField, varifyPasswordSignUpTextField, signUpButton;

//-----------------------------------------------------------
//
// Name: viewDidLoad
//
// Purpose: when the sceen comes up the text fields rounded,
// there is no autocorrect, and the keyboard comes up after
// 0.4 seconds.
//
//-----------------------------------------------------------

- (void)viewDidLoad
{
    
    emailTextField.layer.cornerRadius = 7;
    
    userSignUpTextField.layer.cornerRadius = 7;
    
    passwordSignUpTextField.layer.cornerRadius = 7;
    
    varifyPasswordSignUpTextField.layer.cornerRadius = 7;
    
    self.varifyPasswordSignUpTextField.delegate = self;
    
    emailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    emailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    userSignUpTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    userSignUpTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    passwordSignUpTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    passwordSignUpTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    varifyPasswordSignUpTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    varifyPasswordSignUpTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;

    [self performSelector:@selector(showKeyBoard) withObject:nil afterDelay:0.4];
    
    int smallScreen = 480;
    
    CGSize result = [[UIScreen mainScreen] bounds].size;
    if(result.height == smallScreen)
    {
        
        signUpButton.frame = CGRectMake(113, 229, signUpButton.frame.size.width, signUpButton.frame.size.height);
        
        userSignUpTextField.frame = CGRectMake(11, 24, userSignUpTextField.frame.size.width, userSignUpTextField.frame.size.height);
        
        emailTextField.frame = CGRectMake(11, 76, emailTextField.frame.size.width, emailTextField.frame.size.height);
        
        passwordSignUpTextField.frame = CGRectMake(11, 128, passwordSignUpTextField.frame.size.width, passwordSignUpTextField.frame.size.height);
        
        varifyPasswordSignUpTextField.frame = CGRectMake(11, 180, varifyPasswordSignUpTextField.frame.size.width, varifyPasswordSignUpTextField.frame.size.height);
        
    }
    
    UIFont *textFont = [UIFont fontWithName:@"PWSimpleHandwriting" size:20];
    
    userSignUpTextField.font = textFont;
    emailTextField.font = textFont;
    passwordSignUpTextField.font = textFont;
    varifyPasswordSignUpTextField.font = textFont;
    
}

//----------------------------------------------------------
//
// Name: closeKeyBoard
//
// Purpose: closes the keyboard if you touch any free space
// in the view.
//
//----------------------------------------------------------

-(IBAction) closeKeyBoard:(UITapGestureRecognizer *)sender
{
    
    [self.emailTextField resignFirstResponder];
    
    [self.passwordSignUpTextField resignFirstResponder];
    
    [self.userSignUpTextField resignFirstResponder];
    
    [self.varifyPasswordSignUpTextField resignFirstResponder];
    
}

//---------------------------------------------------------
//
// Name: showKeyBoard
//
// Purpose: Method to show keyboard.
//
//---------------------------------------------------------

-(void) showKeyBoard
{
    
    [self.userSignUpTextField becomeFirstResponder];
    
}

//---------------------------------------------------------
//
// Name: signUpUserPressed
//
// Purpose: When the user presses the sign-up button , this
// method creates the User record in Parse. Upon completion
// the user will be taken to the canvas screen.
//
//---------------------------------------------------------

-(IBAction) signUpUserPressed:(id)sender
{
    
    LoadTraces *loadTraces = [[LoadTraces alloc] init];
    NSUserDefaults *traceDefaults = [NSUserDefaults standardUserDefaults];

    
    if ([passwordSignUpTextField.text isEqual:varifyPasswordSignUpTextField.text])
    {
    
        PFUser *user = [PFUser user];
    
        user.email = self.emailTextField.text;
        user.username = self.userSignUpTextField.text;
        user.password = self.passwordSignUpTextField.text;
    
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
        
             if (!error)
             {
                 
                 (APP).firstTime = YES;
            
                 [self performSegueWithIdentifier:@"SignupSuccesful" sender:self];
            
                 [self textFieldShouldReturn:varifyPasswordSignUpTextField];
            
                 [[PFInstallation currentInstallation] setObject:[PFUser currentUser] forKey:@"user"];
            
                 [[PFInstallation currentInstallation] saveEventually];
                 
                 [[PFUser currentUser] setObject:@"Y" forKey:@"LoggedIn"];
                 [[PFUser currentUser] saveInBackground];
                 
                 [traceDefaults setObject:user.username forKey:@"username"];
                 [traceDefaults setObject:@"NO" forKey:@"sawTut"];
                 [traceDefaults synchronize];
                 
                 [self establishLeaveATraceFriendship:user.username];
                 [self establishFirstTrace:user.username];
                 
                 [loadTraces loadRequestsArray];
            
             }
             else if (error)
             {
         
                 UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Username already taken or not valid email" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            
                 [errorAlertView show];
            
                 userSignUpTextField.text = nil;
            
                 emailTextField.text = nil;
            
             }
        
         }];
        
    }
    else
    {
        
        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Password does not match verify passowrd!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        
        [errorAlertView show];
        
        passwordSignUpTextField.text = nil;
        
        varifyPasswordSignUpTextField.text = nil;
        
    }
    
}

//---------------------------------------------------------
//
// Name: establishLeaveATraceFriendship
//
// Purpose:  Whewn a new user signs up, then we automatically
// setup a friendship with the Leave A Trace user. They don't
// have to confirm the friendship and they can't delete it.
//
//---------------------------------------------------------

-(void) establishLeaveATraceFriendship:(NSString *)newUser
{

    LoadTraces *loadTraces = [[LoadTraces alloc] init];

    PFObject *userContact = [PFObject objectWithClassName:@"UserContact"];
    
    [userContact setObject:newUser forKey:@"username"];
    [userContact setObject:@"Leave A Trace" forKey:@"contact"];
    [userContact setObject:@"YES" forKey:@"userAccepted"];
    [userContact setObject:@"" forKey:@"nickname"];
    
    [userContact saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (succeeded)
        {
            
            [loadTraces loadContactsArray];
            
        }
        else
        {
            
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"There there was an error, please try loggin in again!" message:nil delegate:nil cancelButtonTitle:@"Ok"    otherButtonTitles:nil, nil];
            
            [errorAlertView show];
            
        }
        
    }];

    
}
//---------------------------------------------------------
//
// Name: establishLeaveATraceFriendship
//
// Purpose:  Whewn a new user signs up, then we automatically
// setup a friendship with the Leave A Trace user. They don't
// have to confirm the friendship and they can't delete it.
//
//---------------------------------------------------------

-(void) establishFirstTrace:(NSString *)newUser
{
    
    LoadTraces *loadTraces = [[LoadTraces alloc] init];
    
    NSDate *currentDateTime = [NSDate date];
    
    PFObject *firstTraceObject = [PFObject objectWithClassName:@"TracesObject"];
    
    UIImage *welcomeImage = [UIImage imageNamed:@"FirstTrace.png"];

    
    NSData *pictureData = UIImageJPEGRepresentation(welcomeImage, 1.0);
    
    PFFile *firstTraceFile = [PFFile fileWithName:@"Wimg" data:pictureData];
    
    [firstTraceObject setObject:firstTraceFile forKey:@"image"];
    [firstTraceObject setObject:@"Leave A Trace" forKey:@"fromUser"];
    [firstTraceObject setObject:@"YES" forKey:@"fromUserDisplay"];
    [firstTraceObject setObject:@"Leave A Trace" forKey:@"lastSentBy"];
    [firstTraceObject setObject:currentDateTime forKey:@"lastSentByDateTime"];
    [firstTraceObject setObject:newUser forKey:@"toUser"];
    [firstTraceObject setObject:@"YES" forKey:@"toUserDisplay"];
    [firstTraceObject setObject:@"D"forKey:@"status"];
    
    [(APP).tracesArray insertObject:firstTraceObject atIndex:0];
    
    [firstTraceFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (succeeded)
        {
            
            [firstTraceObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                if (succeeded)
                {
                    
                    [loadTraces loadTracesArray];
                    
                }
                else
                {
                    
                    UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Opps" message:@"There was an error!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    
                    [errorAlertView show];
                    
                }
                
            }];
            
        }
        else
        {
            
            NSString *errorString = [[error userInfo] objectForKey:@"error"];
            
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [errorAlertView show];
            
        }
        
    }
 ];
    
}

//---------------------------------------------------------
//
// Name:
//
// Purpose:
//
//---------------------------------------------------------

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    
    [textField resignFirstResponder];
    
    return NO;
}

@end

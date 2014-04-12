//
//  LoginViewController.h
//  Checklists
//
//  Created by Ricky Brown on 10/26/13.
//  Copyright (c) 2013 Hollance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController <UITextFieldDelegate> {
    
    IBOutlet UIActivityIndicatorView *loadingLogin;
    
    IBOutlet UIButton *logInButton;
    
}

//username name text field
@property (strong, nonatomic) IBOutlet UITextField *userNameTextField;

//password text field
@property (strong, nonatomic) IBOutlet UITextField *passWordTextField;

//Actions for the view
-(IBAction) userLogInPressed:(id)sender;
-(IBAction) closeKeyBoard:(UITapGestureRecognizer *)sender;

//Methods for the view
-(void) showKeyBoard;
-(void)logingIn;
-(BOOL)textFieldShouldReturn:(UITextField *)textField ;

@end

//
//  SignUpViewController.h
//  Checklists
//
//  Created by Ricky Brown on 10/26/13.
//  Copyright (c) 2013 Hollance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignUpViewController : UIViewController <UITextFieldDelegate>

//Buttons for view
@property (strong, nonatomic) IBOutlet UIButton *signUpButton;

//Text fields for view
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UITextField *userSignUpTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordSignUpTextField;
@property (strong, nonatomic) IBOutlet UITextField *varifyPasswordSignUpTextField;

//Actions for view 
-(IBAction) signUpUserPressed:(id)sender;
-(IBAction) closeKeyBoard:(UITapGestureRecognizer *)sender;

//Methods for view
-(BOOL)textFieldShouldReturn:(UITextField *)textField;
-(void)showKeyBoard;

@end

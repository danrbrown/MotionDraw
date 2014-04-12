//
//  ForgotPasswordViewController.h
//  LeaveATrace
//
//  Created by Daniel Brown on 2/16/14.
//  Copyright (c) 2014 15and50. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForgotPasswordViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate> {
    
    IBOutlet UITextField *FusernameTextFeild;
    NSString *fogottenUserName;
    
}

//Actions
-(IBAction)resetPassword:(id)sender;

@end

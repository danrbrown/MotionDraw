//
//  FirstPageViewController.h
//  LeaveATrace
//
//  Created by Ricky Brown on 11/12/13.
//  Copyright (c) 2013 15and50. All rights reserved.
//

#import <UIKit/UIKit.h>

extern BOOL LoggedIn;

@interface FirstPageViewController : UIViewController {
    
    //Outlets
    IBOutlet UIButton *logInButton;
    IBOutlet UIButton *signUpButton;
    IBOutlet UIButton *fifteenAndFifty;
    IBOutlet UIButton *infoButton;
    
    IBOutlet UIButton *trashBT;
    IBOutlet UIButton *startBT;
    IBOutlet UIButton *stopBT;
    IBOutlet UIButton *redoBT;
    IBOutlet UIButton *replayBT;
    IBOutlet UIImageView *testImage;
    
    //Variables for drawing
    CGPoint lastPoint;
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat brush;
    CGFloat opacity;
    BOOL mouseSwiped;
    BOOL isTesting;
    
}

//Propertys for drawing
@property CGFloat red;
@property CGFloat green;
@property CGFloat blue;
@property CGFloat brush;
@property (weak, nonatomic) IBOutlet UIImageView *mainImage;

//Actions
-(IBAction)fifteenAndFifty:(id)sender;

@end

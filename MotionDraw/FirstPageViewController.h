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
    CGFloat redT;
    CGFloat greenT;
    CGFloat blueT;
    CGFloat brushT;
    CGFloat opacityT;
    BOOL mouseSwipedT;
    BOOL isTesting;
    
    //PLay back variables
    NSMutableArray *captureDrawing;
    NSMutableDictionary *drawingDictionary;
    int timerInt;
    NSTimer *timer;
    
}

//Propertys for drawing
@property CGFloat redT;
@property CGFloat greenT;
@property CGFloat blueT;
@property CGFloat brushT;
@property (weak, nonatomic) IBOutlet UIImageView *mainImageT;

//Actions
-(IBAction)fifteenAndFifty:(id)sender;

@end

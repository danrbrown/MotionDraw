//
//  ThreadViewController.h
//  LeaveATrace
//
//  Created by RICKY BROWN on 11/27/13.
//  Copyright (c) 2013 15and50. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ThreadViewController : UIViewController <UIActionSheetDelegate> {
    
    //Variables for drawing
    CGPoint lastPoint;
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat brush;
    CGFloat opacity;
    BOOL mouseSwiped;
    UIColor *theColor;
    double hue;
    double trace_DRAW_SPEED;
    float subtractionAmount;
    float SCALING_FACTOR;

    
    //Undo
    UIImage *undoThreadImage;
    NSMutableArray *undoThreadImageArray;
    IBOutlet UIProgressView *progress;
    
    double speed;
    
    NSMutableArray *capArray;
    
    NSTimer *threadTimer;
    int threadTimerInt;
    
    NSString *friendScreenSize;
    NSString *userScreenSize;
    
    //Variables
    IBOutlet UIButton *undoB;
    IBOutlet UIButton *trashB;
    IBOutlet UIButton *colorsB;
    IBOutlet UIButton *saveB;
    IBOutlet UIButton *sendB;
    IBOutlet UILabel *otherUser;
    IBOutlet UIActivityIndicatorView *loadingSent;
    IBOutlet UIActivityIndicatorView *loadingTrace;
    IBOutlet UIImageView *sliderImage;
    IBOutlet UIButton *replayB;
    IBOutlet UIImageView *newProg, *newProgMin;
    
    UIView *_hudView;
    UILabel *_captionLabel;
    int viewText;
    PFObject *traceObject;
    NSString *traceObjectId;

}

//Property type UIImageView for the image that you draw on
@property (weak, nonatomic) IBOutlet UIImageView *mainThreadImage;

//Property type UIImageView for the current color you are drawing
@property (weak, nonatomic) IBOutlet UIImageView *currentColorImage;

//Varibles for colors
@property CGFloat red;
@property CGFloat green;
@property CGFloat blue;
@property IBOutlet UISlider *brushSize;
@property IBOutlet UISlider *colorValue;

//Actions for the View
-(IBAction) close:(id)sender;

//Methods for view
-(void) getThreadTrace:(NSString *)userWhoSentTrace traceObjectStatus:(NSString *)traceStatus;
-(UIImage *) convertToMask:(UIImage *)image;

@end






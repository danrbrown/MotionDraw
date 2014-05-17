//----------------------------------------------------------------
//
//  FirstPageViewController.m
//  LeaveATrace
//
//  Created by Ricky Brown on 11/12/13.
//  Copyright (c) 2013 15and50. All rights reserved.
//
//  Perpose: this file of class ViewController is the first screen
//  that the user sees if he logs out or is the first time using
//  the app. It has two options log in & sign up. 
//
//----------------------------------------------------------------

#import "FirstPageViewController.h"
#import "CanvasViewController.h"

BOOL LoggedIn;

@interface FirstPageViewController ()

@end

@implementation FirstPageViewController

@synthesize red,blue,green,brush,mainImage;

//---------------------------------------------------------
//
// Name: viewDidLoad
//
// Purpose: when the screen opens and you are logged in
// it will skip this screen and go to the drawing screen
// in the app.
//
//---------------------------------------------------------

- (void)viewDidLoad
{
    
    red = 0;
    blue = 255;
    green = 0;
    brush = 11;
    opacity = 1.0;
    
    int smallScreen = 480;
    
    isTesting = NO;
    
    CGSize result = [[UIScreen mainScreen] bounds].size;
    if(result.height == smallScreen)
    {
        
        signUpButton.frame = CGRectMake(77, 245, signUpButton.frame.size.width, signUpButton.frame.size.height);
        logInButton.frame = CGRectMake(86, 142, logInButton.frame.size.width, logInButton.frame.size.height);
        fifteenAndFifty.frame = CGRectMake(20, 449, fifteenAndFifty.frame.size.width, fifteenAndFifty.frame.size.height);
        infoButton.frame = CGRectMake(278, 444, infoButton.frame.size.width, infoButton.frame.size.height);
        mainImage.frame = CGRectMake(mainImage.frame.origin.x, mainImage.frame.origin.y, mainImage.frame.size.width, smallScreen);
        
    }
    
    testImage.backgroundColor = [UIColor whiteColor];
    testImage.frame = CGRectMake(26, 571, testImage.frame.size.width, testImage.frame.size.height);
    
    testImage.frame = CGRectMake(26, 571, testImage.frame.size.width, testImage.frame.size.height);
    startBT.frame = CGRectMake(26, 571, startBT.frame.size.width, startBT.frame.size.height);
    stopBT.frame = CGRectMake(26, 571, stopBT.frame.size.width, stopBT.frame.size.height);
    trashBT.frame = CGRectMake(26, 571, trashBT.frame.size.width, trashBT.frame.size.height);
    replayBT.frame = CGRectMake(26, 571, replayBT.frame.size.width, replayBT.frame.size.height);
    redoBT.frame = CGRectMake(26, 571, redoBT.frame.size.width, redoBT.frame.size.height);
    
#pragma mark beforeDrawing
    
    [redoBT setHidden:YES];
    [replayBT setHidden:YES];
    [trashBT setHidden:YES];
    [stopBT setHidden:YES];
    
}

//---------------------------------------------------------
//
// Name: logInUsingDefaults
//
// Purpose: Log into Parse based on user defaults
//
//---------------------------------------------------------

-(void) logInUsingDefaults:(NSString *)parseUserDef parsePasswordDef:(NSString *)parsePasswordDef
{
    
    [PFUser logInWithUsernameInBackground:parseUserDef password:parsePasswordDef block:^(PFUser *user, NSError *error) {
        
        if (user)
        {
            
            if (![[user objectForKey:@"emailVerified"] boolValue])
            {
                
                [user refresh];
                
                if (![[user objectForKey:@"emailVerified"] boolValue])
                {
                    
                    UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"You must verify your email before logging in." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    
                    [errorAlertView show];
                    
                }
                
            }
            else
            {
                
                [self performSegueWithIdentifier:@"userAlreadyLoggedIn" sender:self];
                
            }
            
        }
        else
        {
            
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Try again" message:@"There was a error loging in, please try again!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            
            [errorAlertView show];
            
        }
        
    }];
    
}

//---------------------------------------------------------
//
// Name: viewDidAppear
//
// Purpose: when the screen opens and you are logged in
// it will skip this screen and go to the drawing screen
// in the app.
//
//---------------------------------------------------------

- (void) viewDidAppear:(BOOL)animated
{
    
    
    
}

//----------------------------------------------------------------------------------
//
// Name: convertToMask
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(UIImage*) convertToMask:(UIImage *)image
{
    
    if (image != nil)
    {
        
        UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
        
        CGRect imageRect = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);
        
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        
        CGContextSetRGBFillColor(ctx, 1.0f, 1.0f, 1.0f, 0.9f);
        
        CGContextFillRect(ctx, imageRect);
        
        [image drawInRect:imageRect blendMode:kCGBlendModeDestinationIn alpha:1.0f];
        
        UIImage* outImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        return outImage;
        
    }
    else
    {
        
        return image;
        
    }
    
}

#pragma mark Drawing

//----------------------------------------------------------------------------------
//
// Name: touchesBegan
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    UITouch *touch = [touches anyObject];
    lastPoint = [touch locationInView:self.view];
    
    if (lastPoint.x > 32 && lastPoint.y < 472 && lastPoint.x < 286 && lastPoint.y > 131 && isTesting)
    {
        
        mouseSwiped = NO;
        
    }
    
}

//----------------------------------------------------------------------------------
//
// Name: touchesMoved
//
// Purpose:
//
//----------------------------------------------------------------------------------


-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self.view];
    
    if (currentPoint.x > 32 && currentPoint.y < 472 && currentPoint.x < 286 && currentPoint.y > 131 && isTesting)
    {
        
        mouseSwiped = YES;
        
        UIGraphicsBeginImageContext(self.view.frame.size);
        [mainImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush );
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, 1.0);
        CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
        
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        mainImage.image = UIGraphicsGetImageFromCurrentImageContext();
        [mainImage setAlpha:opacity];
        UIGraphicsEndImageContext();
        
        lastPoint = currentPoint;
        
    }
    
}

//----------------------------------------------------------------------------------
//
// Name: touchesEnded
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    if(!mouseSwiped && isTesting)
    {
        
        UIGraphicsBeginImageContext(self.view.frame.size);
        [self.mainImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, opacity);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        CGContextFlush(UIGraphicsGetCurrentContext());
        self.mainImage.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
    }
    
    UIGraphicsBeginImageContext(self.mainImage.frame.size);
    [self.mainImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode:kCGBlendModeNormal alpha:opacity];
    self.mainImage.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
}

//----------------------------------------------------------------------------------
//
// Name: fifteenAndFifty
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(IBAction)fifteenAndFifty:(id)sender
{
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.15and50.com"]];
    
}

//----------------------------------------------------------------------------------
//
// Name: fade
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(void) fade
{
    
    [UIView beginAnimations:@"suck" context:NULL];
    [UIView setAnimationTransition:108 forView:mainImage cache:NO];
    [UIView setAnimationDuration:1.0f];
    [UIView commitAnimations];
    
    mainImage.image = nil;
    
}

-(IBAction)testIt:(id)sender
{
    
    isTesting = YES;
    
    [UIView beginAnimations:@"makeRoom" context:nil];
    [UIView setAnimationDuration:1];
    
    signUpButton.frame = CGRectMake(155, 22, signUpButton.frame.size.width, signUpButton.frame.size.height);
    logInButton.frame = CGRectMake(15, 14, logInButton.frame.size.width, logInButton.frame.size.height);
    
    testImage.frame = CGRectMake(26, 133, testImage.frame.size.width, testImage.frame.size.height);
    trashBT.frame = CGRectMake(262, 452, trashBT.frame.size.width, trashBT.frame.size.height);
    startBT.frame = CGRectMake(111, 297, startBT.frame.size.width, startBT.frame.size.height);
    stopBT.frame = CGRectMake(24, 442, stopBT.frame.size.width, stopBT.frame.size.height);
    replayBT.frame = CGRectMake(111, 448, replayBT.frame.size.width, replayBT.frame.size.height);
    redoBT.frame = CGRectMake(26, 448, redoBT.frame.size.width, redoBT.frame.size.height);
    
    testImage.alpha = 1;
    
    [UIView commitAnimations];
    
}

#pragma mark whenDrawing

-(IBAction) start:(id)sender
{
    
    [startBT setHidden:YES];
    [stopBT setHidden:NO];
    [trashBT setHidden:NO];
    
}

-(IBAction) stop:(id)sender
{
    
    [stopBT setHidden:YES];
    [replayBT setHidden:NO];
    [trashBT setHidden:YES];
    [redoBT setHidden:NO];

}

-(IBAction) redo:(id)sender
{
    
    mainImage.image = nil;
    [startBT setHidden:NO];
    [stopBT setHidden:YES];
    [trashBT setHidden:YES];
    [redoBT setHidden:YES];
    [replayBT setHidden:YES];
    
}

-(IBAction) replay:(id)sender
{
    
}

-(IBAction) trash:(id)sender
{
    
    [self fade];
    
}

@end



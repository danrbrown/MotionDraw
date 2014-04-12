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
    
    red = (CGFloat)random()/(CGFloat)RAND_MAX;
    green = (CGFloat)random()/(CGFloat)RAND_MAX;
    blue = (CGFloat)random()/(CGFloat)RAND_MAX;
    brush = 13;
    opacity = 1.0;
    
    int smallScreen = 480;
    
    CGSize result = [[UIScreen mainScreen] bounds].size;
    if(result.height == smallScreen)
    {
        
        signUpButton.frame = CGRectMake(77, 245, signUpButton.frame.size.width, signUpButton.frame.size.height);
        
        logInButton.frame = CGRectMake(86, 142, logInButton.frame.size.width, logInButton.frame.size.height);
        
        fifteenAndFifty.frame = CGRectMake(20, 449, fifteenAndFifty.frame.size.width, fifteenAndFifty.frame.size.height);
        
        infoButton.frame = CGRectMake(278, 444, infoButton.frame.size.width, infoButton.frame.size.height);
        
        mainImage.frame = CGRectMake(mainImage.frame.origin.x, mainImage.frame.origin.y, mainImage.frame.size.width, smallScreen);
        
    }

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

//----------------------------------------------------------------------------------
//
// Name: touchesBegan
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    mouseSwiped = NO;
    
    UITouch *touch = [touches anyObject];
    
    lastPoint = [touch locationInView:self.view];
    
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
    
    mouseSwiped = YES;
    
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self.view];
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    [self.mainImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush );
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, 1.0);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
    
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.mainImage.image = UIGraphicsGetImageFromCurrentImageContext();
    [self.mainImage setAlpha:opacity];
    UIGraphicsEndImageContext();
    
    lastPoint = currentPoint;
    
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
    
    if(!mouseSwiped)
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
    [self.mainImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
    [self.mainImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode:kCGBlendModeNormal alpha:opacity];
    self.mainImage.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    red = (CGFloat)random()/(CGFloat)RAND_MAX;
    green = (CGFloat)random()/(CGFloat)RAND_MAX;
    blue = (CGFloat)random()/(CGFloat)RAND_MAX;
    
    [self performSelector:@selector(fade) withObject:nil afterDelay:4.0];
    
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

@end



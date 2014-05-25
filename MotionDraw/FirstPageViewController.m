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

@synthesize redT,blueT,greenT,brushT,mainImageT;

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
    
    redT = 0;
    blueT = 255;
    greenT = 0;
    brushT = 11;
    opacityT = 1.0;
    
    int smallScreen = 480;
    
    isTesting = NO;
    
    CGSize result = [[UIScreen mainScreen] bounds].size;
    if(result.height == smallScreen)
    {
        
        signUpButton.frame = CGRectMake(77, 245, signUpButton.frame.size.width, signUpButton.frame.size.height);
        logInButton.frame = CGRectMake(86, 142, logInButton.frame.size.width, logInButton.frame.size.height);
        fifteenAndFifty.frame = CGRectMake(20, 449, fifteenAndFifty.frame.size.width, fifteenAndFifty.frame.size.height);
        infoButton.frame = CGRectMake(278, 444, infoButton.frame.size.width, infoButton.frame.size.height);
        mainImageT.frame = CGRectMake(mainImageT.frame.origin.x, mainImageT.frame.origin.y, mainImageT.frame.size.width, smallScreen);
        
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
    
    captureDrawing = [[NSMutableArray alloc] init];
    drawingDictionary = [[NSMutableDictionary alloc] init];
    
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
    CGPoint currentPoint = [touch locationInView:self.view];
    lastPoint = [touch locationInView:self.view];
    
    if (lastPoint.x > 32 && lastPoint.y < 472 && lastPoint.x < 286 && lastPoint.y > 131 && isTesting)
    {
        
        mouseSwipedT = NO;
        [self getMyCords:currentPoint.x cord2:currentPoint.y cord3:lastPoint.x cord4:lastPoint.y brush:brushT red:redT green:greenT blue:blueT];
        
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
        
        mouseSwipedT = YES;
        
        int x = currentPoint.x;
        int y = currentPoint.y;
        int lx = lastPoint.x;
        int ly = lastPoint.y;
        
        [self getMyCords:x cord2:y cord3:lx cord4:ly brush:brushT red:redT green:greenT blue:blueT];
        
        UIGraphicsBeginImageContext(self.view.frame.size);
        [mainImageT.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brushT);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), redT, greenT, blueT, 1.0);
        CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
        
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        mainImageT.image = UIGraphicsGetImageFromCurrentImageContext();
        [mainImageT setAlpha:opacityT];
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
    
    if(!mouseSwipedT && isTesting)
    {
        
        UIGraphicsBeginImageContext(self.view.frame.size);
        [self.mainImageT.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brushT);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), redT, greenT, blueT, opacityT);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        CGContextFlush(UIGraphicsGetCurrentContext());
        self.mainImageT.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
    }
    
    UIGraphicsBeginImageContext(self.mainImageT.frame.size);
    [self.mainImageT.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode:kCGBlendModeNormal alpha:opacityT];
    self.mainImageT.image = UIGraphicsGetImageFromCurrentImageContext();
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
    [UIView setAnimationTransition:108 forView:mainImageT cache:NO];
    [UIView setAnimationDuration:1.0f];
    [UIView commitAnimations];
    
    mainImageT.image = nil;
    
}

//----------------------------------------------------------------------------------
//
// Name: fade
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(IBAction)testIt:(id)sender
{
    
    isTesting = YES;
    
    [UIView beginAnimations:@"makeRoom" context:nil];
    [UIView setAnimationDuration:1];
    
    signUpButton.frame = CGRectMake(155, 25, signUpButton.frame.size.width, signUpButton.frame.size.height);
    logInButton.frame = CGRectMake(15, 17, logInButton.frame.size.width, logInButton.frame.size.height);
    
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

//----------------------------------------------------------------------------------
//
// Name: fade
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(IBAction) start:(id)sender
{
    
    [startBT setHidden:YES];
    [stopBT setHidden:NO];
    [trashBT setHidden:NO];
    [undoImageArray removeAllObjects];
    [captureDrawing removeAllObjects];
    
}

//----------------------------------------------------------------------------------
//
// Name: fade
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(IBAction) stop:(id)sender
{
    
    [stopBT setHidden:YES];
    [replayBT setHidden:NO];
    [trashBT setHidden:YES];
    [redoBT setHidden:NO];
    timerInt = 0;
    mainImageT.image = nil;
    timer = [NSTimer scheduledTimerWithTimeInterval:0.04 target:self selector:@selector(showVideo) userInfo:nil repeats:YES];

}

//----------------------------------------------------------------------------------
//
// Name: fade
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(IBAction) redo:(id)sender
{
    
    [timer invalidate];
    mainImageT.image = nil;
    [startBT setHidden:NO];
    [stopBT setHidden:YES];
    [trashBT setHidden:YES];
    [redoBT setHidden:YES];
    [replayBT setHidden:YES];
    
}

//----------------------------------------------------------------------------------
//
// Name: fade
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(IBAction) replay:(id)sender
{
    
    [timer invalidate];
    timerInt = 0;
    mainImageT.image = nil;
    timer = [NSTimer scheduledTimerWithTimeInterval:0.04 target:self selector:@selector(showVideo) userInfo:nil repeats:YES];
    
}

//----------------------------------------------------------------------------------
//
// Name: fade
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(IBAction) trash:(id)sender
{
    
    [self fade];
    
}

-(void) getMyCords: (int)currentX cord2:(int)currentY cord3:(int)lastx cord4:(int)lasty brush:(CGFloat)bSize red:(CGFloat)redC green:(CGFloat)greenC blue:(CGFloat)blueC
{
    
    id xId = [NSNumber numberWithInt:currentX];
    id yId = [NSNumber numberWithInt:currentY];
    id lxId = [NSNumber numberWithInt:lastx];
    id lyId = [NSNumber numberWithInt:lasty];
    id bId = [NSNumber numberWithFloat:bSize];
    id redId = [NSNumber numberWithFloat:redC];
    id greenId = [NSNumber numberWithFloat:greenC];
    id blueId = [NSNumber numberWithFloat:blueC];
    
    drawingDictionary = [[NSMutableDictionary alloc] init];
    
    [drawingDictionary setObject:xId forKey:@"x"];
    [drawingDictionary setObject:yId forKey:@"y"];
    [drawingDictionary setObject:lxId forKey:@"lastx"];
    [drawingDictionary setObject:lyId forKey:@"lasty"];
    [drawingDictionary setObject:bId forKey:@"brush"];
    [drawingDictionary setObject:redId forKey:@"red"];
    [drawingDictionary setObject:greenId forKey:@"green"];
    [drawingDictionary setObject:blueId forKey:@"blue"];
    
    [captureDrawing addObject:drawingDictionary];
    
}


-(void) showVideo
{
    
    NSString *STRx = [[captureDrawing objectAtIndex:timerInt] objectForKey:@"x"];
    NSString *STRy = [[captureDrawing objectAtIndex:timerInt] objectForKey:@"y"];
    NSString *STRlastx = [[captureDrawing objectAtIndex:timerInt] objectForKey:@"lastx"];
    NSString *STRlasty = [[captureDrawing objectAtIndex:timerInt] objectForKey:@"lasty"];
    NSString *bSize = [[captureDrawing objectAtIndex:timerInt] objectForKey:@"brush"];
    
    NSString *STRred = [[captureDrawing objectAtIndex:timerInt] objectForKey:@"red"];
    NSString *STRgreen = [[captureDrawing objectAtIndex:timerInt] objectForKey:@"green"];
    NSString *STRblue = [[captureDrawing objectAtIndex:timerInt] objectForKey:@"blue"];
    
    float x_float = [STRx floatValue];
    float y_float = [STRy floatValue];
    float last_x_float = [STRlastx floatValue];
    float last_y_float = [STRlasty floatValue];
    float brush_size = [bSize floatValue];
    
    //    x_float *= 480.0/568.0;
    //    last_x_float *= 480.0/568.0;
    //
    //    y_float *= 480.0/568.0;
    //    last_y_float *= 480.0/568.0;
    //    brush_size *= 480.0/568.0;
    
    float redColor = [STRred floatValue];
    float greenColor = [STRgreen floatValue];
    float blueColor = [STRblue floatValue];
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    
    [self.mainImageT.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), last_x_float, last_y_float); // lastX, lastY
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), x_float, y_float); //x, y
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush_size);
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), redColor, greenColor, blueColor, 1.0);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
    
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.mainImageT.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    timerInt += 1;
    
    if (timerInt == captureDrawing.count)
    {
        [timer invalidate];
    }
    
}

@end



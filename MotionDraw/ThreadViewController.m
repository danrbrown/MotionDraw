//----------------------------------------------------------------------------------
//
//  ThreadViewController.m
//  LeaveATrace
//
//  Created by RICKY BROWN on 11/27/13.
//  Copyright (c) 2013 15and50. All rights reserved.
//
//  Purpose: This class file of ViewController is for drawing back to a user that sent
//  you a drawing, in a thread convo.
//
//----------------------------------------------------------------------------------

#import "ThreadViewController.h"
#import "tracesViewController.h"
#import "LoadTraces.h"
#import "AppDelegate.h"
#import <objc/runtime.h>


@interface ThreadViewController ()

@end

@implementation ThreadViewController

@synthesize mainThreadImage, currentColorImage, red, green, blue;

//----------------------------------------------------------------------------------
//
// Name: viewDidLoad
// 
// Purpose: First screen where the user will update a trace that was sent to them
// This first gets from our global object the name of the user that sent the trace.
// Then we do generate graphics including a dot that shows the current color.
//
//----------------------------------------------------------------------------------

-(void) viewDidLoad
{
    
#define SPEED 0.0009
#define DRAW_SPEED 0.008
    
    undoThreadImageArray = [[NSMutableArray alloc] init];
    
    red = 0;
    green = 0;
    blue = 255;
    brush = 11.0;
    opacity = 1.0;
    
    self.colorValue.value = 0.640678;
    self.brushSize.value = brush;
    
    hue = 0.640678;
    
    theColor = [UIColor colorWithHue:hue saturation:1.0 brightness:1.0 alpha:1.0];
    
    currentColorImage.backgroundColor = theColor;
    currentColorImage.layer.cornerRadius = 0.0;
    currentColorImage.layer.borderColor = [UIColor blackColor].CGColor;
    currentColorImage.layer.borderWidth = 3.0;

    CGAffineTransform trans = CGAffineTransformMakeRotation(M_PI * 1.5);
    self.brushSize.transform = trans;
    self.colorValue.transform = trans;
    sliderImage.transform = trans;
    
    int smallScreen = 480;
    
    CGSize result = [[UIScreen mainScreen] bounds].size;
    if(result.height == smallScreen)
    {
        
        sendB.frame = CGRectMake(250, 434, 64, 40);
        undoB.frame = CGRectMake(102, 430, 53, 47);
        trashB.frame = CGRectMake(61, 432, 39, 45);
        saveB.frame = CGRectMake(7, 433, 49, 43);
        
    }
    
    int bigScreen = 568;
    
    if(result.height == bigScreen)
    {
        
        sendB.frame = CGRectMake(sendB.frame.origin.x, sendB.frame.origin.y, 64, 40);
        trashB.frame = CGRectMake(trashB.frame.origin.x, trashB.frame.origin.y, 39, 45);
        undoB.frame = CGRectMake(undoB.frame.origin.x, undoB.frame.origin.y, undoB.frame.size.width, undoB.frame.size.height);
        saveB.frame = CGRectMake(saveB.frame.origin.x, saveB.frame.origin.y, 49, 43);
        
    }
    
    UIImage *MaxImage = [UIImage imageNamed:@"BrushSizeSliderMax.png"];
    UIImage *MinImage = [UIImage imageNamed:@"BrushSizeSliderMin.png"];
    UIImage *ThumbImage = [UIImage imageNamed:@"BrushSizeSliderThumb.png"];
    
    [_brushSize setMaximumTrackImage:MaxImage forState:UIControlStateNormal];
    [_brushSize setMinimumTrackImage:MinImage forState:UIControlStateNormal];
    [_brushSize setThumbImage:ThumbImage forState:UIControlStateNormal];
    
    UIImage *colorThumbImage = [UIImage imageNamed:@"Nothing.png"];
    [_colorValue setThumbImage:colorThumbImage forState:UIControlStateNormal];
    
}

//----------------------------------------------------------------------------------
//
// Name: 
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(BOOL) prefersStatusBarHidden
{

    return YES;
    
}

//----------------------------------------------------------------------------------
//
// Name:
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(void) viewDidAppear:(BOOL)animated
{
    
    traceObject = [(APP).tracesArray objectAtIndex:traceObjectIdx];
    
    traceObjectId = [traceObject objectId];
    
    NSString *userWhoSentTrace = [traceObject objectForKey:@"toUser"];
    NSString *tmpStatus = [traceObject objectForKey:@"status"];
    
    otherUser.text = userWhoSentTrace;
    
    [self getThreadTrace:userWhoSentTrace traceObjectStatus:tmpStatus];

}

//----------------------------------------------------------------------------------
//
// Name:
//
// Purpose:
//
//----------------------------------------------------------------------------------

//this should be done better - shouldn't loop since we're bringing back one image Dan DRB

-(void) getThreadTrace:(NSString *)userWhoSentTrace traceObjectStatus:(NSString *)traceStatus
{
    
    viewText = 1;
    
    NSUserDefaults *traceDefaults = [NSUserDefaults standardUserDefaults];
    [traceDefaults setObject:@"YES" forKey:@"sawTut"];
    [traceDefaults synchronize];
    
    [self loadingTrace];
    
    PFQuery *traceQuery = [PFQuery queryWithClassName:@"TracesObject"];

    [traceQuery whereKey:@"objectId" equalTo:traceObjectId];
    
    [traceQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error)
        {
            
            for (PFObject *myImages in objects)
            {
            
                capArray = [[NSMutableArray alloc] init];
                
                capArray = [myImages objectForKey:@"imgVid"];
                
                size_t total;
                total = 0;
                id obj;
                for (obj in capArray)
                {
                    total += class_getInstanceSize([obj class]);
                }
                
                NSLog(@"Array size : %ld",total);
                NSLog(@"array count %lu", (unsigned long)capArray.count);


                
                if (!error)
                {
                    
                    
                    [loadingTrace stopAnimating];
                    [_hudView removeFromSuperview];
                    
                    NSString *tmpCurrentUser = [[PFUser currentUser]username];
                    NSString *tmpLastSentBy = [myImages objectForKey:@"lastSentBy"];
                    
                    if (![tmpCurrentUser isEqualToString:tmpLastSentBy])
                    {
                        
                        if (((APP).unopenedTraceCount > 0) && ([traceStatus isEqualToString:@"D"]))
                        {
                            
                            (APP).unopenedTraceCount--;
                                                            
                        }
                        
                        [myImages setObject:@"O"forKey:@"status"];
                        [traceObject setObject:@"O"forKey:@"status"];
                        [myImages saveInBackground];
                        
                    }
                }
                
                [self callShowVideo];
              
            }
            
        }
        else
        {
            
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
        
    }];
    
}

//----------------------------------------------------------------------------------
//
// Name:
//
// Purpose: this method doesent give us a warning when the user draws.
//
//----------------------------------------------------------------------------------

-(IBAction)replay:(id)sender
{
    
    [threadTimer invalidate];
    
    progress.progress = 1.0;

    threadTimerInt = 0;
    
    mainThreadImage.image = nil;
    
    threadTimer = [NSTimer scheduledTimerWithTimeInterval:0.008 target:self selector:@selector(showVideo) userInfo:nil repeats:YES];
    
}

//----------------------------------------------------------------------------------
//
// Name:
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(void) callShowVideo
{
    
    threadTimerInt = 0;
    
    mainThreadImage.image = nil;
    
    threadTimer = [NSTimer scheduledTimerWithTimeInterval:0.008 target:self selector:@selector(showVideo) userInfo:nil repeats:YES];
    
}

//----------------------------------------------------------------------------------
//
// Name:
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(void) showVideo
{
    
    progress.progress = progress.progress - (1.0 / capArray.count);
    
    progress.tintColor = [UIColor blackColor];
    
    NSString *STRx = [[capArray objectAtIndex:threadTimerInt] objectForKey:@"x"];
    NSString *STRy = [[capArray objectAtIndex:threadTimerInt] objectForKey:@"y"];
    NSString *STRlastx = [[capArray objectAtIndex:threadTimerInt] objectForKey:@"lastx"];
    NSString *STRlasty = [[capArray objectAtIndex:threadTimerInt] objectForKey:@"lasty"];
    NSString *bSize = [[capArray objectAtIndex:threadTimerInt] objectForKey:@"brush"];
    
    NSString *STRred = [[capArray objectAtIndex:threadTimerInt] objectForKey:@"red"];
    NSString *STRgreen = [[capArray objectAtIndex:threadTimerInt] objectForKey:@"green"];
    NSString *STRblue = [[capArray objectAtIndex:threadTimerInt] objectForKey:@"blue"];
    
    int x_int = [STRx intValue];
    int y_int = [STRy intValue];
    int last_x_int = [STRlastx intValue];
    int last_y_int = [STRlasty intValue];
    float brush_size = [bSize floatValue];
    
    float redColor = [STRred floatValue];
    float greenColor = [STRgreen floatValue];
    float blueColor = [STRblue floatValue];
    
    if ((x_int == 0) && (y_int == 0))
    {
        
        [UIView beginAnimations:@"suck" context:NULL];
        [UIView setAnimationTransition:108 forView:mainThreadImage cache:NO];
        [UIView setAnimationDuration:0.3f];
        [UIView commitAnimations];
        
        self.mainThreadImage.image = nil;

    }
    else
    {

        UIGraphicsBeginImageContext(self.view.frame.size);
        [self.mainThreadImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), last_x_int, last_y_int); // lastX, lastY
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), x_int, y_int); //x, y
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush_size);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), redColor, greenColor, blueColor, 1.0);
        CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
        
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        self.mainThreadImage.image = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
    }
    
    // NSLog(@"threadTimerInt %d array count %lu",threadTimerInt, (unsigned long)capArray.count);
    
    threadTimerInt += 1;
    
    if (threadTimerInt == capArray.count)
    {
        [threadTimer invalidate];
         progress.progress = 0;
    }
    

}

//----------------------------------------------------------------------------------
//
// Name: convertToMask
//
// Purpose: this method doesent give us a warning when the user draws.
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
        
        UIImage *outImage = UIGraphicsGetImageFromCurrentImageContext();
        
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
// Name: close
//
// Purpose: closes the tread view.
//
//----------------------------------------------------------------------------------

-(IBAction) close:(id)sender
{
    
    [self dismissViewControllerAnimated:NO completion:nil];
    
}

//----------------------------------------------------------------------------------
//
// Name: getThreadTrace
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(void) loadingTrace
{
    
    _hudView = [[UIView alloc] initWithFrame:CGRectMake(45, 180, 230, 50)];
    _hudView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    _hudView.clipsToBounds = YES;
    _hudView.layer.cornerRadius = 10.0;
    
    loadingTrace = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    loadingTrace.frame = CGRectMake(25, 16, loadingTrace.bounds.size.width, loadingTrace.bounds.size.height);
    [_hudView addSubview:loadingTrace];
    [loadingTrace startAnimating];
    
    _captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 15, 130, 22)];
    _captionLabel.backgroundColor = [UIColor clearColor];
    _captionLabel.textColor = [UIColor whiteColor];
    _captionLabel.adjustsFontSizeToFitWidth = YES;
    _captionLabel.font = [UIFont fontWithName:@"verdana" size:15.0];
    
    if (viewText == 2)
    {
        
        _captionLabel.text = @"Sending trace...";
        
    }
    else if (viewText == 1)
    {
        
        _captionLabel.text = @"Loading trace...";
        
    }
    else if (viewText == 3)
    {
        
        [loadingTrace stopAnimating];
        
        _captionLabel.frame = CGRectMake(53, 15, 130, 22);
        _captionLabel.text = @"Trace was sent!";
        
        [sendB setEnabled:YES];
        
        [sendB setAlpha:1.0];
        
        [self fade];
        
    }
    else if (viewText == 4)
    {
        
        _captionLabel.text = @"Saving trace...";
        
    }
    else if (viewText == 5)
    {
        
        [loadingTrace stopAnimating];
        
        _captionLabel.frame = CGRectMake(53, 15, 130, 22);
        _captionLabel.text = @"Trace was saved!";
        
        [sendB setEnabled:YES];
        
        [sendB setAlpha:1.0];
        
        [self fade];
        
    }

    [_captionLabel setTextAlignment:NSTextAlignmentCenter];
    [_hudView addSubview:_captionLabel];
    
    [self.view addSubview:_hudView];
    
}

//----------------------------------------------------------------------------------
//
// Name: getThreadTrace
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(void) fade
{
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:5];
    [_hudView setAlpha:0];
    [UIView commitAnimations];
    [_hudView removeFromSuperview];
    
}

@end










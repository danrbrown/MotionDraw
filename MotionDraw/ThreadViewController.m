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

-(BOOL) prefersStatusBarHidden
{

    return YES;
    
}

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
// Name: getThreadTrace
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
            
                PFFile *imageFile = [myImages objectForKey:@"image"];
                imageFile = [myImages objectForKey:@"image"];
                
                [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    
                    if (!error)
                    {

                        UIImage *image = [UIImage imageWithData:data];
                        mainThreadImage.image = image;
                        
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
                    
                }];
                
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

-(void) fade
{
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:5];
    [_hudView setAlpha:0];
    [UIView commitAnimations];
    [_hudView removeFromSuperview];
    
}

@end










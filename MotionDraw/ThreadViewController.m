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
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "LoadTraces.h"
#import "AppDelegate.h"
#import <objc/runtime.h>

BOOL responding;
NSString *respondingTraceUsername;

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
    
    trace_DRAW_SPEED = 0.0;
    
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
        replayB.frame = CGRectMake(4, 438, 92, 38);
        
        userScreenSize = @"4";
        
    }
    else
    {
        
        userScreenSize = @"5";
        
    }
    
    UIImage *MaxImage = [UIImage imageNamed:@"BrushSizeSliderMax.png"];
    UIImage *MinImage = [UIImage imageNamed:@"BrushSizeSliderMin.png"];
    UIImage *ThumbImage = [UIImage imageNamed:@"BrushSizeSliderThumb.png"];
    
    [_brushSize setMaximumTrackImage:MaxImage forState:UIControlStateNormal];
    [_brushSize setMinimumTrackImage:MinImage forState:UIControlStateNormal];
    [_brushSize setThumbImage:ThumbImage forState:UIControlStateNormal];
    
    UIImage *colorThumbImage = [UIImage imageNamed:@"Nothing.png"];
    [_colorValue setThumbImage:colorThumbImage forState:UIControlStateNormal];
    
    responding = NO;
    respondingTraceUsername = @"";
    
    textMessage.font = [UIFont fontWithName:@"ComicRelief" size:14];
    textMessage.text = @"testing";
    
    
        
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
    respondingTraceUsername = [traceObject objectForKey:@"toUser"];
    
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
    
//    NSUserDefaults *traceDefaults = [NSUserDefaults standardUserDefaults];
//    [traceDefaults setObject:@"YES" forKey:@"sawTut"];
//    [traceDefaults synchronize];
    
    [self loadingTrace];
    
    PFQuery *traceQuery = [PFQuery queryWithClassName:@"TracesObject"];

    [traceQuery whereKey:@"objectId" equalTo:traceObjectId];
    
    [traceQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error)
        {
            
            for (PFObject *myImages in objects)
            {
                
                PFFile *imageFile = [myImages objectForKey:@"imgVidFile"];

                [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    
                    if (!error)
                    {
                        //NSData *imageVidData = [imageFile getData];

                        NSData *imageVidData = data;
                        capArray = [NSKeyedUnarchiver unarchiveObjectWithData:imageVidData];

                        NSNumber *traceDrawSpeed = [myImages objectForKey:@"traceDrawSpeed"];
                        NSNumber *xCordTmp = [myImages objectForKey:@"xCord"];
                        NSNumber *yCordTmp = [myImages objectForKey:@"yCord"];
                        textMessageText = [myImages objectForKey:@"textMessage"];
                        
                        xCord = [xCordTmp floatValue];
                        yCord = [yCordTmp floatValue];
                        trace_DRAW_SPEED = [traceDrawSpeed floatValue];
                       
                        friendScreenSize = [myImages objectForKey:@"screenSize"];
                        
                        [self callShowVideo];
                        
                        [loadingTrace stopAnimating];
                        [_hudView removeFromSuperview];
                        
                        NSString *tmpCurrentUser = [[PFUser currentUser]username];
                        NSString *tmpLastSentBy = [myImages objectForKey:@"lastSentBy"];
                        
                        if (![tmpCurrentUser isEqualToString:tmpLastSentBy])
                        {
                            
                            if (((APP).unopenedTraceCount > 0) && ([traceStatus isEqualToString:@"D"]))
                            {
                                
                                (APP).unopenedTraceCount--;
                                
                                [[PFUser currentUser] incrementKey:@"tracesViewed"];
                                [[PFUser currentUser] saveInBackground];
 
                                
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
// Name:
//
// Purpose: this method doesent give us a warning when the user draws.
//
//----------------------------------------------------------------------------------

-(IBAction)replay:(id)sender
{
    
    [threadTimer invalidate];
    
    progress.progress = 1.0;
    newProg.frame = CGRectMake(newProg.frame.origin.x, newProg.frame.origin.y, 264, newProg.frame.size.height);

    threadTimerInt = 0;
    
    mainThreadImage.image = nil;
    
    threadTimer = [NSTimer scheduledTimerWithTimeInterval:trace_DRAW_SPEED target:self selector:@selector(showVideo) userInfo:nil repeats:YES];
    
}

//----------------------------------------------------------------------------------
//
// Name:
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(IBAction)respond:(id)sender
{
    
    responding = YES;
    [self dismissViewControllerAnimated:NO completion:nil];
    
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
    subtractionAmount = 264.0 / (float) capArray.count;
    
    if ([friendScreenSize isEqual:userScreenSize])
    {
        SCALING_FACTOR = 1.0;
    }
    
    if ([friendScreenSize isEqual:@"4"] && [userScreenSize isEqual:@"5"])
    {

        SCALING_FACTOR = 568.0/480.0;
        
    }
    
    if ([friendScreenSize isEqual:@"5"] && [userScreenSize isEqual:@"4"])
    {
        
        SCALING_FACTOR = 480.0/568.0;
        
    }

    mainThreadImage.image = nil;
    
    threadTimer = [NSTimer scheduledTimerWithTimeInterval:trace_DRAW_SPEED target:self selector:@selector(showVideo) userInfo:nil repeats:YES];
    
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
    
    [textMessage setAlpha:0];
    [textBox setAlpha:0];
    [speachB setEnabled:NO];
    
    newProg.frame = CGRectMake(newProg.frame.origin.x, newProg.frame.origin.y, newProg.frame.size.width - subtractionAmount, newProg.frame.size.height);
    
    progress.tintColor = [UIColor blackColor];
    
    NSString *STRx = [[capArray objectAtIndex:threadTimerInt] objectForKey:@"x"];
    NSString *STRy = [[capArray objectAtIndex:threadTimerInt] objectForKey:@"y"];
    NSString *STRlastx = [[capArray objectAtIndex:threadTimerInt] objectForKey:@"lastx"];
    NSString *STRlasty = [[capArray objectAtIndex:threadTimerInt] objectForKey:@"lasty"];
    NSString *bSize = [[capArray objectAtIndex:threadTimerInt] objectForKey:@"brush"];
    
    NSString *STRred = [[capArray objectAtIndex:threadTimerInt] objectForKey:@"red"];
    NSString *STRgreen = [[capArray objectAtIndex:threadTimerInt] objectForKey:@"green"];
    NSString *STRblue = [[capArray objectAtIndex:threadTimerInt] objectForKey:@"blue"];
    
    float x_float = [STRx floatValue];
    float y_float = [STRy floatValue];
    float last_x_float = [STRlastx floatValue];
    float last_y_float = [STRlasty floatValue];
    float brush_size = [bSize floatValue];
    
    // Possible code to scale to different screen sizes. Not part of release 1.0
//    x_float *= SCALING_FACTOR;
//    last_x_float *= SCALING_FACTOR;
//    
//    y_float *= SCALING_FACTOR;
//    last_y_float *= SCALING_FACTOR;
//    brush_size *= SCALING_FACTOR;

    
    float redColor = [STRred floatValue];
    float greenColor = [STRgreen floatValue];
    float blueColor = [STRblue floatValue];

    UIGraphicsBeginImageContext(self.view.frame.size);
    [self.mainThreadImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), last_x_float, last_y_float); // lastX, lastY
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), x_float, y_float); //x, y
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush_size);
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), redColor, greenColor, blueColor, 1.0);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
    
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.mainThreadImage.image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
        
    threadTimerInt += 1;
    
    if (threadTimerInt == capArray.count)
    {
        [threadTimer invalidate];
         progress.progress = 0;
        
        if (textMessageText.length > 0)
        {
            
            [speachB setEnabled:YES];
            
            textBox.frame = CGRectMake(xCord, yCord, textBox.frame.size.width, textBox.frame.size.height);
            textMessage.frame = CGRectMake(xCord, yCord, textMessage.frame.size.width, textMessage.frame.size.height);
            textMessage.text = textMessageText;
            
            [UIView beginAnimations:@"fadeInMessage" context:nil];
            [UIView setAnimationDuration:0.5];
            
            [textBox setAlpha:0.92];
            [textMessage setAlpha:0.92];
            
            [UIView commitAnimations];
            
        }

    }
    

}
//----------------------------------------------------------------------------------
//
// Name: speakText
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(IBAction) speakText:(id)sender
{
    
    AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc]init];
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:textMessageText];
    [utterance setRate:0.3f];
    [synthesizer speakUtterance:utterance];
    
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










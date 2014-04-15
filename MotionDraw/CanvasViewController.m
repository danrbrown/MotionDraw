//----------------------------------------------------------------------------------
//
//  CanvasViewController.m
//  Checklists
//
//  Created by Ricky Brown on 10/19/13.
//  Copyright (c) 2013 Hollance. All rights reserved.
//
//  Purpose:
//
//----------------------------------------------------------------------------------

#import "CanvasViewController.h"
#import "SelectAContactViewController.h"
#import "AppDelegate.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <Twitter/Twitter.h>
#import <Parse/Parse.h>
#import <objc/runtime.h>

//Global variables
NSString *badgeString;
NSString *tracesBadgeString;
long iconBadge;
BOOL sentImage;
NSMutableArray *undoImageArray;
UIImageView *mainImage;

@interface CanvasViewController ()

@end

@implementation CanvasViewController

@synthesize mainImage,red,green,blue,brush,currentColorImage,colorValue,brushSize,speed;

//----------------------------------------------------------------------------------
//
// Name: viewDidLoad
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(void) viewDidLoad
{
    
#define SPEED 0.0009
#define DRAW_SPEED 0.0100
    
    if (!(APP).IS_ADMIN)
    {
        
        [secretAdminB setHidden:NO];
        (APP).IS_ADMIN = YES;
        
    }
    else
    {
        
        [secretAdminB setHidden:YES];
        
    }
    
    undoImageArray = [[NSMutableArray alloc] init];
    undoRecordImageArray = [[NSMutableArray alloc] init];
    onlyUndoImageArray = [[NSMutableArray alloc] init];
    drawingDictionary = [[NSMutableDictionary alloc] init];

    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    red = 0;
    green = 0;
    blue = 255;
    brush = 11.0;
    opacity = 1.0;
    
    colorValue.value = 0.640678;
    brushSize.value = brush;
    NSLog(@"%f", speed.value);
    
    hue = 0.640678;
    
    theColor = [UIColor colorWithHue:hue saturation:1.0 brightness:1.0 alpha:1.0];
    
    currentColorImage.backgroundColor = theColor;
    currentColorImage.layer.cornerRadius = 0.0;
    currentColorImage.layer.borderColor = [UIColor blackColor].CGColor;
    currentColorImage.layer.borderWidth = 2.5;
    
    progress.tintColor = [UIColor blackColor];
    
    imagesArray = [[NSMutableArray alloc] init];
    
    CGAffineTransform trans = CGAffineTransformMakeRotation(M_PI * 1.5);
    self.brushSize.transform = trans;
    self.colorValue.transform = trans;
    sliderImage.transform = trans;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateBadges:)
                                                 name:@"PushTraceNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateBadges:)
                                                 name:@"SendTraceNotification"
                                               object:nil];

    int smallScreen = 480;
    
    CGSize result = [[UIScreen mainScreen] bounds].size;
    if(result.height == smallScreen)
    {
        
        sendB.frame = CGRectMake(250, 383, 64, 40);
        undoB.frame = CGRectMake(103, 383, 53, 47);
        trashB.frame = CGRectMake(61, 383, 39, 45);
        saveB.frame = CGRectMake(6, 385, 49, 43);
        mainImage.frame = CGRectMake(0, 0, 320, 431);
        
    }
    
    if (!(APP).firstTime)
    {
    
        [tutorialImage setHidden:YES];
        
    }
    
    UIImage *MaxImage = [UIImage imageNamed:@"BrushSizeSliderMax.png"];
    UIImage *MinImage = [UIImage imageNamed:@"BrushSizeSliderMin.png"];
    UIImage *ThumbImage = [UIImage imageNamed:@"BrushSizeSliderThumb.png"];
    
    [brushSize setMaximumTrackImage:MaxImage forState:UIControlStateNormal];
    [brushSize setMinimumTrackImage:MinImage forState:UIControlStateNormal];
    [brushSize setThumbImage:ThumbImage forState:UIControlStateNormal];

    UIImage *colorThumbImage = [UIImage imageNamed:@"Nothing.png"];
    [colorValue setThumbImage:colorThumbImage forState:UIControlStateNormal];
    
    [currentColorImage setHidden:YES];
    [sliderImage setHidden:YES];
    [colorValue setHidden:YES];
    [brushSize setHidden:YES];
    [sendB setHidden:YES];
    [restartB setHidden:YES];
    [stopB setHidden:YES];
    [speed setHidden:YES];
    [undoB setHidden:YES];
    [trashB setHidden:YES];
    [replayB setHidden:YES];
    [progress setHidden:YES];
    
    canDraw = NO;
    
    captureDrawing = [[NSMutableArray alloc] init];

    [self getMyCords:1 cord2:1 cord3:1 cord4:1 brush:1 red:1 green:1 blue:1];
    [self getMyCords:1 cord2:1 cord3:1 cord4:1 brush:1 red:1 green:1 blue:1];
    [self getMyCords:1 cord2:1 cord3:1 cord4:1 brush:1 red:1 green:1 blue:1];

    size_t total;
    id obj;
    for (obj in captureDrawing)
    {
        total += class_getInstanceSize([obj class]);
    }
    
    NSLog(@"View did load 1 array size : %ld count of rows %lu",total,(unsigned long)captureDrawing.count);


}

//----------------------------------------------------------------------------------
//
// Name: adminSecretButton
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(IBAction)adminSecretButton:(id)sender
{
    
    NSLog(@"DONT POKE THE DRAGIN");
    
    [self createIntroTrace];
    
}

//----------------------------------------------------------------------------------
//
// Name: viewWillAppear
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
// Name: viewWillAppear
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(void) viewDidAppear:(BOOL)animated
{
    
    [self displayBadgeCounts];
    
    [self becomeFirstResponder];
    
}

//----------------------------------------------------------------------------------
//
// Name: viewWillAppear
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(void) viewWillAppear:(BOOL)animated
{
    
    if (sentImage)
    {
        
        mainImage.image = nil;
        
        [self.tabBarController setSelectedIndex:0];
        
        sentImage = NO;
        
    }
    
}

//----------------------------------------------------------------------------------
//
// Name: viewDidDisappear
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(void) viewDidDisappear:(BOOL)animated
{
    
    [self resignFirstResponder];
    
    [super viewDidDisappear:animated];
    
}

//----------------------------------------------------------------------------------
//
// Name: viewDidDisappear
//
// Purpose:
//
//----------------------------------------------------------------------------------

- (void) updateBadges:(NSNotification *) notification
{
    
    if ([[notification name] isEqualToString:@"PushTraceNotification"])
    {
        
        [self displayBadgeCounts];
        
    }
    
    if ([[notification name] isEqualToString:@"SendTraceNotification"])
    {
        
        [self displayBadgeCounts];
        
    }

}

//----------------------------------------------------------------------------------
//
// Name: canBecomeFirstResponder
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(BOOL) canBecomeFirstResponder
{
    
    return YES;
    
}

//----------------------------------------------------------------------------------
//
// Name: displayBadgeCounts
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(void) displayBadgeCounts
{
    
    NSString *countTracesBadge = [NSString stringWithFormat:@"%lu",(long)(APP).unopenedTraceCount];
    NSString *countFriendRequestsBadge = [NSString stringWithFormat:@"%lu",(long)(APP).friendRequestsCount];
    
    // Count of unopened Traces
    
    if ((APP).unopenedTraceCount == 0)
    {
                
        [[[[[self tabBarController] tabBar] items] objectAtIndex:0] setBadgeValue:nil];
                
    }
    else
    {
        
        [[[[[self tabBarController] tabBar] items] objectAtIndex:0] setBadgeValue:countTracesBadge];
        
    }

    // Count of Friend Requests
    
    if ((APP).friendRequestsCount == 0)
    {
        
        [[[[[self tabBarController] tabBar] items] objectAtIndex:3] setBadgeValue:nil];
        
    }
    else
    {
        
        [[[[[self tabBarController] tabBar] items] objectAtIndex:3] setBadgeValue:countFriendRequestsBadge];
        
    }

}

//----------------------------------------------------------------------------------
//
// Name: countTraces
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(void) countTraces
{
    
    PFQuery *toUserQuery = [PFQuery queryWithClassName:@"TracesObject"];
    
    NSString *tmpCurrentUser = [[PFUser currentUser]username];
    
    [toUserQuery whereKey:@"toUser" equalTo:tmpCurrentUser];
    [toUserQuery whereKey:@"lastSentBy" notEqualTo:tmpCurrentUser];
    
    PFQuery *fromUserQuery = [PFQuery queryWithClassName:@"TracesObject"];
    
    [fromUserQuery whereKey:@"fromUser" equalTo:tmpCurrentUser];
    [fromUserQuery whereKey:@"lastSentBy" notEqualTo:tmpCurrentUser];
    
    PFQuery *countQuery = [PFQuery orQueryWithSubqueries:@[toUserQuery,fromUserQuery]];
    
    [countQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error)
        {
            
            if (objects.count == 0)
            {
                
                [[[[[self tabBarController] tabBar] items] objectAtIndex:1] setBadgeValue:nil];
                
            }
            else
            {
                
                tracesBadgeString = [NSString stringWithFormat:@"%lu",(unsigned long)objects.count];
                
                [[[[[self tabBarController] tabBar] items] objectAtIndex:0] setBadgeValue:tracesBadgeString];
                
            }
            
        }
        
    }];
    
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
// Name: clear
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(IBAction) clear:(id)sender
{
        
    [UIView beginAnimations:@"suck" context:NULL];
    [UIView setAnimationTransition:108 forView:mainImage cache:NO];
    [UIView setAnimationDuration:0.3f];
    [UIView commitAnimations];
    
    self.mainImage.image = nil;
    
    [self getMyCords:0 cord2:0 cord3:0 cord4:0 brush:0 red:0 green:0 blue:0];
    
}

//----------------------------------------------------------------------------------
//
// Name: clear
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(IBAction)replay:(id)sender
{
    
    [timer invalidate];
    
    progress.progress = 0;
    
    timerInt = 0;
    
    mainImage.image = nil;
    
    timer = [NSTimer scheduledTimerWithTimeInterval:DRAW_SPEED target:self selector:@selector(showVideo) userInfo:nil repeats:YES];
    
}

//----------------------------------------------------------------------------------
//
// Name: undo
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(IBAction) undo:(id)sender
{
    
    if (undoImageArray.count > 0)
    {
        
        undoImage = [undoImageArray lastObject];
        
        [undoImageArray removeLastObject];
        
        mainImage.image = undoImage;
        
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
    
    if (canDraw)
    {
     
        if ((APP).firstTime)
        {
            
            [tutorialImage setHidden:YES];
            (APP).firstTime = NO;
            
        }
        
        mouseSwiped = NO;
        
        UITouch *touch = [touches anyObject];
        
        CGPoint currentPoint = [touch locationInView:self.view];
        lastPoint = [touch locationInView:self.view];
        
        UIGraphicsBeginImageContextWithOptions(mainImage.bounds.size, NO, 0.0);
        [mainImage.image drawInRect:CGRectMake(0, 0, mainImage.frame.size.width, mainImage.frame.size.height)];
        undoImage = UIGraphicsGetImageFromCurrentImageContext();
        [undoImageArray addObject:undoImage];
     
        [self getMyCords:currentPoint.x cord2:currentPoint.y cord3:lastPoint.x cord4:lastPoint.y brush:brush red:red green:green blue:blue];
        
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
    
    if (canDraw)
    {
        
        mouseSwiped = YES;
        
        UITouch *touch = [touches anyObject];
        CGPoint currentPoint = [touch locationInView:self.view];
        
        int x = currentPoint.x;
        int y = currentPoint.y;
        int lx = lastPoint.x;
        int ly = lastPoint.y;
        
        UIGraphicsBeginImageContext(self.view.frame.size);
        [self.mainImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, 1.0);
        CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
    
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        self.mainImage.image = UIGraphicsGetImageFromCurrentImageContext();
        
        [self getMyCords:x cord2:y cord3:lx cord4:ly brush:brush red:red green:green blue:blue];
        
        [self.mainImage setAlpha:opacity];
        
        UIGraphicsEndImageContext();
        
        lastPoint = currentPoint;
        
        [self hide];
        
        progress.progress = progress.progress + SPEED;
        
        if (progress.progress == 1)
        {
            
            progress.progress = 0;
            
            canDraw = NO;
            
            UIAlertView *stopDrawing = [[UIAlertView alloc] initWithTitle:@"Nice drawing, but..." message:@"You must stop!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
         
            [stopDrawing show];
            
            [progress setHidden:NO];
            
            [self stop:nil];
            
        }
        
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
    
    [self show];
    
    size_t total;
    id obj;
    for (obj in captureDrawing)
    {
        total += class_getInstanceSize([obj class]);
    }
    
    NSLog(@"Touches Ended Array size : %ld",total);
    NSLog(@"captureDrawing.count %lu", (unsigned long)captureDrawing.count);
    
    
}

//----------------------------------------------------------------------------------
//
// Name: prepareForSegue
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([[segue identifier] isEqualToString:@"selectAContact"])
    {
        
        UINavigationController *navigationController = segue.destinationViewController;
        SelectAContactViewController *controller = (SelectAContactViewController *)navigationController.topViewController;
        controller.captureArray = captureDrawing;
        
    }
    
}

//----------------------------------------------------------------------------------
//
// Name: sliderChanged
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(IBAction) sliderChanged:(id)sender
{
    
    UISlider *changedSlider = (UISlider*)sender;
    
    if(changedSlider == self.brushSize)
    {
        
        brush = self.brushSize.value;
        
    }
    
    if(changedSlider == self.colorValue)
    {
        
        hue = changedSlider.value;
        
        theColor = [UIColor colorWithHue:hue saturation:1.0 brightness:1.0 alpha:1.0];
        
        CGColorRef colorRef = [theColor CGColor];
            
        const CGFloat *_components = CGColorGetComponents(colorRef);
        
        red     = _components[0];
        green   = _components[1];
        blue    = _components[2];
        
        currentColorImage.backgroundColor = theColor;
        
        if (changedSlider.value <= -0.1)
        {
            
            red = 255;
            blue = 255;
            green = 255;
            
            currentColorImage.backgroundColor = [UIColor whiteColor];
            
        }
        
        if (changedSlider.value > 0.85)
        {
            
            red = 0;
            blue = 0;
            green = 0;
            
            currentColorImage.backgroundColor = [UIColor blackColor];
            
        }
        
    }
    
}

//----------------------------------------------------------------------------------
//
// Name: save
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(IBAction) save:(id)sender
{
    
    viewText = 1;
    [self loadingSave];
    
    UIGraphicsBeginImageContextWithOptions(mainImage.bounds.size, NO, 0.0);
    [mainImage.image drawInRect:CGRectMake(0, 0, mainImage.frame.size.width, mainImage.frame.size.height)];
    UIImage *SaveImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageWriteToSavedPhotosAlbum(SaveImage, self,@selector(image:didFinishSavingWithError:contextInfo:), nil);
    
    [colorValue setThumbImage:[UIImage alloc] forState:UIControlStateNormal];
    
}

//----------------------------------------------------------------------------------
//
// Name: image
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(void) image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    
    if (error != NULL)
    {
        
        [loading stopAnimating];
        [_hudView removeFromSuperview];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Opps" message:@"If you wish to save go into Settings > Privacy > Photos and turn Leave A Trace on" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
        
        [alert show];
        
    }
    else
    {
        
        [loading stopAnimating];
        [_hudView removeFromSuperview];
        
        viewText = 2;
        [self loadingSave];
        
    }
    
}

//----------------------------------------------------------------------------------
//
// Name:
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(IBAction) send:(id)sender
{
    
    progress.progress = 0;
    
    [timer invalidate];
    
    [currentColorImage setHidden:YES];
    [sliderImage setHidden:YES];
    [colorValue setHidden:YES];
    [brushSize setHidden:YES];
    [sendB setHidden:YES];
    [stopB setHidden:YES];
    [drawB setHidden:NO];
    [restartB setHidden:YES];
    [replayB setHidden:YES];
    [progress setHidden:YES];
    
    [self performSegueWithIdentifier:@"selectAContact" sender:self];
    
}

-(void) show
{
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:5];
    [colorValue setAlpha:1];
    [UIView commitAnimations];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [trashB setAlpha:1];
    [undoB setAlpha:1];
    [saveB setAlpha:1];
    [colorValue setAlpha:1];
    [brushSize setAlpha:1];
    [undoB setAlpha:1];
    [sendB setAlpha:1];
    [undoB setAlpha:1];
    [sliderImage setAlpha:1];
    [currentColorImage setAlpha:1];
    [UIView commitAnimations];
    
}

//----------------------------------------------------------------------------------
//
// Name:
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(void) hide
{
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.1];
    [colorValue setAlpha:0];
    [UIView commitAnimations];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [trashB setAlpha:0];
    [undoB setAlpha:0];
    [saveB setAlpha:0];
    [colorValue setAlpha:0];
    [brushSize setAlpha:0];
    [undoB setAlpha:0];
    [undoB setAlpha:0];
    [currentColorImage setAlpha:0];
    [sliderImage setAlpha:0];
    [UIView commitAnimations];
    
}

//----------------------------------------------------------------------------------
//
// Name:
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(void) loadingSave
{
    
    _hudView = [[UIView alloc] initWithFrame:CGRectMake(45, 180, 230, 50)];
    _hudView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    _hudView.clipsToBounds = YES;
    _hudView.layer.cornerRadius = 10.0;
    
    loading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    loading.frame = CGRectMake(25, 16, loading.bounds.size.width, loading.bounds.size.height);
    [_hudView addSubview:loading];
    [loading startAnimating];
    
    _captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 15, 130, 22)];
    _captionLabel.backgroundColor = [UIColor clearColor];
    _captionLabel.textColor = [UIColor whiteColor];
    _captionLabel.adjustsFontSizeToFitWidth = YES;
    
    if (viewText == 1)
    {
        
        _captionLabel.text = @"Saving trace...";
    
    }
    
    if (viewText == 2)
    {
        
        
        [loading stopAnimating];
        
        _captionLabel.frame = CGRectMake(53, 15, 130, 22);
        
        _captionLabel.text = @"Trace was saved!";
        
        [self fade];
        
    }
    
    [_captionLabel setTextAlignment:NSTextAlignmentCenter];
    [_hudView addSubview:_captionLabel];
    
    [self.view addSubview:_hudView];
    
}

//----------------------------------------------------------------------------------
//
// Name:
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

//----------------------------------------------------------------------------------
//
// Name:
//
// Purpose:
//
//----------------------------------------------------------------------------------

- (IBAction)HideTut:(UITapGestureRecognizer *)sender
{

    [tutorialImage setHidden:YES];
    
}

//----------------------------------------------------------------------------------
//
// Name:
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(IBAction)draw:(id)sender
{
    size_t total;
    id obj;
    for (obj in captureDrawing)
    {
        total += class_getInstanceSize([obj class]);
    }
    
    NSLog(@"Draw before array size : %ld",total);

    mainImage.image = nil;
    
    [undoRecordImageArray removeAllObjects];
    [undoImageArray removeAllObjects];
    [captureDrawing removeAllObjects];
    
    [currentColorImage setHidden:NO];
    [sliderImage setHidden:NO];
    [colorValue setHidden:NO];
    [brushSize setHidden:NO];
    [stopB setHidden:NO];
    [drawB setHidden:YES];
    [undoB setHidden:NO];
    [trashB setHidden:NO];
    [progress setHidden:NO];
    
    canDraw = YES;
    
    total = 0;
    for (obj in captureDrawing)
    {
        total += class_getInstanceSize([obj class]);
    }
    
    NSLog(@"After before array size : %ld",total);
    
}

//----------------------------------------------------------------------------------
//
// Name:
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(IBAction)reset:(id)sender
{
    
    progress.progress = 0;
    
    [timer invalidate];
   
    [currentColorImage setHidden:YES];
    [sliderImage setHidden:YES];
    [colorValue setHidden:YES];
    [brushSize setHidden:YES];
    [sendB setHidden:YES];
    [stopB setHidden:YES];
    [drawB setHidden:NO];
    [restartB setHidden:YES];
    [replayB setHidden:YES];
    [progress setHidden:YES];
    
    [undoRecordImageArray removeAllObjects];
    [undoImageArray removeAllObjects];
    [captureDrawing removeAllObjects];
    mainImage.image = nil;
    
}

//----------------------------------------------------------------------------------
//
// Name:
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(IBAction)stop:(id)sender
{

    progress.progress = 0;
    
    
    if (captureDrawing.count > 0)
    {
        canDraw = NO;
        
        [currentColorImage setHidden:YES];
        [sliderImage setHidden:YES];
        [colorValue setHidden:YES];
        [brushSize setHidden:YES];
        [sendB setHidden:NO];
        [stopB setHidden:YES];
        [drawB setHidden:YES];
        [restartB setHidden:NO];
        [undoB setHidden:YES];
        [trashB setHidden:YES];
        [replayB setHidden:NO];
        
        timerInt = 0;
        
        mainImage.image = nil;
        
        timer = [NSTimer scheduledTimerWithTimeInterval:DRAW_SPEED target:self selector:@selector(showVideo) userInfo:nil repeats:YES];
    }
    
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
    
    progress.progress = progress.progress + SPEED;
    
    progress.tintColor = [UIColor blackColor];
    
    NSString *STRx = [[captureDrawing objectAtIndex:timerInt] objectForKey:@"x"];
    NSString *STRy = [[captureDrawing objectAtIndex:timerInt] objectForKey:@"y"];
    NSString *STRlastx = [[captureDrawing objectAtIndex:timerInt] objectForKey:@"lastx"];
    NSString *STRlasty = [[captureDrawing objectAtIndex:timerInt] objectForKey:@"lasty"];
    NSString *bSize = [[captureDrawing objectAtIndex:timerInt] objectForKey:@"brush"];
    
    NSString *STRred = [[captureDrawing objectAtIndex:timerInt] objectForKey:@"red"];
    NSString *STRgreen = [[captureDrawing objectAtIndex:timerInt] objectForKey:@"green"];
    NSString *STRblue = [[captureDrawing objectAtIndex:timerInt] objectForKey:@"blue"];
    
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
        [UIView setAnimationTransition:108 forView:mainImage cache:NO];
        [UIView setAnimationDuration:0.1f];
        [UIView commitAnimations];
        
        self.mainImage.image = nil;

    }
    else
    {
        
        UIGraphicsBeginImageContext(self.view.frame.size);
        [self.mainImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), last_x_int, last_y_int); // lastX, lastY
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), x_int, y_int); //x, y
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush_size);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), redColor, greenColor, blueColor, 1.0);
        CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
        
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        self.mainImage.image = UIGraphicsGetImageFromCurrentImageContext();
        
    }
    
    timerInt += 1;
    
    if (timerInt == captureDrawing.count)
    {
        [timer invalidate];
    }
    
}

//----------------------------------------------------------------------------------
//
// Name:
//
// Purpose:
//
//----------------------------------------------------------------------------------

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
    
//    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
//                          xId,@"x",
//                          yId,@"y",
//                          lxId,@"lastx",
//                          lyId,@"lasty",
//                          bId,@"y",
//                          redId,@"red",
//                          greenId,@"green",
//                          blueId, @"blue",nil];
//   
    [captureDrawing addObject:drawingDictionary];
    
    size_t total;
    id obj;
    for (obj in captureDrawing)
    {
        total += class_getInstanceSize([obj class]);
    }
    
 //   NSLog(@"getMyCords 1 array size : %ld count of rows %lu",total,(unsigned long)captureDrawing.count);

    
}

//----------------------------------------------------------------------------------
//
// Name:
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(void) createIntroTrace
{
    
    sentImage = YES;
    
    mainImage.image = nil;
    
    [undoImageArray removeAllObjects];
    
    PFObject *introObject = [PFObject objectWithClassName:@"IntroObject"];
    
    [introObject setObject:captureDrawing forKey:@"imgVid"];
    
    [introObject saveInBackground];
    
}


@end














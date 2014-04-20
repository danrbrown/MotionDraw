//
//  StartUpViewController.m
//  LeaveATrace
//
//  Created by RICKY BROWN on 1/18/14.
//  Copyright (c) 2014 15and50. All rights reserved.
//

#import "StartUpViewController.h"
#import "LoadTraces.h"
#import "AppDelegate.h"

@interface StartUpViewController ()

@end

@implementation StartUpViewController

//----------------------------------------------------------------------------------
//
// Name:
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(void)viewDidLoad
{
        
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveLoadNotification:)
                                                 name:@"LoadTracesNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveLoadNotification:)
                                                 name:@"LoadContactsNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveLoadNotification:)
                                                 name:@"LoadRequestsNotification"
                                               object:nil];
    
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
    
    [self performSelector:@selector(defaults)];
    
}

//----------------------------------------------------------------------------------
//
// Name:
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(void) defaults
{
    //rb
    LoadTraces *loadTraces = [[LoadTraces alloc] init];
    
    NSUserDefaults *traceDefaults = [NSUserDefaults standardUserDefaults];
    NSString *tmpUsername = [traceDefaults objectForKey:@"username"];
    
    if ([tmpUsername length] != 0)
    {
                
        if ([tmpUsername isEqual:@"admin"])
        {
            
            (APP).IS_ADMIN = YES;
            
        }
        else
        {
            
            (APP).IS_ADMIN = NO;
            
        }
        
        [loadTraces loadTracesArray];
        [loadTraces loadContactsArray];
        [loadTraces loadRequestsArray];
        
        [self performSegueWithIdentifier:@"userAlreadyLoggedIn" sender:self];
        
    }
    else
    {
        
        [self performSegueWithIdentifier:@"userNeedsToLogIn" sender:self];
        
    }
    
}

//----------------------------------------------------------------------------------
//
// Name:
//
// Purpose:
//
//----------------------------------------------------------------------------------

- (void) receiveLoadNotification:(NSNotification *) notification
{
    
    if ([[notification name] isEqualToString:@"LoadTracesNotification"])
    {
        
        (APP).TRACES_DATA_LOADED = YES;
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"SendTraceNotification"
         object:self];
        
    }
    
    if ([[notification name] isEqualToString:@"LoadContactsNotification"])
    {
        
        (APP).CONTACTS_DATA_LOADED = YES;
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"ContactsLoadedNotification"
         object:self];
        
    }
    
    if ([[notification name] isEqualToString:@"LoadRequestsNotification"])
    {
        
        (APP).REQUESTS_DATA_LOADED = YES;
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"RequestsLoadedNotification"
         object:self];
        
    }
    
    if ((APP).TRACES_DATA_LOADED && (APP).CONTACTS_DATA_LOADED && (APP).REQUESTS_DATA_LOADED)
        NSLog (@"Successfully loaded all the data!");
    
}

@end

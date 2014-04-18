//
//  AppDelegate.m
//  LeaveATrace
//
//  Created by Ricky Brown on 10/26/13.
//  Copyright (c) 2013 15and50. All rights reserved.
//

#import <Parse/Parse.h>
#import "AppDelegate.h"
#import "LoadTraces.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    _tracesArray = [[NSMutableArray alloc] init];
    _contactsArray = [[NSMutableArray alloc] init];
    _requestsArray = [[NSMutableArray alloc] init];
    
    _unopenedTraceCount = 0;
    _friendRequestsCount = 0;
    
    _TRACES_DATA_LOADED = NO;
    _CONTACTS_DATA_LOADED = NO;
    _REQUESTS_DATA_LOADED = NO;
    
    _firstTime = NO;
    _firstTimeTrace = YES;
    _firstTimeThread = YES;
    _IS_ADMIN = NO;
    
    [Parse setApplicationId:@"Kdf476m7VNchMaa6Ylqyd9UF9sBvZ9c2ry5GYapw"
                  clientKey:@"wUt0JnO791TAa3UTir4zUdAihK0HMw3yayNud6XJ"];
    
    // Register for push notifications
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge |UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
    
    NSDictionary *notificationPayload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    if (notificationPayload)
    {
        
        NSUserDefaults *traceDefaults = [NSUserDefaults standardUserDefaults];
        NSString *traceUsername = [traceDefaults objectForKey:@"username"];
        NSString *pushReceiver = [notificationPayload objectForKey:@"r"];
        
        if ([traceUsername isEqualToString:pushReceiver])
        {
            
        }
        
    }
    
    [[UITabBar appearance] setTintColor:[UIColor yellowColor]];
    
    application.applicationSupportsShakeToEdit = YES;
    
    UIFont *titleFont = [UIFont fontWithName:@"PWSimpleHandwriting" size:26];
    
    NSShadow* shadow = [NSShadow new];
    shadow.shadowOffset = CGSizeMake(0.0f, 0.0f);
    shadow.shadowColor = [UIColor clearColor];
    [[UINavigationBar appearance] setTitleTextAttributes: @{
                                                            NSForegroundColorAttributeName: [UIColor yellowColor],
                                                            NSFontAttributeName:titleFont,
                                                            NSShadowAttributeName:shadow
                                                            }];

    return YES;
    
}

//----------------------------------------------------------------------------------
//
// Name:
//
// Purpose:
//
//----------------------------------------------------------------------------------

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken {
    
    NSLog(@"Registering the installation...");
    
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:newDeviceToken];
    [currentInstallation saveInBackground];
    
}

//----------------------------------------------------------------------------------
//
// Name:
//
// Purpose:
//
//----------------------------------------------------------------------------------

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    // [PFPush handlePush:userInfo];
    
    NSString *msgType = [userInfo objectForKey:@"msgType"];

    // NSLog(@"Got a push....type is %@",msgType);
    
    if ([msgType isEqualToString:@"Trace"])
    {
        
        [self processTracePush:userInfo];
        
    }
    else if ([msgType isEqualToString:@"Thread"])
    {
        
        [self processThreadPush:userInfo];
        
    }
    else  // "Request" or "Confirmed"
    {
        
        LoadTraces *loadTraces = [[LoadTraces alloc] init];
        
        [loadTraces loadContactsArray];
        [loadTraces loadRequestsArray];
        
        [PFPush handlePush:userInfo];
        
    }
    
}

//----------------------------------------------------------------------------------
//
// Name:
//
// Purpose:
//
//----------------------------------------------------------------------------------

- (void)processTracePush : (NSDictionary *)userInfo {
    
    // [PFPush handlePush:userInfo];
    
    NSUserDefaults *traceDefaults = [NSUserDefaults standardUserDefaults];
    NSString *traceUsername = [traceDefaults objectForKey:@"username"];
    
    NSString *objId = [userInfo objectForKey:@"objId"];
    NSString *friend = [userInfo objectForKey:@"friend"];
    
    // Only deal with the push if the user is logged in, and the logged in user
    // is the one receiving the push
    
    if (([traceUsername length] > 0) && [friend isEqualToString:traceUsername])
    {
        
        PFQuery *pushQuery = [PFQuery queryWithClassName:@"TracesObject"];
        [pushQuery whereKey:@"objectId" equalTo:objId];
        
        [pushQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            if (!error)
            {
                for (PFObject *obj in objects)
                {
                    [obj setObject:@"D"forKey:@"status"];
                    
                    [_tracesArray addObject:obj];
                    _unopenedTraceCount++;
                    
                    [obj saveInBackground];
                    
                }
                
                NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"lastSentByDateTime" ascending:NO];
                [_tracesArray sortUsingDescriptors:[NSArray arrayWithObject:sort]];
                
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"SendTraceNotification"
                 object:self];
                
            }
            else
            {
                
                NSLog(@"There was an error loading the pushed trace.");
                
            }
            
        }];
        
    }
    
}

//----------------------------------------------------------------------------------
//
// Name:
//
// Purpose:
//
//----------------------------------------------------------------------------------

- (void)processThreadPush : (NSDictionary *)userInfo {
    
    NSUserDefaults *traceDefaults = [NSUserDefaults standardUserDefaults];
    NSString *traceUsername = [traceDefaults objectForKey:@"username"];
    
    NSString *arrayObjId;
    NSString *objId = [userInfo objectForKey:@"objId"];
    NSString *friend = [userInfo objectForKey:@"friend"];
    NSString *sender = [userInfo objectForKey:@"sender"];
    NSDate *currentDateTime = [NSDate date];
    
    // Only deal with the push if the user is logged in, and the logged in user
    // is the one receiving the push
    
    if (([traceUsername length] > 0) && [friend isEqualToString:traceUsername])
    {
        
        BOOL objectIdFound = NO;
        for (PFObject *obj in _tracesArray)
        {
            arrayObjId = [obj objectId];
            
            if([arrayObjId isEqualToString:objId])
            {
                objectIdFound = YES;
                
                [obj setObject:@"YES"forKey:@"fromUserDisplay"];
                [obj setObject:@"YES"forKey:@"toUserDisplay"];
                [obj setObject:sender forKey:@"lastSentBy"];
                [obj setObject:currentDateTime forKey:@"lastSentByDateTime"];
                [obj setObject:@"D"forKey:@"status"];
                
                _unopenedTraceCount++;
                
                break;
            }
            
            
        }
        
        if (!objectIdFound)  // Should only happen if user deleted the trace
        {
            LoadTraces *loadTraces = [[LoadTraces alloc] init];
            [loadTraces loadTracesArray];
            
        }
        else
        {
            
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"lastSentByDateTime" ascending:NO];
            [_tracesArray sortUsingDescriptors:[NSArray arrayWithObject:sort]];
            
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"SendTraceNotification"
             object:self];
            
        }
        
    }
    
}

//----------------------------------------------------------------------------------

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = _unopenedTraceCount + _friendRequestsCount;
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    (APP).TRACES_DATA_LOADED = NO;
    (APP).CONTACTS_DATA_LOADED = NO;
    (APP).REQUESTS_DATA_LOADED = NO;
    
    NSUserDefaults *traceDefaults = [NSUserDefaults standardUserDefaults];

    //-------------------------------------------------------
    //    UNCOMMENT THIS IF YOU NEED TO FORCE A LOGIN
    //    [traceDefaults setObject:@"" forKey:@"username"];
    //    [traceDefaults synchronize];
    //-------------------------------------------------------
    
    NSString *tmpUsername = [traceDefaults objectForKey:@"username"];
    NSString *tmpCurrentUser = [[PFUser currentUser]username];

    // If the username default is set, and the username default is eqaul to the PFuser, then proceed
    // with querying Parse.  If any of these are not true, then the user has to log in.
    // If any of that is not true, then make sure to null out the username. This will force the
    // login screen to appear.
    
    NSLog(@"usernaame %@ PFUsername %@",tmpUsername, tmpCurrentUser);
    
    if ( ([tmpUsername length] != 0 ) && ([tmpCurrentUser length] !=0) && [tmpUsername isEqualToString:tmpCurrentUser] )
    {
        
        LoadTraces *loadTraces = [[LoadTraces alloc] init];
        
        [loadTraces loadTracesArray];
        [loadTraces loadContactsArray];
        [loadTraces loadRequestsArray];
        
    }
    else
    {
        [traceDefaults setObject:@"" forKey:@"username"];
        [traceDefaults synchronize];
    }
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

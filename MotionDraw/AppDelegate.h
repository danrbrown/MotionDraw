//
//  AppDelegate.h
//  LeaveATrace
//
//  Created by Ricky Brown on 10/26/13.
//  Copyright (c) 2013 15and50. All rights reserved.
//

#import <UIKit/UIKit.h>

#define APP (AppDelegate*)[[UIApplication sharedApplication] delegate]

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, atomic) NSMutableArray *tracesArray;
@property (strong, atomic) NSMutableArray *contactsArray;
@property (strong, atomic) NSMutableArray *requestsArray;
@property (nonatomic, assign) NSInteger unopenedTraceCount;
@property (nonatomic, assign) NSInteger friendRequestsCount;
@property (nonatomic, assign) BOOL firstTime;
@property (nonatomic, assign) BOOL firstTimeTrace;
@property (nonatomic, assign) BOOL firstTimeThread;
@property (nonatomic, assign) BOOL TRACES_DATA_LOADED;
@property (nonatomic, assign) BOOL CONTACTS_DATA_LOADED;
@property (nonatomic, assign) BOOL REQUESTS_DATA_LOADED;

@end

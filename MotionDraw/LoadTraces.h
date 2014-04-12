//
//  LoadTraces.h
//  LeaveATrace
//
//  Created by RICKY BROWN on 1/18/14.
//  Copyright (c) 2014 15and50. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoadTraces : NSObject

-(void) loadTracesArray;

-(void) loadContactsArray;

-(void) loadRequestsArray;

-(NSInteger) countTracesForFriend:(NSString *)friend;
-(NSInteger) countFriendRequestsForFriend:(NSString *)friend;

@end

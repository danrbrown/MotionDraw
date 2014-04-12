//
//  LoadTraces.m
//  LeaveATrace
//
//  Created by RICKY BROWN on 1/18/14.
//  Copyright (c) 2014 15and50. All rights reserved.
//

#import "LoadTraces.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>

@implementation LoadTraces

//----------------------------------------------------------------------------------
//
// Name:
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(void) loadTracesArray
{
    
    (APP).unopenedTraceCount = 0;
    
    PFQuery *toUserQuery = [PFQuery queryWithClassName:@"TracesObject"];
    [toUserQuery whereKey:@"toUser" equalTo:[[PFUser currentUser]username]];
    [toUserQuery whereKey:@"toUserDisplay" equalTo:@"YES"];
    
    PFQuery *fromUserQuery = [PFQuery queryWithClassName:@"TracesObject"];
    [fromUserQuery whereKey:@"fromUser" equalTo:[[PFUser currentUser]username]];
    [fromUserQuery whereKey:@"fromUserDisplay" equalTo:@"YES"];
    
    PFQuery *tracesQuery = [PFQuery orQueryWithSubqueries:@[toUserQuery,fromUserQuery]];
    
    [tracesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error)
        {
            
            (APP).tracesArray = [[NSMutableArray alloc] initWithArray:objects];
            
            for (PFObject *objStatus in objects) {
                
                NSString *tmpCurrentUser = [[PFUser currentUser]username];
                NSString *tmpStatus = [objStatus objectForKey:@"status"];
                NSString *tmpLastSentBy = [objStatus objectForKey:@"lastSentBy"];

                if (![tmpCurrentUser isEqualToString:tmpLastSentBy])  // Not the current user sent it
                {
                    if ([tmpStatus isEqualToString:@"S"] || [tmpStatus isEqualToString:@"D"])
                    {
                        
                        (APP).unopenedTraceCount++;
                        
                    }
                    
                    if ([tmpStatus isEqualToString:@"S"])
                    {
                        
                        [objStatus setObject:@"D"forKey:@"status"];
                        [objStatus saveInBackground];
                        
                    }

                }
                
            }
            
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"lastSentByDateTime" ascending:NO];
            
            [(APP).tracesArray sortUsingDescriptors:[NSArray arrayWithObject:sort]];
            
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"LoadTracesNotification"
             object:self];
            
        }
        else
        {
            
            NSLog(@"There was an error loading the traces");
            
        }
        
    }];
    
}

//----------------------------------------------------------------------------------
//
// Name:
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(void) loadContactsArray
{
    
    PFQuery *contactsQuery = [PFQuery queryWithClassName:@"UserContact"];
    
    [contactsQuery whereKey:@"username" equalTo:[[PFUser currentUser]username]];
    
    [contactsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error)
        {
            
            (APP).contactsArray = [[NSMutableArray alloc] initWithArray:objects];
            
            NSSortDescriptor *sort1 = [NSSortDescriptor sortDescriptorWithKey:@"contact" ascending:YES selector:@selector(caseInsensitiveCompare:)];
            
            [(APP).contactsArray sortUsingDescriptors:[NSArray arrayWithObject:sort1]];
            
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"LoadContactsNotification"
             object:self];

        }
        else
        {
            
            NSLog(@"There was an error loading the contacts");
            
        }
        
    }];
    
}

//----------------------------------------------------------------------------------
//
// Name:
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(void) loadRequestsArray
{
    
    (APP).friendRequestsCount = 0;
    
    PFQuery *requestsQuery = [PFQuery queryWithClassName:@"UserContact"];
    
    [requestsQuery whereKey:@"contact" equalTo:[[PFUser currentUser]username]];
    [requestsQuery whereKey:@"userAccepted" equalTo:@"NO"];
    [requestsQuery orderByAscending:@"contact"];
    
    [requestsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error)
        {
            
            (APP).requestsArray = [[NSMutableArray alloc] initWithArray:objects];
            (APP).friendRequestsCount = objects.count;
            
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"LoadRequestsNotification"
             object:self];
            
        }
        else
        {
    
            NSLog(@"There was an error loading the Requests");
            
        }
        
    }];
    
}

//----------------------------------------------------------------------------------
//
// Name:
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(NSInteger) countTracesForFriend:(NSString *)friend
{
    
    NSInteger unopenedTraceCountForFriend = 0;
    
    PFQuery *toUserQuery = [PFQuery queryWithClassName:@"TracesObject"];
    [toUserQuery whereKey:@"toUser" equalTo:friend];
    [toUserQuery whereKey:@"toUserDisplay" equalTo:@"YES"];
    
    PFQuery *fromUserQuery = [PFQuery queryWithClassName:@"TracesObject"];
    [fromUserQuery whereKey:@"fromUser" equalTo:friend];
    [fromUserQuery whereKey:@"fromUserDisplay" equalTo:@"YES"];
    
    PFQuery *tracesQuery = [PFQuery orQueryWithSubqueries:@[toUserQuery,fromUserQuery]];
    
    NSArray *friendsTracesArray = [tracesQuery findObjects];
    
    for (PFObject *objStatus in friendsTracesArray) {
        
        NSString *tmpCurrentUser = friend;
        NSString *tmpStatus = [objStatus objectForKey:@"status"];
        NSString *tmpLastSentBy = [objStatus objectForKey:@"lastSentBy"];
        
        if (![tmpCurrentUser isEqualToString:tmpLastSentBy])  // Not the current user sent it
        {
            if ([tmpStatus isEqualToString:@"S"] || [tmpStatus isEqualToString:@"D"])
            {
                
                unopenedTraceCountForFriend++;
                
            }
            
        }
    }
    
    return unopenedTraceCountForFriend;
    
}

//----------------------------------------------------------------------------------
//
// Name:
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(NSInteger) countFriendRequestsForFriend:(NSString *)friend
{
    
    PFQuery *requestsQuery = [PFQuery queryWithClassName:@"UserContact"];
    
    [requestsQuery whereKey:@"contact" equalTo:friend];
    [requestsQuery whereKey:@"userAccepted" equalTo:@"NO"];
    [requestsQuery orderByAscending:@"contact"];
    
    NSArray *friendsRequestsArray = [requestsQuery findObjects];
    
    return friendsRequestsArray.count;
    
}


//----------------------------------------------------------------------------------


@end

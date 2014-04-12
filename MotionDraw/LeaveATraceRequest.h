//
//  LeaveATraceRequest.h
//  LeaveATrace
//
//  Created by Ricky Brown on 11/23/13.
//  Copyright (c) 2013 15and50. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LeaveATraceRequest : NSObject

//Text in request cell
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *userAccepted;

@end

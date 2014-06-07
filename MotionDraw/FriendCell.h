//
//  FriendCell.h
//  MotionDraw
//
//  Created by Ricky Brown on 6/7/14.
//  Copyright (c) 2014 15and50. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *friendLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIButton *inviteFriendB;
@property (weak, nonatomic) IBOutlet UIButton *sendRequestB;

@end

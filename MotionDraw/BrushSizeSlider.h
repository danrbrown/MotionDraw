//
//  BrushSizeSlider.h
//  LeaveATrace
//
//  Created by Ricky Brown on 1/31/14.
//  Copyright (c) 2014 15and50. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopoverView.h"

@interface BrushSizeSlider : UISlider

@property (strong, nonatomic) PopoverView *popup;

@property (nonatomic, readonly) CGRect thumbRect;

@end

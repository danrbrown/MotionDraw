//
//  PopoverView.m
//  LeaveATrace
//
//  Created by Ricky Brown on 1/31/14.
//  Copyright (c) 2014 15and50. All rights reserved.
//

#import "PopoverView.h"

@implementation PopoverView {
    
    UILabel *textLabel;
    
    UIImageView *popoverView;
    
}

-(id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.font = [UIFont boldSystemFontOfSize:15.0f];
        
        popoverView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sliderlabel.png"]];
        [self addSubview:popoverView];
        
        textLabel = [[UILabel alloc] init];
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.font = self.font;
        textLabel.textColor = [UIColor colorWithWhite:1.0f alpha:0.7];
        textLabel.text = self.text;
        textLabel.textAlignment = NSTextAlignmentCenter;
        popoverView.frame = CGRectMake(-20, -30.0f, 100, 100);
        [self addSubview:textLabel];
        
    }
    return self;
}

-(void) setValue:(float)aValue
{
    
    _value = aValue;
    
   // self.text = [NSString stringWithFormat:@"%4.2f", _value];
   // textLabel.text = self.text;
    
    //popoverView.frame = CGRectMake(0, 1.0f, popoverView.frame.size.width, popoverView.frame.size.height);
    
    UIGraphicsBeginImageContext(popoverView.frame.size);
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), aValue);
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.0, 0.0, 0.0, 1.0);
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(),45, 45);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(),45, 45);
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    popoverView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self setNeedsDisplay];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

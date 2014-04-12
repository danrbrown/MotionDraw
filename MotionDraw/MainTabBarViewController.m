//
//  MainTabBarViewController.m
//  LeaveATrace
//
//  Created by RICKY BROWN on 1/18/14.
//  Copyright (c) 2014 15and50. All rights reserved.
//

#import "MainTabBarViewController.h"

@interface MainTabBarViewController ()

@end

@implementation MainTabBarViewController

- (void)viewDidLoad
{
    
    self.selectedIndex = 1;
    
    UITabBar *tabBar = self.tabBar;
    UITabBarItem *tabBarItem1 = [tabBar.items objectAtIndex:0];
    UITabBarItem *tabBarItem2 = [tabBar.items objectAtIndex:1];
    UITabBarItem *tabBarItem3 = [tabBar.items objectAtIndex:2];
    UITabBarItem *tabBarItem4 = [tabBar.items objectAtIndex:3];

    UIImage *tabImage1small = [UIImage imageNamed:@"TracesIcon.png"];
    UIImage *tabImage2small = [UIImage imageNamed:@"NewTraceIconSmall.png"];
    UIImage *tabImage3small = [UIImage imageNamed:@"FriendsIcon.png"];
    UIImage *tabImage4small = [UIImage imageNamed:@"RequestsIcon.png"];

    CGSize result = [[UIScreen mainScreen] bounds].size;
    if(result.height == 480)
    {

        tabBarItem1.image = tabImage1small;
        tabBarItem2.image = tabImage2small;
        tabBarItem3.image = tabImage3small;
        tabBarItem4.image = tabImage4small;

        NSLog(@"Small");

    }
    
    UIImage *tabImage1big = [UIImage imageNamed:@"TracesIconBig.png"];
    UIImage *tabImage2big = [UIImage imageNamed:@"NewTraceIcon.png"];
    UIImage *tabImage3big = [UIImage imageNamed:@"FriendsIconBig.png"];
    UIImage *tabImage4big = [UIImage imageNamed:@"RequestsIconBig.png"];
    
    if (result.height == 568)
    {
        
        tabBarItem1.image = tabImage1big;
        tabBarItem2.image = tabImage2big;
        tabBarItem3.image = tabImage3big;
        tabBarItem4.image = tabImage4big;
        
        tabBarItem1.selectedImage = tabImage1big;
        tabBarItem2.selectedImage = tabImage2big;
        tabBarItem3.selectedImage = tabImage3big;
        tabBarItem4.selectedImage = tabImage4big;
        
        NSLog(@"Big");
        
    }
    
}

@end

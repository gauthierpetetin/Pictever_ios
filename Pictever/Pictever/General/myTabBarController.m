//
//  myTabBarController.m
//  Keo
//
//  Created by Gauthier Petetin on 10/07/2014.
//  Copyright (c) 2014 Gauthier Petetin. All rights reserved.
//

#import "myTabBarController.h"

@interface myTabBarController ()

@end

@implementation myTabBarController
@synthesize myTabBar;

UIColor *theKeoOrangeColor;//global

bool appOpenedOnNotification;//global

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    myTabBar.tintColor = theKeoOrangeColor;
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

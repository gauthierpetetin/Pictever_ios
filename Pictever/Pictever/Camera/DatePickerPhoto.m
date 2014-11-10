//
//  DatePickerPhoto.m
//  Keo
//
//  Created by Gauthier Petetin on 31/05/2014.
//  Copyright (c) 2014 Gauthier Petetin. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////(GO TO APPDELEGATE.M FOR MORE INFO ABOUT THE GLOBAL VARIABLES)/////////////////////////////////

#import "DatePickerPhoto.h"

#import "myGeneralMethods.h"

@interface DatePickerPhoto ()

@end

@implementation DatePickerPhoto
@synthesize myDatePickerPhoto;

//size if the screen
CGFloat screenWidth;//global
CGFloat screenHeight;//global
CGFloat tabBarHeight;//global

NSString * storyboardName; //global
NSString * backgroundImage; //global
NSString *sendToDateLocal;//local
NSString *sendToDateAsText;//global
NSString *sendToTimeStamp;//global

UIColor *theBackgroundColor;//global

bool sendKeo;//false

NSString* lastLabelSelected;//global

UILabel *infoLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = theBackgroundColor;
    
    myDatePickerPhoto.minimumDate = [[NSDate date] dateByAddingTimeInterval:60];
    myDatePickerPhoto.maximumDate = [[NSDate date] dateByAddingTimeInterval:31536000];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(sendKeo)
     forControlEvents:UIControlEventTouchUpInside];
    button.layer.cornerRadius = 10; // arrondir les angles
    button.clipsToBounds = YES;
    button.backgroundColor = [UIColor whiteColor];
    [button setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [button setTitle:@"Confirm" forState:UIControlStateNormal];
    button.frame = CGRectMake(100.0, 370.0, 122.0, 30.0);
    [self.view addSubview:button];
    
    int xInfo = 200;
    int yInfo = 70;
    CGRect rectLabInfo = CGRectMake(screenWidth*0.5-0.5*xInfo,0.84*screenHeight,xInfo,yInfo);
    infoLabel = [[UILabel alloc] initWithFrame: rectLabInfo];
    [infoLabel setTextAlignment:NSTextAlignmentCenter];
    [infoLabel setFont:[UIFont systemFontOfSize:8]];
    infoLabel.text = @"(The date selected corresponds to the date in your actual timezone)";
    infoLabel.textColor = [UIColor grayColor];
    infoLabel.lineBreakMode = NSLineBreakByWordWrapping;
    infoLabel.numberOfLines = 0;
    
    [self.view addSubview:infoLabel];
}


//-------------------the user presses the confirm button, we leave the view and and the message will be sent to the selected date----------
-(void) sendKeo{
    lastLabelSelected = @"calendar";
    
    NSDate *sendingDate = [myDatePickerPhoto date];
    
    NSTimeInterval dateStamp = [sendingDate timeIntervalSince1970];
    sendToTimeStamp = [NSString stringWithFormat:@"%.0f",dateStamp];
    APLLog(@"time stamp since 1970: %@",sendToTimeStamp);
    
    NSTimeInterval timeIntervalInSeconds = [sendingDate timeIntervalSinceNow];
    NSTimeInterval timeIntervalInMinutes = floor(timeIntervalInSeconds/60);
    NSString *stringTimeIntervalInMinutes = [NSString stringWithFormat:@"%f",timeIntervalInMinutes];
    stringTimeIntervalInMinutes = [stringTimeIntervalInMinutes componentsSeparatedByString:@"."][0];
    sendToDateLocal = [stringTimeIntervalInMinutes stringByReplacingOccurrencesOfString:@" " withString:@""];
    sendToDateAsText = [myGeneralMethods getStringToPrint:sendingDate];
    
    if(timeIntervalInSeconds > 0){
        sendKeo = true;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else{
        UIAlertView *alert3 = [[UIAlertView alloc]
                               initWithTitle:@"Sorry a Pictever message can only be sent in the future!"
                               message:[NSString stringWithFormat:@"%@",@""] delegate:self
                               cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert3 show];
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelPressed4:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


@end
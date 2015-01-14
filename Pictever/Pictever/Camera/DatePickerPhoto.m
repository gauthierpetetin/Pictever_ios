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

NSString *myLocaleString;
NSString * storyboardName; //global
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
    
    //self.view.backgroundColor = theBackgroundColor;
    self.view.backgroundColor = [UIColor whiteColor];
    
    //--------------navigation bar color (code couleur transformé du orangekeo sur
    //http://htmlpreview.github.io/?https://github.com/tparry/Miscellaneous/blob/master/UINavigationBar_UIColor_calculator.html)
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:244/255.0f green:58/255.0f blue:0/255.0f alpha:1.0f];
    self.navigationController.navigationBar.barStyle=UIStatusBarStyleLightContent;
    
    
    //----------------confirm and cancel buttons----------------------------------
    NSString *cancelTitle = @"Cancel";
    if([myLocaleString isEqualToString:@"FR"]){
        cancelTitle = @"Annuler";
    }
    UIBarButtonItem *cancelItem2 = [[UIBarButtonItem alloc] initWithTitle:cancelTitle style:UIBarButtonItemStylePlain target:self action:@selector(cancelPressed4:)];

    self.navigationItem.leftBarButtonItem = cancelItem2;
    
    NSDictionary *barButtonAppearanceDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                             [[UIColor whiteColor] colorWithAlphaComponent:1.0],
                                             NSForegroundColorAttributeName,
                                             [UIFont fontWithName:@"GothamRounded-Light" size:16.0],
                                             NSFontAttributeName,
                                             nil];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
     setTitleTextAttributes:barButtonAppearanceDict forState:UIControlStateNormal];
    
    UILabel *pickadateLabel;
    pickadateLabel = (UILabel *)[self.view viewWithTag:1];
    pickadateLabel.font = [UIFont fontWithName:@"GothamRounded-Light" size:16.0];
    NSString *pickTitle = @"Pick a date for your message!";
    if([myLocaleString isEqualToString:@"FR"]){
        pickTitle = @"Choisis une date pour ton message!";
    }
    pickadateLabel.text = pickTitle;
    

    myDatePickerPhoto.minimumDate = [[NSDate date] dateByAddingTimeInterval:60];
    myDatePickerPhoto.maximumDate = [[NSDate date] dateByAddingTimeInterval:31536000];
    
    
    int xButton = 122;
    int yButton = 30;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(sendKeo)
     forControlEvents:UIControlEventTouchUpInside];
    button.layer.cornerRadius = 10; // arrondir les angles
    button.clipsToBounds = YES;
    button.backgroundColor = [UIColor clearColor];
    button.titleLabel.font = [UIFont fontWithName:@"GothamRounded-Bold" size:20];
    [button setTitleColor:[myGeneralMethods getColorFromHexString:@"f6591e"] forState:UIControlStateNormal];
    [button setTitle:@"Confirm" forState:UIControlStateNormal];
    if([myLocaleString isEqualToString:@"FR"]){
        [button setTitle:@"Confirmer" forState:UIControlStateNormal];
    }
    button.frame = CGRectMake(0.5*screenWidth-0.5*xButton, 0.77*screenHeight, xButton, yButton);
    [self.view addSubview:button];
    
    int xInfo = 200;
    int yInfo = 70;
    CGRect rectLabInfo = CGRectMake(screenWidth*0.5-0.5*xInfo,0.84*screenHeight,xInfo,yInfo);
    infoLabel = [[UILabel alloc] initWithFrame: rectLabInfo];
    [infoLabel setTextAlignment:NSTextAlignmentCenter];
    [infoLabel setFont:[UIFont fontWithName:@"GothamRounded-Light" size:8]];
    infoLabel.text = @"(The date selected corresponds to the date in your actual timezone)";
    if([myLocaleString isEqualToString:@"FR"]){
        infoLabel.text = @"(La date sélectionnée correspond à celle de ton propre fuseau horaire)";
    }
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
        NSString *title3 = @"Sorry a Pictever message can only be sent in the future!";
        if([myLocaleString isEqualToString:@"FR"]){
            title3 = @"Désolé, les messages Pictever ne peuvent être envoyés que dans le futur!";
        }
        UIAlertView *alert3 = [[UIAlertView alloc]
                               initWithTitle:title3
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
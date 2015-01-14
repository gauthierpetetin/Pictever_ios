//
//  SettingsController.m
//  Test6
//
//  Created by Gauthier Petetin on 08/07/2014.
//  Copyright (c) 2014 Gauthier Petetin. All rights reserved.
//

#import "SettingsController.h"

#import <AWSiOSSDKv2/AWSMobileAnalytics.h>
#import <AWSiOSSDKv2/AWSCore.h>

#import "InfosCell.h"

#import "myConstants.h"

#import "ShyftMessage.h"
#import "ShyftSet.h"

@interface SettingsController ()

@end



@implementation SettingsController

/////////////All my global variables (GO TO APPDELEGATE.M FOR MORE INFO ABOUT THE VARIABLES)////////////////

ShyftSet *myShyftSet;//global

AWSMobileAnalytics* analytics;//global

NSString *myCurrentPhoneNumber;

NSUserDefaults *prefs;//global

NSString *myLocaleString;
NSString *username;//global
NSString *hashPassword;//global
bool logIn;//global
NSString *myStatus;//global

NSString *storyboardName;//global

UIColor *theBackgroundColor;//global
UIColor *theKeoOrangeColor;//global

NSString *myVersionInstallUrl;

CGFloat screenWidth;//global
CGFloat screenHeight;//global

NSString *adresseIp2;//global

UIButton *futureButton;
UIButton *statusButton;
UILabel *futureLabel;
UILabel *infoLabel;

UIColor *thePicteverGreenColor;//global
UIColor *thePicteverYellowColor;//global
UIColor *thePicteverRedColor;//global
UIColor *thePicteverGrayColor;//global

NSTimer *myFutureTimer;

NSString *myVersionInstallUrl;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor clearColor];

    self.parentViewController.view.backgroundColor = [UIColor whiteColor];

    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    
    //--------------navigation bar color (code couleur transformé du orangekeo sur
    //http://htmlpreview.github.io/?https://github.com/tparry/Miscellaneous/blob/master/UINavigationBar_UIColor_calculator.html)
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:244/255.0f green:58/255.0f blue:0/255.0f alpha:1.0f];
    self.navigationController.navigationBar.barStyle=UIStatusBarStyleLightContent;
    [self setNeedsStatusBarAppearanceUpdate];//status bar text color
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                     [[UIColor whiteColor] colorWithAlphaComponent:1.0],
                                                                     NSForegroundColorAttributeName,
                                                                     [UIFont fontWithName:@"GothamRounded-Bold" size:18.0],
                                                                     NSFontAttributeName,
                                                                     nil]
     ];
    
    
    
    //----------------confirm and cancel buttons----------------------------------
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backButton:)];
    
    self.navigationItem.rightBarButtonItem = backItem;

    
    NSDictionary *barButtonAppearanceDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                             [[UIColor whiteColor] colorWithAlphaComponent:1.0],
                                             NSForegroundColorAttributeName,
                                             [UIFont fontWithName:@"GothamRounded-Light" size:16.0],
                                             NSFontAttributeName,
                                             nil];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
     setTitleTextAttributes:barButtonAppearanceDict forState:UIControlStateNormal];
    
    
    APLLog(@"SettingsViewDidLoad");
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(insertNewRow:) name:@"insertNewRow" object: nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"insertNewRow" object:nil];
}

//---------------insert new message from notification---------------------

-(void)insertNewRow:(NSNotification *)notification{
    APLLog(@"insertNewRow: %@",[notification.userInfo description]);
    NSMutableDictionary *newPhotoMessage = [notification.userInfo mutableCopy];
    ShyftMessage *shyftToInsert = [[ShyftMessage alloc] initWithShyft:newPhotoMessage];
    if(![myShyftSet containsShyft:shyftToInsert]){
        [myShyftSet insertNewShyft:shyftToInsert];
    }
}



//-------------we send the info to amazon analytics to have statistics about how often the user asks for this info---------
-(void)alertAnalyticsAskStatus{
    APLLog(@"alertAnalytics ask status pressed");
    id<AWSMobileAnalyticsEventClient> eventClient = analytics.eventClient;
    id<AWSMobileAnalyticsEvent> levelEvent = [eventClient createEventWithEventType:@"iosHowToIncreaseMyStatus"];
    //[levelEvent addAttribute:numberr forKey:@"number_of_future_messages"];
    //[levelEvent addMetric:myNumber forKey:@"number_of_future_messages"];
    //APLLog(@"levelevent:%@",[[levelEvent allAttributes] description]);
    [eventClient recordEvent:levelEvent];
    [eventClient submitEvents];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    /*if(indexPath.row == 0){
        return NO;
    }
    if(indexPath.row == 4){
        return NO;
    }*/
    //return YES;
    return NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 3;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row==0){
        return 170;
        //return 155;
    }
    else{
        return 125;
        //return 82;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    APLLog(@"didselectrowatindexpath");
    if(indexPath.row == 1){
        [self alertAnalyticsAskStatus];
    }
    if(indexPath.row == 2){
        /*UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Noooooo"
                              message:@"Why do you want to do this?" delegate:self
                              cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [alert show];*/
    }
    if(indexPath.row == 3){
        APLLog(@"open website");
        //[[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.pictever.com/"]];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)deleteContact{
    APLLog(@"deletecontact pressed");
    NSString *titleAlert = @"Noooooo";
    NSString *messageAlert = @"Why do you want to do this?";
    if([myLocaleString isEqualToString:@"FR"]){
        titleAlert = @"Nooooonnnn";
        messageAlert = @"Pourquoi vouloir faire ca??";
    }
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:titleAlert
                          message:messageAlert delegate:self
                          cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
    [alert show];
}

-(void)gotoappStore{
    APLLog(@"go to app store pressed");
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: myVersionInstallUrl]];
}


//-----------We fill the tableview-----------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil;
    
    NSLog(@"cellforrowatindexpath: %ld",(long)indexPath.row);
    
    if(indexPath.row == 0){
        cell = [tableView dequeueReusableCellWithIdentifier:@"InfosCell" forIndexPath:indexPath];
        InfosCell *infosCell = (InfosCell *)cell;
        infosCell.backGroundLabel1.clipsToBounds = YES;
        infosCell.backGroundLabel1.layer.cornerRadius = 5;
        infosCell.titleLabel.font = [UIFont fontWithName:@"GothamRounded-Bold" size:18];
        infosCell.emailTitleLabel.font = [UIFont fontWithName:@"GothamRounded-Bold" size:14];
        infosCell.phoneTitleLabel.font = [UIFont fontWithName:@"GothamRounded-Bold" size:14];
        infosCell.phoneContentLabel.font = [UIFont fontWithName:@"GothamRounded-Light" size:14];
        infosCell.emailContentLabel.font = [UIFont fontWithName:@"GothamRounded-Light" size:14];
        infosCell.phoneContentLabel.text = myCurrentPhoneNumber;
        infosCell.emailContentLabel.text = username;
        
        infosCell.titleLabel.text = @"My Infos";
        infosCell.emailTitleLabel.text = @"Email address";
        infosCell.phoneTitleLabel.text = @"Phone Number";
        if([myLocaleString isEqualToString:@"FR"]){
            infosCell.titleLabel.text = @"Mes Infos";
            infosCell.emailTitleLabel.text = @"Adresse mail";
            infosCell.phoneTitleLabel.text = @"Téléphone";
        }
        
    }
    if(indexPath.row == 1){
        cell = [tableView dequeueReusableCellWithIdentifier:@"DoubleInfosCell" forIndexPath:indexPath];
        InfosCell *doubleInfosCell = (InfosCell *)cell;
        doubleInfosCell.button1.clipsToBounds = YES;
        doubleInfosCell.button2.clipsToBounds = YES;
        doubleInfosCell.button1.layer.cornerRadius = 5;
        doubleInfosCell.button2.layer.cornerRadius = 5;
        doubleInfosCell.emailTitleLabel.font = [UIFont fontWithName:@"GothamRounded-Bold" size:14];
        doubleInfosCell.phoneTitleLabel.font = [UIFont fontWithName:@"GothamRounded-Bold" size:14];
        doubleInfosCell.emailContentLabel.font = [UIFont fontWithName:@"GothamRounded-Light" size:14];
        doubleInfosCell.phoneContentLabel.font = [UIFont fontWithName:@"GothamRounded-Light" size:14];
        
        doubleInfosCell.emailContentLabelbis.font = [UIFont fontWithName:@"GothamRounded-Bold" size:13];
        doubleInfosCell.emailContentLabelbis.text = myStatus;
        doubleInfosCell.button1.userInteractionEnabled = NO;
        [doubleInfosCell.button2 addTarget:self action:@selector(deleteContact) forControlEvents:UIControlEventTouchUpInside];
        

        doubleInfosCell.emailTitleLabel.text = @"My Status";
        doubleInfosCell.phoneTitleLabel.text = @"My Contacts";
        doubleInfosCell.emailContentLabel.text = @"You're now a";
        doubleInfosCell.phoneContentLabel.text = @"Block a contact.";
        if([myLocaleString isEqualToString:@"FR"]){
            doubleInfosCell.emailTitleLabel.text = @"Mon Statut";
            doubleInfosCell.phoneTitleLabel.text = @"Mes Contacts";
            doubleInfosCell.emailContentLabel.text = @"Tu es un";
            doubleInfosCell.phoneContentLabel.text = @"Bloquer un contact.";
        }
        
    }
    if(indexPath.row == 2){
        cell = [tableView dequeueReusableCellWithIdentifier:@"ThirdInfosCell" forIndexPath:indexPath];
        InfosCell *thirdInfosCell = (InfosCell *)cell;
        thirdInfosCell.button1.clipsToBounds = YES;
        thirdInfosCell.button2.clipsToBounds = YES;
        thirdInfosCell.button1.layer.cornerRadius = 5;
        thirdInfosCell.button2.layer.cornerRadius = 5;
        thirdInfosCell.emailTitleLabel.font = [UIFont fontWithName:@"GothamRounded-Bold" size:14];
        thirdInfosCell.phoneTitleLabel.font = [UIFont fontWithName:@"GothamRounded-Bold" size:14];
        thirdInfosCell.emailContentLabel.font = [UIFont fontWithName:@"GothamRounded-Light" size:14];
        thirdInfosCell.phoneContentLabel.font = [UIFont fontWithName:@"GothamRounded-Light" size:14];
        thirdInfosCell.button2.userInteractionEnabled = NO;
        [thirdInfosCell.button1 addTarget:self action:@selector(gotoappStore) forControlEvents:UIControlEventTouchUpInside];
        
        thirdInfosCell.emailTitleLabel.text = @"Help us";
        thirdInfosCell.phoneTitleLabel.text = @"Any bug ?";
        thirdInfosCell.emailContentLabel.text = @"Rate us on the app store.";
        thirdInfosCell.phoneContentLabel.text = @"Shake your phone to report a bug;)";
        if([myLocaleString isEqualToString:@"FR"]){
            thirdInfosCell.emailTitleLabel.text = @"Nous aider";
            thirdInfosCell.phoneTitleLabel.text = @"Un bug ?";
            thirdInfosCell.emailContentLabel.text = @"Donne nous une note sur l'app store.";
            thirdInfosCell.phoneContentLabel.text = @"Secoue pour nous signaler un bug;)";
        }
    }

    if (cell == nil) {
        APLLog(@"cell nil");
    }
    //cell = [tableView dequeueReusableCellWithIdentifier:@"InfosCell" forIndexPath:indexPath];
    
    
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}


//----------------the user presses "back" in order to leave the settings----------------------
- (IBAction)backButton:(id)sender {
    APLLog(@"back pressed");
    [self dismissViewControllerAnimated:YES completion:nil];
}

//------------------alertView delegate (first tips for the user)-----------------------------------

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if([alertView.title isEqualToString:my_actionsheet_wanna_help_us]||[alertView.title isEqualToString:my_actionsheet_wanna_help_us_french]){
        if (buttonIndex == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:myVersionInstallUrl]];
        }
    }
    else if ([alertView.title isEqualToString:my_actionsheet_you_are_great]||[alertView.title isEqualToString:my_actionsheet_you_are_great_french]){
        if (buttonIndex == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:my_facebook_page_adress]];
        }
    }
}



@end

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

NSString *username;//global
NSString *hashPassword;//global
bool logIn;//global
NSString *myStatus;//global

NSString *storyboardName;//global

UIColor *theBackgroundColor;//global
UIColor *theKeoOrangeColor;//global

NSString *backgroundImage;//global

CGFloat screenWidth;//global
CGFloat screenHeight;//global

NSString *adresseIp2;//global

UIButton *futureButton;
UIButton *statusButton;
UILabel *futureLabel;
UILabel *infoLabel;

NSTimer *myFutureTimer;

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
    self.parentViewController.view.backgroundColor=[[UIColor alloc] initWithPatternImage:[UIImage imageNamed:backgroundImage]];

    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
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
    if(indexPath.row == 0){
        return NO;
    }
    if(indexPath.row == 4){
        return NO;
    }
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row==0){
        return 133;
        //return 155;
    }
    else{
        return 67;
        //return 82;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    APLLog(@"didselectrowatindexpath");
    if(indexPath.row == 1){
        [self alertAnalyticsAskStatus];
    }
    if(indexPath.row == 2){
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Noooooo"
                              message:@"Why do you want to do this?" delegate:self
                              cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [alert show];
    }
    if(indexPath.row == 3){
        APLLog(@"open website");
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.pictever.com/"]];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


//-----------We fill the tableview-----------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil;
    
    if(indexPath.row == 0){
        cell = [tableView dequeueReusableCellWithIdentifier:@"InfosCell"];
        InfosCell *infosCell = (InfosCell *)cell;
        infosCell.phoneContentLabel.text = myCurrentPhoneNumber;
        infosCell.emailContentLabel.text = username;
    }
    if(indexPath.row == 1){
        cell = [tableView dequeueReusableCellWithIdentifier:@"StatusCell"];
        InfosCell *infosCell = (InfosCell *)cell;
        infosCell.emailTitleLabel.text = myStatus;
    }
    if(indexPath.row == 2){
        cell = [tableView dequeueReusableCellWithIdentifier:@"ContactsCell"];
    }
    if(indexPath.row == 3){
        cell = [tableView dequeueReusableCellWithIdentifier:@"LikeCell"];
    }
    if(indexPath.row == 4){
        cell = [tableView dequeueReusableCellWithIdentifier:@"BugCell"];
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





@end

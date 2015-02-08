//
//  KeoMessages.m
//  Keo
//
//  Created by Gauthier Petetin on 11/06/2014.
//  Copyright (c) 2014 Gauthier Petetin. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////(GO TO APPDELEGATE.M FOR MORE INFO ABOUT THE GLOBAL VARIABLES)/////////////////////////////////

//------Facebook-----------
#import <FacebookSDK/FacebookSDK.h>
#import <QuartzCore/QuartzCore.h>

#import "KeoMessages.h"

//#import "OldBucketRequest.h"
#import "NewBucketRequest.h"
#import "GPSession.h"
#import "GPRequests.h"

#import "myGeneralMethods.h"
#import "myConstants.h"

#import "ShyftSet.h"
#import "ShyftMessage.h"
#import "ShyftCell.h"
#import "PandaCell.h"

#import "PhotoDetail.h"


//---------Amazon-------------
#import <AWSiOSSDKv2/AWSCore.h>
#import <AWSiOSSDKv2/S3.h>
#import <AWSiOSSDKv2/DynamoDB.h>
#import <AWSiOSSDKv2/SQS.h>
#import <AWSiOSSDKv2/SNS.h>
#import <AWSiOSSDKv2/AWSMobileAnalytics.h>



@interface KeoMessages () <UITableViewDataSource, UITableViewDelegate>

@property (assign, nonatomic) CGFloat previousScrollViewYOffset;
@property (assign, nonatomic) CGFloat initialLoadingLabelYOffset;
@property (assign, nonatomic) CGFloat initialSpinnerTopYOffset;
@property (assign, nonatomic) CGFloat initialNavigationBarYOffset;

@end

@implementation KeoMessages

ShyftSet *myShyftSet;


AWSMobileAnalytics* analytics;//global

NSUserDefaults *prefs;

NSString *myUserID;

NSString *adresseIp2;//global

NSString *myLocaleString;
NSString *username;//global
NSString *myStatus;//global
bool logIn;
NSString *hashPassword;//global

NSString* numberOfMessagesInTheFuture;//global

NSString* myVersionInstallUrl;//global

ShyftMessage * theShyftToResend;
NSMutableDictionary *theKeoToResend;
NSIndexPath *theResendIndexPath;

NSMutableArray *resendBox;

//size if the screen
CGFloat screenWidth;//global
CGFloat screenHeight;//global
CGFloat tabBarHeight;//global

NSMutableArray *messagesDataFile;//global
NSString *myCurrentPhotoPath;//global


NSMutableDictionary *importKeoContacts;//global
NSMutableDictionary *importKeoPhotos;//global

float uploadProgress;//global (to upadate the progress bar)

int openingWindow;//global
bool appOpenedOnNotification;//global

NSString *storyboardName;//global

bool firstGlobalOpening;//global


//--------sizes used for the dimensiosn of labels in the tableview cells-------------------
int nameBarHeight1;//local
int nameBarHeight2;//local
int spaceHeight;//local

NSMutableDictionary * selectedLocalDic;//global (message selected by the user to see the photo in full screen)

bool viewDidAppear;

NSMutableArray *vibrateBox;


//-----------colors--------------------------
UIColor *theBackgroundColor;//global
UIColor *theBackgroundColorDarker;//global
UIColor *theKeoOrangeColor;//global
UIColor *thePicteverGreenColor;//global
UIColor *thePicteverYellowColor;//global
UIColor *thePicteverRedColor;//global
UIColor *thePicteverGrayColor;//global
UIColor *lightGrayColor;
UIColor *theFacebookBlueColor;

UIImage *facebookIconImage;
UIImage *resendIconImage;
UIImage *downloadIconImage;


//------------shows the user when the table view is loading new messages------------------
UITapGestureRecognizer *billyTapRecognizer;
UILabel *futureLabel;
UIImageView *myBillyImageView;
UIView *loadingView;
UIActivityIndicatorView *spinner;
//UIActivityIndicatorView *spinnerTop;
UIActivityIndicatorView *loadSpinner;
UIView *hdView;

UILabel *firstInfoLabel;



UITextView *infoTextView;
UILabel* infoBarLabel;
UIButton *okButton;

bool zoomOn;//global
bool reloaded2;
NSTimer *myFutureTimer;
NSTimer *reloadTimer;
NSTimer *reloadTimer2;
NSTimer *reloadTimerOldMessages;
NSTimer *reloadTimerNewMessages;
NSTimer *waitTimer;

NSTimer *messagesLoadedTimer;
UILabel *waitLabel;
UILabel *refreshLabel;

UILabel *resentSuccessfullyLabelK;
UILabel *resentSuccessfullyLabelK2;
UILabel *sentSuccessfullyLabelK;
UILabel *sentSuccessfullyLabelK2;


bool isReloadingTableView;

bool uploadPhotoOnCloudinary;//global
bool downloadPhotoOnAmazon;//global

//-------------informs us all the messages are loaded-------------------
bool messagesLoaded;


UIProgressView *progressView2;

//------------loadbox containing messages for which the photos are not downloaded-------------
NSMutableArray *loadBox;//global
bool isLoadingLoadBox;//global


myTabBarController *myController;

UISwipeGestureRecognizer *swipeRecognizer3;


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
    viewDidAppear = false;
    [super viewDidLoad];
    
    //--------------navigation bar color (code couleur transformé du orangekeo sur
    //http://htmlpreview.github.io/?https://github.com/tparry/Miscellaneous/blob/master/UINavigationBar_UIColor_calculator.html)
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:244/255.0f green:58/255.0f blue:0/255.0f alpha:1.0f];
    self.navigationController.navigationBar.barStyle=UIStatusBarStyleLightContent;
    [self setNeedsStatusBarAppearanceUpdate];//status bar text color
    
    //----------------confirm and cancel buttons----------------------------------
    //UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(cameraPressed:)];
    UIButton *backButtonLabel = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButtonLabel setFrame:CGRectMake(16,9,45,25)];
    backButtonLabel.backgroundColor = [UIColor clearColor];
    [backButtonLabel setTitle:@"Back" forState:UIControlStateNormal];
    backButtonLabel.titleLabel.font = [UIFont fontWithName:@"GothamRounded-Light" size:16.0];
    backButtonLabel.titleLabel.textColor = [UIColor whiteColor];
    backButtonLabel.titleLabel.textAlignment = NSTextAlignmentLeft;
    [backButtonLabel addTarget:self action:@selector(cameraPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButtonLabel];
    
    self.navigationItem.leftBarButtonItem = backItem;
    
    
    NSDictionary *barButtonAppearanceDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                             [[UIColor whiteColor] colorWithAlphaComponent:1.0],
                                             NSForegroundColorAttributeName,
                                             [UIFont fontWithName:@"GothamRounded-Light" size:16.0],
                                             NSFontAttributeName,
                                             nil];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
     setTitleTextAttributes:barButtonAppearanceDict forState:UIControlStateNormal];
    //--------------
    
    
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    myController = (myTabBarController *)[storyboard instantiateViewControllerWithIdentifier:my_storyboard_master_controller];
    
    messagesLoaded = false;
    isReloadingTableView = false;
    
    zoomOn = false;
    reloaded2 = false;
    
    nameBarHeight1 = 60;
    nameBarHeight2 = 50;
    spaceHeight = 2;
    
    vibrateBox = [[NSMutableArray alloc] init];
    
    theKeoToResend = [[NSMutableDictionary alloc] init];
    theResendIndexPath = [[NSIndexPath alloc] init];
    
    lightGrayColor = [UIColor colorWithRed:240/255.0f green:245/255.0f blue:248/255.0f alpha:1.0f];
    theFacebookBlueColor = [myGeneralMethods getColorFromHexString:@"3b579d"];
    
    facebookIconImage = [myGeneralMethods scaleImage:[UIImage imageNamed:@"facebook_small.png"] toWidth:35];
    resendIconImage = [myGeneralMethods scaleImage:[UIImage imageNamed:@"resend_small.png"] toWidth:35];
    downloadIconImage = [myGeneralMethods scaleImage:[UIImage imageNamed:@"download_small.png"] toWidth:35];
    
    //[self.tableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    //----------if the gallery contains messages----------------------------
    if([messagesDataFile count] > 0){
        APLLog(@"%d messages in the gallery",[messagesDataFile count]);
        //self.view.backgroundColor = [myGeneralMethods getColorFromHexString:@"e4e1e0"];
        self.view.backgroundColor = [UIColor whiteColor];
    }
    //----------if the gallery is empty----------------------------
    else{
        APLLog(@"No messages in the gallery");
        //self.view.backgroundColor = [myGeneralMethods getColorFromHexString:@"e4e1e0"];
        self.view.backgroundColor = [UIColor whiteColor];
    }
    
    //keoTableView.frame = CGRectMake(0, 65, screenWidth, screenHeight-65-tabBarHeight);
    
    if(firstGlobalOpening){
        APLLog(@"FIRST KEO OPENING");
        isLoadingLoadBox = false;
        
        if(appOpenedOnNotification){
            [self.tabBarController setSelectedIndex:2];
            appOpenedOnNotification = false;
        }
        else{
            [self.tabBarController setSelectedIndex:1]; //load Keo at first opening
        }
        
        [[NSNotificationCenter defaultCenter]removeObserver:self];
        //[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(loadUnloadImages) name:@"loadPhotos" object: nil];
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(hideProgressBar2) name:@"hideProgressBars" object: nil];
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(updateUploadProgress2:) name:@"uploadProgress" object: nil];
        
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(vibrateForNewShyft:) name:@"vibrateForNewShyft" object: nil];
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(downloadPhotoOnNewBucket:) name:@"downloadPhotoOnNewBucket" object: nil];
        
        
        //------------initially loads ten messages for the tableview-------------------
        //[self reloadTheWholeTableViewFirstTime];
        [NSThread detachNewThreadSelector:@selector(firstLoad) toTarget:self withObject:nil];
        
        //------------progressview to inform the user he is currently still uploading a photo (in the TakePicture2 view)
        progressView2 = [[UIProgressView alloc] init];
        progressView2.frame = CGRectMake(0,64,screenWidth,2);
        [progressView2 setProgressTintColor:thePicteverGreenColor];
        [progressView2 setUserInteractionEnabled:NO];
        [progressView2 setProgressViewStyle:UIProgressViewStyleBar];
        [progressView2 setTrackTintColor:[UIColor clearColor]];
    }
    else{
        
    }
    
    //----------------show the user he is currently downloading an image-------------------
    //_backgroundLoadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.04*screenWidth, 20, 100, 30)];
    int widthOfLoadingLabel = 100;
    _backgroundLoadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.5*screenWidth-0.5*widthOfLoadingLabel, tabBarHeight+20, widthOfLoadingLabel, 30)];
    _backgroundLoadingLabel.backgroundColor = thePicteverYellowColor;
    _backgroundLoadingLabel.clipsToBounds = YES;
    _backgroundLoadingLabel.layer.cornerRadius = 4;
    _backgroundLoadingLabel.alpha = 0.9;
    _backgroundLoadingLabel.hidden = YES;
    [self.parentViewController.view addSubview:_backgroundLoadingLabel];
    
    //_loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.14*screenWidth, 20, 100, 40)];
    _loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.5*screenWidth-0.5*widthOfLoadingLabel+35, tabBarHeight+20, widthOfLoadingLabel-35, 30)];
    _loadingLabel.backgroundColor = [UIColor clearColor];
    _loadingLabel.textColor = [UIColor whiteColor];
    //[_loadingLabel setFont:[UIFont systemFontOfSize:12]];
    [_loadingLabel setFont:[UIFont fontWithName:@"GothamRounded-Light" size:14]];
    self.initialLoadingLabelYOffset = _loadingLabel.frame.origin.y;
    [self.parentViewController.view addSubview:_loadingLabel];
    
    _spinnerTop = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    //_spinnerTop.center = CGPointMake(0.075*screenWidth, 40);
    _spinnerTop.center = CGPointMake(0.5*screenWidth-0.5*widthOfLoadingLabel+17, 83);
    _spinnerTop.color = [UIColor whiteColor];
    _spinnerTop.hidesWhenStopped = YES;
    self.initialSpinnerTopYOffset = _spinnerTop.frame.origin.y;
    [self.parentViewController.view addSubview:_spinnerTop];
    
    
    
    self.initialNavigationBarYOffset = self.navigationController.navigationBar.frame.origin.y;
    
    //------------------show the user he is currently refreshing the tableview--------------------
    /*refreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.56*screenWidth, 5, 100, 40)];
     refreshLabel.text = @"";
     refreshLabel.backgroundColor = [UIColor clearColor];
     [refreshLabel setFont:[UIFont systemFontOfSize:12]];
     
     //voir si pas trop lent
     spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
     spinner.center = CGPointMake(0.5*screenWidth, 25);
     spinner.color = [UIColor blackColor];
     spinner.hidesWhenStopped = YES;
     [self.view addSubview:spinner];*/
    
    CGFloat navBarHeight = self.navigationController.navigationBar.frame.size.height+0.04*screenHeight;
    
    _loadTbvLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,navBarHeight,screenWidth,screenHeight-navBarHeight)];
    _loadTbvLabel.text = @"";
    _loadTbvLabel.backgroundColor = [UIColor whiteColor];
    _loadTbvLabel.alpha = 0.85;
    [_loadTbvLabel setFont:[UIFont fontWithName:@"GothamRounded-Light" size:14]];
    
    _loadTbvSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _loadTbvSpinner.center = CGPointMake(0.5*screenWidth, 0.5*screenHeight-navBarHeight);
    _loadTbvSpinner.color = [UIColor darkGrayColor];
    _loadTbvSpinner.hidesWhenStopped = YES;
    [_loadTbvLabel addSubview:_loadTbvSpinner];
    
    
    //------------Create two swipe recognizers (one for left/right direction and one for top/down direction)----------------
    swipeRecognizer3 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(respondToSwipeGesture3:)];
    [swipeRecognizer3 setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.view addGestureRecognizer:swipeRecognizer3];
    
    
    [self initHeaderView];
    
    [self initPopupViews];
    
    
    int margeWidth = 20;
    firstInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(margeWidth, 170, screenWidth-2*margeWidth, 100)];
    firstInfoLabel.text = @"This is where you will receive your future messages!";
    if([myLocaleString isEqualToString:@"FR"]){
        firstInfoLabel.text = @"C'est ici qu'arriveront tes futurs messages!";
    }
    firstInfoLabel.font = [UIFont fontWithName:@"GothamRounded-Bold" size:18];
    firstInfoLabel.numberOfLines=0;
    firstInfoLabel.lineBreakMode = NSLineBreakByWordWrapping;
    firstInfoLabel.textAlignment = NSTextAlignmentCenter;
    firstInfoLabel.textColor = thePicteverGrayColor;
    
    if([self.tableView numberOfRowsInSection:0]>0){
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    
    [self.tableView reloadData];
    

    APLLog(@"KeoMessages didload");
}

-(void)initPopupViews{
    resentSuccessfullyLabelK = [[UILabel alloc] initWithFrame:CGRectMake(0, -30, screenWidth, 30)];
    resentSuccessfullyLabelK.backgroundColor = thePicteverGreenColor;
    resentSuccessfullyLabelK.textColor = [UIColor whiteColor];
    resentSuccessfullyLabelK.font = [UIFont fontWithName:@"GothamRounded-Bold" size:18];
    resentSuccessfullyLabelK.textAlignment = NSTextAlignmentCenter;
    resentSuccessfullyLabelK.alpha = 1;
    resentSuccessfullyLabelK.text = @"Message resent successfully!";
    if([myLocaleString isEqualToString:@"FR"]){
        resentSuccessfullyLabelK.text = @"Message renvoyé!";
    }
    
    resentSuccessfullyLabelK2 = [[UILabel alloc] initWithFrame:CGRectMake(0, -48, screenWidth, 18)];
    resentSuccessfullyLabelK2.backgroundColor = thePicteverGreenColor;
    resentSuccessfullyLabelK2.alpha = 1;
    
    [self.parentViewController.view addSubview:resentSuccessfullyLabelK2];
    [self.parentViewController.view addSubview:resentSuccessfullyLabelK];
    
    sentSuccessfullyLabelK = [[UILabel alloc] initWithFrame:CGRectMake(0, -30, screenWidth, 30)];
    sentSuccessfullyLabelK.backgroundColor = thePicteverYellowColor;
    sentSuccessfullyLabelK.textColor = [UIColor whiteColor];
    sentSuccessfullyLabelK.font = [UIFont fontWithName:@"GothamRounded-Bold" size:18];
    sentSuccessfullyLabelK.textAlignment = NSTextAlignmentCenter;
    sentSuccessfullyLabelK.alpha = 1;
    sentSuccessfullyLabelK.text = @"Message sent successfully!";
    if([myLocaleString isEqualToString:@"FR"]){
        sentSuccessfullyLabelK.text = @"Message envoyé!";
    }
    
    sentSuccessfullyLabelK2 = [[UILabel alloc] initWithFrame:CGRectMake(0, -48, screenWidth, 18)];
    sentSuccessfullyLabelK2.backgroundColor = thePicteverYellowColor;
    sentSuccessfullyLabelK2.alpha = 1;
    
    [self.parentViewController.view addSubview:sentSuccessfullyLabelK2];
    [self.parentViewController.view addSubview:sentSuccessfullyLabelK];
}

-(void)initHeaderView{
    //----------------subview to show the refresh spinner and label----------------------
    hdView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 100)];//50 before Billy
    //hdView.backgroundColor = [myGeneralMethods getColorFromHexString:@"e4e1e0"];
    hdView.backgroundColor = [UIColor whiteColor];
    
    
    //---------------add Billy with flag-----------------------------
    myBillyImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.06*screenWidth, 0.43*hdView.frame.size.height, screenWidth*0.875, 0.6*hdView.frame.size.height)];
    NSString *robotImageName = @"robot_plein_small.png";
    if([myLocaleString isEqualToString:@"FR"]){
        robotImageName = @"robot_plein_french_small.png";
    }
    myBillyImageView.image = [myGeneralMethods scaleImage3:[UIImage imageNamed:robotImageName] withFactor:4];
    myBillyImageView.contentMode = UIViewContentModeCenter;
    myBillyImageView.backgroundColor = [UIColor clearColor];
    
    billyTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(billyTapped)];
    billyTapRecognizer.numberOfTapsRequired = 1;
    [myBillyImageView addGestureRecognizer:billyTapRecognizer];
    myBillyImageView.userInteractionEnabled = YES;
    
    futureLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.51*screenWidth, 0.51
                                                            *hdView.frame.size.height, 0.39*screenWidth, 0.45*hdView.frame.size.height)];
    futureLabel.textAlignment = NSTextAlignmentCenter;
    futureLabel.font = [UIFont fontWithName:@"GothamRounded-Bold" size:28];
    futureLabel.textColor = [UIColor whiteColor];
    //futureLabel.backgroundColor = [UIColor yellowColor];
    
    [hdView addSubview:spinner];
    [hdView addSubview:refreshLabel];
    [hdView addSubview:myBillyImageView];
    [hdView addSubview:futureLabel];
    self.tableView.tableHeaderView = hdView;
}

-(IBAction)respondToSwipeGesture3:(UISwipeGestureRecognizer *)recognizer{
    APLLog(@"respondToSwipeGesture3");
    [self animateNavBarTo:20 withFixedAlpha:true];
}


//-----------------------------animation when message is sent succesfully--------------------------------

-(void)showAnimateMessageSentSuccessfullyK{
    NSLog(@"showAnimateMessageSentSuccessfullyK");
    
    [self.parentViewController.view bringSubviewToFront:sentSuccessfullyLabelK];
    [self.parentViewController.view bringSubviewToFront:sentSuccessfullyLabelK2];
    
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         sentSuccessfullyLabelK.frame = CGRectMake(0, 18, screenWidth, 30);
                         sentSuccessfullyLabelK2.frame = CGRectMake(0, 0, screenWidth, 18);
                     }
                     completion:^(BOOL completed){
                         [UIView animateWithDuration:0.5 delay:1.0 options:UIViewAnimationOptionCurveLinear
                                          animations:^{
                                              sentSuccessfullyLabelK.frame = CGRectMake(0, -30, screenWidth, 30);
                                              sentSuccessfullyLabelK2.frame = CGRectMake(0, -48, screenWidth, 18);
                                          }
                                          completion:nil];
                     }];
}

//-----------------------------animation when message is resent succesfully--------------------------------

-(void)showAnimateMessageResentSuccessfullyK{
    APLLog(@"showAnimateMessageResentSuccessfullyK");
    [self initPopupViews];
    
    [self.view bringSubviewToFront:resentSuccessfullyLabelK];
    [self.view bringSubviewToFront:resentSuccessfullyLabelK2];
    
    dispatch_async(dispatch_get_main_queue(), ^{
    
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             resentSuccessfullyLabelK.frame = CGRectMake(0, 18, screenWidth, 30);
                             resentSuccessfullyLabelK2.frame = CGRectMake(0, 0, screenWidth, 18);
                         }
                         completion:^(BOOL completed){
                             [UIView animateWithDuration:0.5 delay:1.0 options:UIViewAnimationOptionCurveLinear
                                              animations:^{
                                                  resentSuccessfullyLabelK.frame = CGRectMake(0, -30, screenWidth, 30);
                                                  resentSuccessfullyLabelK2.frame = CGRectMake(0, -48, screenWidth, 18);
                                              }
                                              completion:nil];
                         }];
        
    });
    
}


//----------------tap billy to ask number of future messges-------------------------------
-(void)billyTapped{
    APLLog(@"Billy tapped: %@",numberOfMessagesInTheFuture);
    
    [self initHeaderView];
    
    billyTapRecognizer.enabled = NO;
    
    futureLabel.text = [NSString stringWithFormat:@"%@!",numberOfMessagesInTheFuture];
    myBillyImageView.image = [myGeneralMethods scaleImage3:[UIImage imageNamed:@"robot_small.png"] withFactor:4];
    
    if(![GPRequests connected]){
        //the user will have only 1.3 seconds to see the info
        myFutureTimer = [NSTimer scheduledTimerWithTimeInterval: 1.3 target:self selector: @selector(hideFutureMessages) userInfo:nil repeats: NO];
    }
    else{
        [[[GPSession alloc] init] askNumberOfMessagesInTheFuture:self];
    }
}

-(void)showFutureMessages:(NSNotification *)notification{
    APLLog(@"show future messages: %@",[notification.userInfo description]);
    NSMutableDictionary * dicFromNotif = [notification.userInfo mutableCopy];
    NSString *newNumber;
    if([dicFromNotif objectForKey:@"numberOfMessagesInTheFuture"]){
        newNumber = [dicFromNotif objectForKey:@"numberOfMessagesInTheFuture"];
    }
    else{
        newNumber = @"";
    }
    
    APLLog(@"futurelabeltext before: %@",futureLabel.text);
    futureLabel.text = [NSString stringWithFormat:@"%@!",newNumber];
    APLLog(@"futurelabeltext after: %@",futureLabel.text);
    
    myFutureTimer = [NSTimer scheduledTimerWithTimeInterval: 1.3 target:self selector: @selector(hideFutureMessages) userInfo:nil repeats: NO];
    
    [self alertAnalyticsFutureMessages:newNumber];
}

-(void)hideFutureMessages{
    APLLog(@"hide future messages");
    billyTapRecognizer.enabled = YES;
    futureLabel.text = @"";
    NSString *robotImageName = @"robot_plein_small.png";
    if([myLocaleString isEqualToString:@"FR"]){
        robotImageName = @"robot_plein_french_small.png";
    }
    myBillyImageView.image = [myGeneralMethods scaleImage3:[UIImage imageNamed:robotImageName] withFactor:4];
}


//----------------we inform amazon analytics when the user asks for the number of messages he will receive (for our statistics)------------
-(void)alertAnalyticsFutureMessages:(NSString *) numberr{
    APLLog(@"alertAnalytics future message pressed");
    id<AWSMobileAnalyticsEventClient> eventClient = analytics.eventClient;
    id<AWSMobileAnalyticsEvent> levelEvent = [eventClient createEventWithEventType:@"iosGetNumberOfFutureMessages"];
    NSNumberFormatter * fff = [[NSNumberFormatter alloc] init];
    [fff setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber * myNumber = [fff numberFromString:numberr];
    [levelEvent addMetric:myNumber forKey:@"number_of_future_messages"];
    APLLog(@"levelevent:%@",[[levelEvent allMetrics] description]);
    [eventClient recordEvent:levelEvent];
    [eventClient submitEvents];
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    /*
     if(!zoomOn){
     _shownIndexes = [NSMutableSet set];
     [self.tableView reloadData];
     }*/
    [firstInfoLabel removeFromSuperview];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //------------show all the navigationbar barbutton items-------------------
    [self updateBarButtonItems:1.0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAnimateMessageSentSuccessfullyK) name:my_notif_messageSentSuccessfully_name object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAnimateMessageResentSuccessfullyK) name:my_notif_messageResentSuccessfully_name object:nil];
    
    if([messagesDataFile count]==0){
        [self.view addSubview:firstInfoLabel];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //------------------replace the tabbar in case it is not--------------
    /*CGRect frame2 = self.tabBarController.tabBar.frame;
    CGFloat height2 = frame2.size.height;
    
    // zero duration means no animation
    CGFloat duration = (animated)? 0.3 : 0.0;
    [UIView animateWithDuration:duration animations:^{
        self.tabBarController.tabBar.frame = CGRectMake(0, screenHeight-height2, frame2.size.width, frame2.size.height);
    }];*/
    if([self tabBarIsVisible]){
        [self setTabBarVisible:NO animated:YES];
    }
    
    billyTapRecognizer.enabled = YES;

    
    //------------progressview to inform the user he is currently still uploading a photo (in the TakePicture2 view)
    [progressView2 setProgress:uploadProgress animated:NO];
    if(uploadPhotoOnCloudinary){
        APLLog(@"showProgressview3: %f",uploadProgress);
        progressView2.hidden = NO;
    }
    else{
        APLLog(@"hideProgressView3");
        progressView2.hidden = YES;
    }
    [self.navigationController.view addSubview:progressView2];
    
    appOpenedOnNotification = false;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    viewDidAppear = true;
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(startLoadingAnimation) name:@"startLoadingAnimation" object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(stopLoadingAnimation) name:@"stopLoadingAnimation" object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(insertNewRow:) name:@"insertNewRow" object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reloadDataT) name:@"reloadData" object: nil];
    //[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(vibrateForNewShyft:) name:@"vibrateForNewShyft" object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(showFutureMessages:) name:@"showFutureMessages" object: nil];
    
    if(downloadPhotoOnAmazon){
        [self startLoadingAnimation];
        APLLog(@"download already started");
    }
    else{
        [self stopLoadingAnimation];
        APLLog(@"no download started for the moment");
    }
    
    APLLog(@"KeoMessages didappear");
    
    if(![myShyftSet isLoaded]){
        [self showLoadTbvLabel];
    }
    
    
    //------------show all the navigationbar barbutton items-------------------
    [self updateOtherViewsToFrame:self.navigationController.navigationBar.frame withAlpha:1.0];
    
    
    
    //----------------retry to resend failed resent messages----------------
    if(resendBox){
        if([resendBox count]>0){
            [[[GPSession alloc] init] resendRequest:[resendBox objectAtIndex:0] for:self];
        }
    }
    
}



//----------if more than 10 messages are loaded in the tableview, remove them to avoid memory errors---------------
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"startLoadingAnimation" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"stopLoadingAnimation" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"insertNewRow" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"reloadData" object:nil];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"vibrateForNewShyft" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"showFutureMessages" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:my_notif_messageSentSuccessfully_name object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:my_notif_messageResentSuccessfully_name object:nil];
}

-(void)reloadDataT{
    [self.tableView reloadData];
}

-(void)showLoadTbvLabel{
    [_loadTbvSpinner startAnimating];
    [self.navigationController.view addSubview:_loadTbvLabel];
}

-(void)hideLoadTbvLabel{
    [_loadTbvSpinner stopAnimating];
    [_loadTbvLabel removeFromSuperview];
}


-(bool)galleryIsVisible{
    if (self.isViewLoaded && self.view.window) {
        // viewController is visible
        return true;
    }
    return false;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)insertNewRow:(NSNotification *)notification{
    APLLog(@"insertNewRow: %@",[notification.userInfo description]);
    [firstInfoLabel removeFromSuperview];
    
    NSMutableDictionary *newPhotoMessage = [notification.userInfo mutableCopy];
    ShyftMessage *shyftToInsert = [[ShyftMessage alloc] initWithShyft:newPhotoMessage];
    if(![myShyftSet containsShyft:shyftToInsert]){
        
        [self.tableView beginUpdates];
        
        [myShyftSet insertNewShyft:shyftToInsert];
        
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [self.tableView endUpdates];
        
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}



//------------alert the user he received a new message AND the photo has been downloaded----------------
-(void)vibrateForNewShyft:(NSNotification *)notification{
    APLLog(@"vibrateForNewShyft1: %@",[notification.userInfo description]);
    NSMutableDictionary *newPhotoMessage2 = [notification.userInfo mutableCopy];

    if([myShyftSet isLoaded]){
        [self vibrateNow:newPhotoMessage2];
    }
    else{
        [self vibrateLater:newPhotoMessage2];
    }
    
}

-(void)vibrateNow:(NSMutableDictionary *)newPhotoMessage{
    [firstInfoLabel removeFromSuperview];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    KeoMessages * vck = (KeoMessages *)[storyboard instantiateViewControllerWithIdentifier:my_storyboard_timeline_Name];
    // viewController is visible
    if([vck.tableView numberOfRowsInSection:0]>0){
        APLLog(@"not first message");
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"insertNewRow" object:self userInfo:newPhotoMessage];
        });
    }
    else{//----------case of the first message
        APLLog(@"first message");
        dispatch_async(dispatch_get_main_queue(), ^{
            ShyftMessage *shyftToInsert = [[ShyftMessage alloc] initWithShyft:newPhotoMessage];
            if(![myShyftSet containsShyft:shyftToInsert]){
                [myShyftSet insertNewShyft:shyftToInsert];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadData" object:self userInfo:newPhotoMessage];
                });
            }
        });
    }
    
    APLLog(@"vibrate for new shyft 2 (now): %@", [newPhotoMessage description]);
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    [[NSNotificationCenter defaultCenter] postNotificationName:my_notif_showBilly_name object:nil];
    
    [[[GPSession alloc] init] increaseReceiveTipCounter:self];
    
}

-(void)vibrateLater:(NSMutableDictionary *)newPhotoMessage{
    [vibrateBox insertObject:newPhotoMessage atIndex:[vibrateBox count]];
}

-(void)hideProgressBar2{
    APLLog(@"hideProgressBar2");
    progressView2.hidden = YES;
}

//------------progressview to inform the user he is currently still uploading a photo (in the TakePicture2 view)-------------
-(void)updateUploadProgress2:(NSNumber *)number{
    APLLog(@"updateUploadProgress2: %f",uploadProgress);
    
    [progressView2 setProgress:uploadProgress animated:YES];
}

//----------------show the user he is currently downloading an image-------------------
-(void)addLoadingSpinner{
    APLLog(@"keotableViewheight: %d",self.view.frame.size.height);
    loadingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, self.view.frame.size.height)];
    loadingView.backgroundColor = [UIColor clearColor];
    loadingView.tag = 7;
    loadSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    loadSpinner.center = CGPointMake(0.5*screenWidth, loadingView.frame.size.height - 130);
    loadSpinner.color = [UIColor whiteColor];
    loadSpinner.hidesWhenStopped = YES;
    [loadSpinner startAnimating];
    [loadingView addSubview:loadSpinner];
    [self.navigationController.view addSubview:loadingView];
}

-(void)removeLoadingSpinner{
    APLLog(@"removeLoadingSpinner");
    [loadSpinner stopAnimating];
    [[self.navigationController.view viewWithTag:7] removeFromSuperview];
}


//--------------------look in messagesdatafile (contains all the messages) if some of them didn't download the photo----------------------
//----------------------------if yes put them in the loadbox and try to download the photos-----------------------------------------------


-(void)loadUnloadImages{
    if(!isLoadingLoadBox){
        loadBox = [[NSMutableArray alloc] init];
        for(NSMutableDictionary *loadDic in [messagesDataFile mutableCopy]){
            if([loadDic objectForKey:my_photo_Key]){
                if([[loadDic objectForKey:my_photo_Key] isEqualToString:image_not_downloaded_string]||[[loadDic objectForKey:my_loaded_Key] isEqualToString:@"no"]){
                    if(![[loadDic objectForKey:my_loaded_Key] isEqualToString:my_inprogress_string]){
                        if(![loadBox containsObject:loadDic]){
                            [loadBox insertObject:loadDic atIndex:0];
                            [loadDic setObject:my_inprogress_string forKey:my_loaded_Key];// in_progress
                        }
                    }
                }
                else{
                }
            }
        }
        if([loadBox count] > 0){
            APLLog(@"loadBox not empty: %@", [loadBox description]);
            APLLog(@"loadbox start loading %d messages.",[loadBox count]);
            for(NSMutableDictionary *unloadedMessage in [loadBox mutableCopy]){
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    APLLog(@"send notif startLoadingAnimation: %@", [unloadedMessage description]);
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"startLoadingAnimation" object: nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"downloadPhotoOnNewBucket" object:self userInfo:[unloadedMessage mutableCopy]];
                });
                
            }
        }
        else{
            APLLog(@"Empty loadbox");
        }
    }
}



//------------animations------------
-(void)startLoadingAnimation{
    APLLog(@"startLoadingAnimation");
    [_spinnerTop startAnimating];
    _loadingLabel.text = @"loading..";
    _backgroundLoadingLabel.hidden = NO;
}

-(void)stopLoadingAnimation{
    APLLog(@"stopLoadingAnimation");
    [_spinnerTop stopAnimating];
    _loadingLabel.text = @"";
    _backgroundLoadingLabel.hidden = YES;
}

-(void)emptyVibrateBox{
    if([vibrateBox count]>0){
        for(NSMutableDictionary *newDic in [vibrateBox mutableCopy]){
            if(newDic != nil){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"vibrateForNewShyft" object:self userInfo:newDic];
                });
                [vibrateBox removeObjectAtIndex:[vibrateBox indexOfObject:newDic]];
            }
        }
    }
}



//------------prepare the array ShyftSet which will feed the tableview -------------------------
//-------------(we prepare it from messagesdatafile which contains all the messages)---------------------
-(void)reloadTheWholeTableViewFirstTime{
    APLLog(@"RELOAD THE TABLEVIEW");
    if(!isReloadingTableView){
        
        isReloadingTableView = true;
        messagesDataFile = [KeoMessages bubbleSort:messagesDataFile];
        NSMutableArray *messagesDataFileCopy2 = [messagesDataFile mutableCopy];
        ShyftSet *replacementShyftSet = [[ShyftSet alloc] initWithName:@"principalShyftSet" shyftsData:messagesDataFileCopy2];
        
        myShyftSet = replacementShyftSet;
        
        isReloadingTableView = false;
    }
    
    //---------------hide the loading view--------------
    APLLog(@"Hide the loading wiew");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideLoadTbvLabel];
        [myShyftSet setLoaded];
        [self emptyVibrateBox];
    });
    APLLog(@"everything reloaded");
}

-(void)firstLoad{
    APLLog(@"firstLoad");
    [self reloadTheWholeTableViewFirstTime];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //------------show the loaded tableview---------------
        
        [self.tableView reloadData];
        APLLog(@"tableview reloaded");
        if([self.tableView numberOfSections] > 0){
            if([self.tableView numberOfRowsInSection:0]>0){
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            }
        }
    });
}



//----------------------find image in the memory of the app------------------------
-(UIImage *) getImageFromURL:(NSString *)fileURL {
    UIImage * result;
    
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
    result = [UIImage imageWithData:data];
    
    return result;
}


//--------------------------TableView-------------------------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    APLLog(@"numberOfRowsInSection: %d", [myShyftSet size]);
    if([myShyftSet size] > 0){
        return [myShyftSet size]+1;
    }
    else{
        return 0;
    }
}


//-------------the photo is selected to be put in full screen -----------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if(indexPath.row < [myShyftSet size]){
        
    }
}

-(void)showInfoLabelForPict:(ShyftMessage *)pictToDetail{
    [self okButtonPressed];
    
    NSString *stringForTextView = @"From:\n";
    if(![pictToDetail.from_facebook_name isEqualToString:@""]){
        stringForTextView = [NSString stringWithFormat:@"%@-%@\n",stringForTextView,pictToDetail.from_facebook_name];
    }
    if(![pictToDetail.from_email isEqualToString:@""]){
        stringForTextView = [NSString stringWithFormat:@"%@-%@\n",stringForTextView,pictToDetail.from_email];
    }
    if(![pictToDetail.from_numero isEqualToString:@""]){
        stringForTextView = [NSString stringWithFormat:@"%@-%@\n",stringForTextView,pictToDetail.from_numero];
    }
    stringForTextView = [stringForTextView stringByAppendingString:@"\nSent:\n"];
    if(![pictToDetail.created_at isEqualToString:@""]){
        NSDate *sentRealDate = [NSDate dateWithTimeIntervalSince1970:([pictToDetail.created_at doubleValue])];
        stringForTextView = [NSString stringWithFormat:@"%@-%@\n",stringForTextView,[myGeneralMethods getStringToPrint:sentRealDate]];
    }
    stringForTextView = [stringForTextView stringByAppendingString:@"\nReceived:\n"];
    if(![pictToDetail.received_at isEqualToString:@""]){
        NSDate *receivedRealDate = [NSDate dateWithTimeIntervalSince1970:([pictToDetail.received_at doubleValue])];
        stringForTextView = [NSString stringWithFormat:@"%@-%@\n\n",stringForTextView,[myGeneralMethods getStringToPrint:receivedRealDate]];
    }
    
    int textViewWidth = screenWidth-50;
    int textViewHeight = 300;
    int barMarge = 10;
    int bottomPlaceHeight = 50;
    int okButtonSize = 40;
    CGRect initialPointRect = CGRectMake(0, screenHeight, 0, 0);
    CGRect infoTextViewFrame = CGRectMake(0.5*(screenWidth-textViewWidth), 100, textViewWidth, textViewHeight);
    CGRect infoBarLabelFrame = CGRectMake(infoTextViewFrame.origin.x+barMarge, infoTextViewFrame.origin.y+infoTextViewFrame.size.height-bottomPlaceHeight, infoTextViewFrame.size.width-2*barMarge, 1);
    CGRect okButtonFrame = CGRectMake(infoBarLabelFrame.origin.x, infoTextViewFrame.origin.y+infoTextViewFrame.size.height-bottomPlaceHeight+0.5*(bottomPlaceHeight-okButtonSize), infoBarLabelFrame.size.width, okButtonSize);
    
    infoTextView = [[UITextView alloc] initWithFrame:initialPointRect];
    [infoTextView setEditable:NO];
    [infoTextView setScrollEnabled:NO];
    infoTextView.backgroundColor = thePicteverGreenColor;
    infoTextView.layer.masksToBounds = YES;
    infoTextView.layer.cornerRadius = 8;
    infoTextView.textColor = [UIColor whiteColor];
    infoTextView.font = [UIFont fontWithName:@"GothamRounded-Bold" size:16];
    infoTextView.alpha=0.9;
    infoTextView.text = stringForTextView;
    
    infoBarLabel = [[UILabel alloc] initWithFrame:initialPointRect];
    infoBarLabel.backgroundColor = [UIColor whiteColor];
    
    okButton = [[UIButton alloc] initWithFrame:initialPointRect];
    okButton.backgroundColor = [UIColor clearColor];
    okButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [okButton setTitle:@"Ok" forState:UIControlStateNormal];
    okButton.titleLabel.textColor = [UIColor whiteColor];
    okButton.titleLabel.font = [UIFont fontWithName:@"GothamRounded-Bold" size:18];
    [okButton addTarget:self action:@selector(okButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [self.parentViewController.view addSubview:infoTextView];
    [self.parentViewController.view addSubview:infoBarLabel];
    [self.parentViewController.view addSubview:okButton];
    
    [UIView animateWithDuration:0.1
                     animations: ^{
                         [infoTextView setFrame:infoTextViewFrame];
                         [infoBarLabel setFrame:infoBarLabelFrame];
                         [okButton setFrame:okButtonFrame];
                     }
     
                     completion:^(BOOL finished) {
                         if (finished) {
                             
                         }
                     }];
}

-(void)okButtonPressed{
    [infoTextView removeFromSuperview];
    [infoBarLabel removeFromSuperview];
    [okButton removeFromSuperview];
}

- (IBAction)detailPressed:(id)sender {
    APLLog(@"Detail pressed");
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    if(indexPath.row < [myShyftSet size]){
        ShyftMessage *thePictToDetail = [myShyftSet getShyftAtIndex:indexPath.row];
        if(thePictToDetail){
            [self showInfoLabelForPict:thePictToDetail];
        }
    }
}

- (IBAction)imagePressed:(id)sender {//-----------user wants to zoom image-------
    APLLog(@"image pressed");
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    if(indexPath.row < [myShyftSet size]){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
        PhotoDetail * vc = (PhotoDetail *)[storyboard instantiateViewControllerWithIdentifier:@"PhotoDetail"];
        vc.shyftToDetail = [myShyftSet getShyftAtIndex:indexPath.row];
        if(vc.shyftToDetail != nil){
            zoomOn = true;
            [self presentViewController:vc animated:NO completion:nil];
        }
    }
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row < [myShyftSet size]){
        UITableViewCell *cellS = [tableView cellForRowAtIndexPath:indexPath];
        ShyftCell *shyftCellS = (ShyftCell *)cellS;
        [shyftCellS.imageButton setUserInteractionEnabled:NO];
    }
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row < [myShyftSet size]){
        UITableViewCell *cellS = [tableView cellForRowAtIndexPath:indexPath];
        ShyftCell *shyftCellS = (ShyftCell *)cellS;
        [shyftCellS.imageButton setUserInteractionEnabled:YES];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    APLLog(@"cellForRowAtIndexPath: %d", indexPath.row);
    // Create the cell (based on prototype)
    UITableViewCell *cell = nil;
    
    if(indexPath.row < [myShyftSet size]){
        static NSString* CellIdentifier1 = @"ShyftCell";
        ShyftMessage *shyftForCell = [myShyftSet getShyftAtIndex:indexPath.row];
        
        // Configure the cell
        APLLog(@"shyftForCell: %@", [shyftForCell getDescription]);
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1 forIndexPath:indexPath];
        
        ShyftCell *shyftCell = (ShyftCell *)cell;
        
        
        [shyftCell.nameLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:16]];
        [shyftCell.periodLabel setFont:[UIFont fontWithName:@"GothamRounded-Light" size:12]];
        //shyftCell.periodLabel.textColor = shyftForCell.color;
        //shyftCell.nameLabel.textColor = shyftForCell.color;
        shyftCell.nameLabel.textColor = theKeoOrangeColor;
        
        //------------------sender name-------------------------------------
        if(![shyftForCell.fullName isEqualToString:@""]){
            shyftCell.nameLabel.text = shyftForCell.fullName;
            shyftCell.emailLabel.text = @"";
        }
        else{
            shyftCell.nameLabel.text = shyftForCell.from_numero;
            //shyftCell.emailLabel.text = shyftForCell.from_email;
            shyftCell.emailLabel.text = @"";
        }
        
        
        //--------------------in 3 days, in 3 months, in a year--------------------------
        if(shyftForCell.receive_label){

            NSDate *realDate = [NSDate dateWithTimeIntervalSince1970:([shyftForCell.created_at doubleValue])];
            shyftCell.periodLabel.text = [myGeneralMethods getStringToPrint2:realDate];
        }
        
        //------------------PHOTO----------------------------
        shyftCell.bigImageView.backgroundColor = [UIColor blackColor];
        shyftCell.bigImageView.layer.cornerRadius = 10;
        shyftCell.bigImageView.layer.masksToBounds = YES;
        shyftCell.bigImageView.image = shyftForCell.croppedImage;
        
        //------------------text if textmessage----------------
        shyftCell.messageLabel.font = [UIFont fontWithName:@"GothamRounded-Bold" size:20];
        if ([shyftForCell isTextMessage]) {
            
            shyftCell.messageLabel.text = shyftForCell.message;
            shyftCell.messageLabel.textColor = [UIColor whiteColor];
        }
        else{
            shyftCell.messageLabel.text = @"";
        }
        
        //-------------------sender profile picture---------------------
        shyftCell.userProfileImageView.layer.cornerRadius = 3;
        shyftCell.userProfileImageView.layer.masksToBounds = YES;
        shyftCell.userProfileImageView.backgroundColor = thePicteverGrayColor;
        shyftCell.userProfileImageView.contentMode = UIViewContentModeScaleAspectFill;
        
        if(shyftForCell.userProfileImage != nil){
            shyftCell.userProfileImageView.image = shyftForCell.userProfileImage;
        }
        
        
        //-------------buttons-------------------------
        
        [shyftCell.imageButton setUserInteractionEnabled:YES];
        
        shyftCell.fbButton.layer.cornerRadius = 3;
        shyftCell.fbButton.layer.masksToBounds = YES;
        shyftCell.fbButton.backgroundColor = theFacebookBlueColor;//facebook blue color
        [shyftCell.fbButton addTarget:self action:@selector(shareOnFB:) forControlEvents:UIControlEventTouchUpInside];
        [shyftCell.fbButton setImage:facebookIconImage forState:UIControlStateNormal];
        
        shyftCell.resendButton.layer.cornerRadius = 3;
        shyftCell.resendButton.layer.masksToBounds = YES;
        shyftCell.resendButton.backgroundColor = theKeoOrangeColor;
        [shyftCell.resendButton addTarget:self action:@selector(resendPressed:) forControlEvents:UIControlEventTouchUpInside];
        [shyftCell.resendButton setImage:resendIconImage forState:UIControlStateNormal];
        
        shyftCell.downloadButton.layer.cornerRadius = 3;
        shyftCell.downloadButton.layer.masksToBounds = YES;
        shyftCell.downloadButton.backgroundColor = thePicteverGreenColor;
        [shyftCell.downloadButton addTarget:self action:@selector(downloadImage:) forControlEvents:UIControlEventTouchUpInside];
        [shyftCell.downloadButton setImage:downloadIconImage forState:UIControlStateNormal];
        
        
        cell.backgroundColor = [UIColor clearColor];
        shyftCell.backgroundLabel.frame = CGRectMake(0, 0, screenWidth, 60);
    }
    else{
        static NSString* CellIdentifier2 = @"PandaCell";
        // Configure the cell
        APLLog(@"shyftForCell: Panda");
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2 forIndexPath:indexPath];
        
        PandaCell *pandaCell = (PandaCell *)cell;
        
        pandaCell.pandaSpeakLabel.text = @"Be careful! The timeline contains only your 10 last messages. Resend them to the future if you want to remember them! (orange button)";
        if([myLocaleString isEqualToString:@"FR"]){
            pandaCell.pandaSpeakLabel.text = @"Attention! La timeline ne contient que les 10 derniers messages. Renvoie-les dans le futur si tu veux t'en souvenir! (bouton orange)";
        }
        //pandaCell.pandaSpeakLabel.font = [UIFont fontWithName:@"Gabriola" size:20];
        pandaCell.pandaSpeakLabel.font = [UIFont fontWithName:@"GothamRounded-Light" size:16];
        pandaCell.contentMode = UIViewContentModeScaleAspectFit;
        pandaCell.pandaImgv.image = [myGeneralMethods scaleImage:[UIImage imageNamed:@"robot_disco_small.png"] toWidth:pandaCell.pandaImgv.frame.size.width];
    }
    
    
    
    return cell;
    
}

-(void)downloadImage:(id)sender{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    NSLog(@"downloadImage");
    if (indexPath != nil){
        ShyftMessage *thePictToDownload = [myShyftSet getShyftAtIndex:indexPath.row];
        APLLog(@"DownloadPressed: %@",[thePictToDownload getDescription]);
        UIImage *imageToDownload = [KeoMessages prepareImageForExport:thePictToDownload];
        UIImageWriteToSavedPhotosAlbum(imageToDownload,nil,nil,nil);
        NSString *title5 = @"Image saved";
        NSString *message5 = @"The image was saved in your phone gallery";
        if([myLocaleString isEqualToString:@"FR"]){
            title5 = @"Image enregistrée";
            message5 = @"L'image a été enregistrée dans la gallerie de ton téléphone";
        }
        UIAlertView *alert5 = [[UIAlertView alloc]
                               initWithTitle:title5
                               message:message5 delegate:self
                               cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert5 show];
    }
}


//---------------------------Share the photo on facebook-------------------------------------------------
- (void)shareOnFB:(id)sender{
    if([GPRequests connected]){
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
        if (indexPath != nil)
        {
            ShyftMessage *theShyftToShare = [myShyftSet getShyftAtIndex:indexPath.row];
            APLLog(@"ShareOnPressed: %@",[theShyftToShare getDescription]);
            UIImage *imageToShare;
            
            imageToShare = [KeoMessages prepareImageForExport:theShyftToShare];
            
            // If the Facebook app is installed and we can present the share dialog
            if ([FBDialogs canPresentShareDialogWithPhotos]) {
                UIImage *img = imageToShare;
                
                FBPhotoParams *params = [[FBPhotoParams alloc] init];
                
                // Note that params.photos can be an array of images.  In this example
                // we only use a single image, wrapped in an array.
                params.photos = @[img];
                
                [FBDialogs presentShareDialogWithPhotoParams:params
                                                 clientState:nil
                                                     handler:^(FBAppCall *call,
                                                               NSDictionary *results,
                                                               NSError *error) {
                                                         if (error) {
                                                             APLLog(@"Error: %@",
                                                                    error.description);
                                                         } else {
                                                             APLLog(@"Success!");
                                                         }
                                                     }];
            } else {
                // The user doesn't have the Facebook for iOS app installed.  You
                // may be able to use a fallback.
            }
            
            
        }
        
    }
    else{
        NSString *title5 = @"Connection problem";
        NSString *message5 = @"You have no internet connection";
        if([myLocaleString isEqualToString:@"FR"]){
            title5 = @"Problème de connexion";
            message5 = @"Vous n'avez pas de connexion internet";
        }
        UIAlertView *alert5 = [[UIAlertView alloc]
                               initWithTitle:title5
                               message:message5 delegate:self
                               cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert5 show];
    }
}


//------------------------------------------------------------------------------------------------------------------------
//-------------------prepare image for facebook export (add Pictever logo and name on the picture)---------------------------
//------------------------------------------------------------------------------------------------------------------------

//---------------select image to share (photo or image with text if text message)------------
+(UIImage*)prepareImageForExport:(ShyftMessage *)thePictToShare{
    UIImage *localImageToShare;
    //---------------------photo message
    if((![thePictToShare.photo isEqualToString:@"None"])&&(![thePictToShare.photo isEqualToString:@""])){
        localImageToShare = thePictToShare.uiControl;
        localImageToShare = [myGeneralMethods scaleImage:localImageToShare toWidth:2*localImageToShare.size.width];//--------image *2
    }
    else{//-----------------text message
        NSString *shyftMessage = thePictToShare.message;
        UIFont *messageFont = [UIFont fontWithName:@"GothamRounded-Bold" size:36];
        
        CGSize messageLabelSize = [myGeneralMethods text:shyftMessage sizeWithFont:messageFont constrainedToSize:CGSizeMake(2*(screenWidth-45),2*180)];
        localImageToShare = thePictToShare.croppedImage;
        localImageToShare = [myGeneralMethods scaleImage:localImageToShare toWidth:2*localImageToShare.size.width];//------image *2
        
        localImageToShare = [KeoMessages drawText2:shyftMessage inImage:localImageToShare inRect:CGRectMake(localImageToShare.size.width*0.5-messageLabelSize.width*0.5, localImageToShare.size.height*0.5-messageLabelSize.height*0.5, messageLabelSize.width,messageLabelSize.height+50) withFont:messageFont withColor:[UIColor whiteColor]];//+50 par sécurité
    }
    
    localImageToShare = [KeoMessages addPicteverBrandOnImage:localImageToShare];
    return localImageToShare;
}


+ (UIImage*) addPicteverBrandOnImage:(UIImage *)imageForExport{
    UIImage *picteverLabel = [UIImage imageNamed:@"PicteverLabel.png"];
    picteverLabel = [myGeneralMethods scaleImage:picteverLabel toWidth:0.3*imageForExport.size.width];
    imageForExport = [KeoMessages addImage:picteverLabel atPoint:CGPointMake(5, imageForExport.size.height-picteverLabel.size.height-5) onImage:imageForExport];
    //imageForExport = [KeoMessages addImage:picteverLabel atPoint:CGPointMake(10, 10) onImage:imageForExport];
    return imageForExport;
    
    /*
    int topBandHeight = 40;
    UIImage *spirale = [myGeneralMethods scaleImage3:[UIImage imageNamed:@"spirale-white2.png"] withFactor:7];
    
    //-----------create a bigger background to place the band-------------
    UIImage *bckgroundImage = [KeoMessages fillImgOfSize:CGSizeMake(imageForExport.size.width, imageForExport.size.height+topBandHeight) withColor:[UIColor whiteColor]];
    
    NSString *title = [NSString stringWithFormat:@"%@ on Pictever!", labelForExport];
    
    UIFont* titleLabelFont = [UIFont fontWithName:@"Gabriola" size:26];
    CGSize titleLabelSize = [myGeneralMethods text:title sizeWithFont:titleLabelFont constrainedToSize:CGSizeMake(screenWidth-spirale.size.width-20, 100)];
    
    //-----------add top bande on background ----------------
    UIImage *topBande = [KeoMessages fillImgOfSize:CGSizeMake(imageForExport.size.width, topBandHeight) withColor:theKeoOrangeColor];
    bckgroundImage = [KeoMessages addImage:topBande atPoint:CGPointMake(0, 0) onImage:bckgroundImage];
    
    //------------add photo on background--------------------
    imageForExport = [KeoMessages addImage:imageForExport atPoint:CGPointMake(0, topBandHeight) onImage:bckgroundImage];
    imageForExport = [KeoMessages addImage:spirale atPoint:CGPointMake(0, -2) onImage:imageForExport];
    APLLog(@"top bande size: %f titlelabelsize: %f",topBande.size.height,titleLabelSize.height);
    
    imageForExport = [KeoMessages drawText2:title inImage:imageForExport inRect:CGRectMake(spirale.size.width-15+(topBande.size.width-spirale.size.width)*0.5-titleLabelSize.width*0.5, 10+topBande.size.height*0.5-titleLabelSize.height*0.5, titleLabelSize.width, titleLabelSize.height) withFont:titleLabelFont withColor:[UIColor whiteColor]];
    
    return imageForExport;*/
}

+ (UIImage*) fillImgOfSize:(CGSize)img_size withColor:(UIColor*)img_color{
    
    /* begin the graphic context */
    UIGraphicsBeginImageContext(img_size);
    
    /* set the color */
    [img_color set];
    
    /* fill the rect */
    UIRectFill(CGRectMake(0, 0, img_size.width, img_size.height));
    
    /* get the image, end the context */
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    /* return the value */
    return scaledImage;
}



+ (UIImage*) addImage:(UIImage*)smallImage atPoint:(CGPoint)originPoint onImage:(UIImage*)backgroundImg{
    CGSize size = CGSizeMake(backgroundImg.size.width, backgroundImg.size.height);
    UIGraphicsBeginImageContext(size);
    
    CGPoint backgroundPoint = CGPointMake(0, 0);
    [backgroundImg drawAtPoint:backgroundPoint];
    
    //CGPoint smallImagePoint = originPoint;
    [smallImage drawAtPoint:originPoint];
    
    UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}


+(UIImage*) drawText2:(NSString*) text inImage:(UIImage*)image inRect:(CGRect)rect withFont:(UIFont *)font withColor:(UIColor*)textColor{
    
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    //CGRect rect = CGRectMake(point.x, point.y, image.size.width-30, image.size.height);
    [textColor set];
    //[text drawInRect:CGRectIntegral(rect) withFont:font]; deprecated in ios7
    
    /// Make a copy of the default paragraph style
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    /// Set line break mode
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    /// Set text alignment
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{ NSFontAttributeName: font,
                                  NSParagraphStyleAttributeName: paragraphStyle,
                                  NSForegroundColorAttributeName: textColor};
    
    [text drawInRect:rect withAttributes:attributes];
    
    
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

//------------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------------



//------------------------------------------------------------------------------------------------------------------------
//--------------------------------Resend an image in the future-----------------------------------------------------------

- (void)resendPressed:(id)sender{
    if([GPRequests connected]){
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
        if (indexPath != nil){
            theShyftToResend = [myShyftSet getShyftAtIndex:indexPath.row];
            APLLog(@"ResendPressed: %@",[theShyftToResend getDescription]);
            theResendIndexPath = indexPath;
            
            NSString *titleAlert = my_actionsheet_want_to_remember;
            NSString *messageAlert = @"Resend it to yourself randomly in the future!";
            NSString *titreCancel = @"Cancel";
            NSString *titreResend = @"Resend";
            if([myLocaleString isEqualToString:@"FR"]){
                titleAlert = my_actionsheet_want_to_remember_french;
                messageAlert = @"Renvoie-le à toi même dans le futur à une date au hasard!";
                titreCancel = @"Annuler";
                titreResend = @"Renvoyer";
            }
            UIAlertView *resendAlert = [[UIAlertView alloc] initWithTitle:titleAlert message:messageAlert  delegate:self cancelButtonTitle:titreCancel otherButtonTitles: titreResend, nil];
            [resendAlert show];
        }
    }
    else{
        NSString *titleAlert5 = @"Connection problem";
        NSString *messageAlert5 = @"You have no internet connection";
        if([myLocaleString isEqualToString:@"FR"]){
            titleAlert5 = @"Problème de connexion";
            messageAlert5 = @"Vous n'avez pas de connexion internet";
        }
        UIAlertView *alert5 = [[UIAlertView alloc]
                               initWithTitle:titleAlert5
                               message:messageAlert5 delegate:self
                               cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert5 show];
    }
}

//--------------------------alert amazon analytics when we resend an image (for our own statistics)----------------------
-(void)alertAnalyticsResendSent{
    APLLog(@"alertAnalytics resend");
    id<AWSMobileAnalyticsEventClient> eventClient = analytics.eventClient;
    id<AWSMobileAnalyticsEvent> levelEvent = [eventClient createEventWithEventType:@"iosResend"];
    [eventClient recordEvent:levelEvent];
    [eventClient submitEvents];
}

//--------the user has to confirm he wants to resend the photo---------------


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    
    if([alertView.title isEqualToString:my_actionsheet_want_to_remember]||[alertView.title isEqualToString:my_actionsheet_want_to_remember_french]){
        // the user clicked one of the OK/Cancel buttons
        if (buttonIndex == 0)
        {
            APLLog(@"Cancel");
        }
        else
        {
            if([GPRequests connected]){
                
                [self activateResendRequest];
                
                [self alertAnalyticsResendSent];
                
                ShyftMessage *shyftToDeleteR = [myShyftSet getShyftAtIndex:theResendIndexPath.row];
                NSUInteger delIndexR = [KeoMessages getIndexPathOfShyft:shyftToDeleteR];
                
                if(delIndexR != -1){
                    [messagesDataFile removeObjectAtIndex:delIndexR];
                    
                    NSString *deletePhotoID = shyftToDeleteR.photo;
                    //Supression from the memory of the phone
                    if(![deletePhotoID isEqualToString:@""]){
                        NSString *photoField = [deletePhotoID stringByReplacingOccurrencesOfString:@" " withString:@""];
                        APLLog(@"photoField: %@",photoField);
                        if(![photoField isEqualToString:@"None"]){
                            NSString *deletePath = [NSString stringWithFormat:@"%@/%@",myCurrentPhotoPath,deletePhotoID];
                            APLLog(@"DELETE PHOTO AT PATH (commiteditingstyle): %@",deletePath);
                            [myGeneralMethods deletePhotoAtPath:deletePath];
                        }
                    }
                    
                    if([self.tableView numberOfRowsInSection:0]>2){//-------not the last row (number 2 because of Billy row)-----
                        APLLog(@"not the last row");
                        [self.tableView beginUpdates];
                        [myShyftSet deleteShyftAtIndex:theResendIndexPath.row];
                        [self.tableView deleteRowsAtIndexPaths:@[theResendIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                        [self.tableView endUpdates];
                    }
                    else{//------in the case of last row, remove the whole section-----
                        APLLog(@"last row");
                        [myShyftSet deleteShyftAtIndex:theResendIndexPath.row];
                        [self.tableView reloadData];
                        
                        [self.view addSubview:firstInfoLabel];
                    }
                    [myGeneralMethods saveMessagesData];
                    
                    
                }
                
            }
            else{
                NSString *titleAlert5 = @"Connection problem";
                NSString *messageAlert5 = @"You have no internet connection";
                if([myLocaleString isEqualToString:@"FR"]){
                    titleAlert5 = @"Problème de connexion";
                    messageAlert5 = @"Vous n'avez pas de connexion internet";
                }
                UIAlertView *alert5 = [[UIAlertView alloc]
                                       initWithTitle:titleAlert5
                                       message:messageAlert5 delegate:self
                                       cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert5 show];
            }
        }
    }
    else if([alertView.title isEqualToString:my_actionsheet_wanna_help_us]||[alertView.title isEqualToString:my_actionsheet_wanna_help_us_french]){
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

//-----------the photo is resent-------------
-(void)activateResendRequest{
    APLLog(@"ActivateResendRequest: %@", [theShyftToResend getDescription]);
    
    if(theShyftToResend){
        //--------------------new way to resend-------------------------
        if(![theShyftToResend.shyft_id isEqualToString:@""]){
            [[[GPSession alloc] init] resendRequest:theShyftToResend.shyft_id for:self];
        }
        //--------------------old way to resend(to delete in a few weeks)--------------
        else{
            if(theShyftToResend){
                NSMutableArray *idArr = [[NSMutableArray alloc] init];
                [idArr addObject:[NSString stringWithFormat:@"id%@",myUserID]];
                NSString *idArrToSend = [myGeneralMethods stringFromArrayPh:idArr];
                
                if((![theShyftToResend.photo isEqualToString:@"None"])&&(![theShyftToResend.photo isEqualToString:@""])){
                    //---------photo
                    NSString* photoIDToResend = @"";
                    if(theShyftToResend.photo){
                        photoIDToResend = theShyftToResend.photo;
                    }
                    [[[GPSession alloc] init] sendRequest:photoIDToResend to:idArrToSend withPhotoString:@"on" withKeoTime:[myGeneralMethods stringForKeoChoicePh:@"resend" withParameter:@""] for:self];
                }
                else{
                    //----------message
                    NSString* messageToResend = @"";
                    if(theShyftToResend.message){
                        messageToResend = theShyftToResend.message;
                    }
                    
                    [[[GPSession alloc]init] sendRequest:messageToResend to:idArrToSend withPhotoString:@"" withKeoTime:[myGeneralMethods stringForKeoChoicePh:@"resend" withParameter:@""] for:self];
                }
            }
        }
        
    }
}

//------------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------------


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

//------------------------the user wants to delete a message in the gallery--------------------------

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView reloadData];
    
    if(indexPath.row < [myShyftSet size]){//--------to avoid imageButton to be disabled-----
        UITableViewCell *cellD = [tableView cellForRowAtIndexPath:indexPath];
        ShyftCell *shyftCellD = (ShyftCell *)cellD;
        [shyftCellD.imageButton setUserInteractionEnabled:YES];
    }
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        ShyftMessage *shyftToDelete = [myShyftSet getShyftAtIndex:indexPath.row];
        
        NSUInteger delIndex = [KeoMessages getIndexPathOfShyft:shyftToDelete];
        
        if(delIndex != -1){
            [messagesDataFile removeObjectAtIndex:delIndex];
            
            
            NSString *deletePhotoID = shyftToDelete.photo;
            //Supression from the memory of the phone
            if(![deletePhotoID isEqualToString:@""]){
                NSString *photoField = [deletePhotoID stringByReplacingOccurrencesOfString:@" " withString:@""];
                APLLog(@"photoField: %@",photoField);
                if(![photoField isEqualToString:@"None"]){
                    NSString *deletePath = [NSString stringWithFormat:@"%@/%@",myCurrentPhotoPath,deletePhotoID];
                    APLLog(@"DELETE PHOTO AT PATH (commiteditingstyle): %@",deletePath);
                    [myGeneralMethods deletePhotoAtPath:deletePath];
                }
            }
            
            if([self.tableView numberOfRowsInSection:0]>2){//-------not the last row (number 2 because of Billy row)-----
                APLLog(@"not the last row");
                [self.tableView beginUpdates];
                [myShyftSet deleteShyftAtIndex:indexPath.row];
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView endUpdates];
            }
            else{//------in the case of last row, remove the whole section-----
                APLLog(@"last row");
                [myShyftSet deleteShyftAtIndex:indexPath.row];
                [self.tableView reloadData];
                
                [self.view addSubview:firstInfoLabel];
            }
            [myGeneralMethods saveMessagesData];
        }
    }
}


//---------------------get indexpath of shyft in messages data file-------------------------
+ (NSUInteger)getIndexPathOfShyft:(ShyftMessage *)myShyftToDelete{
    for(NSMutableDictionary* currentMessage in [messagesDataFile mutableCopy]){
        if([currentMessage objectForKey:my_from_id_Key]){
            if([[currentMessage objectForKey:my_from_id_Key] isEqualToString:myShyftToDelete.from_id]){
                if([currentMessage objectForKey:my_created_at_Key]){
                    if([[currentMessage objectForKey:my_created_at_Key] isEqualToString:myShyftToDelete.created_at]){
                        if([currentMessage objectForKey:my_shyft_id_Key]){
                            if([[currentMessage objectForKey:my_shyft_id_Key] isEqualToString:myShyftToDelete.shyft_id]){
                                return [messagesDataFile indexOfObject:currentMessage];
                            }
                        }
                    }
                }
            }
        }
    }
    return -1;
}



//------------------Height of the cell--------------------------------------------------

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath{
    //return 360;
    if(indexPath.row < [myShyftSet size]){
        return 371;
    }
    else{
        return 130;
    }
}


//------------ settings button pressed---------------
- (IBAction)settingsPressed:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"SettingsScreen"];
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)cameraPressed:(id)sender {
    UITabBarController * tabBarController = (UITabBarController *)self.tabBarController;
    int controllerIndex = 1;
    UIView * fromView = tabBarController.selectedViewController.view;
    UIView * toView = [[tabBarController.viewControllers objectAtIndex:controllerIndex] view];
    
    // Get the size of the view area.
    CGRect viewSize = fromView.frame;
    BOOL scrollRight = controllerIndex > tabBarController.selectedIndex;
    
    // Add the to view to the tab bar view.
    [fromView.superview addSubview:toView];
    
    // Position it off screen.
    toView.frame = CGRectMake((scrollRight ? 320 : -320), viewSize.origin.y, 320, viewSize.size.height);
    
    [UIView animateWithDuration:0.3
                     animations: ^{
                         
                         // Animate the views on and off the screen. This will appear to slide.
                         fromView.frame =CGRectMake((scrollRight ? -320 : 320), viewSize.origin.y, 320, viewSize.size.height);
                         toView.frame =CGRectMake(0, viewSize.origin.y, 320, viewSize.size.height);
                     }
     
                     completion:^(BOOL finished) {
                         if (finished) {
                             
                             // Remove the old view from the tabbar view.
                             [fromView removeFromSuperview];
                             tabBarController.selectedIndex = controllerIndex;
                         }
                     }];
}


- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error
  contextInfo:(void *)contextInfo
{
    // Was there an error?
    if (error != NULL)
    {
        APLLog(@"Error: could not save photo in the library");
        
    }
    else  // No errors
    {
        // Show message image successfully saved
    }
}



//-----------------copy messagesDataFile------------------------------------------------------------------

+(NSMutableArray *)copyMessagesDataFile2:(NSArray *)importedArray{
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    for(NSDictionary *cmessage in importedArray){
        //NSMutableDictionary *newMessage3 = [KeoMessages copySingleMessage:message];
        NSMutableDictionary *newMessage3 = [cmessage mutableCopy];
        [returnArray insertObject:newMessage3 atIndex:[returnArray count]];
    }
    return returnArray;
}

+(NSMutableDictionary *)copySingleMessage:(NSDictionary *)message{
    NSMutableDictionary *newMessage2 = [[NSMutableDictionary alloc] init];
    
    if([message objectForKey:@"from_email"]){
        [newMessage2 setObject:[message objectForKey:@"from_email"] forKey:@"from_email"];}
    else{
        [newMessage2 setObject:@"" forKey:@"from_email"];}
    if([message objectForKey:@"from_id"]){
        [newMessage2 setObject:[message objectForKey:@"from_id"] forKey:@"from_id"];}
    else{
        [newMessage2 setObject:@"" forKey:@"from_id"];}
    if([message objectForKey:@"message"]){
        [newMessage2 setObject:[message objectForKey:@"message"] forKey:@"message"];}
    else{
        [newMessage2 setObject:@"" forKey:@"message"];}
    if([message objectForKey:@"created_at"]){
        [newMessage2 setObject:[message objectForKey:@"created_at"] forKey:@"created_at"];}
    else{
        [newMessage2 setObject:@"" forKey:@"created_at"];}
    if([message objectForKey:@"received_at"]){
        [newMessage2 setObject:[message objectForKey:@"received_at"] forKey:@"received_at"];}
    else{
        [newMessage2 setObject:@"0" forKey:@"received_at"];}
    if([message objectForKey:@"photo"]){
        [newMessage2 setObject:[message objectForKey:@"photo"] forKey:@"photo"];}
    else{
        [newMessage2 setObject:@"" forKey:@"photo"];}
    if([message objectForKey:@"from_numero"]){
        [newMessage2 setObject:[message objectForKey:@"from_numero"] forKey:@"from_numero"];}
    else{
        [newMessage2 setObject:@"" forKey:@"from_numero"];}
    if([message objectForKey:@"receive_label"]){
        [newMessage2 setObject:[message objectForKey:@"receive_label"] forKey:@"receive_label"];}
    else{
        [newMessage2 setObject:@"" forKey:@"receive_label"];}
    if([message objectForKey:@"receive_color"]){
        [newMessage2 setObject:[message objectForKey:@"receive_color"] forKey:@"receive_color"];}
    else{
        [newMessage2 setObject:@"" forKey:@"receive_color"];}
    if([message objectForKey:@"loaded"]){
        [newMessage2 setObject:[message objectForKey:@"loaded"] forKey:@"loaded"];}
    else{
        [newMessage2 setObject:@"yes" forKey:@"loaded"];}
    return newMessage2;
}


//----------------sort messages in the chronological order--------------------------------------

+(NSMutableArray *)bubbleSort: (NSMutableArray *)myMessages{
    APLLog(@"bubblesort");
    NSUInteger num = [myMessages count];
    if(num < 2){
        APLLog(@"Nothing to sort");
        return myMessages;
    }
    APLLog(@"there is something to sort");
    bool changeDone = true;
    while (changeDone) {
        changeDone=false;
        for(int j =0; j<num-1; j++){
            if([[[myMessages objectAtIndex:j] objectForKey:@"received_at"] doubleValue] < [[[myMessages objectAtIndex:(j+1)] objectForKey:@"received_at"] doubleValue]){
                [KeoMessages switchElements:myMessages index1:j index2:j+1];
                changeDone=true;
            }
        }
        num=num-1;
    }
    
    APLLog(@"bubblesort fin");
    
    return myMessages;
    
}


+(void)switchElements: (NSMutableArray *)myArray index1: (int) firstint index2: (int) secondint{
    id firstObject = [myArray objectAtIndex:firstint];
    id secondObject = [myArray objectAtIndex:secondint];
    [myArray replaceObjectAtIndex:firstint withObject:secondObject];
    [myArray replaceObjectAtIndex:secondint withObject:firstObject];
}




//------------------user scrolls to load new messages or to refresh tableview-----------------------------------

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    
    CGPoint offset = aScrollView.contentOffset;
    
    if(offset.y > hdView.frame.size.height){
        [self updateNavigationBar:aScrollView];
    }
    
    
    if(offset.y <= (-100.0)){
        //APLLog(@"TOP");
        if(!reloaded2){
            //if(viewDidAppear){
            if(true){
                reloaded2 = true;
                reloadTimer2 = [NSTimer scheduledTimerWithTimeInterval: 2.0 target: self selector: @selector(canReloadTableView2) userInfo: nil repeats: NO];
                APLLog(@"RELOADTABLEVIEWPHantom: %f",offset.y);
                
                refreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.56*screenWidth, 5, 100, 40)];
                refreshLabel.text = @"";
                refreshLabel.backgroundColor = [UIColor clearColor];
                [refreshLabel setFont:[UIFont fontWithName:@"GothamRounded-Light" size:12]];
                [self.view addSubview:refreshLabel];
                
                spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                spinner.center = CGPointMake(0.5*screenWidth, 25);
                spinner.color = [UIColor blackColor];
                spinner.hidesWhenStopped = YES;
                [self.view addSubview:spinner];
                [spinner startAnimating];
                refreshLabel.text = @"refreshing..";
                
                reloadTimerNewMessages = [NSTimer scheduledTimerWithTimeInterval: 0.2 target: self selector: @selector(loadTheNewMessages:) userInfo: nil repeats: NO];
            }
            else{
                APLLog(@"viewdidnotappear");
            }
        }
        else{
            //APLLog(@"messages loaded");
        }
    }
}



//--------------here we use notifications to start these methods because if we don't, the spinner doesn't start---------------------

-(void)loadTheNewMessages:(NSTimer*) reloadTimerNewMessagest{
    [self loadUnloadImages];
    waitTimer = [NSTimer scheduledTimerWithTimeInterval: 0.7 target: self selector: @selector(nowReload) userInfo: nil repeats: NO];
}

-(void)nowReload{
    [self reloadTheWholeTableViewFirstTime];
    [self.tableView reloadData];
    [spinner stopAnimating];
    refreshLabel.text = @"";
    if([self.tableView numberOfRowsInSection:0]>0){
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"askNewMessages2" object: nil];
}

-(void)canReloadTableView2{
    APLLog(@"CANRELOADTABLEVIEW2");
    reloaded2 = false;
}




//---------------------hide/show tabbar-------------------

// a param to describe the state change, and an animated flag
// optionally add a completion block which matches UIView animation
- (void)setTabBarVisible:(BOOL)visible animated:(BOOL)animated {
    
    // bail if the current state matches the desired state
    if ([self tabBarIsVisible] == visible) return;
    
    // get a frame calculation ready
    CGRect frame = self.tabBarController.tabBar.frame;
    CGFloat height = frame.size.height;
    CGFloat offsetY = (visible)? -height : height;
    
    // zero duration means no animation
    CGFloat duration = (animated)? 0.3 : 0.0;
    
    [UIView animateWithDuration:duration animations:^{
        self.tabBarController.tabBar.frame = CGRectOffset(frame, 0, offsetY);
    }];
}

// know the current state
- (BOOL)tabBarIsVisible {
    NSLog(@"tabbar y origin: %f", self.tabBarController.tabBar.frame.origin.y);
    NSLog(@"MAX Y, %f", CGRectGetMaxY(self.view.frame));
    return self.tabBarController.tabBar.frame.origin.y < CGRectGetMaxY(self.view.frame);
}

-(void)downloadPhotoOnNewBucket:(NSNotification *)notification{
    APLLog(@"downloadPhotoOnNewBucket: %@",[notification.userInfo description]);
    NSMutableDictionary * newMessage = [notification.userInfo mutableCopy];
    [self startLoadingAnimation];
    downloadPhotoOnAmazon = true;
    [[[NewBucketRequest alloc] init] sessionNewBucket:newMessage];
}





//--------------------hide the navigation controller bar----------------------------------------

- (void)updateNavigationBar:(UIScrollView *)scrollView
{
    CGRect frame = self.navigationController.navigationBar.frame;
    CGFloat size = frame.size.height - 21;
    CGFloat framePercentageHidden = ((20 - frame.origin.y) / (frame.size.height - 1));
    CGFloat scrollOffset = scrollView.contentOffset.y;
    CGFloat scrollDiff = scrollOffset - self.previousScrollViewYOffset;
    CGFloat scrollHeight = scrollView.frame.size.height;
    CGFloat scrollContentSizeHeight = scrollView.contentSize.height + scrollView.contentInset.bottom;
    
    if (scrollOffset <= -scrollView.contentInset.top) {
        frame.origin.y = 20;
    } else if ((scrollOffset + scrollHeight) >= scrollContentSizeHeight) {
        frame.origin.y = -size;
    } else {
        frame.origin.y = MIN(20, MAX(-size, frame.origin.y - scrollDiff));
    }
    
    [self updateOtherViewsToFrame:frame withAlpha:(1 - framePercentageHidden)];
    
    [self.navigationController.navigationBar setFrame:frame];
    [self updateBarButtonItems:(1 - framePercentageHidden)];
    self.previousScrollViewYOffset = scrollOffset;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self stoppedScrolling];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self stoppedScrolling];
    }
}

- (void)stoppedScrolling
{
    CGRect frame = self.navigationController.navigationBar.frame;
    if (frame.origin.y < 20) {
        [self animateNavBarTo:-(frame.size.height - 21) withFixedAlpha:false];
    }
}

- (void)updateBarButtonItems:(CGFloat)alpha
{
    [self.navigationItem.leftBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem* item, NSUInteger i, BOOL *stop) {
        item.customView.alpha = alpha;
    }];
    [self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem* item, NSUInteger i, BOOL *stop) {
        item.customView.alpha = alpha;
    }];
    self.navigationItem.titleView.alpha = alpha;
    self.navigationController.navigationBar.tintColor = [self.navigationController.navigationBar.tintColor colorWithAlphaComponent:alpha];

    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                     [[UIColor whiteColor] colorWithAlphaComponent:alpha],
                                                                     NSForegroundColorAttributeName,
                                                                     [UIFont fontWithName:@"GothamRounded-Bold" size:18.0],
                                                                     NSFontAttributeName,
                                                                     nil]];
    
    
}

- (void)animateNavBarTo:(CGFloat)y withFixedAlpha:(bool)alphaFixed
{
    [UIView animateWithDuration:0.2 animations:^{
        CGRect frame = self.navigationController.navigationBar.frame;
        CGFloat alpha = (frame.origin.y >= y ? 0 : 1);
        if(alphaFixed){
            alpha = 1;
        }
        frame.origin.y = y;
        
        [self updateOtherViewsToFrame:frame withAlpha:alpha];
        
        [self.navigationController.navigationBar setFrame:frame];
        [self updateBarButtonItems:alpha];
    }];
}

-(void)updateOtherViewsToFrame:(CGRect)barFrame withAlpha:(CGFloat)alpha{
    CGRect progressViewFrame = progressView2.frame;
    progressViewFrame.origin.y = barFrame.origin.y+barFrame.size.height;
    [progressView2 setFrame:progressViewFrame];
    
    CGRect spinnerTopFrame = _spinnerTop.frame;
    spinnerTopFrame.origin.y = self.initialSpinnerTopYOffset+barFrame.origin.y-self.initialNavigationBarYOffset;
    [_spinnerTop setFrame:spinnerTopFrame];
    //_spinnerTop.alpha = alpha;
    
    CGRect loadingLabelFrame = _loadingLabel.frame;
    loadingLabelFrame.origin.y = self.initialLoadingLabelYOffset+barFrame.origin.y-self.initialNavigationBarYOffset;
    [_loadingLabel setFrame:loadingLabelFrame];
    //_loadingLabel.alpha = alpha;
    
    CGRect backgroundLoadingLabelFrame = _backgroundLoadingLabel.frame;
    backgroundLoadingLabelFrame.origin.y = self.initialLoadingLabelYOffset+barFrame.origin.y-self.initialNavigationBarYOffset;
    [_backgroundLoadingLabel setFrame:backgroundLoadingLabelFrame];
}

/*
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}*/


@end

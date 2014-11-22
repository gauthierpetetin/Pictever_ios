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

@end

@implementation KeoMessages

ShyftSet *myShyftSet;


AWSMobileAnalytics* analytics;//global

NSUserDefaults *prefs;

NSString *myUserID;

NSString *adresseIp2;//global

NSString *username;//global
NSString *myStatus;//global
bool logIn;
NSString *hashPassword;//global

NSString* numberOfMessagesInTheFuture;//global

NSString* myVersionInstallUrl;//global

ShyftMessage * theShyftToResend;
NSMutableDictionary *theKeoToResend;
NSIndexPath *theResendIndexPath;

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
NSString *backgroundImage;//global

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
UIColor *lightGrayColor;


//------------shows the user when the table view is loading new messages------------------
UITapGestureRecognizer *billyTapRecognizer;
UILabel *futureLabel;
UILabel *billyLabel;
UIImageView *myBillyImageView;
UIView *loadingView;
UIActivityIndicatorView *spinner;
//UIActivityIndicatorView *spinnerTop;
UIActivityIndicatorView *loadSpinner;
UIView *hdView;

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
//UILabel *loadingLabel;

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
    
    //[self.tableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    //----------if the gallery contains messages----------------------------
    if([messagesDataFile count] > 0){
        APLLog(@"%d messages in the gallery",[messagesDataFile count]);
        self.view.backgroundColor = [myGeneralMethods getColorFromHexString:@"e4e1e0"];
    }
    //----------if the gallery is empty----------------------------
    else{
        APLLog(@"No messages in the gallery");
        self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"background_nomessages.png"]];
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
        [progressView2 setProgressTintColor:[UIColor orangeColor]];
        [progressView2 setUserInteractionEnabled:NO];
        [progressView2 setProgressViewStyle:UIProgressViewStyleBar];
        [progressView2 setTrackTintColor:[UIColor clearColor]];
        
    }
    else{
        
    }
    
    //----------------show the user he is currently downloading an image-------------------
    _loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.14*screenWidth, 20, 100, 40)];
    _loadingLabel.backgroundColor = [UIColor clearColor];
    [_loadingLabel setFont:[UIFont systemFontOfSize:12]];
    [self.parentViewController.view addSubview:_loadingLabel];
    
    _spinnerTop = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _spinnerTop.center = CGPointMake(0.075*screenWidth, 40);
    _spinnerTop.color = [UIColor blackColor];
    _spinnerTop.hidesWhenStopped = YES;
    [self.parentViewController.view addSubview:_spinnerTop];
    
    
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
    
    _loadTbvSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _loadTbvSpinner.center = CGPointMake(0.5*screenWidth, 0.5*screenHeight-navBarHeight);
    _loadTbvSpinner.color = [UIColor darkGrayColor];
    _loadTbvSpinner.hidesWhenStopped = YES;
    [_loadTbvLabel addSubview:_loadTbvSpinner];
    
    
    [self initHeaderView];
    
    
    if([self.tableView numberOfRowsInSection:0]>0){
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    
    [self.tableView reloadData];
    
    APLLog(@"KeoMessages didload");
}

-(void)initHeaderView{
    //----------------subview to show the refresh spinner and label----------------------
    hdView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 210)];//50 before Billy
    hdView.backgroundColor = [myGeneralMethods getColorFromHexString:@"e4e1e0"];
    
    
    //---------------add Billy with flag-----------------------------
    myBillyImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.06*screenWidth, 0.02*screenHeight, screenWidth*0.875, 180)];
    myBillyImageView.image = [myGeneralMethods scaleImage3:[UIImage imageNamed:@"panda_top_timeline.png"] withFactor:2];
    myBillyImageView.contentMode = UIViewContentModeCenter;
    
    billyTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(billyTapped)];
    billyTapRecognizer.numberOfTapsRequired = 1;
    [myBillyImageView addGestureRecognizer:billyTapRecognizer];
    myBillyImageView.userInteractionEnabled = YES;
    
    //billyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.06*screenWidth, 0.34*screenHeight, screenWidth*0.875, 40)];
    billyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.06*screenWidth, hdView.frame.size.height-45, screenWidth*0.875, 40)];
    billyLabel.numberOfLines = 0;
    billyLabel.lineBreakMode = NSLineBreakByWordWrapping;
    billyLabel.textAlignment = NSTextAlignmentCenter;
    billyLabel.text = @"Wanna know how many messages you will receive in the future? Ask Billy!";
    [billyLabel setFont:[UIFont fontWithName:@"Gabriola" size:18]];
    
    futureLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.43*screenWidth, 0.28
                                                            *hdView.frame.size.height, 0.36*screenWidth, 40)];
    futureLabel.textAlignment = NSTextAlignmentCenter;
    futureLabel.font = [UIFont fontWithName:@"Gabriola" size:30];
    futureLabel.textColor = [UIColor whiteColor];
    //futureLabel.backgroundColor = [UIColor yellowColor];
    
    [hdView addSubview:spinner];
    [hdView addSubview:refreshLabel];
    [hdView addSubview:myBillyImageView];
    [hdView addSubview:billyLabel];
    [hdView addSubview:futureLabel];
    self.tableView.tableHeaderView = hdView;
}

-(void)billyTapped{
    APLLog(@"Billy tapped: %@",numberOfMessagesInTheFuture);
    
    [self initHeaderView];
    
    billyTapRecognizer.enabled = NO;
    
    futureLabel.text = [NSString stringWithFormat:@"%@!",numberOfMessagesInTheFuture];
    myBillyImageView.image = [myGeneralMethods scaleImage3:[UIImage imageNamed:@"panda_parle.png"] withFactor:2];
    
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
    myBillyImageView.image = [myGeneralMethods scaleImage3:[UIImage imageNamed:@"panda_top_timeline.png"] withFactor:2];
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
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //------------------replace the tabbar in case it is not--------------
    CGRect frame2 = self.tabBarController.tabBar.frame;
    CGFloat height2 = frame2.size.height;
    
    // zero duration means no animation
    CGFloat duration = (animated)? 0.3 : 0.0;
    [UIView animateWithDuration:duration animations:^{
        self.tabBarController.tabBar.frame = CGRectMake(0, screenHeight-height2, frame2.size.width, frame2.size.height);
    }];
    
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
    APLLog(@"vibrateForNewShyft: %@",[notification.userInfo description]);
    NSMutableDictionary *newPhotoMessage2 = [notification.userInfo mutableCopy];

    if([myShyftSet isLoaded]){
        [self vibrateNow:newPhotoMessage2];
    }
    else{
        [self vibrateLater:newPhotoMessage2];
    }
    
}

-(void)vibrateNow:(NSMutableDictionary *)newPhotoMessage{
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
    
    APLLog(@"vibrate for new shyft: %@", [newPhotoMessage description]);
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    [[[GPSession alloc] init] increaseReceiveTipCounter];
    
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
        for(NSMutableDictionary *loadDic in messagesDataFile){
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
            for(NSMutableDictionary *unloadedMessage in loadBox){
                
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
}

-(void)stopLoadingAnimation{
    APLLog(@"stopLoadingAnimation");
    [_spinnerTop stopAnimating];
    _loadingLabel.text = @"";
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
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
        PhotoDetail * vc = (PhotoDetail *)[storyboard instantiateViewControllerWithIdentifier:@"PhotoDetail"];
        vc.shyftToDetail = [myShyftSet getShyftAtIndex:indexPath.row];
        if(vc.shyftToDetail != nil){
            zoomOn = true;
            [self presentViewController:vc animated:NO completion:nil];
        }
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
        
        
        
        //------------------sender name-------------------------------------
        if(![shyftForCell.fullName isEqualToString:@""]){
            shyftCell.nameLabel.text = shyftForCell.fullName;
            shyftCell.emailLabel.text = @"";
        }
        else{
            shyftCell.nameLabel.text = shyftForCell.from_numero;
            shyftCell.emailLabel.text = shyftForCell.from_email;
        }
        
        
        //--------------------in 3 days, in 3 months, in a year--------------------------
        if(shyftForCell.receive_label){
            if(![shyftForCell.receive_label isEqualToString:@"calendar"]){
                shyftCell.periodLabel.text = shyftForCell.receive_label;
            }
            else{
                if(shyftForCell.created_at){
                    NSDate *realDate = [NSDate dateWithTimeIntervalSince1970:([shyftForCell.created_at doubleValue])];
                    shyftCell.periodLabel.text = [NSString stringWithFormat:@"Sent: %@",[myGeneralMethods getStringToPrint:realDate]];
                }
            }
        }
        shyftCell.periodLabel.backgroundColor = shyftForCell.color;
        [shyftCell.periodLabel setFont:[UIFont fontWithName:@"Gabriola" size:24]];
        
        //-----------------date of reception-----------------------------------------
        if(shyftForCell.receive_date){
            shyftCell.dateLabel.text = [myGeneralMethods getStringToPrint2:shyftForCell.receive_date];
        }
        
        //------------------PHOTO----------------------------
        shyftCell.bigImageView.image = shyftForCell.croppedImage;
        
        //------------------text if textmessage----------------
        if ([shyftForCell isTextMessage]) {
            
            shyftCell.messageLabel.text = shyftForCell.message;
            shyftCell.messageLabel.textColor = shyftForCell.color;
        }
        else{
            shyftCell.messageLabel.text = @"";
        }
        
        //-------------------sender profile picture---------------------
        shyftCell.userProfileImageView.layer.cornerRadius = shyftCell.userProfileImageView.frame.size.width / 2;
        shyftCell.userProfileImageView.layer.masksToBounds = YES;
        
        if(shyftForCell.userProfileImage != nil){
            shyftCell.userProfileImageView.image = shyftForCell.userProfileImage;
        }
        
        
        //-------------buttons-------------------------
        [shyftCell.fbButton addTarget:self action:@selector(shareOnFB:) forControlEvents:UIControlEventTouchUpInside];
        [shyftCell.fbButton setImage:[myGeneralMethods scaleImage3:[UIImage imageNamed:@"buton_fb.png"] withFactor:1.5] forState:UIControlStateNormal];
        [shyftCell.resendButton addTarget:self action:@selector(resendPressed:) forControlEvents:UIControlEventTouchUpInside];
        [shyftCell.resendButton setImage:[myGeneralMethods scaleImage3:[UIImage imageNamed:@"bulle_resend.png"] withFactor:1.5] forState:UIControlStateNormal];
        
        cell.backgroundColor = [UIColor clearColor];
        shyftCell.backgroundLabel.frame = CGRectMake(0, 0, screenWidth, 60);
    }
    else{
        static NSString* CellIdentifier2 = @"PandaCell";
        // Configure the cell
        APLLog(@"shyftForCell: Panda");
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2 forIndexPath:indexPath];
        
        PandaCell *pandaCell = (PandaCell *)cell;
        
        pandaCell.pandaSpeakLabel.text = @"Be careful! The timeline contains only your 10 last messages. Resend them in the future if you want to remember them!";
        pandaCell.pandaSpeakLabel.font = [UIFont fontWithName:@"Gabriola" size:20];
        pandaCell.contentMode = UIViewContentModeCenter;
        pandaCell.pandaImgv.image = [myGeneralMethods scaleImage3:[UIImage imageNamed:@"little_billy_disco.png"] withFactor:1.7];
    }
    
    
    
    return cell;
    
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
            
            //---------------------photo message
            if((![theShyftToShare.photo isEqualToString:@"None"])&&(![theShyftToShare.photo isEqualToString:@""])){
                imageToShare = theShyftToShare.uiControl;
            }
            else{//-----------------text message
                NSString *shyftMessage = theShyftToShare.message;
                UIFont *messageFont = [UIFont systemFontOfSize:18];
                
                CGSize messageLabelSize = [myGeneralMethods text:shyftMessage sizeWithFont:messageFont constrainedToSize:CGSizeMake(screenWidth-30, 180)];
                imageToShare = theShyftToShare.croppedImage;
                
                imageToShare = [KeoMessages drawText2:shyftMessage inImage:imageToShare inRect:CGRectMake(imageToShare.size.width*0.5-messageLabelSize.width*0.5, imageToShare.size.height*0.5-messageLabelSize.height*0.5, messageLabelSize.width,messageLabelSize.height) withFont:messageFont withColor:theShyftToShare.color];
            }
            
            
            imageToShare = [KeoMessages prepareImageForExport:imageToShare withLabel:theShyftToShare.receive_label];
            
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
        UIAlertView *alert5 = [[UIAlertView alloc]
                               initWithTitle:@"Connection problem"
                               message:@"You have no internet connection" delegate:self
                               cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert5 show];
    }
}


//------------------------------------------------------------------------------------------------------------------------
//-------------------prepare image for facebook export (add shyft logo and name on the picture)---------------------------
//------------------------------------------------------------------------------------------------------------------------

+ (UIImage*) prepareImageForExport:(UIImage *)imageForExport withLabel:(NSString*)labelForExport{
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
    
    return imageForExport;
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
            
            if(![theShyftToResend.shyft_id isEqualToString:@""]){//----------------new way to resend (to keep)--------------
                UIAlertView *resendAlert = [[UIAlertView alloc] initWithTitle:my_actionsheet_want_to_remember message:@"Resend it to yourself randomly in the future!"  delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"Resend", nil];
                [resendAlert show];
            }
            else{
                //--------------old way to resend (to delete in a few weeks)---------------------
                UIAlertView *resendAlert = [[UIAlertView alloc] initWithTitle:my_actionsheet_want_to_remember message:@"Resend it to yourself randomly in the future!"  delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"Resend", nil];
                [resendAlert show];
                
            }
        }
    }
    else{
        UIAlertView *alert5 = [[UIAlertView alloc]
                               initWithTitle:@"Connection problem"
                               message:@"You have no internet connection" delegate:self
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
    
    
    if([alertView.title isEqualToString:my_actionsheet_want_to_remember]){
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
                    }
                    [myGeneralMethods saveMessagesData];
                    
                    
                }
                
            }
            else{
                UIAlertView *alert5 = [[UIAlertView alloc]
                                       initWithTitle:@"Connection problem"
                                       message:@"You have no internet connection" delegate:self
                                       cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert5 show];
            }
        }
    }
    else if([alertView.title isEqualToString:my_actionsheet_wanna_help_us]){
        if (buttonIndex == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:myVersionInstallUrl]];
        }
    }
    else if ([alertView.title isEqualToString:my_actionsheet_you_are_great]){
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
            }
            [myGeneralMethods saveMessagesData];
        }
    }
}


//---------------------get indexpath of shyft in messages data file-------------------------
+ (NSUInteger)getIndexPathOfShyft:(ShyftMessage *)myShyftToDelete{
    for(NSMutableDictionary* currentMessage in messagesDataFile){
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
        return 368;
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
                [refreshLabel setFont:[UIFont systemFontOfSize:12]];
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


@end

//
//  WelcomeScreen.m
//  Keo
//
//  Created by Gauthier Petetin on 10/06/2014.
//  Copyright (c) 2014 Gauthier Petetin. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////(GO TO APPDELEGATE.M FOR MORE INFO ABOUT THE GLOBAL VARIABLES)/////////////////////////////////

#import <AWSiOSSDKv2/AWSCore.h>
#import <AWSiOSSDKv2/AWSMobileAnalytics.h>

#import "WelcomeScreen.h"

#import "GPRequests.h"
#import "GPSession.h"

#import "myGeneralMethods.h"
#import "myConstants.h"

#import "PickContact.h"
#import "AppDelegate.h"
#import "ContactModel.h"
#import "ShyftMessage.h"
#import "ShyftSet.h"


@interface WelcomeScreen ()

@end

@implementation WelcomeScreen

NSUserDefaults *prefs;

NSString *myAppVersion;

ShyftSet *myShyftSet;//global

//Amazon
NSString *aws_account_id;
NSString *cognito_pool_id;
NSString *cognito_role_auth;
NSString *cognito_role_unauth;
NSString *S3BucketName;
//

//new App version
bool myVersionForceInstall;//global
NSString *myVersionInstallUrl;//global
//

NSString *myDeviceToken;

NSString *myUserID;

NSString *username;
NSString *hashPassword;
NSString *myCurrentPhoneNumber;
NSString *myCountryCode;
NSString *myStatus;//global

NSString *downloadPhotoRequestName;

NSString *adresseIp2;//global


NSMutableArray *importKeoChoices;//global
NSMutableArray *importContactsData; //global
NSMutableDictionary *importKeoPhotos;//global

bool logIn;//global
int openingWindow;//global
bool firstGlobalOpening;//global
bool firstContactOpening;//global

//size if the screen
CGFloat screenWidth;//global
CGFloat screenHeight;//global
CGFloat tabBarHeight;//global

UILabel *deviceLabel;
UILabel *myUpdateVersionLabel;
UILabel *myWelcomeLabel2;
UIButton *signUpButton2;
UIButton *logInButton2;
UIButton *installButton;

UIColor *theKeoOrangeColor;//global

NSString *storyboardName;//global

NSString *jsonOfContatPhones;//global

int imageViewSize;
int xLabel;
int xButton;
int yInitial;
int yButton;
int xButton2;
int yButton2;

NSTimer *myWelcomeTimer;

bool localWork;

GPSession *myUploadContactSession;//global

int myBlinkingCounter;

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
    APLLog(@"Welcome screen");
    
    if(![GPRequests connected]){
        UIAlertView *alert5 = [[UIAlertView alloc]
                               initWithTitle:@"Connection problem"
                               message:@"You have no internet connection" delegate:self
                               cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert5 show];
    }
    
    myBlinkingCounter = 0;
    
    [self doFirstLogin];
    //[NSThread detachNewThreadSelector:@selector(doFirstLogin) toTarget:self withObject:nil];
    
    
}


-(void)decideWhichViewToLaunch{
    if(myVersionForceInstall){
        [self.view addSubview:myUpdateVersionLabel];
        [self.view addSubview:installButton];
    }
    else{
        if(logIn){//------------------------user already log in---------------------------
            APLLog(@"already logIn");
            
            self.view.backgroundColor =  [[UIColor alloc] initWithPatternImage:[myGeneralMethods scaleImage:[UIImage imageNamed:@"Ecran_acceuil_orange5@2x.png"]]];
            
            //// Switch screen
            
            bool userHasPhoneNumber = false;
            if(myCurrentPhoneNumber){
                if(![myCurrentPhoneNumber isEqualToString:@""]){
                    if(myCountryCode){
                        if(![myCountryCode isEqualToString:@""]){
                            userHasPhoneNumber = true;
                        }
                    }
                }
            }
            
            if(!userHasPhoneNumber){
                APLLog(@"please enter a phoneNumber first!");
                //// Switch screen to phone number
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
                    UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"phoneScreen"];
                    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                    [self presentViewController:vc animated:YES completion:nil];
                });
            }
            else{
                APLLog(@"okay for phoneNumber");
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
                    UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"MasterController"];
                    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                    [self presentViewController:vc animated:YES completion:nil];
                });
            }
        }
        //---------------user not login --> needs to sign up or login----------------
        else{
            APLLog(@"not login - show controls");
            self.view.backgroundColor =  [[UIColor alloc] initWithPatternImage:[myGeneralMethods scaleImage:[UIImage imageNamed:@"Ecran_acceuil_orange_empty.png"]]];
            [self initControls];
            [self.view addSubview:myWelcomeLabel2];
            [self.view addSubview:signUpButton2];
            [self.view addSubview:logInButton2];
        }
    }
    
}

-(void)doFirstLogin{
    //-------------------first login (we receive a lot of info from the server in answer) -------------------------
    
    if(username){
        if(hashPassword){
            if(!myVersionForceInstall){
                APLLog(@"Do first login!");
                if([GPRequests connected]){
                    [[[GPSession alloc]init] asynchronousLoginWithEmailfor:self];
                }
                else{
                    [NSThread detachNewThreadSelector:@selector(askThingsInBackground) toTarget:self withObject:nil];
                }
            }
        }
    }
}

-(void)askThingsInBackground{
    APLLog(@"askThingsInBackground");
    if(myCurrentPhoneNumber){
        if(![myCurrentPhoneNumber isEqualToString:@""]){
            [[[GPSession alloc] init] getStatusRequest:self];
            //[GPRequests askKeoChoicesfor:self];
            [[[GPSession alloc] init] askSendChoicesfor:self];
            bool contactsOk = [[ContactModel alloc] init];
            if(contactsOk){
                APLLog(@"Contacts loaded");
            }
            [myUploadContactSession uploadContacts:[myGeneralMethods createJsonArrayOfContacts] withTableViewReload:YES for:self];
        }
    }
}

//---------------go to the app store (in the case we want to force a new version installation)-----
-(void)installNewApp{
    myVersionForceInstall = false;
    [prefs setBool:myVersionForceInstall forKey:@"myVersionForceInstall"];
    APLLog(@"installNewApp pressed");
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: myVersionInstallUrl]];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//------------------alertview to inform the user (not force) about a new version-------------------

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *locTitle = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([locTitle isEqualToString:@"Install"]){
        APLLog(@"Install was selected.");
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: myVersionInstallUrl]];
    }
    if([locTitle isEqualToString:@"Cancel"]){
        APLLog(@"Cancel (install new version) was selected.");
    }
}


//-----------------the user wants to create a new account-->go to sign up screen----------------

-(void)signUpPressed{
    //// Switch screen
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"registerScreen"];
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:vc animated:YES completion:nil];
}

//-----------------the user already has an account-->go to log in screen----------------

-(void)logInPressed{
    //// Switch screen
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"logInScreen"];
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:vc animated:YES completion:nil];
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

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"insertNewRow" object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(insertNewRow:) name:@"insertNewRow" object: nil];
    
    [self decideWhichViewToLaunch];
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}


-(void)initControls{
    imageViewSize=150;
    xLabel = 300;
    xButton = 200;
    //yInitial = 325;
    yInitial = 290;
    yButton = 50;
    xButton2 = 90;
    yButton2 = 30;
    
    //--------------creation of welcome label
    CGRect rectLabUsername = CGRectMake(0.5*screenWidth-(0.5*xLabel),70,xLabel,60);
    myWelcomeLabel2 = [[UILabel alloc] initWithFrame: rectLabUsername];
    [myWelcomeLabel2 setTextAlignment:NSTextAlignmentCenter];
    [myWelcomeLabel2 setFont:[UIFont fontWithName:@"Gabriola" size:42]];
    myWelcomeLabel2.text = @"Welcome to Pictever!";
    myWelcomeLabel2.textColor = [UIColor whiteColor];
    
    
    //---------------Creation of Sign Up button
    signUpButton2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    signUpButton2.frame = CGRectMake(0.5*screenWidth-(0.5*xButton),yInitial,xButton,yButton);
    signUpButton2.backgroundColor = [UIColor clearColor];
    signUpButton2.layer.cornerRadius = 8;
    signUpButton2.clipsToBounds = YES;
    //[[signUpButton2 layer] setBorderWidth:2.0f];
    //[[signUpButton2 layer] setBorderColor:[UIColor whiteColor].CGColor];
    [signUpButton2 setTitle:@"SIGN UP" forState:UIControlStateNormal];
    [signUpButton2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [signUpButton2.titleLabel setFont:[UIFont fontWithName:@"Gabriola" size:47]];
    [signUpButton2 addTarget:self
                      action:@selector(signUpPressed)
            forControlEvents:UIControlEventTouchUpInside];
    
    //-----------------Creation of Log IN button
    logInButton2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    logInButton2.frame = CGRectMake(screenWidth-xButton2-10,screenHeight-yButton2-10,xButton2,yButton2);
    logInButton2.backgroundColor = [UIColor clearColor];
    logInButton2.layer.cornerRadius = 8;
    logInButton2.clipsToBounds = YES;
    //[[logInButton2 layer] setBorderWidth:2.0f];
    //[[logInButton2 layer] setBorderColor:[UIColor whiteColor].CGColor];
    [logInButton2 setTitle:@"LOG IN" forState:UIControlStateNormal];
    [logInButton2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [logInButton2.titleLabel setFont:[UIFont fontWithName:@"Gabriola" size:27]];
    [logInButton2 addTarget:self
                     action:@selector(logInPressed)
           forControlEvents:UIControlEventTouchUpInside];
    
    //--------------creation of label Update app version(in the case we want to force a new version installation)
    CGRect rectLabUpdate = CGRectMake(0.5*screenWidth-(0.5*xLabel),50,xLabel,60);
    myUpdateVersionLabel = [[UILabel alloc] initWithFrame: rectLabUpdate];
    [myUpdateVersionLabel setTextAlignment:NSTextAlignmentCenter];
    [myUpdateVersionLabel setFont:[UIFont systemFontOfSize:18]];
    myUpdateVersionLabel.text = @"Please update your app version";
    myUpdateVersionLabel.textColor = [UIColor whiteColor];
    
    //----------------Creation of Install button (in the case we want to force a new version installation)
    installButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    installButton.frame = CGRectMake(0.5*screenWidth-(0.5*xButton),yInitial,xButton,yButton);
    installButton.backgroundColor = [UIColor clearColor];
    [installButton setTitle:@"INSTALL NOW" forState:UIControlStateNormal];
    [installButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [installButton.titleLabel setFont:[UIFont systemFontOfSize:23]];
    [installButton addTarget:self
                      action:@selector(installNewApp)
            forControlEvents:UIControlEventTouchUpInside];
    
    [self flashOn:signUpButton2];
}

- (void)flashOff:(UIView *)v
{
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^ {
        signUpButton2.alpha = .1;  //don't animate alpha to 0, otherwise you won't be able to interact with it
    } completion:^(BOOL finished) {
        [self flashOn:v];
    }];
}

- (void)flashOn:(UIView *)v
{
    myBlinkingCounter +=1;
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^ {
        signUpButton2.alpha = 1;
    } completion:^(BOOL finished) {
        if(myBlinkingCounter<8){
            [self flashOff:v];
        }
    }];
}

@end

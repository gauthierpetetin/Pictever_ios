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

UIActivityIndicatorView *facebookLoginSpinner;

//Amazon
NSString *aws_account_id;
NSString *cognito_pool_id;
NSString *cognito_role_auth;
NSString *cognito_role_unauth;
NSString *S3BucketName;
//

NSString *myFacebookName;
NSString *myFacebookID;
NSString *myFacebookBirthDay;

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

FBLoginView *fbLoginView;
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
                    UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:my_storyboard_phone_screen];
                    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                    [self presentViewController:vc animated:YES completion:nil];
                });
            }
            else{
                APLLog(@"okay for phoneNumber");
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
                    UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:my_storyboard_master_controller];
                    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                    [self presentViewController:vc animated:YES completion:nil];
                });
            }
        }
        //---------------user not login --> needs to sign up or login----------------
        else{
            APLLog(@"not login - show controls");
            //self.view.backgroundColor =  [[UIColor alloc] initWithPatternImage:[myGeneralMethods scaleImage:[UIImage imageNamed:@"Ecran_acceuil_orange_empty.png"]]];
            self.view.backgroundColor =  [[UIColor alloc] initWithPatternImage:[myGeneralMethods scaleImage:[UIImage imageNamed:@"FillesTrek@2x.png"]]];
            //self.view.backgroundColor =  [[UIColor alloc] initWithPatternImage:[myGeneralMethods scaleImage:[UIImage imageNamed:@"GarconMontagneOrange@2x.png"]]];
            [self initControls];

            [self.view addSubview:signUpButton2];
            [self.view addSubview:logInButton2];
            [self.view addSubview:fbLoginView];
        }
    }
    
}

-(void)doFirstLogin{
    //-------------------first login (we receive a lot of info from the server in answer) -------------------------
    
    if(username){
        if(![username isEqualToString:@""]){
            if(logIn){
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
    
    if([alertView.title isEqualToString:my_actionsheet_install_it_now]){
        NSString *locTitle = [alertView buttonTitleAtIndex:buttonIndex];
        
        if([locTitle isEqualToString:@"Install"]){
            APLLog(@"Install was selected.");
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString: myVersionInstallUrl]];
        }
        if([locTitle isEqualToString:@"Cancel"]){
            APLLog(@"Cancel (install new version) was selected.");
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
    
    [signUpButton2 removeFromSuperview];
    [logInButton2 removeFromSuperview];
    [fbLoginView removeFromSuperview];

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
    xButton = screenWidth-30;
    //yInitial = 325;
    yInitial = 290;
    yButton = 35;
    xButton2 = 90;
    yButton2 = 10;
    
    //--------------creation of welcome label
    CGRect rectLabUsername = CGRectMake(0.5*screenWidth-(0.5*xLabel),0.15*screenHeight,xLabel,60);
    myWelcomeLabel2 = [[UILabel alloc] initWithFrame: rectLabUsername];
    [myWelcomeLabel2 setTextAlignment:NSTextAlignmentCenter];
    [myWelcomeLabel2 setFont:[UIFont fontWithName:@"Gabriola" size:42]];
    myWelcomeLabel2.text = @"Welcome to Pictever!";
    myWelcomeLabel2.textColor = [UIColor whiteColor];
    
    fbLoginView = [[FBLoginView alloc] initWithReadPermissions:
                   @[@"public_profile", @"email"]];
    // Align the button in the center horizontally
    fbLoginView.frame = CGRectMake(0.5*screenWidth-0.5*xButton,screenHeight-3*yButton-3*yButton2,xButton,yButton);
    fbLoginView.layer.cornerRadius = 4;
    fbLoginView.alpha = 0.95;
    for (id obj in fbLoginView.subviews)
    {
        if ([obj isKindOfClass:[UIButton class]])
        {
            UIButton * loginButton =  obj;
            UIImage *loginImage = [UIImage imageNamed:@"Facebookconnect.png"];
            [loginButton setBackgroundImage:loginImage forState:UIControlStateNormal];
            [loginButton setBackgroundImage:nil forState:UIControlStateSelected];
            [loginButton setBackgroundImage:nil forState:UIControlStateHighlighted];
            [loginButton sizeToFit];
        }
        if ([obj isKindOfClass:[UILabel class]])
        {
            UILabel * loginLabel =  obj;
            loginLabel.text = @"Connect with Facebook";
            loginLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
            loginLabel.textAlignment = NSTextAlignmentCenter;
            loginLabel.frame = CGRectMake(0, 0, fbLoginView.frame.size.width, fbLoginView.frame.size.height);
        }
    }
    fbLoginView.delegate = self;
    
    //---------------Creation of Sign Up button
    signUpButton2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    signUpButton2.frame = CGRectMake(0.5*screenWidth-(0.5*xButton),screenHeight-2*yButton-yButton2-5,xButton,yButton);
    signUpButton2.backgroundColor = [UIColor darkGrayColor];
    signUpButton2.layer.cornerRadius = 4;
    signUpButton2.clipsToBounds = YES;
    //[[signUpButton2 layer] setBorderWidth:2.0f];
    //[[signUpButton2 layer] setBorderColor:[UIColor whiteColor].CGColor];
    [signUpButton2 setTitle:@"Register with email" forState:UIControlStateNormal];
    [signUpButton2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    signUpButton2.alpha = 0.75;
    [signUpButton2 addTarget:self
                      action:@selector(signUpPressed)
            forControlEvents:UIControlEventTouchUpInside];
    
    //-----------------Creation of Log IN button
    logInButton2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    logInButton2.frame = CGRectMake(0.5*screenWidth-(0.5*xButton),screenHeight-yButton-yButton2,xButton,yButton);
    logInButton2.backgroundColor = [UIColor darkGrayColor];
    logInButton2.layer.cornerRadius = 4;
    logInButton2.clipsToBounds = YES;
    //[[logInButton2 layer] setBorderWidth:2.0f];
    //[[logInButton2 layer] setBorderColor:[UIColor whiteColor].CGColor];
    [logInButton2 setTitle:@"Log in" forState:UIControlStateNormal];
    [logInButton2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    logInButton2.alpha = 0.61;
    [logInButton2 addTarget:self
                     action:@selector(logInPressed)
           forControlEvents:UIControlEventTouchUpInside];
    
    //--------------creation of label Update app version(in the case we want to force a new version installation)
    CGRect rectLabUpdate = CGRectMake(0.5*screenWidth-(0.5*xLabel),0.1*screenHeight,xLabel,60);
    myUpdateVersionLabel = [[UILabel alloc] initWithFrame: rectLabUpdate];
    [myUpdateVersionLabel setTextAlignment:NSTextAlignmentCenter];
    [myUpdateVersionLabel setFont:[UIFont systemFontOfSize:18]];
    myUpdateVersionLabel.text = @"Please update your app version";
    myUpdateVersionLabel.textColor = [UIColor whiteColor];
    
    //----------------Creation of Install button (in the case we want to force a new version installation)
    installButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    installButton.frame = CGRectMake(0.5*screenWidth-(0.5*xButton),0.6*screenHeight,xButton,yButton);
    installButton.backgroundColor = [UIColor clearColor];
    [installButton setTitle:@"INSTALL NOW" forState:UIControlStateNormal];
    [installButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [installButton.titleLabel setFont:[UIFont systemFontOfSize:23]];
    [installButton addTarget:self
                      action:@selector(installNewApp)
            forControlEvents:UIControlEventTouchUpInside];
    
    //-----------------Creation of loading facebook spinner---------
    facebookLoginSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    facebookLoginSpinner.center = CGPointMake(0.5*screenWidth,0.5*screenHeight);
    facebookLoginSpinner.color = [UIColor blackColor];
    facebookLoginSpinner.hidesWhenStopped = YES;

}


- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    APLLog(@"FBcall was handled");
    
    // Call FBAppCall's handleOpenURL:sourceApplication to handle Facebook app responses
    BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    
    // You can add your app-specific url handling code here if needed
    
    return wasHandled;
}

// This method will be called when the user information has been fetched
- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    
    [signUpButton2 removeFromSuperview];
    [logInButton2 removeFromSuperview];
    [fbLoginView removeFromSuperview];
    
    myFacebookName = [user name];
    myFacebookID = [user objectID];
    if([user objectForKey:@"user_birthday"]){
        myFacebookBirthDay = [user objectForKey:@"user_birthday"];
        if(!myFacebookBirthDay){
            myFacebookBirthDay = @"";
        }
    }
    else{
        myFacebookBirthDay = @"";
    }
    if([user objectForKey:@"email"]){
        username = [user objectForKey:@"email"];
    }
    else{
        username = @"";
    }
    
    APLLog(@"fetched user with info: %@ and id: %@ and birthday:%@ and email: %@", myFacebookName, myFacebookID, myFacebookBirthDay,username);
    
    [prefs setObject:myFacebookName forKey:my_prefs_fb_name_key];
    [prefs setObject:myFacebookID forKey:my_prefs_fb_id_key];
    [prefs setObject:myFacebookBirthDay forKey:my_prefs_fb_birthday_key];
    
    
    [self localAsynchronousFacebookLoginWithID:myFacebookID withFbName:myFacebookName andBirthday:myFacebookBirthDay for:self];
}

//------------Logged-in user experience
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    
    APLLog(@"User logged on facebook");
}

//----------Logged-out user experience
- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    APLLog(@"user logged out");
}

//----------------Handle possible errors that can occur during login
- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    NSString *alertMessage, *alertTitle;
    
    // If the user should perform an action outside of you app to recover,
    // the SDK will provide a message for the user, you just need to surface it.
    // This conveniently handles cases like Facebook password change or unverified Facebook accounts.
    if ([FBErrorUtility shouldNotifyUserForError:error]) {
        alertTitle = @"Facebook error";
        alertMessage = [FBErrorUtility userMessageForError:error];
        
        // This code will handle session closures that happen outside of the app
        // You can take a look at our error handling guide to know more about it
        // https://developers.facebook.com/docs/ios/errors
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
        
        // If the user has cancelled a login, we will do nothing.
        // You can also choose to show the user a message if cancelling login will result in
        // the user not being able to complete a task they had initiated in your app
        // (like accessing FB-stored information or posting to Facebook)
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
        NSLog(@"user cancelled login");
        
        // For simplicity, this sample handles other errors with a generic message
        // You can checkout our error handling guide for more detailed information
        // https://developers.facebook.com/docs/ios/errors
    } else {
        alertTitle  = @"Something went wrong";
        alertMessage = @"Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}



-(void)localAsynchronousFacebookLoginWithID:(NSString *)fbID withFbName:(NSString *)fbName andBirthday:(NSString *)fbBirthday for:(id)sender{
    
    if ([GPRequests connected]){

        [self.view addSubview:facebookLoginSpinner];
        [facebookLoginSpinner startAnimating];
        
        // 1
        NSURL *loginUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",adresseIp2,my_loginRequestName]];
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
        
        // 2
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:loginUrl];
        request.HTTPMethod = @"POST";
        
        // 3
        
        
        NSString *postString = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@",@"email=",username,@"&password=",hashPassword,@"&reg_id=",myDeviceToken,@"&os=ios",@"&app_version=",myAppVersion,@"&facebook_id=",fbID,@"&facebook_name=",fbName,@"&facebook_birthday=",fbBirthday];
        APLLog([NSString stringWithFormat:@" local asynchronous login session post: %@",postString]);
        NSData* data = [postString dataUsingEncoding:NSUTF8StringEncoding];
        
        NSError *error = nil;
        
        if (!error) {
            // 4
            APLLog(@"local login session: %@", loginUrl);
            NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request
                                                                       fromData:data completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
                                                                           dispatch_async(dispatch_get_main_queue(), ^{
                                                                               [self.view addSubview:signUpButton2];
                                                                               [self.view addSubview:logInButton2];
                                                                               [self.view addSubview:fbLoginView];
                                                                               [facebookLoginSpinner stopAnimating];
                                                                               [facebookLoginSpinner removeFromSuperview];
                                                                           });
                                                                           if(error != nil){
                                                                               APLLog(@"New login Error: [%@]", [error description]);
                                                                               
                                                                           }
                                                                           else{
                                                                               NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                                                               NSInteger sessionErrorCode = [httpResponse statusCode];
                                                                               [self localFacebookLoginSucceeded:data withErrorCode:sessionErrorCode from:sender];
                                                                           }
                                                                       }];
            
            // 5
            [uploadTask resume];
        }
    }
}

-(void)localFacebookLoginSucceeded:(NSData *)data withErrorCode:(NSInteger)sessionErrorCode from:(id)sender{
    APLLog(@"local login session did receive response with error code: %i",sessionErrorCode);
    if(sessionErrorCode != 200){
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:@"Facebook connection error" delegate:self
                                  cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            
        });
    }
    else{
        firstUseEver = true;
        logIn = true;
        
        //---------saves user info--------------
        
        [prefs setBool:logIn forKey:my_prefs_login_key];
        [prefs setObject:username forKey:my_prefs_username_key];
        [prefs setObject:hashPassword forKey:my_prefs_password_key];
        
        //-----------update timestamp-------------------------------
        NSString *newLogInTimeStamp = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
        mytimeStamp = newLogInTimeStamp;
        [prefs setObject:newLogInTimeStamp forKey:my_prefs_timestamp_key];
        
        
        //--------------Switch screen to phone number------
        dispatch_async(dispatch_get_main_queue(), ^{
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
            UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:my_storyboard_phone_screen];
            vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            [self presentViewController:vc animated:YES completion:nil];
        });
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view addSubview:signUpButton2];
        [self.view addSubview:logInButton2];
        [self.view addSubview:fbLoginView];
        [facebookLoginSpinner stopAnimating];
        [facebookLoginSpinner removeFromSuperview];
    });
}


@end

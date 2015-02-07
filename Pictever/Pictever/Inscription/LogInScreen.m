//
//  LogInScreen.m
//  Keo
//
//  Created by Gauthier Petetin on 14/03/2014.
//  Copyright (c) 2014 Gauthier Petetin. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////(GO TO APPDELEGATE.M FOR MORE INFO ABOUT THE GLOBAL VARIABLES)/////////////////////////////////

#import "LogInScreen.h"
#import "RegisterScreen.h"
#import "GPRequests.h"
#import <AWSiOSSDKv2/AWSMobileAnalytics.h>
#import <AWSiOSSDKv2/AWSCore.h>
#import "myConstants.h"
#import "GPSession.h"
#import "myGeneralMethods.h"


@interface LogInScreen ()

//@property (nonatomic, strong) NSMutableData *responseData2;


@end

@implementation LogInScreen

bool firstUseEver;



bool openingWindow;
NSString *storyboardName;

//size if the screen
CGFloat screenWidth;//global
CGFloat screenHeight;//global
CGFloat tabBarHeight;//global

NSString *adresseIp2;
NSString *myAppVersion;

NSUserDefaults *prefs;

CGSize keyboardSize;
CGRect rect;

UITextField *textFieldUsernameLogin;
UITextField *textFieldPassword1Login;


//UILabel *myWelcomeLabel;
UILabel *monLabelPassword1;

UITapGestureRecognizer *tapRecognizer;
UIButton *backButton2;
UIButton *passwordRecoveryButton;

UIButton *logInButton;

NSString *myLocaleString;
NSString *username;//global
NSString *password;
NSString *password1;
NSString *hashPassword;//global
NSString *myCurrentPhoneNumber;//global

UIColor *theKeoOrangeColor;
UIColor *thePicteverGreenColor;//global
UIColor *thePicteverYellowColor;//global
UIColor *thePicteverRedColor;//global
UIColor *thePicteverGrayColor;//global

NSString *reponseLogIn;
NSString *myDeviceToken;
NSString *mytimeStamp;

bool logIn;
bool *connectionDidFinishLoadingOver;


int height;
int yInitial;
int xPassword;
int xButton;
int xUsername;
int yUsername;
int yEspace;
int elevation;

UIActivityIndicatorView *loginSpinnerLogin;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[myGeneralMethods scaleImage:[UIImage imageNamed:@"RegisterBackground@2x.png"]]];
    //self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[myGeneralMethods scaleImage:[UIImage imageNamed:@"GarconMontagneEmpty@2x.png"]]];
    
    logIn = false;
    
    
    connectionDidFinishLoadingOver = false;
    
    [self initControls];
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(setUsernameByNotif) name:@"setUsername" object: nil];

}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    logInButton.enabled = YES;
    logInButton.highlighted = NO;
    passwordRecoveryButton.enabled = YES;
    passwordRecoveryButton.highlighted = NO;
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.view addSubview: backButton2];
    //[self.view addSubview: myWelcomeLabel];
    [self.view addSubview: textFieldUsernameLogin];
    [self.view addSubview: textFieldPassword1Login];
    [self.view addSubview: logInButton];
    [self.view addSubview:passwordRecoveryButton];
    [self.view addGestureRecognizer:tapRecognizer];
    [textFieldUsernameLogin becomeFirstResponder];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [loginSpinnerLogin stopAnimating];
    [loginSpinnerLogin removeFromSuperview];
}

//----------set username when user comes from Register screen ------------------------

-(void)setUsernameByNotif{
    APLLog(@"setUsername");
    textFieldUsernameLogin.text=username;
}


//---------------hide keyboard when user taps the screen---------

- (IBAction)respondToTapGesture2:(UITapGestureRecognizer *)recognizer {
    [textFieldPassword1Login resignFirstResponder];
    [textFieldUsernameLogin resignFirstResponder];
}

//---------------recover password pressed------------------------
-(void)recoverPasswordPressed{
    NSLog(@"recover password pressed");
    
    if([GPRequests connected]){
        if(![textFieldUsernameLogin.text isEqualToString:@""]){
            [[[GPSession alloc] init] sendResetMailRequest:textFieldUsernameLogin.text for:self];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
            UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:my_storyboard_password_recovery];
            vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            [self presentViewController:vc animated:YES completion:nil];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:@"Please enter your email address first!" delegate:self
                                  cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
    }
}


//----------------return pressed--------------------------

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textFieldUsernameLogin.isFirstResponder){
        [textFieldPassword1Login becomeFirstResponder];
    }
    else{
        [textFieldPassword1Login resignFirstResponder];
        [textFieldUsernameLogin resignFirstResponder];
    }
    
    return YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//-----------------go back to welcome screen ------------------------------

-(void) backPressed2{
    [myGeneralMethods initializeAllAccountVariables];
    [self dismissViewControllerAnimated:YES completion:nil];
}


//-------------------user presses login button-----------------------------------

- (IBAction)myActionLogIn:(id)sender {
    if([textFieldUsernameLogin.text isEqualToString:@""]){
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Error"
                              message:@"Please enter your username first!" delegate:self
                              cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        textFieldPassword1Login.text=@"";
    }
    else if ([textFieldPassword1Login.text isEqualToString:@""]){
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Error"
                              message:@"Please enter your password first!" delegate:self
                              cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
    else{
        username = textFieldUsernameLogin.text;
        password1 = textFieldPassword1Login.text;
        
        username = [username stringByReplacingOccurrencesOfString:@" " withString:@""];
        password1 = [password1 stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        hashPassword = [GPRequests sha256HashFor:password1];
        
        [self localAsynchronousLoginWithEmail:username withHashPass:hashPassword for:self];
        
    }
}

-(void)localAsynchronousLoginWithEmail:(NSString *) userN withHashPass:(NSString *)hashP for:(id)sender{
    
    if ([GPRequests connected]){
        logInButton.enabled = NO;
        logInButton.highlighted = YES;
        passwordRecoveryButton.enabled = NO;
        [self.view addSubview:loginSpinnerLogin];
        [loginSpinnerLogin startAnimating];
        
        // 1
        NSURL *loginUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",adresseIp2,my_loginRequestName]];
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
        
        // 2
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:loginUrl];
        request.HTTPMethod = @"POST";
        
        // 3
        
        
        NSString *postString = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@",@"email=",userN,@"&password=",hashP,@"&reg_id=",myDeviceToken,@"&os=ios",@"&app_version=",myAppVersion];
        APLLog([NSString stringWithFormat:@" local asynchronous login session post: %@",postString]);
        NSData* data = [postString dataUsingEncoding:NSUTF8StringEncoding];
        
        NSError *error = nil;
        
        if (!error) {
            // 4
            APLLog(@"local login session: %@", loginUrl);
            NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request
                                                                       fromData:data completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
                                                                           dispatch_async(dispatch_get_main_queue(), ^{
                                                                               logInButton.enabled=YES;
                                                                               logInButton.highlighted=NO;
                                                                               passwordRecoveryButton.enabled = YES;
                                                                               [loginSpinnerLogin stopAnimating];
                                                                               [loginSpinnerLogin removeFromSuperview];
                                                                           });
                                                                           if(error != nil){
                                                                               APLLog(@"New login Error: [%@]", [error description]);
                                                                               
                                                                           }
                                                                           else{
                                                                               NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                                                               NSInteger sessionErrorCode = [httpResponse statusCode];
                                                                               [self localLoginSucceeded:data withErrorCode:sessionErrorCode from:sender];
                                                                           }
                                                                       }];
            
            // 5
            [uploadTask resume];
        }
    }
}

-(void)localLoginSucceeded:(NSData *)data withErrorCode:(NSInteger)sessionErrorCode from:(id)sender{
    APLLog(@"local login session did receive response with error code: %i",sessionErrorCode);
    if(sessionErrorCode != 200){
        if(sessionErrorCode == 401){
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"Login error"
                                      message:@"Wrong password" delegate:self
                                      cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                textFieldPassword1Login.text = @"";

                //[self.view addSubview:passwordRecoveryButton];
            });
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"Error"
                                      message:@"Wrong identifier or password" delegate:self
                                      cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                
            });
        }
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
        logInButton.enabled=YES;
        logInButton.highlighted=NO;
        passwordRecoveryButton.enabled = YES;
        [loginSpinnerLogin stopAnimating];
        [loginSpinnerLogin removeFromSuperview];
    });
}


-(void)initControls{

    yInitial=115;
    xPassword=190;
    xUsername=screenWidth-40;
    yEspace=50;
    //xButton=100;
    xButton=140;
    yUsername=30;
    
    
    rect = self.view.frame;
    height = rect.size.height;
    
    
    //-------------Create tap gesture recognizer---------------------
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondToTapGesture2:)];
    tapRecognizer.numberOfTapsRequired = 1;
    
    
    //--------------------CREATION OF CONTROLS---------------------
    
    //-------------------creation of title label
    /*CGRect rectLabUsername = CGRectMake(0.5*screenWidth-(0.5*xUsername),45,xUsername,60);
    myWelcomeLabel = [[UILabel alloc] initWithFrame: rectLabUsername];
    [myWelcomeLabel setTextAlignment:NSTextAlignmentCenter];
    //[myWelcomeLabel setFont:[UIFont systemFontOfSize:30]];
    [myWelcomeLabel setFont:[UIFont fontWithName:@"Gabriola" size:42]];
    myWelcomeLabel.text = @"Log In";
    myWelcomeLabel.textColor = theKeoOrangeColor;*/
    
    
    //----------------Creation of textField Username
    CGRect rectTFUsername = CGRectMake(0.5*screenWidth-(0.5*xUsername),yInitial,xUsername,yUsername); // Définition d'un rectangle
    textFieldUsernameLogin = [[UITextField alloc] initWithFrame:rectTFUsername];
    textFieldUsernameLogin.textAlignment = NSTextAlignmentCenter;
    textFieldUsernameLogin.borderStyle = UITextBorderStyleLine;
    textFieldUsernameLogin.delegate=self;
    textFieldUsernameLogin.backgroundColor = [UIColor clearColor];
    textFieldUsernameLogin.placeholder = @"Enter your email address";
    textFieldUsernameLogin.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textFieldUsernameLogin.borderStyle = UITextBorderStyleRoundedRect;
    textFieldUsernameLogin.keyboardType = UIKeyboardTypeEmailAddress;
    textFieldUsernameLogin.font = [UIFont fontWithName:@"GothamRounded-Bold" size:16];
    textFieldUsernameLogin.layer.borderWidth = 2.0f;
    textFieldUsernameLogin.layer.borderColor = [UIColor whiteColor].CGColor;
    textFieldUsernameLogin.layer.cornerRadius = 4.0f;
    textFieldUsernameLogin.textColor = [UIColor whiteColor];
    
    //------------------Creation of textField Password1
    CGRect rectTFPassword1 = CGRectMake(0.5*screenWidth-(0.5*xUsername),yInitial+yUsername+10,xUsername,yUsername);; // Définition d'un rectangle
    textFieldPassword1Login = [[UITextField alloc] initWithFrame:rectTFPassword1];
    textFieldPassword1Login.textAlignment = NSTextAlignmentCenter;
    textFieldPassword1Login.borderStyle = UITextBorderStyleLine;
    textFieldPassword1Login.delegate=self;
    textFieldPassword1Login.backgroundColor = [UIColor clearColor];
    textFieldPassword1Login.placeholder = @"Enter your password";
    textFieldPassword1Login.borderStyle = UITextBorderStyleRoundedRect;
    textFieldPassword1Login.secureTextEntry = YES;
    textFieldPassword1Login.font = [UIFont fontWithName:@"GothamRounded-Bold" size:16];
    textFieldPassword1Login.layer.borderWidth = 2.0f;
    textFieldPassword1Login.layer.borderColor = [UIColor whiteColor].CGColor;
    textFieldPassword1Login.layer.cornerRadius = 4.0f;
    textFieldPassword1Login.textColor = [UIColor whiteColor];
    
    
    //----------------------Creation du button LOG IN
    logInButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    logInButton.frame = CGRectMake(0.5*screenWidth-(0.5*xButton),yInitial+yUsername+yUsername+20,xButton,yUsername);
    logInButton.backgroundColor = thePicteverYellowColor;
    logInButton.layer.cornerRadius = 4; // arrondir les
    logInButton.clipsToBounds = YES;     // angles du bouton
    [logInButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [logInButton setTitle:@"Let's go!" forState:UIControlStateNormal];
    [logInButton.titleLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:16]];
    [logInButton addTarget:self
                    action:@selector(myActionLogIn:)
          forControlEvents:UIControlEventTouchUpInside];
    
    //-----------------Creation of back button
    backButton2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    backButton2.frame = CGRectMake(15,screenHeight-45,70,30);
    backButton2.backgroundColor = thePicteverGreenColor;
    backButton2.alpha = 1;
    backButton2.layer.cornerRadius = 4;
    [backButton2 setTitle:@"Back" forState:UIControlStateNormal];
    [backButton2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton2.titleLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:16]];
    [backButton2 addTarget:self
                    action:@selector(backPressed2)
          forControlEvents:UIControlEventTouchUpInside];
    
    //-----------------Creation of loading spinner---------
    loginSpinnerLogin = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    loginSpinnerLogin.center = CGPointMake(0.5*screenWidth+0.5*xButton+20,yInitial+yUsername+0.5*yUsername+50);
    loginSpinnerLogin.color = [UIColor whiteColor];
    loginSpinnerLogin.hidesWhenStopped = YES;
    
    
    //-----------------Creation of password_recovery button
    int xpasswordButton = 200;
    passwordRecoveryButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    passwordRecoveryButton.frame = CGRectMake(0.5*screenWidth-(0.5*xpasswordButton),yInitial+2*yUsername+yUsername+20,xpasswordButton,yUsername);
    passwordRecoveryButton.backgroundColor = [UIColor clearColor];
    [passwordRecoveryButton setTitle:@"Forgot your password ? Reset it here." forState:UIControlStateNormal];
    [passwordRecoveryButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [passwordRecoveryButton.titleLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:10]];
    [passwordRecoveryButton addTarget:self
                               action:@selector(recoverPasswordPressed)
                     forControlEvents:UIControlEventTouchUpInside];
    
    
}


@end




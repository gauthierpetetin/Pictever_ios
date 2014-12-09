//
//  RegisterScreen.m
//  Keo
//
//  Created by Gauthier Petetin on 14/03/2014.
//  Copyright (c) 2014 Gauthier Petetin. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////(GO TO APPDELEGATE.M FOR MORE INFO ABOUT THE GLOBAL VARIABLES)/////////////////////////////////

#include <CommonCrypto/CommonDigest.h>
#import "GPRequests.h"
#import "RegisterScreen.h"
#import <AWSiOSSDKv2/AWSMobileAnalytics.h>
#import <AWSiOSSDKv2/AWSCore.h>
#import "myConstants.h"
#import "myGeneralMethods.h"

@interface RegisterScreen ()

//@property (nonatomic, strong) NSMutableData *responseData2;


@end

@implementation RegisterScreen

bool firstUseEver;

NSString * backgroundImage; //global

bool openingWindow;
NSString *storyboardName;

NSString *adresseIp2;

NSString *mytimeStamp;

//size if the screen
CGFloat screenWidth;//global
CGFloat screenHeight;//global
CGFloat tabBarHeight;//global

NSUserDefaults *prefs;

CGSize keyboardSize;
CGRect rect;

UITextField *textFieldUsernameSignUp;
UITextField *textFieldPassword1SignUp;


UILabel *myWelcomeLabelSignUp;
UILabel *monLabelPassword1;

UIButton *backButton;
UIButton *signUpButton;

NSString *username;//global
NSString *hashPassword;//global
NSString *myCurrentPhoneNumber;//global

bool logIn;//global

NSString *password;
NSString *password1;
NSString *reponseLogIn;
NSString *myDeviceToken;

bool *connectionDidFinishLoadingOver;

UIColor *theKeoOrangeColor;

int height;
int yInitial;
int xPassword;
int xButton;
int xUsername;
int yUsername;
int yEspace;
int elevation;
int xUsernameTitle;

UIActivityIndicatorView *registerSpinner;

- (void)viewDidLoad
{
    [super viewDidLoad];

    //self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:backgroundImage]];
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[myGeneralMethods scaleImage:[UIImage imageNamed:@"FillesTrekEmpty@2x.png"]]];
    //self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[myGeneralMethods scaleImage:[UIImage imageNamed:@"GarconMontagneEmpty@2x.png"]]];
    
    logIn = false;
    
    
    
    connectionDidFinishLoadingOver = false;
    

    
    rect = self.view.frame;
    height = rect.size.height;
    
    
    //----------create labels and buttons ----------
    [self initControls];
    
}


//--------------hide the keyboard when screen touched------------

- (IBAction)respondToTapGesture2:(UITapGestureRecognizer *)recognizer {
    [textFieldPassword1SignUp resignFirstResponder];
    [textFieldUsernameSignUp resignFirstResponder];
}

//---------------return pressed------------------------

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textFieldUsernameSignUp.isFirstResponder){
        [textFieldPassword1SignUp becomeFirstResponder];
    }
    else{
        [textFieldPassword1SignUp resignFirstResponder];
        [textFieldUsernameSignUp resignFirstResponder];
    }
    
    return YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//---------------------sign up pressed (to create a new account)---------------------------

- (IBAction)myActionLogIn:(id)sender {
    if([textFieldUsernameSignUp.text isEqualToString:@""]){
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Error"
                              message:@"Please enter your username first!" delegate:self
                              cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        textFieldPassword1SignUp.text=@"";
    }
    else if ([textFieldPassword1SignUp.text isEqualToString:@""]){
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Error"
                              message:@"Please enter your password first!" delegate:self
                              cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        textFieldPassword1SignUp.text=@"";
    }
    else if ([textFieldPassword1SignUp.text length] < 6){
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Error"
                              message:@"Please enter a password with at least 6 characters" delegate:self
                              cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        textFieldPassword1SignUp.text=@"";

    }
    else{
        username = textFieldUsernameSignUp.text;
        password1 = textFieldPassword1SignUp.text;
        
        username = [username stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        password1 = [password1 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        hashPassword = [GPRequests sha256HashFor:password1];
        
        if ([username rangeOfString:@"@"].location == NSNotFound) {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:@"Please enter a valid email adress" delegate:self
                                  cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
        else if ([username rangeOfString:@" "].location != NSNotFound){
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:@"Please enter a valid email adress" delegate:self
                                  cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
        else if([password1 rangeOfString:@" "].location != NSNotFound){
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:@"Please enter a valid password" delegate:self
                                  cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
        else {
            NSLog(@"string contains @: %@", username);
            //-------------------asynchronous register request---------------
            [self localAsynchronousRegisterWithEmail:username withHashPass:hashPassword for:self];
        }

    }
}

-(void)localAsynchronousRegisterWithEmail:(NSString *) userN withHashPass:(NSString *)hashP for:(id)sender{
    
    if ([GPRequests connected]){
        signUpButton.enabled = NO;
        signUpButton.highlighted = YES;
        [self.view addSubview:registerSpinner];
        [registerSpinner startAnimating];
        
        // 1
        NSURL *loginUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",adresseIp2,my_registerRequestName]];
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
        
        // 2
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:loginUrl];
        request.HTTPMethod = @"POST";
        
        // 3
        
        
        
        NSString *postString = [NSString stringWithFormat:@"%@%@%@%@",@"email=",userN,@"&password=",hashP];
        APLLog([NSString stringWithFormat:@" local asynchronous register session post: %@",postString]);
        NSData* data = [postString dataUsingEncoding:NSUTF8StringEncoding];
        
        NSError *error = nil;
        
        if (!error) {
            // 4
            APLLog(@"local login session: %@", loginUrl);
            NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request
                                                                       fromData:data completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
                                                                           dispatch_async(dispatch_get_main_queue(), ^{
                                                                               signUpButton.enabled=YES;
                                                                               signUpButton.highlighted=NO;
                                                                               [registerSpinner stopAnimating];
                                                                               [registerSpinner removeFromSuperview];
                                                                           });
                                                                           if(error != nil){
                                                                               APLLog(@"New login Error: [%@]", [error description]);
                                                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                                                   UIAlertView *alert = [[UIAlertView alloc]
                                                                                                         initWithTitle:@"Error"
                                                                                                         message:@"Wrong identifier or password" delegate:self
                                                                                                         cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                                                                                   [alert show];
                                                                               });
                                                                           }
                                                                           else{
                                                                               NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                                                               NSInteger sessionErrorCode = [httpResponse statusCode];
                                                                               [self localRegisterSucceeded:data withErrorCode:sessionErrorCode from:self];
                                                                           }
                                                                       }];
            
            // 5
            [uploadTask resume];
        }
    }
}

-(void)localRegisterSucceeded:(NSData *)data withErrorCode:(NSInteger)sessionErrorCode from:(id)sender{
    APLLog(@"local register session did receive response with error code: %i",sessionErrorCode);
    if(sessionErrorCode!=200){
        if(sessionErrorCode==406){
            logIn = false;
            [prefs setBool:logIn forKey:my_prefs_login_key];
            //------- Switch screen to logIn -------account already exists------------
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"Account already exists"
                                      message:@"Please login" delegate:self
                                      cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
                UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"logInScreen"];
                vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                [self presentViewController:vc animated:YES completion:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"setUsername" object: nil];
            });
        }
    }
    else{
        firstUseEver = true;
        
        //----------save user info in preferences-------------------
        logIn = true;
        [prefs setBool:logIn forKey:my_prefs_login_key];
        [prefs setObject:username forKey:my_prefs_username_key];
        [prefs setObject:hashPassword forKey:my_prefs_password_key];
        [prefs setObject:@"" forKey:my_prefs_phoneNumber_key];
        
        //-----------update timestamp-------------------------------
        mytimeStamp = @"1412932000";
        [prefs setObject:mytimeStamp forKey:my_prefs_timestamp_key];
        
        
        //----------Switch screen to phone number screen -------------
        dispatch_async(dispatch_get_main_queue(), ^{
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
            UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:my_storyboard_phone_screen];
            vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            [self presentViewController:vc animated:YES completion:nil];
        });
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        signUpButton.enabled=YES;
        signUpButton.highlighted=NO;
        [registerSpinner stopAnimating];
        [registerSpinner removeFromSuperview];
    });
}



-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [registerSpinner stopAnimating];
    [registerSpinner removeFromSuperview];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    signUpButton.enabled = YES;
    signUpButton.highlighted = NO;
}




//-------------back to welcome screen pressed--------------

-(void) backPressed{
    /*UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"WelcomeScreen"];
    [self presentViewController:vc animated:NO completion:nil];*/
    [self dismissViewControllerAnimated:YES completion:nil];
}


//-------------initialization of all labels and buttons---------------------

-(void)initControls{
    yInitial=110;
    xPassword=190;
    xUsername=250;
    xUsernameTitle=300;
    yEspace=50;
    //xButton=100;
    xButton=90;
    yUsername=30;
    
    //------------Create tap gesture recognizer
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondToTapGesture2:)];
    tapRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tapRecognizer];
    
    
    //---------------creation of label Pictever
    CGRect rectLabUsername = CGRectMake(0.5*screenWidth-(0.5*xUsernameTitle),40,xUsernameTitle,60);
    myWelcomeLabelSignUp = [[UILabel alloc] initWithFrame: rectLabUsername];
    [myWelcomeLabelSignUp setTextAlignment:NSTextAlignmentCenter];
    [myWelcomeLabelSignUp setFont:[UIFont systemFontOfSize:30]];
    [myWelcomeLabelSignUp setFont:[UIFont fontWithName:@"Gabriola" size:42]];
    myWelcomeLabelSignUp.textColor = theKeoOrangeColor;
    myWelcomeLabelSignUp.text = @"Register with email";
    
    //---------------Création du textField Username
    CGRect rectTFUsername = CGRectMake(0.5*screenWidth-(0.5*xUsername),yInitial,xUsername,yUsername); // Définition d'un rectangle
    textFieldUsernameSignUp = [[UITextField alloc] initWithFrame:rectTFUsername];
    textFieldUsernameSignUp.textAlignment = NSTextAlignmentCenter;
    textFieldUsernameSignUp.borderStyle = UITextBorderStyleLine;
    textFieldUsernameSignUp.delegate=self;
    textFieldUsernameSignUp.backgroundColor = [UIColor whiteColor];
    textFieldUsernameSignUp.placeholder = @"Your preferred email";
    textFieldUsernameSignUp.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textFieldUsernameSignUp.borderStyle = UITextBorderStyleRoundedRect;
    textFieldUsernameSignUp.keyboardType = UIKeyboardTypeEmailAddress;
    
    //----------------Creation of textField Password1
    CGRect rectTFPassword1 = CGRectMake(0.5*screenWidth-(0.5*xUsername),yInitial+yUsername,xUsername,yUsername);; // Définition d'un rectangle
    textFieldPassword1SignUp = [[UITextField alloc] initWithFrame:rectTFPassword1];
    textFieldPassword1SignUp.textAlignment = NSTextAlignmentCenter;
    textFieldPassword1SignUp.borderStyle = UITextBorderStyleLine;
    textFieldPassword1SignUp.delegate=self;
    textFieldPassword1SignUp.backgroundColor = [UIColor whiteColor];
    textFieldPassword1SignUp.placeholder = @"Your password (6 min)";
    textFieldPassword1SignUp.borderStyle = UITextBorderStyleRoundedRect;
    textFieldPassword1SignUp.secureTextEntry = YES;
    

    //------------Creation of Sign Up button
    signUpButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    signUpButton.frame = CGRectMake(0.5*screenWidth-(0.5*xButton),yInitial+yUsername+yUsername+20,xButton,yUsername);
    signUpButton.backgroundColor = [UIColor whiteColor];
    [signUpButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    signUpButton.layer.cornerRadius = 10; // arrondir les
    signUpButton.clipsToBounds = YES;     // angles du bouton
    [signUpButton setTitle:@"Let's go!" forState:UIControlStateNormal];
    [signUpButton.titleLabel setFont:[UIFont fontWithName:@"System-Bold" size:15]];
    [[signUpButton layer] setBorderWidth:1.0f];
    [[signUpButton layer] setBorderColor:[[UIColor grayColor] CGColor]];
    [signUpButton addTarget:self
                     action:@selector(myActionLogIn:)
           forControlEvents:UIControlEventTouchUpInside];
    
    
    //---------Creation of back button
    backButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    backButton.frame = CGRectMake(5,screenHeight-45,70,30);
    backButton.backgroundColor = [UIColor blackColor];
    backButton.alpha = 0.61;
    backButton.layer.cornerRadius = 8;
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton.titleLabel setFont:[UIFont systemFontOfSize:18]];
    [backButton addTarget:self
                   action:@selector(backPressed)
         forControlEvents:UIControlEventTouchUpInside];
    
    //-----------------Creation of register spinner---------
    registerSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    registerSpinner.center = CGPointMake(0.5*screenWidth+xButton-25,yInitial+yUsername+0.5*yUsername+50);
    registerSpinner.color = [UIColor blackColor];
    registerSpinner.hidesWhenStopped = YES;
    
    [self.view addSubview: backButton];
    [self.view addSubview: myWelcomeLabelSignUp];
    [self.view addSubview: textFieldUsernameSignUp];
    [self.view addSubview: textFieldPassword1SignUp];
    [self.view addSubview: signUpButton];
    [textFieldUsernameSignUp becomeFirstResponder];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end




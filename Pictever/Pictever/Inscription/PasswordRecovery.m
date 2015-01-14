//
//  PasswordRecovery.m
//  Pictever
//
//  Created by Gauthier Petetin on 12/11/2014.
//  Copyright (c) 2014 Pictever. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "PasswordRecovery.h"
#import "RegisterScreen.h"
#import "GPRequests.h"
#import <AWSiOSSDKv2/AWSMobileAnalytics.h>
#import <AWSiOSSDKv2/AWSCore.h>
#import "myConstants.h"



@interface PasswordRecovery ()

//@property (nonatomic, strong) NSMutableData *responseData2;


@end


bool firstUseEver;


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

UITextField *textFieldConfirmationCode;
UITextField *textFieldResetPassword1;
UITextField *textFieldResetPassword2;


UILabel *myResetInfoLabel;
UILabel *monLabelPassword1;

UIButton *backButton;
UIButton *confirmCodeButton;

NSString *username;//global
NSString *hashPassword;//global
NSString *myCurrentPhoneNumber;//global

bool logIn;//global

NSString *myLocaleString;
NSString *password;
NSString *password1;
NSString *reponseLogIn;
NSString *myDeviceToken;

bool *connectionDidFinishLoadingOver;


int height;
int yInitial;
int xPassword;
int xButton;
int xUsername;
int yUsername;
int yEspace;
int elevation;
int xUsernameTitle;

UIColor *theKeoOrangeColor;//global
UIColor *thePicteverGreenColor;//global
UIColor *thePicteverYellowColor;//global
UIColor *thePicteverRedColor;//global
UIColor *thePicteverGrayColor;//global

UIActivityIndicatorView *confirmCodeSpinner;

@implementation PasswordRecovery


-(void)viewDidLoad{
    [super viewDidLoad];
    
    self.view.backgroundColor = theKeoOrangeColor;
    
    
    [self initControls2];
}



//--------------hide the keyboard when screen touched------------

- (IBAction)respondToTapGesture2:(UITapGestureRecognizer *)recognizer {
    [textFieldResetPassword1 resignFirstResponder];
    [textFieldResetPassword2 resignFirstResponder];
    [textFieldConfirmationCode resignFirstResponder];
}

//---------------return pressed------------------------

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textFieldConfirmationCode.isFirstResponder){
        [textFieldResetPassword1 becomeFirstResponder];
    }
    else if (textFieldResetPassword1.isFirstResponder){
        [textFieldResetPassword2 becomeFirstResponder];
    }
    else{
        [textFieldResetPassword1 resignFirstResponder];
        [textFieldResetPassword2 resignFirstResponder];
        [textFieldConfirmationCode resignFirstResponder];
    }
    
    return YES;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [confirmCodeSpinner stopAnimating];
    [confirmCodeSpinner removeFromSuperview];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    confirmCodeButton.enabled = YES;
    confirmCodeButton.highlighted = NO;
}



//---------------------sign up pressed (to create a new account)---------------------------

- (IBAction)myActionConfirmCode:(id)sender {
    NSString *confirmationCode = @"";
    if([textFieldConfirmationCode.text isEqualToString:@""]){
        NSString *title5 = @"Error";
        NSString *message5 = @"Please enter your confirmation code first!";
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:title5
                              message:message5 delegate:self
                              cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        textFieldResetPassword1.text=@"";
        textFieldResetPassword2.text=@"";
    }
    else if ([textFieldResetPassword1.text isEqualToString:@""]){
        NSString *title5 = @"Error";
        NSString *message5 = @"Please enter your password first!";
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:title5
                              message:message5 delegate:self
                              cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        textFieldResetPassword1.text=@"";
        textFieldResetPassword2.text=@"";
    }
    else if (![textFieldResetPassword1.text isEqualToString:textFieldResetPassword2.text]){
        NSString *title5 = @"Error";
        NSString *message5 = @"The two passwords are different!";
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:title5
                              message:message5 delegate:self
                              cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        textFieldResetPassword1.text=@"";
        textFieldResetPassword2.text=@"";
    }
    else if ([textFieldResetPassword1.text length] < 6){
        NSString *title5 = @"Error";
        NSString *message5 = @"Please enter a password with at least 6 characters";
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:title5
                              message:message5 delegate:self
                              cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        textFieldResetPassword1.text=@"";
        textFieldResetPassword2.text=@"";
    }
    else{
        confirmationCode = textFieldConfirmationCode.text;
        password1 = textFieldResetPassword1.text;
        hashPassword = [GPRequests sha256HashFor:password1];
        
        //-------------------define new password session---------------
        
        [self newPasswordRequest:hashPassword withCode:confirmationCode for:self];
        
    }
}


#pragma mark - define new password

-(void)newPasswordRequest:(NSString *)newPassword withCode:(NSString *)verificationCode for:(id)sender{
    
    if ([GPRequests connected]){
        confirmCodeButton.enabled = NO;
        confirmCodeButton.highlighted = YES;
        [self.view addSubview:confirmCodeSpinner];
        [confirmCodeSpinner startAnimating];
        
        // 1
        NSURL *newPasswordUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",adresseIp2,my_defineNewPassword]];
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
        
        // 2
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:newPasswordUrl];
        request.HTTPMethod = @"POST";
        
        NSString *postString = [NSString stringWithFormat:@"%@%@%@%@%@%@",@"email=",username,@"&verification_code=",verificationCode,@"&new_password=",newPassword];
        APLLog([NSString stringWithFormat:@"Send session post: %@",postString]);
        NSData* data = [postString dataUsingEncoding:NSUTF8StringEncoding];
        
        NSError *error = nil;
        //NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary
        //                                             options:kNilOptions error:&error];
        
        if (!error) {
            // 4
            APLLog(@"send session: %@", newPasswordUrl);
            NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request
                                                                       fromData:data completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
                                                                           dispatch_async(dispatch_get_main_queue(), ^{
                                                                               confirmCodeButton.enabled=YES;
                                                                               confirmCodeButton.highlighted=NO;
                                                                               [confirmCodeSpinner stopAnimating];
                                                                               [confirmCodeSpinner removeFromSuperview];
                                                                           });
                                                                           if(error != nil){
                                                                               APLLog(@"New send Error: [%@]", [error description]);
                                                                               
                                                                           }
                                                                           else{
                                                                               NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                                                               NSInteger sessionErrorCode = [httpResponse statusCode];
                                                                               [self newPasswordDidReceiveResponse:data withErrorCode:sessionErrorCode from:sender];
                                                                           }
                                                                       }];
            
            // 5
            [uploadTask resume];
        }
    }
}

-(void)newPasswordDidReceiveResponse:(NSData *)data withErrorCode:(NSInteger)sendErrorCode from:(id)sender{
    APLLog(@"send session did receive response with error code: %i",sendErrorCode);
    
    if(sendErrorCode != 200){
        if(sendErrorCode==500){
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"newpassword: Error"
                                      message:@"Server problem" delegate:self
                                      cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
            });
            [GPRequests goBackToFirstServer];
        }
        if(sendErrorCode==404){
            [GPRequests goBackToFirstServer];
        }
    }
    else{
        [self newPasswordSucceeded:data];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        confirmCodeButton.enabled=YES;
        confirmCodeButton.highlighted=NO;
        [confirmCodeSpinner stopAnimating];
        [confirmCodeSpinner removeFromSuperview];
    });
}


-(void)newPasswordSucceeded:(NSData *)data{
    APLLog(@"Session succeeded! Received %d bytes of data newPassword",[data length]);
    
    //----------save user info in preferences-------------------
    logIn = true;
    [prefs setBool:logIn forKey:my_prefs_login_key];
    [prefs setObject:username forKey:my_prefs_username_key];
    [prefs setObject:hashPassword forKey:my_prefs_password_key];
    
    //--------------Switch screen to phone number------
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
        UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:my_storyboard_phone_screen];
        vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:vc animated:YES completion:nil];
    });
    
}






//-------------initialization of all labels and buttons---------------------

-(void)initControls2{
    yInitial=80;
    xPassword=190;
    xUsername=screenWidth-40;
    xUsernameTitle=300;
    yEspace=50;
    //xButton=100;
    xButton=170;
    yUsername=30;
    
    //------------Create tap gesture recognizer
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondToTapGesture2:)];
    tapRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tapRecognizer];
    
    
    //---------------creation of label confirmation code
    CGRect rectLabUsername = CGRectMake(0.5*screenWidth-(0.5*xUsernameTitle),20,xUsernameTitle,60);
    myResetInfoLabel = [[UILabel alloc] initWithFrame: rectLabUsername];
    [myResetInfoLabel setTextAlignment:NSTextAlignmentCenter];
    [myResetInfoLabel setFont:[UIFont systemFontOfSize:16]];
    myResetInfoLabel.lineBreakMode = NSLineBreakByWordWrapping;
    myResetInfoLabel.numberOfLines = 0;
    myResetInfoLabel.textColor = [UIColor whiteColor];
    myResetInfoLabel.font = [UIFont fontWithName:@"GothamRounded-Bold" size:16];
    myResetInfoLabel.text = @"You will receive a verification code per email";
    
    //---------------Création du textField confirmation code
    CGRect rectTFUsername = CGRectMake(0.5*screenWidth-(0.5*xUsername),yInitial,xUsername,yUsername); // Définition d'un rectangle
    textFieldConfirmationCode = [[UITextField alloc] initWithFrame:rectTFUsername];
    textFieldConfirmationCode.textAlignment = NSTextAlignmentCenter;
    textFieldConfirmationCode.borderStyle = UITextBorderStyleLine;
    textFieldConfirmationCode.delegate=self;
    textFieldConfirmationCode.backgroundColor = [UIColor clearColor];
    textFieldConfirmationCode.placeholder = @"Enter your verification code";
    textFieldConfirmationCode.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textFieldConfirmationCode.borderStyle = UITextBorderStyleRoundedRect;
    textFieldConfirmationCode.layer.borderWidth = 2;
    textFieldConfirmationCode.layer.borderColor = [UIColor whiteColor].CGColor;
    textFieldConfirmationCode.font = [UIFont fontWithName:@"GothamRounded-Bold" size:16];
    textFieldConfirmationCode.layer.cornerRadius = 4;
    textFieldConfirmationCode.textColor = [UIColor whiteColor];
    
    //----------------Creation of textField Password1
    CGRect rectTFPassword1 = CGRectMake(0.5*screenWidth-(0.5*xUsername),yInitial+yUsername+10,xUsername,yUsername);; // Définition d'un rectangle
    textFieldResetPassword1 = [[UITextField alloc] initWithFrame:rectTFPassword1];
    textFieldResetPassword1.textAlignment = NSTextAlignmentCenter;
    textFieldResetPassword1.borderStyle = UITextBorderStyleLine;
    textFieldResetPassword1.delegate=self;
    textFieldResetPassword1.backgroundColor = [UIColor clearColor];
    textFieldResetPassword1.placeholder = @"Enter a new password";
    textFieldResetPassword1.borderStyle = UITextBorderStyleRoundedRect;
    textFieldResetPassword1.secureTextEntry = YES;
    textFieldResetPassword1.layer.borderWidth = 2;
    textFieldResetPassword1.layer.borderColor = [UIColor whiteColor].CGColor;
    textFieldResetPassword1.font = [UIFont fontWithName:@"GothamRounded-Bold" size:16];
    textFieldResetPassword1.layer.cornerRadius = 4;
    textFieldResetPassword1.textColor = [UIColor whiteColor];
    
    //------------Creation of textField Password2
    CGRect rectTFPassword2 = CGRectMake(0.5*screenWidth-(0.5*xUsername),yInitial+2*yUsername+20,xUsername,yUsername);; // Définition d'un rectangle
    textFieldResetPassword2 = [[UITextField alloc] initWithFrame:rectTFPassword2];
    textFieldResetPassword2.textAlignment = NSTextAlignmentCenter;
    textFieldResetPassword2.borderStyle = UITextBorderStyleLine;
    textFieldResetPassword2.delegate=self;
    textFieldResetPassword2.backgroundColor = [UIColor clearColor];
    textFieldResetPassword2.placeholder = @"Re-Enter your new password";
    textFieldResetPassword2.borderStyle = UITextBorderStyleRoundedRect;
    textFieldResetPassword2.secureTextEntry = YES;
    textFieldResetPassword2.layer.borderWidth = 2;
    textFieldResetPassword2.layer.borderColor = [UIColor whiteColor].CGColor;
    textFieldResetPassword2.font = [UIFont fontWithName:@"GothamRounded-Bold" size:16];
    textFieldResetPassword2.layer.cornerRadius = 4;
    textFieldResetPassword2.textColor = [UIColor whiteColor];
    
    
    //------------Creation of confirm code button
    confirmCodeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    confirmCodeButton.frame = CGRectMake(0.5*screenWidth-(0.5*xButton),yInitial+3*yUsername+30,xButton,yUsername);
    confirmCodeButton.backgroundColor = thePicteverYellowColor;
    [confirmCodeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    confirmCodeButton.layer.cornerRadius = 4; // arrondir les
    confirmCodeButton.clipsToBounds = YES;     // angles du bouton
    [confirmCodeButton setTitle:@"Reset password" forState:UIControlStateNormal];
    [confirmCodeButton.titleLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:16]];
    [confirmCodeButton addTarget:self
                     action:@selector(myActionConfirmCode:)
           forControlEvents:UIControlEventTouchUpInside];
    
    
    //---------Creation of back button
    backButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    backButton.frame = CGRectMake(5,screenHeight-45,70,30);
    backButton.backgroundColor = thePicteverGreenColor;
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton.titleLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:16]];
    backButton.layer.cornerRadius = 4;
    [backButton addTarget:self
                   action:@selector(backPressed3)
         forControlEvents:UIControlEventTouchUpInside];
    
    //-----------------Creation of register spinner---------
    confirmCodeSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    confirmCodeSpinner.center = CGPointMake(0.5*screenWidth+0.5*xButton-25,yInitial+yUsername+0.5*yUsername+80);
    confirmCodeSpinner.color = [UIColor whiteColor];
    confirmCodeSpinner.hidesWhenStopped = YES;
    
    [self.view addSubview: backButton];
    [self.view addSubview: myResetInfoLabel];
    [self.view addSubview: textFieldConfirmationCode];
    [self.view addSubview: textFieldResetPassword1];
    [self.view addSubview: textFieldResetPassword2];
    [self.view addSubview: confirmCodeButton];
    [textFieldConfirmationCode becomeFirstResponder];
}



//-----------------go back to login screen ------------------------------

-(void) backPressed3{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}


@end
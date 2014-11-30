//
//  GPRequests.m
//  Keo
//
//  Created by Gauthier Petetin on 18/06/2014.
//  Copyright (c) 2014 Gauthier Petetin. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////(GO TO APPDELEGATE.M FOR MORE INFO ABOUT THE GLOBAL VARIABLES)/////////////////////////////////

#include <CommonCrypto/CommonDigest.h>
#import "GPRequests.h"

#import <AWSiOSSDKv2/AWSCore.h>
#import <AWSiOSSDKv2/AWSMobileAnalytics.h>

#import "myConstants.h"

@interface GPRequests ()

@property (nonatomic, strong) NSMutableData *responseData;

@end

@implementation GPRequests

NSUserDefaults *prefs;

AWSMobileAnalytics* analytics;//global

NSString *myAppVersion;

NSString *myUserID;

NSString *myStatus;//global

NSString *myFacebookName;
NSString *myFacebookID;
NSString *myFacebookBirthDay;

NSString *mytimeStamp;//global

NSString *myDeviceToken;//global

NSString *username;//global
bool logIn;

NSString *adresseIp2;//global
NSString *hashPassword;//global

NSString *storyboardName;//global


//------------------Request names-------------------
NSString *downloadPhotoRequestName;//global

bool localWork;//global


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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//----------------informs us if the device is connected to the internet---------------------
+ (BOOL)connected{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}


//----------------synchronous sign up request (to create an account)------------------------------------------------

+ (NSInteger) signUpWithEmail:(NSString *)mail withPassWord:(NSString *)password for:(id)sender{

    if([GPRequests connected]){
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",adresseIp2,my_registerRequestName]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:60.0];
        [request setHTTPMethod:@"POST"];
        NSString *postString = [NSString stringWithFormat:@"%@%@%@%@",@"email=",username,@"&password=",password];
        [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];

        
        
        NSError *error = [[NSError alloc] init];
        NSHTTPURLResponse *responseCode = nil;
        [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
        NSInteger myErrorCode = [responseCode statusCode];
        
        if(myErrorCode==406){
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Log In"
                                  message:@"You already have an account" delegate:self
                                  cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            
        }
        if(myErrorCode==500){
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Log In Error"
                                  message:@"Server problem" delegate:self
                                  cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            
        }
        
        APLLog(@"Request sent");
        return myErrorCode;

    }   
    else{
        UIAlertView *alert5 = [[UIAlertView alloc]
                              initWithTitle:@"Connection problem"
                              message:@"You have no internet connection" delegate:self
                              cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert5 show];
    }
    return 1000;
    
}

//---------------------synchronous request to define the phonenumber -----------------------------------------

+ (NSInteger) define_first_phone_number:(NSString *)phoneNumber for:(id)sender{
    APLLog(@"define_first_phone_number");
    if([GPRequests connected]){
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",adresseIp2,my_defineFirstPhoneRequestName]];
        APLLog([NSString stringWithFormat:@"url: %@",url]);
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:60.0];
        [request setHTTPMethod:@"POST"];
        NSString *postString = [NSString stringWithFormat:@"%@%@%@%@%@",@"phone_number=",phoneNumber,@"&os=ios",@"&reg_id=",myDeviceToken];
        APLLog([NSString stringWithFormat:@"postString: %@",postString]);
        [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSError *error = [[NSError alloc] init];
        NSHTTPURLResponse *responseCode = nil;
        [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
        NSInteger myErrorCode = [responseCode statusCode];
        
        if(myErrorCode != 200){
            if(myErrorCode==500){
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"define_first_phone_number Error"
                                      message:@"Server problem" delegate:self
                                      cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                
            }
            if(myErrorCode==406){
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"define_first_phone_number Error"
                                      message:@"Phone number already used for another account" delegate:self
                                      cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                
            }
            if(myErrorCode==401){

                NSInteger loginCheckAnswer =[GPRequests loginWithEmail:username withPassWord:hashPassword for:sender];
                if(loginCheckAnswer == 200){
                    [GPRequests define_first_phone_number:phoneNumber for:sender];
                }
            }
        }
        
        APLLog(@"Request sent");
        return myErrorCode;
    }
    else{
        UIAlertView *alert5 = [[UIAlertView alloc]
                               initWithTitle:@"Connection problem"
                               message:@"You have no internet connection" delegate:self
                               cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert5 show];
    }
    
    return 1000;
}

//---------------------asynchronous request to define the phonenumber -----------------------------------------

+ (void)asynchronousDefine_first_phone_number:(NSString *)phoneNumber for:(id)sender{
    APLLog(@"asynchronous define_first_phone_number");
    
    if([GPRequests connected]){
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",adresseIp2,my_defineFirstPhoneRequestName]];
        APLLog([NSString stringWithFormat:@"url: %@",url]);
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:60.0];
        
        [request setHTTPMethod:@"POST"];
        NSString *postString = [NSString stringWithFormat:@"%@%@%@%@%@",@"phone_number=",phoneNumber,@"&os=ios",@"&reg_id=",myDeviceToken];
        APLLog([NSString stringWithFormat:@"postString: %@",postString]);
        [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:sender];
        APLLog(@"%@",[connection description]);
    }
    else{
        UIAlertView *alert5 = [[UIAlertView alloc]
                               initWithTitle:@"Connection problem"
                               message:@"You have no internet connection" delegate:self
                               cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert5 show];
    }
}


//--------------not used for now, will be used later to confirm the phonenumber with a code received by SMS

+ (NSInteger) confirme_phone_number:(NSString *)phoneNumber withCode:(NSString *)myCode for:(id)sender{
    APLLog(@"confirme_phone_number");
    if([GPRequests connected]){
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",adresseIp2,@"confirm_phone_number"]];
        APLLog([NSString stringWithFormat:@"url: %@",url]);
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:60.0];
        [request setHTTPMethod:@"POST"];
        NSString *postString = [NSString stringWithFormat:@"%@%@",@"&verification_code=",myCode];
        APLLog([NSString stringWithFormat:@"postString: %@",postString]);
        [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSError *error = [[NSError alloc] init];
        NSHTTPURLResponse *responseCode = nil;
        [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
        NSInteger myErrorCode = [responseCode statusCode];
        
        APLLog([NSString stringWithFormat:@"%ld", (long)myErrorCode]);
        if(myErrorCode != 200){
            if(myErrorCode==406){
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"Error"
                                      message:@"The code is wrong" delegate:self
                                      cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                
            }
            if(myErrorCode==401){

                NSInteger loginCheckAnswer =[GPRequests loginWithEmail:username withPassWord:hashPassword for:sender];
                if(loginCheckAnswer == 200){
                    [GPRequests confirme_phone_number:phoneNumber withCode:myCode for:sender];
                }
            }
            if(myErrorCode==500){
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"confirme_phone_number Error"
                                      message:@"Server problem" delegate:self
                                      cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                
            }
        }
        
        APLLog(@"Request sent");
        return myErrorCode;
        
    }
    else{
        UIAlertView *alert5 = [[UIAlertView alloc]
                               initWithTitle:@"Connection problem"
                               message:@"You have no internet connection" delegate:self
                               cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert5 show];
    }
    return 1000;
}

//------------------asynchronous login request (when the useralready has an account)-----------------------

+(void)asynchronousLoginWithEmail:(NSString *)mail withPassWord:(NSString *)password2 for:(id)sender{

    APLLog(@"asynchronous login");
    if([GPRequests connected]){
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",adresseIp2,my_loginRequestName]];
        APLLog([NSString stringWithFormat:@"url: %@",url]);
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:60.0];
        
        [request setHTTPMethod:@"POST"];
        NSString *postString2 = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@",@"email=",username,@"&password=",password2,@"&reg_id=",myDeviceToken,@"&os=ios",@"&app_version=",myAppVersion,@"&facebook_id=",myFacebookID,@"&facebook_name=",myFacebookName,@"&facebook_birthday=",myFacebookBirthDay];
        APLLog([NSString stringWithFormat:@"postString: %@",postString2]);
        [request setHTTPBody:[postString2 dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:sender];
        APLLog(@"%@",[connection description]);
    }
    else{
        UIAlertView *alert5 = [[UIAlertView alloc]
                               initWithTitle:@"Connection problem"
                               message:@"You have no internet connection" delegate:self
                               cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert5 show];
    }
    
}

//------------------synchronous login request (not used anymore)-----------------------

+ (NSInteger) loginWithEmail:(NSString *)mail withPassWord:(NSString *)password for:(id)sender{//500 ou 404 on retourne sur l'adresse par défaut
    APLLog(@"loginwithemail");
    if([GPRequests connected]){
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",adresseIp2,my_loginRequestName]];
        APLLog([NSString stringWithFormat:@"url: %@",url]);
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:60.0];
        [request setHTTPMethod:@"POST"];
        NSString *postString = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@",@"email=",username,@"&password=",password,@"&reg_id=",myDeviceToken,@"&os=ios",@"&app_version=",myAppVersion,@"&facebook_id=",myFacebookID,@"&facebook_name=",myFacebookName,@"&facebook_birthday=",myFacebookBirthDay];
        APLLog([NSString stringWithFormat:@"postString: %@",postString]);
        [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSError *error = [[NSError alloc] init];
        NSHTTPURLResponse *responseCode = nil;
        NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
        NSInteger myErrorCode = [responseCode statusCode];
        APLLog([NSString stringWithFormat:@"loginerrorCode: %ld",(long)myErrorCode]);
        
        if(myErrorCode == 200){
            APLLog(@"LOGIN");
            logIn = true;
            NSError *myError = nil;
            id serverResponse = [NSJSONSerialization JSONObjectWithData:oResponseData options:NSJSONReadingMutableLeaves error:&myError];
            if(serverResponse){
                id mymyId = [serverResponse objectForKey:@"user_id"];
                NSString *mymyIDAsString;
                if(![mymyId isKindOfClass:[NSNull class]]){
                    mymyIDAsString = (NSString *)mymyId;
                    myUserID = mymyIDAsString;
                }
                APLLog(@"MYMYID %@",mymyId);
                id mymyIpAdress = [serverResponse objectForKey:@"web_app_url"];
                NSString *mymyIpAdressAsString;
                if(![mymyIpAdress isKindOfClass:[NSNull class]]){
                    mymyIpAdressAsString = (NSString *)mymyIpAdress;
                    if(!localWork){
                        adresseIp2 = mymyIpAdressAsString;
                        [prefs setObject:adresseIp2 forKey:@"ipAdress"];
                        APLLog(@"MYMYIPADRESS: %@",mymyIpAdressAsString);
                    }
                }
            }
            
        }
        else{
            
            if(myErrorCode==401){
                logIn = false;
                [prefs setBool:logIn forKey:my_prefs_login_key];
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"Log In"
                                      message:@"Wrong identifiers" delegate:self
                                      cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                
            }
            else if(myErrorCode==500){
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"Log In Error"
                                      message:@"Server problem" delegate:self
                                      cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                
            }
            else{
                logIn = false;
                //// Switch screen
                APLLog(@"switch to welcome screen 2");
                [[NSNotificationCenter defaultCenter] postNotificationName:@"showWelcomeScreen" object: nil];
                ////////////////////////////////////////////////////////////////////
            }
        }
        
        
        [prefs setBool:logIn forKey:my_prefs_login_key];
        
        return myErrorCode;
    }
    else{
        UIAlertView *alert5 = [[UIAlertView alloc]
                               initWithTitle:@"Connection problem"
                               message:@"You have no internet connection" delegate:self
                               cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert5 show];
    }
    return 1000;
}


//---------------------request to ask the new messages (with a time stamp)------------------------------------

+ (void)askMessagesfor:(id)sender withTimeStamp:(NSString *)timeStamp{
    APLLog(@"askMessagesfor: %@",mytimeStamp);

    if(mytimeStamp){
        if([GPRequests connected]){
            
            APLLog(@"mytimestamp: %@",mytimeStamp);
            if ([mytimeStamp isKindOfClass:[NSString class]]){
                APLLog(@"myTime stamp is a string");
            }
            else{
                APLLog(@"myTime stamp is not a string");
                mytimeStamp = [NSString stringWithFormat:@"%@",mytimeStamp];
            }
            
            
            NSString *url = [NSString stringWithFormat:@"%@%@%@%@",adresseIp2,my_receiveRequestName,@"?ts=",mytimeStamp];
            //NSString *url = [NSString stringWithFormat:@"%@%@%@%@",adresseIp2,receiveRequestName,@"?ts=",@"1413117804"];
            APLLog(url);
            NSURLRequest *request = [NSURLRequest requestWithURL:
                                     [NSURL URLWithString:url]];
            NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:sender];
            APLLog(@"%@",[connection description]);
        }
        else{

        }
    }
    else{
        APLLog(@"mytimestamp empty ---> no request can be done");
    }
    
    //not a synchronous resquest
}

//-------------------request to ask the send_choices to the server (in 3 days, in 3 weeks, in a year...)--------------------

+ (void)askKeoChoicesfor:(id)sender{
    APLLog(@"askKeoChoicesfor");
    if([GPRequests connected]){
        NSString *url = [NSString stringWithFormat:@"%@%@",adresseIp2,my_keoChoiceRequestName];
        APLLog(url);
        NSURLRequest *request = [NSURLRequest requestWithURL:
                                 [NSURL URLWithString:url]];
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:sender];
        APLLog(@"%@",[connection description]);
        
        //not a synchronous resquest

    }
    else{
    }
}

//-----------------------request to send text messages or photos------------------------------------------------------------

+(void)sendMessage:(NSString *)messageToSend to:(NSString *)recipient withPhotoString:(NSString *)photoString withKeoTime:(NSString *)keo_time for:(id)sender{
    
    APLLog(@"sendMessage");
    if([GPRequests connected]){
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",adresseIp2,my_sendRequestName]];
        APLLog([NSString stringWithFormat:@"url: %@",url]);
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:60.0];
        
        [request setHTTPMethod:@"POST"];
        NSString *postString = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@",@"photo=",photoString,@"&receiver_ids=",recipient,@"&message=",messageToSend,@"&keo_choice=",keo_time];
        APLLog([NSString stringWithFormat:@"postString: %@",postString]);
        [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSURLConnection *connection= [[NSURLConnection alloc] initWithRequest:request delegate:sender];
        APLLog(@"%@",[connection description]);
    }
    else{

    }
    
}


//-------------------request to know which of our contacts also have the app--------------------------------

+(void)uploadContactArray:(NSMutableArray *)contactBookArray for:(id)sender{
    
    APLLog(@"uploadContactArrayRequest");
    if([GPRequests connected]){
        APLLog(@"contact Array size: %d",[contactBookArray count]);
        
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",adresseIp2,my_uploadRequestName]];
        APLLog([NSString stringWithFormat:@"url: %@",url]);
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:60.0];
        
        [request setHTTPMethod:@"POST"];
        
        NSError *errorUpload = nil;
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:contactBookArray options:NSJSONWritingPrettyPrinted error:&errorUpload];

        //just for checks end
        
        APLLog(@"json data:");
        
        if(![jsonData bytes]){
            APLLog(@"empty json databytes");
        }
        else{
            APLLog(@"json databytes not empty");
        }

        NSMutableString * mutableContactString = [[NSMutableString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        if(!mutableContactString){
            mutableContactString = [[NSMutableString alloc] initWithString:@""];
        }
        NSMutableString *postString = [NSMutableString stringWithFormat:@"%@%@",@"contacts=",mutableContactString];
        [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSURLConnection *connection= [[NSURLConnection alloc] initWithRequest:request delegate:sender];
        APLLog(@"%@",[connection description]);
    }
    else{

    }
    
}

//----------------request to know how many messages the user will receive in the future---------

+ (void)askNumberoOfMessagesInTheFuture:(id)sender{
    APLLog(@"askNumberoOfMessagesInTheFuture");
    if([GPRequests connected]){
        NSString *url = [NSString stringWithFormat:@"%@%@",adresseIp2,my_futureMessagesRequestName];
        APLLog(url);
        NSURLRequest *request = [NSURLRequest requestWithURL:
                                 [NSURL URLWithString:url]];
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:sender];
        APLLog(@"%@",[connection description]);
        //not a synchronous resquest
        
    }
    else{

    }
}



//------------------request to ask the status to the server (and then see if it has changed)-----------------

+ (void)getStatus:(id)sender{
    APLLog(@"aaskStatus");
    if([GPRequests connected]){
        NSString *url = [NSString stringWithFormat:@"%@%@",adresseIp2,my_getStatusRequestName];
        APLLog(url);
        NSURLRequest *request = [NSURLRequest requestWithURL:
                                 [NSURL URLWithString:url]];
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:sender];
        APLLog(@"%@",[connection description]);
        //not a synchronous resquest
    }
    else{
    }
}


//-----------------download a new photo on amazon (cloudfront)------------------------------

+ (void)downloadPhotoAtURL:(NSString *)photoIdPath for:(id)sender{
    APLLog(@"downloadPhotoAtURL: %@",photoIdPath);
    if([GPRequests connected]){
        NSString *url = [NSString stringWithFormat:@"%@%@",downloadPhotoRequestName,photoIdPath];
        APLLog(@"URL: %@",url);
        NSURLRequest *request = [NSURLRequest requestWithURL:
                                 [NSURL URLWithString:url]];
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:sender];
        APLLog(@"%@",[connection description]);
        //not a synchronous resquest
        
    }
    else{

    }
}

//------------------cryptage of the password--------------------------

+(NSString*)sha256HashFor:(NSString*)input
{
    const char* str = [input UTF8String];
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(str, strlen(str), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_SHA256_DIGEST_LENGTH; i++)
    {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}

//---------------------if the server doesn't work anymore, go back to the default server---------------

+(void)goBackToFirstServer{
    APLLog(@"GO BACK TO FIRST SERVER!");
    adresseIp2 = my_default_adresseIp;
    [prefs setObject:adresseIp2 forKey:@"ipAdress"];
}


//--------------------alert amazon analytics our status has changed (for our own statistics)----------------------

+(void)alertAnalyticsStatus{
    APLLog(@"alertAnalytics new status");
    id<AWSMobileAnalyticsEventClient> eventClient = analytics.eventClient;
    id<AWSMobileAnalyticsEvent> levelEvent = [eventClient createEventWithEventType:@"iosAllStatus"];
    [levelEvent addAttribute:myStatus forKey:@"Status"];
    APLLog(@"levelevent:%@",[[levelEvent allAttributes] description]);
    [eventClient recordEvent:levelEvent];
    [eventClient submitEvents];
}

@end

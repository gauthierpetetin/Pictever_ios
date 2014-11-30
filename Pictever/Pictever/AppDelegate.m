//
//  AppDelegate.m
//  Pictever    --> for information SHYFT USED TO BE CALLED KEO  , that is the reason of all the "Keo" in the variable names
//
//  Created by Gauthier Petetin on 18/04/2014.
//  Copyright (c) 2014 Gauthier Petetin. All rights reserved.
//

//#import <Frameworks/SDK/FacebookSDK.framework>

#import <FacebookSDK/FacebookSDK.h>
#import "AppDelegate.h"

#import "myConstants.h"
#import "myGeneralMethods.h"

#import "GPSession.h"
#import "ShyftSet.h"

#import <AWSiOSSDKv2/AWSCore.h>
#import <AWSiOSSDKv2/AWSMobileAnalytics.h>


////////default parameters to use to upload images on AWS///////
#define CONST_AWS_ACCOUNT_ID	@"090152412356"
#define CONST_COGNITO_POOL_ID @"us-east-1:a17c5334-6843-49c0-8336-fbb36c40a6eb"
#define CONST_COGNITO_ROLE_AUTH @"arn:aws:iam::090152412356:role/Cognito_TimeAppAuth_DefaultRole"
#define CONST_COGNITO_ROLE_UNAUTH @"arn:aws:iam::090152412356:role/Cognito_TimeAppUnauth_DefaultRole"
///////////////////////////////


@implementation AppDelegate

bool firstUseEver;//global
bool firstGlobalOpening;//global
bool firstContactOpening;//global
bool appOpenedOnNotification;//global



//////// parameters to use to upload images on AWS (received by the server in the answer of the first login request)///////

//Cloudfront (used for a better download of images on AWS)
NSString *cloudfront_url;
//Amazon
NSString *aws_account_id;
NSString *cognito_pool_id;
NSString *cognito_role_auth;
NSString *cognito_role_unauth;
NSString *S3BucketName;

AWSCognitoCredentialsProvider *credentialsProvider;

//amazon analytics
AWSMobileAnalytics* analytics;
///////////////////////////////////////////////////////////////////////////////////////////////////////////




NSUserDefaults *prefs;//preferences where all the variable are saved when the app is killed

//Crucial information about the users account
NSString *myAppVersion;
NSString *username;
NSString *hashPassword;
bool logIn;
NSString *myCurrentPhoneNumber;
NSString *myCountryCode;
NSString *myUserID;
NSString *myStatus;
NSString *myFacebookName;
NSString *myFacebookID;
NSString *myFacebookBirthDay;
///////////////////////


NSString *mytimeStamp;//sent to the server to ask messages, updated every time a new message is received

NSString *myDeviceToken;//device token used to send notification with the server

NSMutableArray *messagesDataFile;//array that contains all the messages received by the user

NSString *myCurrentPhotoPath;//path to find the images saved in the memory of the application


/////timer and boolean used to know when the app has just been openened (an then switch to the photo gallery if there is a new message)
NSTimer *openingAppTimer;
bool appjustOpened;
///

//Variables to force the installation of a new app version
bool myVersionForceInstall;
NSString *myVersionInstallUrl;
//

//number of messages in the future
NSString *numberOfMessagesInTheFuture;

//size if the screen
CGFloat screenWidth;//global
CGFloat screenHeight;//global
CGFloat tabBarHeight;//global



int openingWindow; //to know on which view of the tabbar we have to go


NSMutableArray *importContactsData; //Array that contains all the contacts from the phone
NSMutableArray *importContactsNames;//Array that contains all the full names of my contacts
NSMutableArray *localKeoContacts;//Array that contains all the contacts which also have the Shyft application
NSMutableDictionary *importKeoContacts;//Dictionary that contains all the contacts which also have the Shyft application (the keys are the phonenumbers)
NSMutableDictionary *importKeoPhotos;//Array that contains all the photos of my contacts
NSMutableDictionary *importKeoOccurences;//Array that contains the occurences to find the favorite contacts


///////info given by the server about the send choices (answer of "get_keo_choice" request)/////

NSMutableArray *importKeoChoices;//("in 3 days", "in 3 weeks, in a year"...).


///////info given by the server about the shyft users (answer of "upload_contacts" request)/////
NSMutableArray *importContactPhones;
NSMutableArray *importContactMails;
NSMutableArray *importContactIDs;
/////////////////////////////////////////////////////////

NSMutableArray *myKeoReferences;//all the photo paths in the memory of the app


NSString * storyboardName;//"Main"
NSString * backgroundImage;//name of the background image

NSString *adresseIp2;//ip adress to use to contact the server (given by the server)


NSMutableArray *sendToMail;//array of selected recipients user_id
NSString *sendToName;//array of selected recipients names
NSString *sendToDate;//selected send choice selected id (the send choice has a certain id that the server understands)
NSString *sendToDateAsText;//selected send choice selected name ("in 3 days", "in 3 weeks",...)
NSString *sendToTimeStamp;//timestamp selected by the user in case the send choice is "calendar"


//////////////Request names ////////////////////
NSString *downloadPhotoRequestName;//global
////////////////////////////////////////////////


///load contacts//
bool loadAllcontacts;//to be sure all the contacts are loaded before to continue

/////////colors used/////////////
UIColor *theBackgroundColor;//global
UIColor *theBackgroundColorDarker;//global
UIColor *theKeoOrangeColor;//global
///////////////////////////////////


NSMutableArray *sendBox;//PhotoShyfts are placed in the sendbox before being sent

bool showDatePicker;//Variable to know when the send_choice-picker has to be shown

NSMutableDictionary * selectedLocalDic;//shyft selected in the gallery to get in full screen #PhotoDetail

NSMutableArray *loadBox;//contains all the PhotoShyfts for whom the photo hasn't been downloaded yet
bool isLoadingLoadBox;//true if the app is currently downloading a photo for a shyft in the loadbox

bool sendKeo;//true if the shyft has to be sent
bool uploadPhotoOnCloudinary;//true if the app is currently uploading a photo on amazon (cloudinary was the old service used)
bool downloadPhotoOnAmazon;//true if the app is currently downloading a photo on amazon
bool frontCameraActivated;

float uploadProgress;//upload progress between 0 and 1 to update de UIProgressview

NSString* lastLabelSelected;//last send_choice selected (to inform amazon analytics)

bool localWork;//global

bool sendSMS;//

GPSession *myUploadContactSession;//global

NSString* sendTips;//counter of messages sent to give some tips to the user once he sent his first messages
NSString* receiveTips;//counter of messages received to give some tips to the user once he received his first messages


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    APLLog(@"didFinishLaunchingWithOptions-------Pictever---------");
    
    firstUseEver = false;
    
    
    //--------------initialize Applause--------------
    [self initializeApplause];
    
   
    //------------register for notifications-----------
    [self registerForNotification:application];
    
    
    //-------------App prefereces--------------------
    prefs = [NSUserDefaults standardUserDefaults];
    
    
    myAppVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    APLLog(@"myAppVersion: %@",myAppVersion);
    
    //adresseIp2=@"http://instant-server-keoapp.herokuapp.com/"; //adresseIp2 initilized later by the server login response
    
    //----------Path where the photos are saved
    myCurrentPhotoPath = [self getCurrentAppPath];
    
    
    //----------Colors
    theBackgroundColor = [UIColor colorWithRed:250/255.0f green:241/255.0f blue:236/255.0f alpha:1.0f];
    theBackgroundColorDarker = [UIColor colorWithRed:252/255.0f green:239/255.0f blue:232/255.0f alpha:1.0f];
    theKeoOrangeColor = [UIColor colorWithRed:246/255.0f green:89/255.0f blue:30/255.0f alpha:1.0f];
    
    
    //--------------initialize amazon-------------
    [self importAmazonData];
    
    
    //---------------Screen size-------------------
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    screenWidth = screenRect.size.width;
    screenHeight = screenRect.size.height;
    tabBarHeight = 49;//global
    
    
    //--------------Initialisatio of boolean variables--------
    isLoadingLoadBox = false;
    sendKeo = false;
    firstGlobalOpening = true;
    firstContactOpening = true;
    uploadPhotoOnCloudinary = false;
    downloadPhotoOnAmazon = false;
    showDatePicker = false;
    sendSMS = false;
    
    //Clean Keo repository
    //[self cleanKeoPhotoRepository];
    
    
    
    
    if([prefs objectForKey:@"ipAdress"]){
        NSString *ipAdressCopy;
        ipAdressCopy = [prefs objectForKey:@"ipAdress"];
        adresseIp2 = [[NSString alloc] initWithString:ipAdressCopy];
        APLLog(@"ipAdress: %@",ipAdressCopy);
        if([[adresseIp2 stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]){
            adresseIp2 = my_default_adresseIp;
        }
    }
    else{
        adresseIp2 = my_default_adresseIp;
        APLLog(@"no ipAdress, take default one: %@",adresseIp2);
    }
    
    //--------work in local or not
    localWork=false;
    //localWork=true;
    //adresseIp2=@"http://192.168.0.15:5000/";
    
    
    
    //------------------import all account data----------------------------
    [self importAccountData];
    
    
    //------------------import messages data-----------------------------
    [self importMessagesData];
    
    //---------------import facebook data-------------------------------
    [self importFacebookData];
    
    
    
    loadBox = [[NSMutableArray alloc] init];
    localKeoContacts = [[NSMutableArray alloc] init];
    importContactPhones = [[NSMutableArray alloc] init];
    importContactMails = [[NSMutableArray alloc] init];
    importContactIDs = [[NSMutableArray alloc] init];
    
    
    
    //--------------------importKeoContacts------------
    importKeoContacts = [[NSMutableDictionary alloc] init];
    //NSMutableDictionary *importKeoContactsCopy = [[NSMutableDictionary alloc] init];
    if([prefs dictionaryForKey:@"importKeoContacts"]){
        NSDictionary *importKeoContactsCopy = [prefs dictionaryForKey:@"importKeoContacts"];
        APLLog(@"importKeoContactsCopy: %@",[importKeoContactsCopy description]);
        //importKeoContacts = [self copyKeoContactDictionary:importKeoContactsCopy];
        importKeoContacts = [importKeoContactsCopy mutableCopy];
    }
    else{
        APLLog(@"no Keo contacts");
    }
    
    //---------------------importKeoOccurences--------------
    importKeoOccurences = [[NSMutableDictionary alloc] init];
    if([prefs dictionaryForKey:my_prefs_keo_occurences_key]){
        NSDictionary *importKeoOccurencesCopy = [prefs dictionaryForKey:my_prefs_keo_occurences_key];
        APLLog(@"importKeoOccurencesCopy: %@",[importKeoOccurencesCopy description]);
        importKeoOccurences = [importKeoOccurencesCopy mutableCopy];
    }
    else{
        APLLog(@"no Keo occurences");
    }
    
    
    
    
    selectedLocalDic = [[NSMutableDictionary alloc] init];
    
    
    if([prefs objectForKey:@"allKeoNumbers"]){
        NSArray *importContactPhonesCopy;
        importContactPhonesCopy = [prefs objectForKey:@"allKeoNumbers"];
        importContactPhones = [self copyArray:importContactPhonesCopy];
    }
    if([prefs objectForKey:@"allKeoMails"]){
        NSArray *importContactMailsCopy;
        importContactMailsCopy = [prefs objectForKey:@"allKeoMails"];
        importContactMails = [self copyArray:importContactMailsCopy];
    }
    if([prefs objectForKey:@"allKeoIDs"]){
        NSArray *importContactIDsCopy;
        importContactIDsCopy = [prefs objectForKey:@"allKeoIDs"];
        importContactIDs = [self copyArray:importContactIDsCopy];
    }
    
    
    //---------------import timestamp-----------------
    [self importTimeStamp];

    
    //---------------import device token-----------------
    if([prefs objectForKey:@"deviceToken"]){
        NSString *myDeviceTokenCopy;
        myDeviceTokenCopy = [prefs objectForKey:@"deviceToken"];
        myDeviceToken = [[NSString alloc] initWithString:myDeviceTokenCopy];
    }
    else{
        APLLog(@"no device token");
    }
    APLLog(@"DeviceToken from memory: %@",myDeviceToken);
    
    
    
    myKeoReferences = [[NSMutableArray alloc] init];
    [self getAllPhotoPaths];
    APLLog(@"Pictever References has length: %d and contains: %@",[myKeoReferences count],[myKeoReferences description]);
    
    
    openingWindow = 0;// global variable to switch directly to the chat window at the first opening
    storyboardName = @"Main";
    backgroundImage = @"ShyftBackground.png";
    uploadProgress = 0.0;
    lastLabelSelected = @"";
    sendToTimeStamp = @"";
    sendToMail = [[NSMutableArray alloc] init];
    
    
    //---------------Contacts loading---------------
    
    loadAllcontacts = false;
    importContactsData = [[NSMutableArray alloc] init];
    importContactsNames = [[NSMutableArray alloc] init];
    
    myUploadContactSession = [[GPSession alloc] init];
    
    
    
    //-----------import keo_choices--------------
    
    importKeoChoices = [[NSMutableArray alloc] init];
    if([prefs arrayForKey:@"importKeoChoices2"]){
        NSArray *importKeoChoicesCopy = [prefs arrayForKey:@"importKeoChoices2"];
        //importKeoChoices = [self copyKeoChoicesArray:importKeoChoicesCopy];
        importKeoChoices = [importKeoChoicesCopy mutableCopy];
    }
    
    if([importKeoChoices count] > 0){
        APLLog(@"importKeoChoices: %@", [importKeoChoices description]);
    }
    
    

    //-------------import tips variables-----------------
    [self importTipsVariables];
    
    
    //----------------if the app was opened on a notification, I can switch directly to the gallery------------------
    NSDictionary *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    appOpenedOnNotification = false;
    if (notification) {
        // do something with notification
        appOpenedOnNotification = true;
    }
    
    APLLog([NSString stringWithFormat:@"didFinishLaunchingWithOptions username: %@  coutryCode:%@  phoneNumber:%@   hashpass:%@   status:%@",username,myCountryCode,myCurrentPhoneNumber,hashPassword,myStatus]);
    
    return YES;
}

-(NSMutableArray *)copyArray:(NSArray *)importedArr{
    NSMutableArray *returnArr = [[NSMutableArray alloc] init];
    for(NSDictionary *message2 in importedArr){
        [returnArr insertObject:message2 atIndex:[returnArr count]];
    }
    return returnArr;
}

-(void)initializeApplause{
    [[APLLogger settings] setReportOnShakeEnabled:YES];
    [[APLLogger settings] setDefaultUser:@"gauthierpetetin@hotmail.com"];
    [[APLLogger settings] setServerURL:@"https://aph.applause.com"];
    [APLLogger startNewSessionWithApplicationKey:@"af94f31a47659c5d3f1bd14cb884abdd9949b0c8"];
}

-(void)registerForNotification:(UIApplication *)application{
    // Let the device know we want to receive push notifications
    //-- Set Notification
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        // iOS 8 Notifications
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
        [application registerForRemoteNotifications];
    }
    else
    {
        // iOS < 8 Notifications
        [application registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
}

-(void)importFacebookData{
    if([prefs objectForKey:my_prefs_fb_name_key]){
        NSString *fbNameCopy;
        fbNameCopy = [prefs objectForKey:my_prefs_fb_name_key];
        myFacebookName = [[NSString alloc] initWithString:fbNameCopy];
    }
    else{
        myFacebookName = @"";
        APLLog(@"no facebook name");
    }
    
    if([prefs objectForKey:my_prefs_fb_id_key]){
        NSString *fbIDCopy;
        fbIDCopy = [prefs objectForKey:my_prefs_fb_id_key];
        myFacebookID = [[NSString alloc] initWithString:fbIDCopy];
    }
    else{
        myFacebookID = @"";
        APLLog(@"no facebook ID");
    }
    
    if([prefs objectForKey:my_prefs_fb_birthday_key]){
        NSString *fbBirthdayCopy;
        fbBirthdayCopy = [prefs objectForKey:my_prefs_fb_birthday_key];
        myFacebookBirthDay = [[NSString alloc] initWithString:fbBirthdayCopy];
    }
    else{
        myFacebookBirthDay = @"";
        APLLog(@"no facebook birthday");
    }
}

-(void)importAmazonData{
    
    //---------Cloudfront parameters-----------------
    if([prefs objectForKey:@"downloadPhotoRequestName"]){
        NSString *downloadPhotoRequestNameCopy;
        downloadPhotoRequestNameCopy = [prefs objectForKey:@"downloadPhotoRequestName"];
        downloadPhotoRequestName = [[NSString alloc] initWithString:downloadPhotoRequestNameCopy];
        APLLog(@"downloadPhotoRequestName: %@", downloadPhotoRequestName);
    }
    else{
        APLLog(@"no downloadPhotoRequestName");
        downloadPhotoRequestName = @"http://d380gpjtb0vxfw.cloudfront.net/";
    }
    //downloadPhotoRequestName = cloudfront_url;
    
    //------------AMAZON parameters--------------------
    if([prefs objectForKey:@"aws_account_id"]){
        NSString *aws_account_idCopy;
        aws_account_idCopy = [prefs objectForKey:@"aws_account_id"];
        //APLLog(@"aws: %@",[prefs objectForKey:@"aws_account_id"]);
        aws_account_id = [[NSString alloc] initWithString:aws_account_idCopy];
        APLLog(@"aws_account_id: %@", aws_account_id);
    }
    else{
        APLLog(@"no aws_account_id");
        aws_account_id = @"090152412356";
    }
    if([prefs objectForKey:@"cognito_pool_id"]){
        NSString *cognito_pool_idCopy;
        cognito_pool_idCopy = [prefs objectForKey:@"cognito_pool_id"];
        cognito_pool_id = [[NSString alloc] initWithString:cognito_pool_idCopy];
        APLLog(@"cognito_pool_id: %@", cognito_pool_id);
    }
    else{
        APLLog(@"no cognito_pool_id");
        cognito_pool_id = @"us-east-1:cf4486fa-e5e0-423f-9399-e6aae8d08e3f";
    }
    if([prefs objectForKey:@"cognito_role_auth"]){
        NSString *cognito_role_authCopy;
        cognito_role_authCopy = [prefs objectForKey:@"cognito_role_auth"];
        cognito_role_auth = [[NSString alloc] initWithString:cognito_role_authCopy];
        APLLog(@"cognito_role_auth: %@", cognito_role_auth);
    }
    else{
        APLLog(@"no cognito_role_auth");
        cognito_role_auth = @"arn:aws:iam::090152412356:role/Cognito_PicteverAuth_DefaultRole";
    }
    if([prefs objectForKey:@"cognito_role_unauth"]){
        NSString *cognito_role_unauthCopy;
        cognito_role_unauthCopy = [prefs objectForKey:@"cognito_role_unauth"];
        cognito_role_unauth = [[NSString alloc] initWithString:cognito_role_unauthCopy];
        APLLog(@"cognito_role_unauth: %@", cognito_role_unauth);
    }
    else{
        APLLog(@"no cognito_role_unauth");
        cognito_role_unauth = @"arn:aws:iam::090152412356:role/Cognito_PicteverUnauth_DefaultRole";
    }
    if([prefs objectForKey:@"S3BucketName"]){
        NSString *S3BucketNameCopy;
        S3BucketNameCopy = [prefs objectForKey:@"S3BucketName"];
        S3BucketName = [[NSString alloc] initWithString:S3BucketNameCopy];
        APLLog(@"S3BucketName: %@", S3BucketName);
    }
    else{
        APLLog(@"no S3BucketName");
        S3BucketName = @"picteverbucket";
    }
    
    APLLog(@"accountId: %@, cog1: %@, cog2: %@, cog3: %@",aws_account_id, cognito_pool_id, cognito_role_unauth, cognito_role_auth);
    
    
    //---------------initialisation of Amazon tool------------
    credentialsProvider = [AWSCognitoCredentialsProvider credentialsWithRegionType:AWSRegionUSEast1
                                                                         accountId:aws_account_id
                                                                    identityPoolId:cognito_pool_id
                                                                     unauthRoleArn:cognito_role_unauth
                                                                       authRoleArn:cognito_role_auth];
    
    
    
    APLLog(@"CREDENTIALS %@",credentialsProvider.identityPoolId);
    AWSServiceConfiguration *configuration = [AWSServiceConfiguration configurationWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider];
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
    
    
    
    
    //---------------initialisation of AMAZON ANALYTICS----------
    //if([GPRequests connected]){
    APLLog(@"connect to analytics");
    analytics = [AWSMobileAnalytics defaultMobileAnalyticsWithAppNamespace:@"App.PicteverProd"];
    //}
    

}

-(void)importMessagesData{
    messagesDataFile = [[NSMutableArray alloc] init];
    
    if([prefs arrayForKey:@"messagesDataFile"]){
        NSArray *messagesDataFileCopy;
        if([prefs objectForKey:@"messagesDataFile"]){
            messagesDataFileCopy = [prefs arrayForKey:@"messagesDataFile"];
        }
        messagesDataFile = [self copyMessagesDataFile:messagesDataFileCopy];
        [prefs setObject:messagesDataFile forKey:@"messagesDataFile"];
    }
    else{
        APLLog(@"no messages");
    }
    if(messagesDataFile){
        APLLog(@"MessagesDataFile length: %d", [messagesDataFile count]);
    }
    else{
        messagesDataFile = [[NSMutableArray alloc] init];
    }
    
    APLLog(@"%@",[messagesDataFile description]);
    
    
    //sendBox (messages to send)
    sendBox = [[NSMutableArray alloc] init];
    if([prefs arrayForKey:@"sendBox"]){
        NSArray *sendBoxCopy;
        if([prefs objectForKey:@"sendBox"]){
            sendBoxCopy = [prefs arrayForKey:@"sendBox"];
        }
        if(sendBoxCopy){
            for(int i=0; i<[sendBoxCopy count]; i++){
                [sendBox insertObject:sendBoxCopy[i] atIndex:[sendBox count]];
            }
        }
    }
    else{
        APLLog(@"no messages in SendBox");
    }
    APLLog(@"SENDBox: %@", [sendBox description]);
    
}

-(void)importAccountData{

    bool logInCopy = [prefs boolForKey:my_prefs_login_key];
    if(logInCopy){
        logIn = true;
        APLLog(@"logIn true");
    }
    else{
        logIn = false;
        APLLog(@"login false");
    }
    
    
    bool myVersionForceInstallCopy = [prefs boolForKey:@"myVersionForceInstall"];
    if(myVersionForceInstallCopy){
        myVersionForceInstall = true;
        APLLog(@"FORCEINSTALL");
    }
    else{
        myVersionForceInstall = false;
        APLLog(@"no forced install");
    }
    if([prefs objectForKey:@"myVersionInstallUrl"]){
        NSString *myVersionInstallUrlCopy;
        myVersionInstallUrlCopy = [prefs objectForKey:@"myVersionInstallUrl"];
        myVersionInstallUrl = [[NSString alloc] initWithString:myVersionInstallUrlCopy];
        APLLog(@"Version install url: %@", myVersionInstallUrl);
    }
    else{
        APLLog(@"no version install url");
    }
    
    bool frontCameraActivatedCopy = [prefs boolForKey:@"frontCamera"];
    if(frontCameraActivatedCopy){
        frontCameraActivated = true;
    }
    else{
        frontCameraActivated = false;
    }
    
    
    if([prefs objectForKey:my_prefs_username_key]){
        NSString *usernameCopy;
        usernameCopy = [prefs objectForKey:my_prefs_username_key];
        username = [[NSString alloc] initWithString:usernameCopy];
    }
    else{
        username = @"";
        APLLog(@"no username");
    }
    
    if([prefs objectForKey:my_prefs_password_key]){
        NSString *hashPasswordCopy;
        hashPasswordCopy = [prefs objectForKey:my_prefs_password_key];
        hashPassword = [[NSString alloc] initWithString:hashPasswordCopy];
    }
    else{
        hashPassword = @"";
        APLLog(@"no password");
    }
    
    myStatus = @"";
    if([prefs objectForKey:@"myStatus"]){
        NSString *myStatusCopy;
        myStatusCopy = [prefs objectForKey:@"myStatus"];
        myStatus = [[NSString alloc] initWithString:myStatusCopy];
    }
    else{
        APLLog(@"no status");
    }
    APLLog(@"My initial mystatus is: %@", myStatus);
    
    
    if([prefs objectForKey:my_prefs_phoneNumber_key]){
        NSString *myCurrentPhoneNumberCopy;
        myCurrentPhoneNumberCopy = [prefs objectForKey:my_prefs_phoneNumber_key];
        myCurrentPhoneNumber = [[NSString alloc] initWithString:myCurrentPhoneNumberCopy];
    }
    else{
        APLLog(@"no phonenumber");
    }
    
    
    if([prefs objectForKey:my_prefs_countryCode_key]){
        NSString *myCountryCodeCopy;
        myCountryCodeCopy = [prefs objectForKey:my_prefs_countryCode_key];
        myCountryCode = [[NSString alloc] initWithString:myCountryCodeCopy];
    }
    else{
        APLLog(@"no countrycode");
    }
    
    if([prefs objectForKey:@"myUserID"]){
        NSString *myUserIDCopy;
        myUserIDCopy = [prefs objectForKey:@"myUserID"];
        myUserID = [[NSString alloc] initWithString:myUserIDCopy];
        APLLog(@"myUserID: %@",myUserID);
    }
    else{
        APLLog(@"no userID");
    }
    
    
    if([prefs objectForKey:@"numberOfMessagesInTheFuture"]){
        NSString *numberOfMessagesInTheFutureCopy;
        numberOfMessagesInTheFutureCopy = [prefs objectForKey:@"numberOfMessagesInTheFuture"];
        numberOfMessagesInTheFuture = [[NSString alloc] initWithString:numberOfMessagesInTheFutureCopy];
        APLLog(@"numberOfMessagesInTheFuture: %@",numberOfMessagesInTheFuture);
    }
    else{
        numberOfMessagesInTheFuture = @"0";
        APLLog(@"no numberOfMessagesInTheFuture");
    }
}


-(void)importTimeStamp{
    
    NSString *amazonStartTimeStamp = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]-16400];
    mytimeStamp = @"";
    if([prefs objectForKey:@"timeStamp"]){
        NSString *mytimeStampCopy;
        mytimeStampCopy = [prefs objectForKey:@"timeStamp"];
        mytimeStamp = [[NSString alloc] initWithString:mytimeStampCopy];
    }
    if ([mytimeStamp isKindOfClass:[NSString class]]){
        APLLog(@"myTime stamp is a string");
    }
    else{
        APLLog(@"myTime stamp is not a string");
        mytimeStamp = [NSString stringWithFormat:@"%@",mytimeStamp];
    }
    
    if(!mytimeStamp){
        APLLog(@"mytimestamp nil");
        mytimeStamp = amazonStartTimeStamp;
    }
    else{
        APLLog(@"mytimestamp not nil");
        if([mytimeStamp isEqualToString:@""]){
            APLLog(@"mytimestamp empty string");
            mytimeStamp = amazonStartTimeStamp;
        }
        if([mytimeStamp isEqualToString:@"(null)"]){
            mytimeStamp = amazonStartTimeStamp;
            APLLog(@"mytimestamp (null)");
        }
    }
    APLLog(@"myActualTimeStamp %@", mytimeStamp);

}

-(void)importTipsVariables{
    //----------------tips-----------------------
    if([prefs objectForKey:my_prefs_send_tips_key]){
        NSString *sendTipsCopy;
        sendTipsCopy = [prefs objectForKey:my_prefs_send_tips_key];
        sendTips = [[NSString alloc] initWithString:sendTipsCopy];
        APLLog(@"sendTipsCounter: %@",sendTips);
    }
    else{
        sendTips = @"0";
        APLLog(@"no sendTipsCounter");
    }
    
    if([prefs objectForKey:my_prefs_receive_tips_key]){
        NSString *receiveTipsCopy;
        receiveTipsCopy = [prefs objectForKey:my_prefs_receive_tips_key];
        receiveTips = [[NSString alloc] initWithString:receiveTipsCopy];
        APLLog(@"receiveTipsCounter: %@",receiveTips);
    }
    else{
        receiveTips = @"0";
        APLLog(@"no receiveTipsCounter");
    }
}

-(NSMutableArray *)copyKeoChoicesArray:(NSArray *)importedChoicesArray{
    NSMutableArray *returnChoicesArray = [[NSMutableArray alloc] init];
    for(NSDictionary *choice in importedChoicesArray){
        NSMutableDictionary *newChoice2 = [[NSMutableDictionary alloc] init];
        
        if([choice objectForKey:my_sendChoice_key]){
            [newChoice2 setObject:[choice objectForKey:my_sendChoice_key] forKey:my_sendChoice_key];}
        else{
            [newChoice2 setObject:@"" forKey:my_sendChoice_key];}
        if([choice objectForKey:my_sendChoice_order_id]){
            [newChoice2 setObject:[choice objectForKey:my_sendChoice_order_id] forKey:my_sendChoice_order_id];}
        else{
            [newChoice2 setObject:@"" forKey:my_sendChoice_order_id];}
        if([choice objectForKey:my_sendChoice_send_label]){
            [newChoice2 setObject:[choice objectForKey:my_sendChoice_send_label] forKey:my_sendChoice_send_label];}
        else{
            [newChoice2 setObject:@"" forKey:my_sendChoice_send_label];}
        
        [returnChoicesArray insertObject:newChoice2 atIndex:[returnChoicesArray count]];
    }
    return returnChoicesArray;
}

-(NSMutableArray *)copyMessagesDataFile:(NSArray *)importedArray{
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    int counter = 0;
    
    if(!myCurrentPhotoPath){
        myCurrentPhotoPath = [self getCurrentAppPath];
    }
    else{
        APLLog(@"myCurrentPhotoPath already exists: %@",myCurrentPhotoPath);
    }
    
    for(NSDictionary *message in importedArray){
        counter += 1;
        //APLLog(@"counter: %d and message: %@",counter, [message description]);
        NSMutableDictionary *newMessage2 = [[NSMutableDictionary alloc] init];
        
        if([message objectForKey:my_shyft_id_Key]){
            [newMessage2 setObject:[message objectForKey:my_shyft_id_Key] forKey:my_shyft_id_Key];}
        else{
            [newMessage2 setObject:@"" forKey:my_shyft_id_Key];}
        
        if([message objectForKey:my_from_email_Key]){
            [newMessage2 setObject:[message objectForKey:my_from_email_Key] forKey:my_from_email_Key];}
        else{
            [newMessage2 setObject:@"" forKey:my_from_email_Key];}
        if([message objectForKey:my_from_id_Key]){
            [newMessage2 setObject:[message objectForKey:my_from_id_Key] forKey:my_from_id_Key];}
        else{
            [newMessage2 setObject:@"" forKey:my_from_id_Key];}
        if([message objectForKey:my_message_Key]){
            [newMessage2 setObject:[message objectForKey:my_message_Key] forKey:my_message_Key];}
        else{
            [newMessage2 setObject:@"" forKey:my_message_Key];}
        if([message objectForKey:my_created_at_Key]){
            [newMessage2 setObject:[message objectForKey:my_created_at_Key] forKey:my_created_at_Key];}
        else{
            [newMessage2 setObject:@"" forKey:my_created_at_Key];}
        if([message objectForKey:my_photo_Key]){
            NSString* phLocStr = [message objectForKey:my_photo_Key];
            NSString* subsLocStr = @"";
            ///OLD BUG ON OLD VERSIONS
            ///to keep until everyone has version #17
            if([phLocStr length] > [myCurrentPhotoPath length]){
                if([[phLocStr substringToIndex:[myCurrentPhotoPath length]] isEqualToString:myCurrentPhotoPath]){
                    subsLocStr = [phLocStr substringFromIndex:([myCurrentPhotoPath length]+1)];
                    APLLog(@"PREVIOUS: %@   NOW: %@",phLocStr,subsLocStr);
                    [newMessage2 setObject:subsLocStr forKey:my_photo_Key];
                }else{[newMessage2 setObject:[message objectForKey:my_photo_Key] forKey:my_photo_Key];}
                
            }else{[newMessage2 setObject:[message objectForKey:my_photo_Key] forKey:my_photo_Key];}
            ///
            
            //TO put instead when everyone will have version #17
            //[newMessage2 setObject:[message objectForKey:@"photo"] forKey:@"photo"];
        }
        else{
            [newMessage2 setObject:@"" forKey:my_photo_Key];}
        if([message objectForKey:my_from_numero_Key]){
            [newMessage2 setObject:[message objectForKey:my_from_numero_Key] forKey:my_from_numero_Key];}
        else{
            [newMessage2 setObject:@"" forKey:my_from_numero_Key];}
        if([message objectForKey:my_receive_label_Key]){
            [newMessage2 setObject:[message objectForKey:my_receive_label_Key] forKey:my_receive_label_Key];}
        else{
            [newMessage2 setObject:@"" forKey:my_receive_label_Key];}
        if([message objectForKey:my_receive_color_Key]){
            [newMessage2 setObject:[message objectForKey:my_receive_color_Key] forKey:my_receive_color_Key];}
        else{
            [newMessage2 setObject:@"" forKey:my_receive_color_Key];}
        if([message objectForKey:my_loaded_Key]){
            [newMessage2 setObject:[message objectForKey:my_loaded_Key] forKey:my_loaded_Key];}
        else{
            [newMessage2 setObject:@"yes" forKey:my_loaded_Key];}
        if([message objectForKey:my_received_at_Key]){
            if(![[message objectForKey:my_received_at_Key] isEqualToString:@""]){
                [newMessage2 setObject:[message objectForKey:my_received_at_Key] forKey:my_received_at_Key];
            }
            else{[newMessage2 setObject:@"0" forKey:my_received_at_Key];}
        }
        else{
            [newMessage2 setObject:@"0" forKey:my_received_at_Key];}
        
        if([[newMessage2 objectForKey:my_message_Key] isEqualToString:@""]){
            if([newMessage2 objectForKey:my_photo_Key]){
                NSString *phphPath = [newMessage2 objectForKey:my_photo_Key];
                if(myCurrentPhotoPath){
                    if([phphPath length] > [myCurrentPhotoPath length]){
                        if ([[phphPath substringToIndex:[myCurrentPhotoPath length]] isEqualToString:myCurrentPhotoPath]) {
                            //APLLog(@"Right Path");
                        }
                        else{ //OLD BUG (on old version) TO DELETE
                            NSRange theRange = [phphPath rangeOfString:@"Keo"];
                            NSString *newPath;
                            //APLLog(@"theRange: %d", theRange.length);
                            if(theRange.length != 0){
                                APLLog(@"Wrong Path");
                                APLLog(phphPath);
                                newPath = [NSString stringWithFormat:@"%@%@",myCurrentPhotoPath,[phphPath substringFromIndex:(theRange.location+theRange.length)]];
                                APLLog(newPath);
                                [newMessage2 setObject:newPath forKey:my_photo_Key];
                            }
                        }
                    }
                    
                }
            }
        }
        
        
        //Delete the old messages to make space in the memory (just the last 80 messages are kept)
        if(counter > 80){
            if([[newMessage2 objectForKey:my_message_Key] isEqualToString:@""]){
                NSString *dPhotoId = @"default";
                if([newMessage2 objectForKey:my_photo_Key]){
                    dPhotoId = [newMessage2 objectForKey:my_photo_Key];
                }
                NSString *inDeletePath = [NSString stringWithFormat:@"%@/%@",myCurrentPhotoPath,dPhotoId];
                APLLog(@"DELETE PHOTO AT PATH (old photo): %@",inDeletePath);
                [myGeneralMethods deletePhotoAtPath:inDeletePath];
            }
        }
        else{
            [returnArray insertObject:newMessage2 atIndex:[returnArray count]];
        }
        
        
    }
    return returnArray;
}



-(NSMutableDictionary *)copyKeoContactDictionary:(NSDictionary *)importedDic{
    NSMutableDictionary *returnDic = [[NSMutableDictionary alloc] init];
    for(NSString *key in [importedDic allKeys]){
        NSMutableDictionary *contactImported3 = [importedDic objectForKey:key];
        NSMutableDictionary *newContact3 = [contactImported3 mutableCopy]; //[self copyKeoContact:contactImported3];
        
        [returnDic setObject:newContact3 forKey:[newContact3 objectForKey:@"phoneNumber1"]];
    }
    return returnDic;
}


-(NSMutableDictionary *)copyKeoContact:(NSDictionary *)contactImported{
    NSMutableDictionary *newContact2 = [[NSMutableDictionary alloc] init];
    
    if([contactImported objectForKey:@"email"]){
        [newContact2 setObject:[contactImported objectForKey:@"email"] forKey:@"email"];}
    else{
        [newContact2 setObject:@"" forKey:@"email"];}
    if([contactImported objectForKey:@"user_id"]){
        [newContact2 setObject:[contactImported objectForKey:@"user_id"] forKey:@"user_id"];}
    else{
        [newContact2 setObject:@"" forKey:@"user_id"];}
    if([contactImported objectForKey:@"status"]){
        [newContact2 setObject:[contactImported objectForKey:@"status"] forKey:@"status"];}
    else{
        [newContact2 setObject:@"" forKey:@"status"];}
    if([contactImported objectForKey:@"firstNames"]){
        [newContact2 setObject:[contactImported objectForKey:@"firstNames"] forKey:@"firstNames"];}
    else{
        [newContact2 setObject:@"" forKey:@"firstNames"];}
    if([contactImported objectForKey:@"lastNames"]){
        [newContact2 setObject:[contactImported objectForKey:@"lastNames"] forKey:@"lastNames"];}
    else{
        [newContact2 setObject:@"" forKey:@"lastNames"];}
    if([contactImported objectForKey:@"phoneNumber1"]){
        [newContact2 setObject:[contactImported objectForKey:@"phoneNumber1"] forKey:@"phoneNumber1"];}
    else{
        [newContact2 setObject:@"" forKey:@"phoneNumber1"];}
    
    return newContact2 ;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    if(deviceToken){
        //-----------------get the device token to send notifications to the user-------------------
        APLLog(@"My token is: %@", deviceToken);
        myDeviceToken = [NSString stringWithFormat:@"%@", deviceToken];
        myDeviceToken = [myDeviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];
        myDeviceToken = [myDeviceToken substringWithRange:NSMakeRange(1,64)];
        [prefs setObject:myDeviceToken forKey:@"deviceToken"];
    }
    else{
        APLLog(@"No deviceToken from phone");
    }
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    APLLog(@"Failed to get token, error: %@", error);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    application.applicationIconBadgeNumber = 0;
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    APLLog(@"applicationWillEnterForeground");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"askNewMessages2" object: nil];
    
    appjustOpened = true;
    openingAppTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0 target: self selector: @selector(appOpenedSinceOneSecond:) userInfo: nil repeats: NO];
    APLLog(@"APP JUST OPENED");
    
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

-(void)appOpenedSinceOneSecond:(NSTimer*) ttt{
    appjustOpened = false;
    APLLog(@"APP OPENED SINCE MORE THAN A SECOND");
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [FBAppEvents activateApp];

    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    //q Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    APLLog(@"NOTIFICATION");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"askNewMessages2" object: nil];
    if(appjustOpened){
        APLLog(@"APP OPENED ON NOTIFICATION");
        appOpenedOnNotification = true;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"switchViewToKeo" object: nil];
    }
    
}

/*
 - (void)localNotification{
 APLLog(@"localnotification");
 UILocalNotification *notification = [[UILocalNotification alloc] init];
 notification.alertBody =  @"Looks like i got a notification - fetch thingy";
 [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
 
 }*/
/*
 - (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
 
 APLLog(@"NOTIFICATION");
 UIApplicationState state = [application applicationState];
 [[NSNotificationCenter defaultCenter] postNotificationName:@"askNewMessages2" object: nil];
 if(appjustOpened){
 APLLog(@"APP OPENED ON NOTIFICATION");
 appOpenedOnNotification = true;
 [[NSNotificationCenter defaultCenter] postNotificationName:@"switchViewToKeo" object: nil];
 }
 }*/

/*
 - (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
 }*/

-(void)cleanKeoPhotoRepository{//delete all photos
    NSFileManager* fm = [[NSFileManager alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:@"/Keo"];
    //NSString *path = @"/var/mobile/Applications/60F163A1-931A-4A3C-B4A6-46543FB54863/Documents/Keo";
    NSDirectoryEnumerator* en = [fm enumeratorAtPath:path];
    NSError* err = nil;
    BOOL res;
    
    NSString* file;
    while (file = [en nextObject]) {
        res = [fm removeItemAtPath:[path stringByAppendingPathComponent:file] error:&err];
        if (!res && err) {
            APLLog(@"oops: %@", err);
        }
    }
}

-(NSString *)getCurrentAppPath{
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"/Keo"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]){
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&error];
    }
    
    //NSString *path = @"/var/mobile/Applications/60F163A1-931A-4A3C-B4A6-46543FB54863/Documents/Keo";
    APLLog([NSString stringWithFormat:@"Appdelegate-path: %@",path]);
    return path;
}

-(void)getAllPhotoPaths{
    NSError *error;
    NSFileManager* fm = [[NSFileManager alloc] init];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:@"/Keo"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]){
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&error];
    }
    
    //NSString *path = @"/var/mobile/Applications/60F163A1-931A-4A3C-B4A6-46543FB54863/Documents/Keo";
    APLLog([NSString stringWithFormat:@"Appdelegate-path: %@",path]);
    
    NSDirectoryEnumerator* en = [fm enumeratorAtPath:path];
    NSString* file;
    while (file = [en nextObject]) {
        [myKeoReferences addObject:[path stringByAppendingPathComponent:file]];
    }
}



- (void)registerDefaultsFromSettingsBundle {//no idea what this is for
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    if(!settingsBundle) {
        APLLog(@"Could not find Settings.bundle");
        return;
    }
    
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
    
    NSMutableDictionary *defaultsToRegister = [[NSMutableDictionary alloc] initWithCapacity:[preferences count]];
    for(NSDictionary *prefSpecification in preferences) {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        if(key) {
            [defaultsToRegister setObject:[prefSpecification objectForKey:@"DefaultValue"] forKey:key];
        }
    }
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsToRegister];
    //[defaultsToRegister release];
}


//no idea why this is here
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // attempt to extract a token from the url
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}


@end

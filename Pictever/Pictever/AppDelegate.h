//
//  AppDelegate.h
//  Pictever
//
//  Created by Gauthier Petetin on 18/04/2014.
//  Copyright (c) 2014 Gauthier Petetin. All rights reserved.
//
#define ApplicationDelegate ((AppDelegate *)[UIApplication sharedApplication].delegate)

#import <UIKit/UIKit.h>

#import <AudioToolbox/AudioServices.h>

#import <Foundation/Foundation.h>

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@class ShyftSet;
@class GPSession;
@class myGeneralMethods;

#import <AWSiOSSDKv2/AWSCore.h>
#import <AWSiOSSDKv2/AWSMobileAnalytics.h>
#import <AWSiOSSDKv2/S3.h>
#import <AWSiOSSDKv2/DynamoDB.h>
#import <AWSiOSSDKv2/SQS.h>
#import <AWSiOSSDKv2/SNS.h>



/////APPLAUSE// service pour le débuggage/////
#import <Applause/APLLogger.h>
/////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////All my global variables (GO TO APPDELEGATE.M FOR MORE INFO ABOUT THE VARIABLES)////////////////


extern bool firstUseEver;
extern bool firstGlobalOpening;
extern bool firstContactOpening;
extern bool appOpenedOnNotification;

extern AWSMobileAnalytics* analytics;

extern ShyftSet *myShyftSet;

extern NSUserDefaults *prefs;

extern NSString *myLocaleString;
extern NSString *myAppVersion;

extern NSString *myFacebookName;
extern NSString *myFacebookID;
extern NSString *myFacebookBirthDay;

extern NSString *username;
extern NSString *hashPassword;
extern bool logIn;
extern NSString *myCurrentPhoneNumber;
extern NSString *myCountryCode;
extern NSString *myUserID;
extern NSString *myStatus;

extern NSString *mytimeStamp;//global

extern NSString *myDeviceToken;

extern NSMutableArray *messagesDataFile;

extern NSString *myCurrentPhotoPath;

extern AWSCognitoCredentialsProvider *credentialsProvider;
//Amazon
extern NSString *aws_account_id;
extern NSString *cognito_pool_id;
extern NSString *cognito_role_auth;
extern NSString *cognito_role_unauth;
extern NSString *S3BucketName;
//


//new App version
extern bool myVersionForceInstall;
extern NSString *myVersionInstallUrl;
//

//number of messages in the future
extern NSString *numberOfMessagesInTheFuture;


extern int openingWindow; //to open directly the chat window

extern NSMutableArray *importContactsData;//global
extern NSMutableArray *importContactsNames;//global
extern NSMutableArray *importKeoChoices;//global
extern NSMutableDictionary *importKeoContacts;//global
extern NSMutableDictionary *importKeoPhotos;//global
extern NSMutableDictionary *importKeoOccurences;//global

extern NSMutableArray *importContactPhones;//global
extern NSMutableArray *importContactMails;//global
extern NSMutableArray *importContactIDs;//global

extern NSString * storyboardName;
extern NSString * backgroundImage; //global
extern NSString *adresseIp2;//global

//size if the screen
extern CGFloat screenWidth;//global
extern CGFloat screenHeight;//global
extern CGFloat tabBarHeight;//global
//

extern NSMutableArray *sendToMail;//global
extern NSString *sendToName;//global
extern NSString *sendToDate;//global
extern NSString *sendToTimeStamp;//global
extern NSString *sendToDateAsText;//global

extern NSString *downloadPhotoRequestName;//global

//extern NSMutableDictionary *saveCurrentSendMessage;//global

extern bool showDatePicker;//global

extern UIColor *theBackgroundColor;//global
extern UIColor *theKeoOrangeColor;//global
extern UIColor *thePicteverGreenColor;//global
extern UIColor *thePicteverYellowColor;//global
extern UIColor *thePicteverRedColor;//global
extern UIColor *thePicteverGrayColor;//global

extern NSMutableArray *localKeoContacts;//global

extern NSMutableArray *sendBox;//global
extern NSMutableArray *loadBox;//global
extern bool isLoadingLoadBox;//global

extern NSMutableDictionary * selectedLocalDic;//global

extern bool zoomOn;//global

extern bool sendKeo;//global

extern bool uploadPhotoOnCloudinary;//global
extern bool downloadPhotoOnAmazon;//global

extern bool frontCameraActivated;//global

extern float uploadProgress;//global

extern NSString* lastLabelSelected;//global

extern bool localWork;//global

extern bool sendSMS;//global

extern GPSession *myUploadContactSession;//global

extern NSString* sendTips;
extern NSString* receiveTips;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


-(NSMutableArray *)copyMessagesDataFile:(NSArray *)importedArray;
-(NSMutableArray *)copyArray:(NSArray *)importedArr;
-(NSMutableArray *)copyKeoChoicesArray:(NSArray *)importedChoicesArray;

@end

//
//  GPRequests.h
//  Keo
//
//  Created by Gauthier Petetin on 18/06/2014.
//  Copyright (c) 2014 Gauthier Petetin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"//conection
#import <SystemConfiguration/SystemConfiguration.h>//connection

//---------APPLAUSE
#import <Applause/APLLogger.h>

@interface GPRequests : UIViewController

+ (BOOL)connected;

+ (NSInteger) signUpWithEmail:(NSString *)mail withPassWord:(NSString *)password for:(id)sender;

+ (NSInteger) define_first_phone_number:(NSString *)phoneNumber for:(id)sender;

+ (NSInteger) confirme_phone_number:(NSString *)phoneNumber withCode:(NSString *)myCode for:(id)sender;

+ (NSInteger) loginWithEmail:(NSString *)mail withPassWord:(NSString *)password for:(id)sender;

+ (void)askMessagesfor:(id)sender withTimeStamp:(NSString *)timeStamp;

+ (void)askKeoChoicesfor:(id)sender;

+(void)sendMessage:(NSString *)messageToSend to:(NSString *)recipient withPhotoString:(NSString *)photoString withKeoTime:(NSString *)keo_time for:(id)sender;

+(void)uploadContactArray:(NSMutableArray *)contactBookArray for:(id)sender;

+(NSString*)sha256HashFor:(NSString*)input;

+(void)goBackToFirstServer;

+(void)asynchronousLoginWithEmail:(NSString *)mail withPassWord:(NSString *)password2 for:(id)sender;

+ (void)asynchronousDefine_first_phone_number:(NSString *)phoneNumber for:(id)sender;

+ (void)askNumberoOfMessagesInTheFuture:(id)sender;

+ (void)getStatus:(id)sender;

+(void)alertAnalyticsStatus;

+ (void)downloadPhotoAtURL:(NSString *)photoIdPath for:(id)sender;

@end

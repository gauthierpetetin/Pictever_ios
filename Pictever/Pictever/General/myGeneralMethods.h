//
//  myGeneralMethods.h
//  Pictever
//
//  Created by Gauthier Petetin on 06/11/2014.
//  Copyright (c) 2014 Pictever. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class myConstants;

@interface myGeneralMethods: NSObject

+ (UIColor *)getColorFromHexString:(NSString *)hexString;

+(CGSize)text:(NSString*)text sizeWithFont:(UIFont*)font constrainedToSize:(CGSize)size;

+(NSString *)getPathwithID:(NSString *)pathID;

+(void)deletePhotoAtPath:(NSString*)myPath;

+ (UIImage*)loadImageAtPath:(NSString *)myNewPath;

+(NSUInteger)indexOfPhotoID:(NSString *) localPhotoID;

+(void)skipCurrentLoadBoxMessage:(NSUInteger)indexOfPhotoReceived;

+(NSInteger)indexOfMessageInSendBox:(NSMutableDictionary *)messageSent;

+(NSMutableDictionary *)receiveAmazonDownLoadedPhotoFromSession:(NSMutableDictionary *)shyftFromSession;

+(void)replaceMessage:(NSMutableDictionary *)replacingMessage andDeleteLoadBoxAtIndex:(NSUInteger)deleteIndex;

+(void)replaceMessage:(NSMutableDictionary *)replacingMessage;

+ (NSString *)saveImageReceived: (UIImage*)imageInKeo atKey:(NSString *)myKey;

+(void)saveMessagesData;

+(void)cleanMessageDataFile;

+(NSString *)stringForKeoChoicePh:(NSString *)choice withParameter:(NSString *)parameter;

+ (UIImage*) scaleImage:(UIImage*)image;

+ (UIImage*) scaleImage3:(UIImage*)image withFactor:(CGFloat)myFactor;

+(NSString *)stringFromArrayPh:(NSMutableArray *)array;

+(NSMutableArray *)createJsonArrayOfContacts;

+(void)receiveAllMessagesTogether:(NSArray *)res withTimeStamp:(NSString *)timeStampToSave;

+(void)checkAccountName:(NSString *)phNumber1;

+(NSString *) getStringToPrint: (NSDate *)dateToPrint;

+(NSString *) getStringToPrint2: (NSDate *)dateToPrint;

@end
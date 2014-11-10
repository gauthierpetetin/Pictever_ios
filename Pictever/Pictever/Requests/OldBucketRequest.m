//
//  OldBucketRequest.m
//  Shyft
//
//  Created by Gauthier Petetin on 20/10/2014.
//  Copyright (c) 2014 Gauthier Petetin. All rights reserved.
//

#import "OldBucketRequest.h"

#import "myConstants.h"
#import "myGeneralMethods.h"


//---------APPLAUSE
#import <Applause/APLLogger.h>

//---------Amazon-------------
#import <AWSiOSSDKv2/AWSCore.h>
#import <AWSiOSSDKv2/S3.h>
#import <AWSiOSSDKv2/DynamoDB.h>
#import <AWSiOSSDKv2/SQS.h>
#import <AWSiOSSDKv2/SNS.h>
#import <AWSiOSSDKv2/AWSMobileAnalytics.h>


@interface OldBucketRequest ()

@end

@implementation OldBucketRequest

AWSCognitoCredentialsProvider *credentialsProvider;
NSString *S3BucketName;

NSString *myCurrentPhotoPath;
NSString *storyboardName;

bool downloadPhotoOnAmazon;//global

- (instancetype)initWithName:(NSString *)name{
    if ((self = [super init])) {
    }
    return self;
}


//------------download on the old bucket----------------
-(void)loadPhotoOnOldBucket:(NSMutableDictionary *) newShyft2{

    _oldMessageDataDict = [newShyft2 mutableCopy];
    
    NSString *photoPublicId2 = [_oldMessageDataDict objectForKey:my_message_Key];
    
    NSString *pathWithID = [myGeneralMethods getPathwithID:photoPublicId2];
    
    ////////AMAZON
    APLLog(@"ASK AMAZON: %@",photoPublicId2);
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    
    AWSS3TransferManagerDownloadRequest *downloadRequest;
    downloadRequest = [AWSS3TransferManagerDownloadRequest new];
    downloadRequest.bucket = @"ShyftBucket";
    downloadRequest.key = photoPublicId2;
    downloadRequest.downloadingFileURL = [NSURL fileURLWithPath:pathWithID];
    
    [[transferManager download:downloadRequest] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        if (task.error != nil) {//----------------download on old bucket failed----------
            [_oldMessageDataDict setObject:@"yes" forKey:my_loaded_Key];
            
            APLLog(@"Error: [%@]", task.error);
            NSInteger errorCodeAma = task.error.code;
            APLLog(@"The amazon error code is %d", errorCodeAma);
            if(errorCodeAma == 516){
                APLLog(@"AMA ERROR CODE 516");
                NSString *deletePathAma = [NSString stringWithFormat:@"%@/%@",myCurrentPhotoPath,photoPublicId2];
                APLLog(@"DELETE PH AT PATH: %@",deletePathAma);
                [myGeneralMethods deletePhotoAtPath:deletePathAma];
            }
            if([[_oldMessageDataDict objectForKey:my_loaded_Key] isEqualToString:@"yes"]){
                NSInteger indexOfErrorPhotoReceived = [myGeneralMethods indexOfPhotoID:[_oldMessageDataDict objectForKey:my_shyft_id_Key]];
                if(indexOfErrorPhotoReceived != -1){
                    [myGeneralMethods skipCurrentLoadBoxMessage:indexOfErrorPhotoReceived];
                }
            }
            else{
                [_oldMessageDataDict setObject:@"yes" forKey:my_loaded_Key];
                [myGeneralMethods replaceMessage:_oldMessageDataDict];
            }
        }
        else {//-------------------------download on old bucket succeeded--------------------
            NSMutableDictionary* newShyft3 = [myGeneralMethods receiveAmazonDownLoadedPhotoFromSession:_oldMessageDataDict];
            
            APLLog(@"OK FOR AMAZON");
            
            if(newShyft3 != nil){
                /*UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
                
                KeoMessages * vck = (KeoMessages *)[storyboard instantiateViewControllerWithIdentifier:my_storyboard_timeline_Name];
                
                [vck vibrateForNewShyft:newShyft3];*/
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"vibrateForNewShyft" object:self userInfo:newShyft3];
                });
            }
            
        }

        downloadPhotoOnAmazon = false;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"stopLoadingAnimation" object: nil];
        });
        return nil;
    }];
    
    
    ////////////
    
    
}


@end
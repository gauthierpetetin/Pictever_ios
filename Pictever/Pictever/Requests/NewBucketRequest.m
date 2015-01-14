//
//  NewBucketRequest.m
//  Shyft
//
//  Created by Gauthier Petetin on 20/10/2014.
//  Copyright (c) 2014 Gauthier Petetin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NewBucketRequest.h"

//#import "OldBucketRequest.h"

#import "myConstants.h"
#import "myGeneralMethods.h"

@interface NewBucketRequest ()


@end

@implementation NewBucketRequest

NSString *downloadPhotoRequestName;
NSString *storyboardName;
NSString *myLocaleString;

NSMutableArray *loadBox;//global

bool downloadPhotoOnAmazon;//global

- (instancetype)initWithName:(NSString *)name{
    if ((self = [super init])) {
        
    }
    return self;
}




-(void)sessionNewBucket:(NSMutableDictionary *)newShyftReceived{
    NSString *urlForNewDownload = [NSString stringWithFormat:@"%@%@",downloadPhotoRequestName,[newShyftReceived objectForKey:my_message_Key]];
    APLLog(@"urlForNewDownload: %@",urlForNewDownload);
    _messageDataDict = [newShyftReceived mutableCopy];
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:urlForNewDownload]
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {
                // handle response
                if(error != nil){
                    APLLog(@"New download Photo Error: [%@]", [error description]);
                    
                    //[[[OldBucketRequest alloc] init] loadPhotoOnOldBucket:_messageDataDict];
                }
                else{
                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                    NSInteger sessionErrorCode = [httpResponse statusCode];
                    if(sessionErrorCode != 200){
                        
                        //--------------remove message from loadbox------------
                        NSString *messageID = @"";
                        if([newShyftReceived objectForKey:my_shyft_id_Key]){
                            messageID = [newShyftReceived objectForKey:my_shyft_id_Key];
                        }
                        NSUInteger indexOfPhotoReceived = [myGeneralMethods indexOfPhotoID:messageID];
                        if([loadBox count] > indexOfPhotoReceived){
                            if(indexOfPhotoReceived != -1){
                                [loadBox removeObjectAtIndex:indexOfPhotoReceived];
                            }
                        }
                        
                        if(sessionErrorCode==500){
                            UIAlertView *alert = [[UIAlertView alloc]
                                                  initWithTitle:@"downloadphoto: Error"
                                                  message:@"Server problem" delegate:self
                                                  cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                            [alert show];
                        }
                        if(sessionErrorCode==403){
                            APLLog(@"newBucket 403");
                            APLLog(@"loadPhotoOnOldBucket: %@", [_messageDataDict description]);
                            //[[[OldBucketRequest alloc] init] loadPhotoOnOldBucket:_messageDataDict];
                        }

                    }
                    else{
                        [self sessionNewBucketSucceededFor:_messageDataDict withData:data];
                        
                    }
                    downloadPhotoOnAmazon = false;
                    if([loadBox count]==0){
                        APLLog(@"stop the loading animations!");
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"stopLoadingAnimation" object: nil];
                        });
                    }
                    else{
                        APLLog(@"still %d messages loading...",[loadBox count]);
                    }
                }
                
            }] resume];
}


-(void)sessionNewBucketSucceededFor:(NSMutableDictionary *) newShyftReceived2 withData:(NSData *)data{
    NSString *photoPublicId4 = [newShyftReceived2 objectForKey:my_message_Key];
    //NSString *pathWithID4 = [KeoMessages getPathwithID:photoPublicId4];
    UIImage *downloadedImage = [UIImage imageWithData:data];
    [myGeneralMethods saveImageReceived:downloadedImage atKey:photoPublicId4];
    
    newShyftReceived2 = [myGeneralMethods receiveAmazonDownLoadedPhotoFromSession:newShyftReceived2];
    
    APLLog(@"OK FOR CLOUDFRONT From Session");
    
    if(newShyftReceived2 != nil){
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"vibrateForNewShyft" object:self userInfo:newShyftReceived2];
        });
    }
}




@end
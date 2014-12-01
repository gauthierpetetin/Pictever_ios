//
//  GPSession.m
//  Shyft
//
//  Created by Gauthier Petetin on 21/10/2014.
//  Copyright (c) 2014 Gauthier Petetin. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "GPSession.h"

#import "GPRequests.h"

#import "PickContact.h"

#import "ContactModel.h"
#import "ShyftSet.h"

#import "myGeneralMethods.h"
#import "myConstants.h"

@interface GPSession ()


@end

@implementation GPSession

ShyftSet *myShyftSet;

NSString *myCurrentPhotoPath;
NSString *myCurrentPhoneNumber;
NSString *storyboardName;
NSString *adresseIp2;
NSString *myFacebookName;
NSString *myFacebookID;
NSString *myFacebookBirthDay;
NSString *username;
NSString *hashPassword;
NSString *myStatus;
NSString *myUserID;
NSString *mytimeStamp;
NSString *numberOfMessagesInTheFuture;
NSString *myDeviceToken;
NSString *myAppVersion;

NSUserDefaults *prefs;

NSMutableDictionary *importKeoPhotos;//global
NSMutableArray *importKeoChoices;//global

NSMutableArray *messagesDataFile;

bool logIn;


NSMutableArray* sendBox;

NSString *downloadPhotoRequestName;

//Amazon
NSString *aws_account_id;
NSString *cognito_pool_id;
NSString *cognito_role_auth;
NSString *cognito_role_unauth;
NSString *S3BucketName;
//

NSString *myVersionInstallUrl;
bool myVersionForceInstall;
bool localWork;

GPSession *myUploadContactSession;//global

NSString* sendTips;//counter of messages sent to give some tips to the user once he sent his first messages
NSString* receiveTips;//counter of messages received to give some tips to the user once he received his first messages

- (instancetype)init{
    if ((self = [super init])) {
        _resendString = @"";
        _sendDictionary = [[NSMutableDictionary alloc] init];
        _sendTextOrPhoto = @"";
        _isUploadingContacts = false;
    }
    return self;
}


#pragma mark - get status

-(void)getStatusRequest:(id)sender{
    if([GPRequests connected]){
        NSString *getStatusUrl = [NSString stringWithFormat:@"%@%@",adresseIp2,my_getStatusRequestName];
        APLLog(@"getStatus session: %@", getStatusUrl);
        NSURLSession *session = [NSURLSession sharedSession];
        [[session dataTaskWithURL:[NSURL URLWithString:getStatusUrl]
                completionHandler:^(NSData *data,
                                    NSURLResponse *response,
                                    NSError *error) {
                    if(error != nil){
                        APLLog(@"New get status Error: [%@]", [error description]);
                    }
                    else{
                        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                        NSInteger sessionErrorCode = [httpResponse statusCode];
                        [self getStatusDidReceiveResponse:data withErrorCode:sessionErrorCode from:sender];
                    }
                    
                }] resume];
    }
}

-(void)getStatusDidReceiveResponse:(NSData *)data withErrorCode:(NSInteger)getStatusErrorCode from:(id)sender{
    if(getStatusErrorCode != 200){
        APLLog(@"getStatus session did receive response with error code: %i",getStatusErrorCode);
        if(getStatusErrorCode == 500){
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"Error get_Status"
                                      message:@"Server Error" delegate:sender
                                      cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
            });
        }
        if(getStatusErrorCode == 401){
            NSInteger loginCheckAnswer =[GPRequests loginWithEmail:username withPassWord:hashPassword for:sender];
            if(loginCheckAnswer == 200){
                [[[GPSession alloc] init] getStatusRequest:sender];
            }
            else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc]
                                          initWithTitle:@"Error"
                                          message:@"Please login first" delegate:sender
                                          cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alert show];
                });
                //----------- Switch screen - not login------------------
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
                UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"WelcomeScreen"];
                dispatch_async(dispatch_get_main_queue(), ^{
                   [sender presentViewController:vc animated:YES completion:nil];
                });
                //-------------------------------------------------------
            }
        }
        if(getStatusErrorCode == 404){
            [GPRequests goBackToFirstServer];
        }
    }
    else{
        [self getStatusSucceeded:data from:sender];
    }
}

-(void)getStatusSucceeded:(NSData *)data from:(id)sender{
    APLLog(@"Session succeeded! Received %d bytes of data getStatus",[data length]);
    NSString *previousStatus = myStatus;
    APLLog(@"My old mystatus: %@", previousStatus);
    myStatus = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if(![myStatus isEqualToString:previousStatus]){
        [PickContact updateMyStatus];
        NSString *prMessage = [NSString stringWithFormat:@"You are now a %@!",myStatus];
        if(![previousStatus isEqualToString:@""]){
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"New Status"
                                      message:prMessage delegate:sender
                                      cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
            });
        }
        [GPRequests alertAnalyticsStatus];
    }
    [prefs setObject:myStatus forKey:my_status_saving_Key];
    APLLog(@"My new mystatus: %@",myStatus);
}


#pragma mark - receive


-(void)receiveRequest:(id)sender{
    if([GPRequests connected]){
        NSString *receiveUrl = @"";
        
        //-----------------First we check if the timestamp is ok--------------------------------
        if(mytimeStamp){
            if ([mytimeStamp isKindOfClass:[NSString class]]){
                receiveUrl = [NSString stringWithFormat:@"%@%@%@%@",adresseIp2,my_receiveRequestName,@"?ts=",mytimeStamp];
            }
        }
        if([receiveUrl isEqualToString:@""]){
            mytimeStamp = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]];
            receiveUrl = [NSString stringWithFormat:@"%@%@%@%@",adresseIp2,my_receiveRequestName,@"?ts=",mytimeStamp];
        }
        
        
        APLLog(@"receive session: %@", receiveUrl);
        NSURLSession *session = [NSURLSession sharedSession];
        [[session dataTaskWithURL:[NSURL URLWithString:receiveUrl]
                completionHandler:^(NSData *data,
                                    NSURLResponse *response,
                                    NSError *error) {
                    if(error != nil){
                        APLLog(@"New receive Error: [%@]", [error description]);
                    }
                    else{
                        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                        NSInteger sessionErrorCode = [httpResponse statusCode];
                        [self receiveDidReceiveResponse:data withErrorCode:sessionErrorCode from:sender];
                    }
                    
                }] resume];
    }
}

-(void)receiveDidReceiveResponse:(NSData *)data withErrorCode:(NSInteger)receiveErrorCode from:(id)sender{

    APLLog(@"receive session did receive response with error code: %i",receiveErrorCode);
    if(receiveErrorCode != 200){
        if(receiveErrorCode==500){
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"Error: receive"
                                      message:@"Server problem" delegate:sender
                                      cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
            });
            [GPRequests goBackToFirstServer];
        }
        if(receiveErrorCode==404){
            [GPRequests goBackToFirstServer];
        }
        if(receiveErrorCode==401){
            APLLog(@"not login for receive");
            
            NSInteger loginCheckAnswer =[GPRequests loginWithEmail:username withPassWord:hashPassword for:sender];
            if(loginCheckAnswer == 200){
                APLLog(@"restart receive request");
                logIn = true;
                [prefs setBool:logIn forKey:my_prefs_login_key];
                [[[GPSession alloc] init] receiveRequest:sender];
            }
        }
    }
    else{
        [self receiveSucceeded:data];
    }
}

-(void)receiveSucceeded:(NSData *)data{

        APLLog(@"Session succeeded! Received %d bytes of data Receive",[data length]);
        NSError *myError = nil;
        id serverAnswer = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&myError];
        APLLog(@"Server answer: %@",[serverAnswer description]);

        if(serverAnswer){
            if(![serverAnswer isKindOfClass:[NSNull class]]){
                
                id myNewKeos = [serverAnswer objectForKey:@"new_messages"];
                NSArray *myNewKeosArray = (NSArray *)myNewKeos;
                
                id timeStamp = [serverAnswer objectForKey:@"ts"];
                NSString *timeStampAsString;
                if ([timeStamp isKindOfClass:[NSString class]]){
                    APLLog(@"myTime stamp is a string");
                    timeStampAsString = (NSString *)timeStamp;
                }
                else{
                    APLLog(@"myTime stamp is a float");
                    timeStampAsString = [NSString stringWithFormat:@"%@",timeStamp];
                }
                APLLog(@"time stamp converted as string: %@",timeStampAsString);
                
                
                NSString *myNewKeosAsString = [myNewKeos description];
                if([[myNewKeosAsString stringByReplacingOccurrencesOfString:@" " withString:@""] length] > 2){
                    if([myNewKeosArray count]>0){
                        /*UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
                        WriteMessage2 * vcm = (WriteMessage2 *)[storyboard instantiateViewControllerWithIdentifier:my_storyboard_message_Name];
                        [vcm receiveAllMessagesTogether:myNewKeosArray withTimeStamp:timeStampAsString];*/
                        
                        
                        /*NSMutableDictionary *resAndTimestampToSend = [[NSMutableDictionary alloc] init];
                        if(myNewKeosArray){
                            [resAndTimestampToSend setObject:myNewKeosArray forKey:@"res"];
                        }
                        if(timeStampAsString){
                            [resAndTimestampToSend setObject:timeStampAsString forKey:@"timeStampToSave"];
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            APLLog(@"sendNotifReceiveAllMessages: %@", [resAndTimestampToSend description]);
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"receiveAllMessagesTogether" object:nil userInfo:resAndTimestampToSend];
                        });*/
                        
                        [myGeneralMethods receiveAllMessagesTogether:myNewKeosArray withTimeStamp:timeStampAsString];
                    }
                }
                else{
                    //no new messages
                }
                
                
            }
        }
        
        
        else{
            APLLog(@"server answer is empty");
        }

}


#pragma mark - send

-(void)sendRequest:(NSString *)messageToSend to:(NSString *)recipient withPhotoString:(NSString *)photoString withKeoTime:(NSString *)keo_time for:(id)sender{
    
    if ([GPRequests connected]){
        
        if([photoString isEqualToString:@""]){
            _sendTextOrPhoto = @"text";
            APLLog(@"Send a text pict");
        }
        else{
            _sendTextOrPhoto = @"photo";
            APLLog(@"send a photo pict");
        }
        
        // 1
        NSURL *sendUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",adresseIp2,my_sendRequestName]];
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
        
        // 2
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:sendUrl];
        request.HTTPMethod = @"POST";
        
        // 3
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        [dictionary setObject:messageToSend forKey:my_message_send_request_field];
        [dictionary setObject:recipient forKey:my_receiver_ids_send_request_field];
        [dictionary setObject:photoString forKey:my_photo_send_request_field];
        [dictionary setObject:keo_time forKey:my_keo_choice_send_request_field];
        _sendDictionary = [dictionary mutableCopy];//-----copy message data in order to resend if 401
        
        
        NSString *postString = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@",@"photo_id=",photoString,@"&receiver_ids=",recipient,@"&message=",messageToSend,@"&delivery_option=",keo_time];
        APLLog([NSString stringWithFormat:@"Send session post: %@",postString]);
        NSData* data = [postString dataUsingEncoding:NSUTF8StringEncoding];
        
        NSError *error = nil;
        //NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary
        //                                             options:kNilOptions error:&error];
        
        if (!error) {
            // 4
            APLLog(@"send session: %@", sendUrl);
            NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request
                                                                       fromData:data completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
                                                                           if(error != nil){
                                                                               APLLog(@"New send Error: [%@]", [error description]);
                                                                               
                                                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                                                   UIAlertView *alert3 = [[UIAlertView alloc]
                                                                                                          initWithTitle:@"Message was not sent"
                                                                                                          message:@"" delegate:sender
                                                                                                          cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                                                                                   [alert3 show];
                                                                               });
                                                                               if ([_sendTextOrPhoto isEqualToString:@"photo"]) {
                                                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                                                       [[NSNotificationCenter defaultCenter] postNotificationName:@"hideProgressBars" object: nil];
                                                                                   });
                                                                               }
                                                                           }
                                                                           else{
                                                                               NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                                                               NSInteger sessionErrorCode = [httpResponse statusCode];
                                                                               [self sendDidReceiveResponse:data withErrorCode:sessionErrorCode from:sender];
                                                                           }
                                                                       }];
            
            // 5
            [uploadTask resume];
        }
    }
}

-(void)sendDidReceiveResponse:(NSData *)data withErrorCode:(NSInteger)sendErrorCode from:(id)sender{
    APLLog(@"send session did receive response with error code: %i",sendErrorCode);
    
    if(sendErrorCode != 200){
        if(sendErrorCode==500){
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"send: Error"
                                      message:@"Server problem" delegate:sender
                                      cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
            });
            [GPRequests goBackToFirstServer];
        }
        if(sendErrorCode==404){
            [GPRequests goBackToFirstServer];
        }
        if(sendErrorCode==401){
            APLLog(@"401 FOR SEND SESSION");
            
            NSInteger loginCheckAnswer =[GPRequests loginWithEmail:username withPassWord:hashPassword for:sender];
            if(loginCheckAnswer == 200){
                logIn = true;
                [prefs setBool:logIn forKey:my_prefs_login_key];
                APLLog(@"restart send request with saveCurrentSendMessage: %@",[_sendDictionary description]);
                NSString *lccMessage = @"";
                NSString *lccReceiverIds = @"";
                NSString *lccPhoto = @"";
                NSString *lccKeoChoice = @"";
                if([_sendDictionary objectForKey:my_message_send_request_field]){
                    lccMessage = [_sendDictionary objectForKey:my_message_send_request_field];
                }
                if([_sendDictionary objectForKey:my_receiver_ids_send_request_field]){
                    lccReceiverIds = [_sendDictionary objectForKey:my_receiver_ids_send_request_field];
                }
                if([_sendDictionary objectForKey:my_photo_send_request_field]){
                    lccPhoto = [_sendDictionary objectForKey:my_photo_send_request_field];
                }
                if([_sendDictionary objectForKey:my_keo_choice_send_request_field]){
                    lccKeoChoice = [_sendDictionary objectForKey:my_keo_choice_send_request_field];
                }
                [[[GPSession alloc] init] sendRequest:lccMessage to:lccReceiverIds withPhotoString:lccPhoto withKeoTime:lccKeoChoice for:sender];
                //[GPRequests sendMessage:lccText to:lccRecipient withPhotoString:@"" withKeoTime:lccKeoTime for:self];
            }
        }
    }
    else{
        [self sendSucceeded:data from:sender];
    }
}


-(void)sendSucceeded:(NSData *)data from:(id)sender{
    APLLog(@"Session succeeded! Received %d bytes of data Send",[data length]);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if([_sendTextOrPhoto isEqualToString:@"text"]){//---------------message is a text---------
            APLLog(@"initialize text viewcontroller");
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"initializeViewM" object:nil];
        }
        else if ([_sendTextOrPhoto isEqualToString:@"photo"]){//--------------message is a photo----------
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"hideProgressBars" object: nil];
            });

            if(sendBox){
                APLLog(@"sendBox exists: %@", [sendBox description]);
                NSInteger deleteInd = [myGeneralMethods indexOfMessageInSendBox:_sendDictionary];
                APLLog(@"sb delete index: %d", deleteInd);
                if(deleteInd != -1){
                    if (deleteInd < [sendBox count]) {
                        //Supression from the memory of the phone
                        APLLog(@"FULL SENDBOX: %@",[sendBox description]);
                        if([sendBox[deleteInd] objectForKey:my_sendbox_path]){
                            APLLog(@"delete image with path: %@%@",myCurrentPhotoPath,[[sendBox objectAtIndex:deleteInd] objectForKey:my_sendbox_path]);
                            
                            NSString *localPathEnd = [[sendBox objectAtIndex:deleteInd] objectForKey:my_sendbox_path];
                            [myGeneralMethods deletePhotoAtPath:[NSString stringWithFormat:@"%@/%@",myCurrentPhotoPath,localPathEnd]];
                            [sendBox removeObjectAtIndex:deleteInd];
                            APLLog(@"EMPTY SENDBOX: %@",[sendBox description]);
                            [prefs setObject:sendBox forKey:@"sendBox"];
                        }
                    }
                }
            }
        }
    });
    [[[GPSession alloc] init] getStatusRequest:self];
    
    [self increaseSendTipCounter:sender];
}



#pragma mark - Resend

-(void)resendRequest:(NSString*)resendShyftID for:(id)sender{
    if ([GPRequests connected]) {
        // 1
        NSURL *sendUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",adresseIp2,my_resendRequestName]];
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
        
        // 2
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:sendUrl];
        request.HTTPMethod = @"POST";
        
        // 3
        NSString *postString = [NSString stringWithFormat:@"message_id=%@",resendShyftID];
        NSData* data = [postString dataUsingEncoding:NSUTF8StringEncoding];
        _resendString = resendShyftID;
        APLLog([NSString stringWithFormat:@"Resend session post: %@",postString]);
        
        NSError *error = nil;
        
        if (!error) {
            // 4
            APLLog(@"resend session: %@", sendUrl);
            NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request
                                                                       fromData:data completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
                                                                           if(error != nil){
                                                                               APLLog(@"New resend Error: [%@]", [error description]);
                                                                               
                                                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                                                   UIAlertView *alert3 = [[UIAlertView alloc]
                                                                                                          initWithTitle:@"Message was not resent"
                                                                                                          message:@"" delegate:sender
                                                                                                          cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                                                                                   [alert3 show];
                                                                               });
                                                                           }
                                                                           else{
                                                                               NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                                                               NSInteger sessionErrorCode = [httpResponse statusCode];
                                                                               [self resendDidReceiveResponse:data withErrorCode:sessionErrorCode from:sender];
                                                                           }
                                                                       }];
            
            // 5
            [uploadTask resume];
        }
    }
}

-(void)resendDidReceiveResponse:(NSData *)data withErrorCode:(NSInteger)resendErrorCode from:(id)sender{
    APLLog(@"resend session did receive response with error code: %i",resendErrorCode);
    
    if(resendErrorCode != 200){
        if(resendErrorCode==500){
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"resend: Error"
                                      message:@"Server problem" delegate:sender
                                      cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
            });
            [GPRequests goBackToFirstServer];
        }
        if(resendErrorCode==404){
            [GPRequests goBackToFirstServer];
        }
        if(resendErrorCode==401){
            APLLog(@"401 FOR RESEND SESSION");
            
            NSInteger loginCheckAnswer =[GPRequests loginWithEmail:username withPassWord:hashPassword for:sender];
            if(loginCheckAnswer == 200){
                logIn = true;
                [prefs setBool:logIn forKey:my_prefs_login_key];
                APLLog(@"restart resend request with resendString: %@",_resendString);

                [[[GPSession alloc] init] resendRequest:_resendString for:sender];
            }
        }
    }
    else{
        [self resendSucceeded:data from:sender];
    }
}

-(void)resendSucceeded:(NSData *)data from:(id)sender{
    APLLog(@"Session succeeded! Received %d bytes of data Resend",[data length]);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert3 = [[UIAlertView alloc]
                               initWithTitle:@"Message resent successfully"
                               message:@"" delegate:sender
                               cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert3 show];
        [alert3 dismissWithClickedButtonIndex:0 animated:YES];
    });
    [[[GPSession alloc] init] getStatusRequest:self];
}


#pragma mark - GetNumberOfFutureMessages

-(void)askNumberOfMessagesInTheFuture:(id)sender{
    APLLog(@"askNumberoOfMessagesInTheFuture");
    if([GPRequests connected]){
        NSString *futureMessagesUrl = [NSString stringWithFormat:@"%@%@",adresseIp2,my_futureMessagesRequestName];
        APLLog(@"futuremessages session: %@", futureMessagesUrl);
        NSURLSession *session = [NSURLSession sharedSession];
        [[session dataTaskWithURL:[NSURL URLWithString:futureMessagesUrl]
                completionHandler:^(NSData *data,
                                    NSURLResponse *response,
                                    NSError *error) {
                    if(error != nil){
                        APLLog(@"New future messages Error: [%@]", [error description]);
                    }
                    else{
                        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                        NSInteger sessionErrorCode = [httpResponse statusCode];
                        [self futureMessagesDidReceiveResponse:data withErrorCode:sessionErrorCode from:sender];
                    }
                    
                }] resume];
    }
}

-(void)futureMessagesDidReceiveResponse:(NSData *)data withErrorCode:(NSInteger)futureMessagesErrorCode from:(id)sender{
    APLLog(@"future messages session did receive response with error code: %i",futureMessagesErrorCode);
    
    if(futureMessagesErrorCode != 200){
        if(futureMessagesErrorCode == 500){
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"Error futur_messages"
                                      message:@"Server Error" delegate:sender
                                      cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
            });
        }
        if(futureMessagesErrorCode == 401){
            NSInteger loginCheckAnswer =[GPRequests loginWithEmail:username withPassWord:hashPassword for:sender];
            if(loginCheckAnswer == 200){
                [[[GPSession alloc] init] askNumberOfMessagesInTheFuture:sender];
            }
        }
        if(futureMessagesErrorCode == 404){
            [GPRequests goBackToFirstServer];
        }
    }
    else{
        [self futureMessagesSucceeded:data];
    }
}

-(void)futureMessagesSucceeded:(NSData *)data{
    APLLog(@"Session succeeded! Received %d bytes of data future messages",[data length]);
    
    numberOfMessagesInTheFuture = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    [prefs setObject:numberOfMessagesInTheFuture forKey:@"numberOfMessagesInTheFuture"];
    
    NSMutableDictionary *dicForNotif = [[NSMutableDictionary alloc] init];
    [dicForNotif setObject:numberOfMessagesInTheFuture forKey:@"numberOfMessagesInTheFuture"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showFutureMessages" object:self userInfo:dicForNotif];
    });

    APLLog(@"New number of messages in the future: %@",numberOfMessagesInTheFuture);
}



#pragma mark - uploadContacts

-(void)uploadContacts:(NSMutableArray *)contactBookArray withTableViewReload:(bool)rel for:(id)sender{
    _contArray = contactBookArray;
    
    if(rel){
        _reloadTableView = @"true";
    }
    else{
        _reloadTableView = @"false";
    }
    
    if([GPRequests connected]&&(!_isUploadingContacts)){
        _isUploadingContacts = true;
        APLLog(@"uploadContacts size: %d",[contactBookArray count]);
        // 1
        NSURL *uploadUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",adresseIp2,my_uploadRequestName]];
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
        
        // 2
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:uploadUrl];
        request.HTTPMethod = @"POST";
        
        // 3
        NSError *errorUpload = nil;
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:contactBookArray options:NSJSONWritingPrettyPrinted error:&errorUpload];
        

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
        
        
        NSString *postString = [NSString stringWithFormat:@"%@%@",@"contacts=",mutableContactString];
        //APLLog([NSString stringWithFormat:@"UploadContacts session post: %@",postString]);
        NSData* data = [postString dataUsingEncoding:NSUTF8StringEncoding];
        
        NSError *error = nil;

        if (!error) {
            // 4
            APLLog(@"UploadContact session: %@", uploadUrl);
            NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request
                                                                       fromData:data completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
                                                                           if(error != nil){
                                                                               APLLog(@"New upload contact Error: [%@]", [error description]);
                                                                               _isUploadingContacts = false;
                                                                           }
                                                                           else{
                                                                               NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                                                               NSInteger sessionErrorCode = [httpResponse statusCode];
                                                                               [self uploadContactDidReceiveResponse:data withErrorCode:sessionErrorCode from:sender];
                                                                           }
                                                                       }];
            
            // 5
            [uploadTask resume];
        }
    }
}

-(void)uploadContactDidReceiveResponse:(NSData *)data withErrorCode:(NSInteger)uploadErrorCode from:(id)sender{
    APLLog(@"UploadContact session did receive response with error code: %i",uploadErrorCode);
    
    if(uploadErrorCode != 200){
        _isUploadingContacts = false;
        if(uploadErrorCode==500){
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"uploadContacts: Error"
                                      message:@"Server problem" delegate:sender
                                      cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
            });
            [GPRequests goBackToFirstServer];
        }
        if(uploadErrorCode==404){
            [GPRequests goBackToFirstServer];
        }
        if(uploadErrorCode==401){
            NSInteger loginCheckAnswer =[GPRequests loginWithEmail:username withPassWord:hashPassword for:sender];
            if(loginCheckAnswer == 200){
                APLLog(@"restart uploadContacts request");
                if([_reloadTableView isEqualToString:@"true"]){
                    [myUploadContactSession uploadContacts:_contArray withTableViewReload:YES for:sender];
                }
                else{
                    [myUploadContactSession uploadContacts:_contArray withTableViewReload:NO for:sender];
                }
            }
        }
    }
    else{
        [self uploadContactSucceeded:data];
    }
}

-(void)uploadContactSucceeded:(NSData *)data{
    APLLog(@"Session succeeded! Received %d bytes of data Upload contact",[data length]);

    NSMutableArray *localUpdateContactData = [[NSMutableArray alloc] init];
    
    NSError *myError = nil;
    id res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&myError];
    
    
    NSMutableArray *importContactPhonesLoc = [[NSMutableArray alloc] init];
    NSMutableArray *importContactMailsLoc = [[NSMutableArray alloc] init];
    NSMutableArray *importContactIDsLoc = [[NSMutableArray alloc] init];
    NSMutableArray *importContactStatusLoc = [[NSMutableArray alloc] init];
    
    NSArray *resArray = (NSArray *)res;
    APLLog(@"Number of Shyft contacts: %d",[resArray count]);
    
    for(id keoContactJson in res){
        id emailOfContact = [keoContactJson objectForKey:my_uploadContact_email];
        NSString * emailOfContactAsString;
        if(![emailOfContact isKindOfClass:[NSNull class]]){
            emailOfContactAsString = (NSString *)emailOfContact;
            [importContactMailsLoc addObject:emailOfContactAsString];
        }
        else{
            APLLog(@"EMPTY email");
            [importContactMailsLoc addObject:@""];
        }
        
        
        
        id phoneOfContact = [keoContactJson objectForKey:my_uploadContact_phoneNumber];
        NSString * phoneOfContactAsString;
        if(![phoneOfContact isKindOfClass:[NSNull class]]){
            phoneOfContactAsString = (NSString *)phoneOfContact;
            [importContactPhonesLoc addObject:phoneOfContactAsString];
        }
        else{
            APLLog(@"EMPTY phone");
            [importContactPhonesLoc addObject:@""];
        }
        
        
        
        id user_idOfContact = [keoContactJson objectForKey:my_uploadContact_user_id];
        NSString * user_idOfContactAsString;
        if(![user_idOfContact isKindOfClass:[NSNull class]]){
            user_idOfContactAsString = (NSString *)user_idOfContact;
            [importContactIDsLoc addObject:user_idOfContactAsString];
        }
        else{
            APLLog(@"EMPTY user_id");
            [importContactIDsLoc addObject:@""];
        }
        
        id statusOfContact = [keoContactJson objectForKey:my_uploadContact_status];
        NSString * statusOfContactAsString;
        if(![statusOfContact isKindOfClass:[NSNull class]]){
            statusOfContactAsString = (NSString *)statusOfContact;
            [importContactStatusLoc addObject:statusOfContactAsString];
        }
        else{
            APLLog(@"EMPTY status");
            [importContactStatusLoc addObject:@""];
        }
        
        NSMutableDictionary *contactToUpadte = [[NSMutableDictionary alloc] init];
        [contactToUpadte setObject:emailOfContactAsString forKey:my_uploadContact_email];
        [contactToUpadte setObject:phoneOfContactAsString forKey:my_uploadContact_phoneNumber];
        [contactToUpadte setObject:user_idOfContactAsString forKey:my_uploadContact_user_id];
        [contactToUpadte setObject:statusOfContactAsString forKey:my_uploadContact_status];
        
        //APLLog(@"contact to upadate %@",[contactToUpadte description]);
        [localUpdateContactData addObject:contactToUpadte];
    }
    
    //-----------update the contact list--------------------------
    [PickContact updateAllContacts:localUpdateContactData];
    
    //-----------prepare the contact list that already have the app for the tableview--------------
    [PickContact initLocalKeoContacts];
    
    importKeoPhotos = [PickContact addPhotosToAllContacts];
    
    APLLog(@"tabs reloaded");
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"reloadContactTableView" object:nil];
    
    if([_reloadTableView isEqualToString:@"true"]){
        dispatch_async(dispatch_get_main_queue(), ^{
            APLLog(@"reloadContactTableView");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadContactTableView" object:nil];
        });
    }
    
    APLLog(@"notif reloadContactTableView sent");
    
    [myShyftSet refreshAllProfilePics];
    
    APLLog(@"myShyftSet refreshed");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadData" object:nil];
    });
    
    _isUploadingContacts = false;
    
}


#pragma mark - askSendChoices


- (void)askSendChoicesfor:(id)sender{
    if([GPRequests connected]){
        NSString *sendChoicesUrl = @"";
        
        sendChoicesUrl = [NSString stringWithFormat:@"%@%@",adresseIp2,my_keoChoiceRequestName];
        
        APLLog(@"send choices session: %@", sendChoicesUrl);
        NSURLSession *session = [NSURLSession sharedSession];
        [[session dataTaskWithURL:[NSURL URLWithString:sendChoicesUrl]
                completionHandler:^(NSData *data,
                                    NSURLResponse *response,
                                    NSError *error) {
                    if(error != nil){
                        APLLog(@"New send choice Error: [%@]", [error description]);
                    }
                    else{
                        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                        NSInteger sessionErrorCode = [httpResponse statusCode];
                        [self sendChoicesDidReceiveResponse:data withErrorCode:sessionErrorCode from:sender];
                    }
                    
                }] resume];
    }
}

-(void)sendChoicesDidReceiveResponse:(NSData *)data withErrorCode:(NSInteger)sendChoiceErrorCode from:(id)sender{
    
    APLLog(@"send choice session did receive response with error code: %i",sendChoiceErrorCode);
    
    if(sendChoiceErrorCode != 200){
        if(sendChoiceErrorCode==500){
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"askSendChoices: Error"
                                      message:@"Server problem" delegate:sender
                                      cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
            });
            [GPRequests goBackToFirstServer];
        }
        if(sendChoiceErrorCode==404){
            [GPRequests goBackToFirstServer];
        }
        if(sendChoiceErrorCode==401){
            APLLog(@"askSendChoices login needed");
            
            NSInteger loginCheckAnswer =[GPRequests loginWithEmail:username withPassWord:hashPassword for:sender];
            if(loginCheckAnswer == 200){
                APLLog(@"restart askSendChoices request");
                [[[GPSession alloc] init] askSendChoicesfor:sender];
            }
        }
    }
    else{
        [self sendChoicesSucceeded:data];
    }
    
}

-(void)sendChoicesSucceeded:(NSData *)data{
    
    APLLog(@"Session succeeded! Received %d bytes of data Send choice",[data length]);

    NSError *myError = nil;
    id res2 = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&myError];
    
    NSArray *choiceArray = (NSArray *)res2;
    APLLog(@"Number of send choices: %d",[choiceArray count]);
    
    if([choiceArray count] > 0){  //upadate Keo choices
        
        importKeoChoices = [[NSMutableArray alloc] init];
        for(id choice in choiceArray){
            NSMutableDictionary *choiceDictionnary = [[NSMutableDictionary alloc] init];
            
            id theId = [choice objectForKey:my_sendChoice_order_id];
            id theKey = [choice objectForKey:my_sendChoice_key];
            id theLabel = [choice objectForKey:my_sendChoice_send_label];
            
            NSString *theIdAsString = (NSString *)theId;
            NSString *theKeyAsString = (NSString *)theKey;
            NSString *theLabelAsString = (NSString *)theLabel;
            
            if(theIdAsString){
                [choiceDictionnary setObject:theIdAsString forKey:my_sendChoice_order_id];
            }
            else{
                [choiceDictionnary setObject:@"" forKey:my_sendChoice_order_id];
            }
            if(theKeyAsString){
                [choiceDictionnary setObject:theKeyAsString forKey:my_sendChoice_key];
            }
            else{
                [choiceDictionnary setObject:@"" forKey:my_sendChoice_key];
            }
            if(theLabelAsString){
                [choiceDictionnary setObject:theLabelAsString forKey:my_sendChoice_send_label];
            }
            else{
                [choiceDictionnary setObject:@"" forKey:my_sendChoice_send_label];
            }
            
            [importKeoChoices insertObject:choiceDictionnary atIndex:[importKeoChoices count]];
        }
        
        APLLog(@"Save send choices: %@", [importKeoChoices description]);
        [prefs setObject:importKeoChoices forKey:@"importKeoChoices2"];
        
    }
    
    
}



#pragma mark - asynchronous login


-(void)asynchronousLoginWithEmailfor:(id)sender{
    
    if ([GPRequests connected]){
        
        // 1
        NSURL *loginUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",adresseIp2,my_loginRequestName]];
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
        
        // 2
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:loginUrl];
        request.HTTPMethod = @"POST";
        
        // 3
        
        
       NSString *postString = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@",@"email=",username,@"&password=",hashPassword,@"&reg_id=",myDeviceToken,@"&os=ios",@"&app_version=",myAppVersion,@"&facebook_id=",myFacebookID,@"&facebook_name=",myFacebookName,@"&facebook_birthday=",myFacebookBirthDay];

        APLLog([NSString stringWithFormat:@"asynchronous login session post: %@",postString]);
        NSData* data = [postString dataUsingEncoding:NSUTF8StringEncoding];
        
        NSError *error = nil;

        if (!error) {
            // 4
            APLLog(@"local session: %@", loginUrl);
            NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request
                                                                       fromData:data completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
                                                                           if(error != nil){
                                                                               APLLog(@"New login Error: [%@]", [error description]);
                                                                               
                                                                           }
                                                                           else{
                                                                               NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                                                               NSInteger sessionErrorCode = [httpResponse statusCode];
                                                                               [self loginDidReceiveResponse:data withErrorCode:sessionErrorCode from:sender];
                                                                           }
                                                                       }];
            
            // 5
            [uploadTask resume];
        }
    }
}

-(void)loginDidReceiveResponse:(NSData *)data withErrorCode:(NSInteger)loginErrorCode from:(id)sender{
    APLLog(@"login session did receive response with error code: %i",loginErrorCode);
    
    if(loginErrorCode != 200){
        if(loginErrorCode==500){
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"login: Error"
                                      message:@"Server problem" delegate:sender
                                      cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
            });
            [GPRequests goBackToFirstServer];
        }
        if(loginErrorCode==404){
            [GPRequests goBackToFirstServer];
        }
        if(loginErrorCode==401){
            logIn = false;
            [prefs setBool:logIn forKey:my_prefs_login_key];
        }
    }
    else{
        [self loginSucceeded:data from:sender];
    }
    
}

-(void)loginSucceeded:(NSData *)data from:(id)sender{
    APLLog(@"FIRST LOGIN OK");
    APLLog(@"Succeeded! Received %d bytes of data login",[data length]);
    NSError *myError = nil;
    
    id res3 = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&myError];
    APLLog(@"res3: %@", [res3 description]);
    if(res3){
        
        ////////////Cloudfront//////////
        id mymy_downloadPhotoRequestName = [res3 objectForKey:@"cloudfront"];
        NSString *mymy_downloadPhotoRequestNameAsString;
        if(![mymy_downloadPhotoRequestName isKindOfClass:[NSNull class]]){
            mymy_downloadPhotoRequestNameAsString = (NSString *)mymy_downloadPhotoRequestName;
            downloadPhotoRequestName = mymy_downloadPhotoRequestNameAsString;
            [prefs setObject:downloadPhotoRequestName forKey:my_downloadPhotoRequestName_key];
            APLLog(@"downloadPhotoRequestName saved: %@",[prefs objectForKey:my_downloadPhotoRequestName_key]);
        }
        APLLog(@"MYMYcloudfront_url: %@",downloadPhotoRequestName);
        
        ////////////Amazon//////////////
        
        id mymy_aws_account_id = [res3 objectForKey:my_aws_account_id_key];
        NSString *mymy_aws_account_idAsString;
        if(![mymy_aws_account_id isKindOfClass:[NSNull class]]){
            mymy_aws_account_idAsString = (NSString *)mymy_aws_account_id;
            aws_account_id = mymy_aws_account_idAsString;
            [prefs setObject:aws_account_id forKey:my_aws_account_id_key];
        }
        APLLog(@"MYMYaws_account_id: %@",aws_account_id);
        
        id mymycognito_pool_id = [res3 objectForKey:my_cognito_pool_id_key];
        NSString *mymycognito_pool_idAsString;
        if(![mymycognito_pool_id isKindOfClass:[NSNull class]]){
            mymycognito_pool_idAsString = (NSString *)mymycognito_pool_id;
            cognito_pool_id = mymycognito_pool_idAsString;
            [prefs setObject:cognito_pool_id forKey:my_cognito_pool_id_key];
        }
        APLLog(@"MYMYcognito_pool_id: %@",cognito_pool_id);
        
        id mymycognito_role_auth = [res3 objectForKey:my_cognito_role_auth_key];
        NSString *mymycognito_role_authAsString;
        if(![mymycognito_role_auth isKindOfClass:[NSNull class]]){
            mymycognito_role_authAsString = (NSString *)mymycognito_role_auth;
            cognito_role_auth = mymycognito_role_authAsString;
            [prefs setObject:cognito_role_auth forKey:my_cognito_role_auth_key];
        }
        APLLog(@"MYMYcognito_role_auth: %@",cognito_role_auth);
        
        id mymycognito_role_unauth = [res3 objectForKey:my_cognito_role_unauth_key];
        NSString *mymycognito_role_unauthAsString;
        if(![mymycognito_role_unauth isKindOfClass:[NSNull class]]){
            mymycognito_role_unauthAsString = (NSString *)mymycognito_role_unauth;
            cognito_role_unauth = mymycognito_role_unauthAsString;
            [prefs setObject:cognito_role_unauth forKey:my_cognito_role_unauth_key];
        }
        APLLog(@"MYMYcognito_role_unauth: %@",cognito_role_unauth);
        
        id mymyS3BucketName = [res3 objectForKey:my_login_bucket_name_key];
        NSString *mymyS3BucketNameAsString;
        if(![mymyS3BucketName isKindOfClass:[NSNull class]]){
            mymyS3BucketNameAsString = (NSString *)mymyS3BucketName;
            S3BucketName = mymyS3BucketNameAsString;
            [prefs setObject:S3BucketName forKey:my_prefs_S3BucketName_key];
        }
        APLLog(@"MYMYS3BucketName: %@",mymyS3BucketName);
        
        ////////////////////////////
        
        id mymyId = [res3 objectForKey:my_login_user_id_key];
        NSString *mymyIDAsString;
        if(![mymyId isKindOfClass:[NSNull class]]){
            mymyIDAsString = (NSString *)mymyId;
            myUserID = mymyIDAsString;
            [prefs setObject:myUserID forKey:@"myUserID"];
        }
        APLLog(@"MYMYID2: %@",mymyId);
        
        id mymyIpAdress = [res3 objectForKey:my_login_web_app_url_key];
        NSString *mymyIpAdressAsString;
        if(![mymyIpAdress isKindOfClass:[NSNull class]]){
            mymyIpAdressAsString = (NSString *)mymyIpAdress;
            if(!localWork){
                adresseIp2 = mymyIpAdressAsString;
                [prefs setObject:adresseIp2 forKey:@"ipAdress"];
                APLLog(@"MYMYIPADRESS2: %@",mymyIpAdressAsString);
            }
        }
        id mymyAppVersion = [res3 objectForKey:my_login_ios_version_needed_key];
        NSString *mymyAppVersionAsString;
        if(![mymyAppVersion isKindOfClass:[NSNull class]]){
            mymyAppVersionAsString = (NSString *)mymyAppVersion;
            APLLog(@"mymyAppVersion: %@",mymyAppVersionAsString);
        }
        id mymyVersionLink = [res3 objectForKey:my_login_ios_update_link_key];
        NSString *mymyVersionLinkAsString;
        if(![mymyVersionLink isKindOfClass:[NSNull class]]){
            mymyVersionLinkAsString = (NSString *)mymyVersionLink;
            APLLog(@"mymyVersionLink: %@",mymyVersionLinkAsString);
        }
        myVersionInstallUrl = mymyVersionLinkAsString;
        id mymyForceBoolean = [res3 objectForKey:my_login_force_update_key];
        NSString *mymyForceBooleanAsString;
        if(![mymyForceBoolean isKindOfClass:[NSNull class]]){
            mymyForceBooleanAsString = (NSString *)mymyForceBoolean;
            APLLog(@"mymyForceBoolean: %@",mymyForceBooleanAsString);
        }
        bool myLocalVersionForceInstall;
        if([mymyForceBooleanAsString isEqualToString:@"true"]){
            myLocalVersionForceInstall = true;
        }
        else{
            myLocalVersionForceInstall = false;
        }
        [prefs setObject:myVersionInstallUrl forKey:@"myVersionInstallUrl"];
        
        APLLog(@"Current appversion: %@",myAppVersion);
        
        double myAppVersionDouble = [myAppVersion doubleValue];
        double mymyAppVersionDouble = [mymyAppVersionAsString doubleValue];
        
        if(mymyAppVersionDouble > myAppVersionDouble){
            if(![mymyForceBooleanAsString isEqualToString:@"true"]){
                
                NSString *versionAlertTitle = [NSString stringWithFormat:@"Pictever version %@ is available!",mymyAppVersionAsString];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *versionAlert = [[UIAlertView alloc]
                                                 initWithTitle:versionAlertTitle
                                                 message:my_actionsheet_install_it_now delegate:sender
                                                 cancelButtonTitle:@"Cancel" otherButtonTitles:@"Install",nil];
                    [versionAlert show];
                });
                
            }
            else{
                APLLog(@"Force update");
            }
        }
        else{
            APLLog(@"Last version installed on this iPhone");
        }
        
        if(myLocalVersionForceInstall){
            myVersionForceInstall = true;
        }
        else{
            myVersionForceInstall = false;
        }
        [prefs setBool:myVersionForceInstall forKey:@"myVersionForceInstall"];
    }
    
    //-----------------Once the login is ok, we do all the other requests-----------------
    [NSThread detachNewThreadSelector:@selector(askSessionsInBackground) toTarget:self withObject:nil];
    
}


-(void)askSessionsInBackground{
    APLLog(@"askSessionsInBackground");
    if(myCurrentPhoneNumber){//this way, it is not done at the first opening
        if(![myCurrentPhoneNumber isEqualToString:@""]){
            [[[GPSession alloc] init] getStatusRequest:self];
            //[GPRequests askKeoChoicesfor:self];
            [[[GPSession alloc] init] askSendChoicesfor:self];
            bool contactsOk = [[ContactModel alloc] init];
            if(contactsOk){
                APLLog(@"Contacts loaded: %d", [messagesDataFile count]);
            }
            else{
                APLLog(@"=contatcs not loaded");
            }
            [myUploadContactSession uploadContacts:[myGeneralMethods createJsonArrayOfContacts] withTableViewReload:YES for:self];
        }
    }
}



#pragma mark - send reset mail


-(void)sendResetMailRequest:(NSString *)email for:(id)sender{
    if([GPRequests connected]){
        NSString *resetUrl = @"";
        
        resetUrl = [NSString stringWithFormat:@"%@%@%@%@",adresseIp2,my_sendResetMail,@"?email=",email];
        
        
        APLLog(@"resetMail session: %@", resetUrl);
        NSURLSession *session = [NSURLSession sharedSession];
        [[session dataTaskWithURL:[NSURL URLWithString:resetUrl]
                completionHandler:^(NSData *data,
                                    NSURLResponse *response,
                                    NSError *error) {
                    if(error != nil){
                        APLLog(@"New resetMail Error: [%@]", [error description]);
                    }
                    else{
                        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                        NSInteger sessionErrorCode = [httpResponse statusCode];
                        [self resetMailDidReceiveResponse:data withErrorCode:sessionErrorCode from:sender];
                    }
                    
                }] resume];
    }
}

-(void)resetMailDidReceiveResponse:(NSData *)data withErrorCode:(NSInteger)resetMailErrorCode from:(id)sender{
    
    APLLog(@"receive session did receive response with error code: %i",resetMailErrorCode);
    if(resetMailErrorCode != 200){
        if(resetMailErrorCode==500){
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"Error: reset"
                                      message:@"Server problem" delegate:sender
                                      cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
            });
            [GPRequests goBackToFirstServer];
        }
        if(resetMailErrorCode==404){
            [GPRequests goBackToFirstServer];
        }
    }
    else{
        [self resetMailSucceeded:data];
    }
}

-(void)resetMailSucceeded:(NSData *)data{
    
    APLLog(@"Session succeeded! Received %d bytes of data resetMail",[data length]);
    NSError *myError = nil;
    id serverAnswer = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&myError];
    APLLog(@"Server answer: %@",[serverAnswer description]);
    
}



# pragma mark - first use tips


-(void)increaseSendTipCounter:(id)sender{


    int sendTipCounter = [sendTips intValue];
    sendTipCounter += 1;
    if(sendTipCounter < 6){
        if (sendTipCounter == 1) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"Congrats, your message is sent!!"
                                      message:@"Little tip: you can send a message to anybody in your adress book ;)" delegate:sender
                                      cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
            });
        }
        else if (sendTipCounter == 3) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:my_actionsheet_wanna_help_us
                                      message:@"Please like us or leave a comment on the AppStore!" delegate:sender
                                      cancelButtonTitle:@"No, thanks" otherButtonTitles:@"Yes I like Pictever :)",nil];
                [alert show];
            });
        }
        else if (sendTipCounter == 5){
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:my_actionsheet_you_are_great
                                      message:@"Please join our community on facebook!" delegate:sender
                                      cancelButtonTitle:@"No, thanks" otherButtonTitles:@"Yes I want to join the community!",nil];
                [alert show];
            });
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert3 = [[UIAlertView alloc]
                                       initWithTitle:@"Message sent successfully"
                                       message:@"" delegate:sender
                                       cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert3 show];
                [alert3 dismissWithClickedButtonIndex:0 animated:YES];
            });
        }
    }
    sendTips = [NSString stringWithFormat:@"%d", sendTipCounter];
    [prefs setObject:sendTips forKey:my_prefs_send_tips_key];
}


-(void)increaseReceiveTipCounter:(id)sender{
    int receiveTipCounter = [receiveTips intValue];
    receiveTipCounter += 1;
    if(receiveTipCounter < 4){
        if (receiveTipCounter == 1 || receiveTipCounter == 4) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"You just received a message in your timeline!"
                                      message:@"Little tip: if you like a message you receive, press the orange button to resend it, so you can be surprised again!" delegate:sender
                                      cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
            });
        }
        
    }
    receiveTips = [NSString stringWithFormat:@"%d", receiveTipCounter];
    [prefs setObject:receiveTips forKey:my_prefs_receive_tips_key];
}



@end



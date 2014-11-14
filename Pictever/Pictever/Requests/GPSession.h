//
//  GPSession.h
//  Shyft
//
//  Created by Gauthier Petetin on 21/10/2014.
//  Copyright (c) 2014 Gauthier Petetin. All rights reserved.
//

@class myGeneralMethods;

@interface GPSession: NSObject

@property (strong, nonatomic) NSString *resendString;

@property (strong, nonatomic) NSMutableDictionary *sendDictionary;

@property (strong, nonatomic) NSString *sendTextOrPhoto;

@property (strong, nonatomic) NSMutableArray *contArray;

@property (strong, nonatomic) NSString *reloadTableView;

@property (nonatomic, assign) BOOL isUploadingContacts;


-(void)getStatusRequest:(id)sender;

-(void)receiveRequest:(id)sender;

-(void)sendRequest:(NSString *)messageToSend to:(NSString *)recipient withPhotoString:(NSString *)photoString withKeoTime:(NSString *)keo_time for:(id)sender;

-(void)resendRequest:(NSString*)resendShyftID for:(id)sender;

-(void)askNumberOfMessagesInTheFuture:(id)sender;

-(void)uploadContacts:(NSMutableArray *)contactBookArray withTableViewReload:(bool)rel for:(id)sender;

- (void)askSendChoicesfor:(id)sender;

-(void)asynchronousLoginWithEmailfor:(id)sender;

-(void)sendResetMailRequest:(NSString *)email for:(id)sender;

@end
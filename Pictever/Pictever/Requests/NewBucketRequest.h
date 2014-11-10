//
//  NewBucketRequest.h
//  Shyft
//
//  Created by Gauthier Petetin on 20/10/2014.
//  Copyright (c) 2014 Gauthier Petetin. All rights reserved.
//

//-------APPLAUSE
#import <Applause/APLLogger.h>


@class myConstants;
@class myGeneralMethods;

@interface NewBucketRequest: NSObject


@property (strong, nonatomic) NSMutableDictionary *messageDataDict ;

-(void)sessionNewBucket:(NSMutableDictionary *)newShyftReceived;

-(void)sessionNewBucketSucceededFor:(NSMutableDictionary *) newShyftReceived2 withData:(NSData *)data;

@end
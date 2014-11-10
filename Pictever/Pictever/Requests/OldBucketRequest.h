//
//  OldBucketRequest.h
//  Shyft
//
//  Created by Gauthier Petetin on 20/10/2014.
//  Copyright (c) 2014 Gauthier Petetin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class myConstants;
@class myGeneralMethods;


@interface OldBucketRequest : NSObject

@property (strong, nonatomic) NSMutableDictionary * oldMessageDataDict ;

-(void)loadPhotoOnOldBucket:(NSMutableDictionary *) newShyft2;


@end
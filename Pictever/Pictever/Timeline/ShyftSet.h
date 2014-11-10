//
//  ShyftSet.h
//  Shyft
//
//  Created by Gauthier Petetin on 18/10/2014.
//  Copyright (c) 2014 Gauthier Petetin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class ShyftMessage;
@class myConstants;

@interface ShyftSet : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSMutableArray *shyftsForTableView;
@property (nonatomic, assign) BOOL loaded;

- (instancetype)initWithName:(NSString *)name shyftsData:(NSMutableArray *)shyftsDataFile;

-(NSString *)getDescription;

- (NSMutableArray *)prepareShyftsForTableView:(NSMutableArray *)shyftsToPrepare;

- (void)insertNewShyft:(ShyftMessage *)newShyft;

-(NSUInteger) size;

-(ShyftMessage *)getShyftAtIndex:(NSUInteger)index;

-(void)deleteShyftAtIndex:(NSUInteger)index;

-(bool)containsShyft:(ShyftMessage *)shyftToCheck;

-(void)refreshAllProfilePics;

-(void)setLoaded;

-(bool)isLoaded;

@end
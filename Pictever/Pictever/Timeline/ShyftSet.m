//
//  ShyftSet.m
//  Shyft
//
//  Created by Gauthier Petetin on 18/10/2014.
//  Copyright (c) 2014 Gauthier Petetin. All rights reserved.
//

#import "ShyftSet.h"
#import "ShyftMessage.h"
#import "myConstants.h"

@implementation ShyftSet

- (instancetype)initWithName:(NSString *)name shyftsData:(NSMutableArray *)shyftsDataFile{
    if ((self = [super init])) {
        _name = name;
        _shyftsForTableView = [self prepareShyftsForTableView:shyftsDataFile];
        _loaded = false;
    }
    return self;
}


- (NSMutableArray *)prepareShyftsForTableView:(NSMutableArray *)shyftsToPrepare{
    NSMutableArray *shyfts = [[NSMutableArray alloc] init];
    //NSLog(@"prepareShyftsForTableView: %@", [shyftsToPrepare description]);
    int i = 0;
    if (shyftsToPrepare) {
        if([shyftsToPrepare count]>0){
            for(NSMutableDictionary* currentShyft in shyftsToPrepare){
                if([currentShyft objectForKey:my_loaded_Key]){
                    if([[currentShyft objectForKey:my_loaded_Key] isEqualToString:@"yes"]){
                        i++;
                        [shyfts addObject:[[ShyftMessage alloc] initWithShyft:currentShyft]];
                        if(i>9){
                            return shyfts;
                        }
                    }
                }
            }
        }
    }
    return shyfts;
}

- (void)insertNewShyft:(ShyftMessage *)newShyft{
    [_shyftsForTableView insertObject:newShyft atIndex:0];
}


-(NSString *)getDescription{
    //NSLog(@"getDescription: %@", [_shyftsForTableView description]);
    NSString* setDescription = @"";
    if(_shyftsForTableView){
        if([_shyftsForTableView count] > 0){
            for(ShyftMessage * shyftMessageToPrint in _shyftsForTableView){
                //NSLog(@"getDescriptionDetail: %@", [shyftMessageToPrint getDescription]);
                setDescription = [NSString stringWithFormat:@"%@, \n %@", setDescription, [shyftMessageToPrint getDescription]];
            }
        }
    }
    return setDescription;
}

-(NSUInteger)size{
    return [_shyftsForTableView count];
}

-(ShyftMessage *)getShyftAtIndex:(NSUInteger)index{
    if([_shyftsForTableView objectAtIndex:index]){
        return [_shyftsForTableView objectAtIndex:index];
    }
    return nil;
}

-(void)deleteShyftAtIndex:(NSUInteger)index{
    [_shyftsForTableView removeObjectAtIndex:index];
}

-(bool)containsShyft:(ShyftMessage *)shyftToCheck{
    if(![shyftToCheck.shyft_id isEqualToString:@""]){
        for(ShyftMessage *shyftt in _shyftsForTableView){
            if([shyftt.shyft_id isEqualToString:shyftToCheck.shyft_id]){
                return true;
            }
        }
    }
    return false;
}

-(void)refreshAllProfilePics{
    for(ShyftMessage *shyftToUpdate in _shyftsForTableView){
        [shyftToUpdate refreshProfilePic];
    }
}

-(void)setLoaded{
    _loaded = true;
}

-(bool)isLoaded{
    return _loaded;
}

@end
//
//  KeoMessages.h
//  Keo
//
//  Created by Gauthier Petetin on 11/06/2014.
//  Copyright (c) 2014 Gauthier Petetin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioServices.h>

//@class OldBucketRequest;
@class NewBucketRequest;

@class GPRequests;
@class GPSession;

@class myConstants;
@class myGeneralMethods;

/////APPLAUSE
#import <Applause/APLLogger.h>

@class ShyftSet;
@class ShyftMessage;
@class ShyftCell;
@class PandaCell;

@class PhotoDetail;


#import "myTabBarController.h"


@interface KeoMessages : UITableViewController <UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UILabel *backgroundLoadingLabel;
@property (strong, nonatomic) IBOutlet UILabel *loadingLabel;
@property (nonatomic, retain) UIActivityIndicatorView *spinnerTop;

@property (strong, nonatomic) IBOutlet UILabel * loadTbvLabel;
@property (nonatomic, retain) UIActivityIndicatorView *loadTbvSpinner;

- (IBAction)detailPressed:(id)sender;

- (IBAction)imagePressed:(id)sender;

-(void)loadUnloadImages;

- (IBAction)settingsPressed:(id)sender;
- (IBAction)cameraPressed:(id)sender;


-(void)reloadTheWholeTableViewFirstTime;

+(NSMutableArray *)copyMessagesDataFile2:(NSArray *)importedArray;//new

+(NSMutableDictionary *)copySingleMessage:(NSDictionary *)message;//new

+(NSMutableArray *)bubbleSort: (NSMutableArray *)myMessages;//new

+(void)switchElements: (NSMutableArray *)myArray index1: (int) firstint index2: (int) secondint;//new

+ (UIImage*) addImage:(UIImage*)smallImage atPoint:(CGPoint)originPoint onImage:(UIImage*)backgroundImg;

+ (UIImage*) fillImgOfSize:(CGSize)img_size withColor:(UIColor*)img_color;

+(UIImage*) drawText2:(NSString*) text inImage:(UIImage*)image inRect:(CGRect)rect withFont:(UIFont *)font withColor:(UIColor*)textColor;

+(UIImage*)prepareImageForExport:(ShyftMessage *)thePictToShare;

+ (UIImage*) addPicteverBrandOnImage:(UIImage *)imageForExport;

-(void)vibrateForNewShyft:(NSMutableDictionary *)newPhotoMessage;

-(void)startLoadingAnimation;

-(void)stopLoadingAnimation;

-(void)showFutureMessages:(NSString *)newNumber;

@end

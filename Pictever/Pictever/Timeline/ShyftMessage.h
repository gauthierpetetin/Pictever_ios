//
//  ShyftMessage.h
//  Shyft
//
//  Created by Gauthier Petetin on 18/10/2014.
//  Copyright (c) 2014 Gauthier Petetin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class myGeneralMethods;
@class myConstants;


@interface ShyftMessage : UITableViewCell

@property (strong, nonatomic) NSString *shyft_id;
@property (strong, nonatomic) NSString *from_email;
@property (strong, nonatomic) NSString *from_id;
@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) NSString *created_at;
@property (strong, nonatomic) NSString *received_at;
@property (strong, nonatomic) NSString *photo;
@property (strong, nonatomic) NSString *from_numero;
@property (strong, nonatomic) NSString *receive_label;
@property (strong, nonatomic) NSDate *receive_date;
@property (strong, nonatomic) NSString *receive_color;
@property (strong, nonatomic) NSString *loaded;
@property (strong, nonatomic) UIColor *color;
@property (strong, nonatomic) UIImage *uiControl;
@property (strong, nonatomic) UIImage *croppedImage;
@property (strong, nonatomic) UIImage *userProfileImage;
@property (strong, nonatomic) NSString *fullName;
@property (strong, nonatomic) NSString *from_facebook_id;
@property (strong, nonatomic) NSString *from_facebook_name;


- (instancetype)initWithShyft:(NSMutableDictionary *)shyftMessage;

-(NSString *)getDescription;

//----------------detect if the Shyft is a text message or a photo----------
- (bool)isTextMessage;

//---------------photo of the sender-----------------------------------
-(void)refreshProfilePic;

//---------------create image of one color------------------------------------------
+ (UIImage*) fillImgOfSize:(CGSize)img_size withColor:(UIColor*)img_color;

//------------------crop image------------------------------------------------------
+(UIImage *)cropIm:(UIImage *)imToCrop toRect:(CGRect)rect;

@end

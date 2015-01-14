//
//  ShyftMessage.m
//  Shyft
//
//  Created by Gauthier Petetin on 18/10/2014.
//  Copyright (c) 2014 Gauthier Petetin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ShyftMessage.h"

#import "myGeneralMethods.h"
#import "myConstants.h"



//size if the screen
CGFloat screenWidth;//global
CGFloat screenHeight;//global

NSString *myCurrentPhotoPath;//global

NSString *myLocaleString;

NSMutableDictionary *importKeoContacts;//global
NSMutableDictionary *importKeoPhotos;//global

@implementation ShyftMessage


- (instancetype)initWithShyft:(NSMutableDictionary *)myShyftMessage{
    if ((self = [super init])) {
        
        if([myShyftMessage objectForKey:my_shyft_id_Key]){
            _shyft_id = [myShyftMessage objectForKey:my_shyft_id_Key];
        }
        else{_shyft_id = @"";}
        _from_email = [myShyftMessage objectForKey:my_from_email_Key];
        _from_id = [myShyftMessage objectForKey:my_from_id_Key];
        _from_numero = [myShyftMessage objectForKey:my_from_numero_Key];
        _message = [myShyftMessage objectForKey:my_message_Key];
        _created_at = [myShyftMessage objectForKey:my_created_at_Key];
        _received_at = [myShyftMessage objectForKey:my_received_at_Key];
        if(_received_at){
            _receive_date = [NSDate dateWithTimeIntervalSince1970:[_received_at doubleValue]];
        }
        else{
            _receive_date = nil;
        }
        _photo = [myShyftMessage objectForKey:my_photo_Key];
        //_receive_label = [NSString stringWithFormat:@" %@ ",[myShyftMessage objectForKey:my_receive_label_Key]];
        _receive_label = [myShyftMessage objectForKey:my_receive_label_Key];
        _receive_color = [myShyftMessage objectForKey:my_receive_color_Key];
        _from_facebook_id = [myShyftMessage objectForKey:my_from_facebook_id_key];
        _from_facebook_name = [myShyftMessage objectForKey:my_from_facebook_name_key];
        _loaded = [myShyftMessage objectForKey:my_loaded_Key];
        _color = [self getShyftUIColor];
        
        if(![self isTextMessage]){//----------case of photo message-------
            if([_photo isEqualToString:image_not_downloaded_string]){
                _uiControl = [myGeneralMethods scaleImageForTimeline:[UIImage imageNamed:default_image_name]];
            }
            else{
                _uiControl = [self imageWithPhotoID:_photo];
            }
        }
        else{//--------------------case of text message------------------
            //UIColor *aWhiteColor = [myGeneralMethods getColorFromHexString:whiteColorString];//used before for the background color of images
            UIImage *receivedImage = [ShyftMessage fillImgOfSize:CGSizeMake(screenWidth, screenHeight) withColor:_color];
            if(receivedImage){
                _uiControl = receivedImage;
            }
        }
        
        if(_uiControl.size.height>default_cropped_image_heigth){//-----------in case image is higher than 300, crop it
            _croppedImage = [ShyftMessage cropIm:_uiControl toRect:CGRectMake(timeline_marge_width, 0.5*(_uiControl.size.height-default_cropped_image_heigth), screenWidth-2*timeline_marge_width, default_cropped_image_heigth)];
        }
        else{
            _croppedImage = _uiControl;
        }
        
        
        //---------------photo of the sender-----------------------------------
        [self refreshProfilePic];
        
        //---------------name of the sender if he is in my contacts (email and phone number if he isn't in my contacts)--------------
        NSDictionary *myContact = [importKeoContacts objectForKey:_from_numero];
        NSString *fullNameLoc = @"";
        _fullName = @"";
        if([myContact objectForKey:my_first_name_Key]||[myContact objectForKey:my_last_name_Key]){
            fullNameLoc = [NSString stringWithFormat:@"%@ %@",[myContact objectForKey:my_first_name_Key],[myContact objectForKey:my_last_name_Key]];
        }
        if(![[fullNameLoc stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]){
            _fullName = fullNameLoc;
        }
        else if (![_from_facebook_name isEqualToString:@""]){
            _fullName = _from_facebook_name;
        }
        
        //------------traduction-------
        if([myLocaleString isEqualToString:@"FR"]){
            if([[_fullName stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@"Myself"]){
                _fullName = @"Moi";
            }
        }
        
    }
    return self;
}

-(void)refreshProfilePic{
    //---------------photo of the sender-----------------------------------
    if([importKeoPhotos objectForKey:_from_numero]){
        _userProfileImage = [importKeoPhotos objectForKey:_from_numero];
    }
    else{
        _userProfileImage = [ShyftMessage scaleImage4:[UIImage imageNamed:@"unknown_small"] toWidth:30];
    }
}


-(NSString *)getDescription{
    NSString *description = [NSString stringWithFormat:@" _shyft_id: %@ \n _from_email: %@ \n _from_id: %@ \n_from_numero:%@ \n _message: %@ \n _created_at: %@ \n _received_at: %@ \n _photo: %@ \n _receive_label: %@ \n _receive_color: %@ \n _loaded: %@ \n _fullName: %@ \n _facebook_id: %@ \n _facebook_name: %@", _shyft_id,_from_email, _from_id, _from_numero, _message, _created_at, _received_at, _photo, _receive_label, _receive_color, _loaded, _fullName, _from_facebook_id, _from_facebook_name];
    return description;
}


//----------------detect if the Shyft is a text message or a photo----------
- (bool)isTextMessage{
    if((![_photo isEqualToString:no_photo_string])&&(![_photo isEqualToString:@""])){
        return false;
    }
    else{
        return true;
    }
}


//--------------search the image with photoID------------------------------
-(UIImage *)imageWithPhotoID:(NSString *)thePhotoID{
    NSString *theLocalImagePath;
    theLocalImagePath = [NSString stringWithFormat:@"%@/%@",myCurrentPhotoPath,thePhotoID];
    UIImage *receivedImageIfExists = [myGeneralMethods loadImageAtPath:theLocalImagePath];//can be nil
    
    UIImage *receivedImage;
    if(receivedImageIfExists != nil){
        NSLog(@"imageWithPhotoID exists: %@",theLocalImagePath);
        receivedImage = [myGeneralMethods scaleImage:receivedImageIfExists];
    }
    else{
        NSLog(@"imageWithPhotoID doesn't exist: %@",theLocalImagePath);
        receivedImage = [myGeneralMethods scaleImage:[UIImage imageNamed:default_image_name]];
    }
    return receivedImage;
}


//-------------transform NSString "receive_color" into UIColor--------------
- (UIColor *)getShyftUIColor{
    UIColor *defaultColor = [myGeneralMethods getColorFromHexString:default_color_code];
    UIColor *colorForBackground = defaultColor;
    if(_receive_color){
        if(![_receive_color isEqualToString:@""]){
            colorForBackground = [myGeneralMethods getColorFromHexString:_receive_color];
        }
    }
    
    if(colorForBackground){
        return colorForBackground;
    }
    else{
        return defaultColor;
    }
}



//---------------create image of one color--------------------------

+ (UIImage*) fillImgOfSize:(CGSize)img_size withColor:(UIColor*)img_color{
    
    /* begin the graphic context */
    UIGraphicsBeginImageContext(img_size);
    
    /* set the color */
    [img_color set];
    
    /* fill the rect */
    UIRectFill(CGRectMake(0, 0, img_size.width, img_size.height));
    
    /* get the image, end the context */
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    /* return the value */
    return scaledImage;
}

//------------------crop image------------------------------
+(UIImage *)cropIm:(UIImage *)imToCrop toRect:(CGRect)rect{
    if (imToCrop.scale > 1.0f) {
        rect = CGRectMake(rect.origin.x * imToCrop.scale,
                          rect.origin.y * imToCrop.scale,
                          rect.size.width * imToCrop.scale,
                          rect.size.height * imToCrop.scale);
    }
    CGImageRef imageRef = CGImageCreateWithImageInRect(imToCrop.CGImage, rect);
    UIImage *result = [UIImage imageWithCGImage:imageRef scale:imToCrop.scale orientation:imToCrop.imageOrientation];
    CGImageRelease(imageRef);
    if(result){
        return result;
    }
    else{
        return nil;
    }
}


//--------------scale image by fixing a width--------------

+ (UIImage*) scaleImage4:(UIImage*)image toWidth:(CGFloat)myWidth{
    CGSize scaledSize = CGSizeMake(image.size.width, image.size.height);
    //CGFloat scaleFactor = scaledSize.height / scaledSize.width;
    
    scaledSize.width = myWidth ;
    scaledSize.height = myWidth;
    
    UIGraphicsBeginImageContextWithOptions( scaledSize, NO, 0.0 );
    CGRect scaledImageRect = CGRectMake( 0.0, 0.0, scaledSize.width, scaledSize.height );
    [image drawInRect:scaledImageRect];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}


@end
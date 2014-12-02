//
//  myGeneralMethods.m
//  Pictever
//
//  Created by Gauthier Petetin on 06/11/2014.
//  Copyright (c) 2014 Pictever. All rights reserved.
//

//------APPLAUSE
#import <Applause/APLLogger.h>

#import "myGeneralMethods.h"
#import "myConstants.h"

//-----------function to convert hexacode to UIcolor----------------
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


//------------loadbox containing messages for which the photos are not downloaded-------------
NSMutableArray *loadBox;//global
NSMutableArray *messagesDataFile;//global
NSString *myCurrentPhotoPath;//global
NSMutableArray *sendBox;//global

NSMutableDictionary *importKeoContacts;//global
NSMutableArray *importContactsData;//global

NSUserDefaults *prefs;

//size if the screen
CGFloat screenWidth;//global
CGFloat screenHeight;//global

bool downloadPhotoOnAmazon;//global

NSString *mytimeStamp;//global


@implementation myGeneralMethods



//--------------------get color from hexacode--------------------------------------

+ (UIColor *)getColorFromHexString:(NSString *)hexString{
    NSMutableString *tempHex=[[NSMutableString alloc] init];
    
    [tempHex appendString:hexString];
    
    unsigned colorInt = 0;
    
    [[NSScanner scannerWithString:tempHex] scanHexInt:&colorInt];
    return UIColorFromRGB(colorInt);
}

//----------------------get size of a text-----------------------------------------

+(CGSize)text:(NSString*)text sizeWithFont:(UIFont*)font constrainedToSize:(CGSize)size{
    
    /// Make a copy of the default paragraph style
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    /// Set line break mode
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    /// Set text alignment
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributesDictionary  = @{ NSFontAttributeName: font,
                                             NSParagraphStyleAttributeName: paragraphStyle };
    
    CGRect frame = [text boundingRectWithSize:size
                                      options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                   attributes:attributesDictionary
                                      context:nil];
    return frame.size;
}


//------------get full path of the place where the photo named "pathID" is saved---------------------
+(NSString *)getPathwithID:(NSString *)pathID{
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* pathMK = [documentsDirectory stringByAppendingPathComponent:@"/Keo"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:pathMK]){
        [[NSFileManager defaultManager] createDirectoryAtPath:pathMK withIntermediateDirectories:NO attributes:nil error:&error];
    }
    pathMK = [pathMK stringByAppendingPathComponent:pathID];
    if(pathMK){
        return pathMK;
    }
    else{
        return @"pathError";
    }
}

//-----------------delete an image in the memory of the phone-------------
+(void)deletePhotoAtPath:(NSString*)myPath{
    NSError *err;
    NSFileManager* fm = [[NSFileManager alloc] init];
    
    BOOL res;
    res = [fm removeItemAtPath:myPath error:&err];
    if (!res && err) {
        APLLog(@"oops: %@", err);
    }
}

//---------------load an image in the memory of the phone-----------
+ (UIImage*)loadImageAtPath:(NSString *)myNewPath{
    APLLog(@"loadImageAtPath");
    UIImage* image = [UIImage imageWithContentsOfFile:myNewPath];
    if(image){
        APLLog(@"loadImage-end-found");
        return image;
    }
    else{
        APLLog(@"loadImage-end-not-found");
        return nil;
    }
}



//--------returns the index of the message in the loadbox---------
+(NSUInteger)indexOfPhotoID:(NSString *) localPhotoID{
    APLLog(@"search index in loadbox..");
    for(NSMutableDictionary * mms in loadBox){
        NSString *photoPublicId3 = [mms objectForKey:my_shyft_id_Key];
        if([localPhotoID isEqualToString:photoPublicId3]){
            APLLog(@"PublicID FOUND: %@",photoPublicId3);
            return [loadBox indexOfObject:mms];
        }
    }
    APLLog(@"URL NOT FOUND");
    return -1;
}

+(void)skipCurrentLoadBoxMessage:(NSUInteger)indexOfPhotoReceived{
    if([loadBox count]){
        NSMutableDictionary *copyMessage = loadBox[indexOfPhotoReceived];
        [loadBox removeObjectAtIndex:indexOfPhotoReceived];
        [loadBox insertObject:copyMessage atIndex:[loadBox count]];
        APLLog(@"new loadBox: %@", [loadBox description]);
    }
}



+(NSInteger)indexOfMessageInSendBox:(NSMutableDictionary *)messageSent{
    NSString *lcccMessage = @"";
    NSString *lcccReceiverIds = @"";
    
    if([messageSent objectForKey:my_photo_send_request_field]){
        lcccMessage = [messageSent objectForKey:my_photo_send_request_field];
    }
    if([messageSent objectForKey:my_receiver_ids_send_request_field]){
        lcccReceiverIds = [messageSent objectForKey:my_receiver_ids_send_request_field];
    }

    for(NSMutableDictionary *sendBoxMessage in sendBox){
        if([sendBoxMessage objectForKey:my_sendbox_key]){
            if([[sendBoxMessage objectForKey:my_sendbox_key] isEqualToString:lcccMessage]){
                if([sendBoxMessage objectForKey:my_sendbox_recipient]){
                    if([[sendBoxMessage objectForKey:my_sendbox_recipient] isEqualToString:lcccReceiverIds]){
                        return [sendBox indexOfObject:sendBoxMessage];
                    }
                }
            }
        }
    }
    return -1;
}



//----------------if the download failed, we place the message at the back of the loadbox------------------
+(NSMutableDictionary *)receiveAmazonDownLoadedPhotoFromSession:(NSMutableDictionary *)shyftFromSession{
    
    NSString *amzPhotoID = @"";
    if([shyftFromSession objectForKey:my_message_Key]){
        amzPhotoID = [shyftFromSession objectForKey:my_message_Key];
    }
    NSString *messageID = @"";
    if([shyftFromSession objectForKey:my_shyft_id_Key]){
        messageID = [shyftFromSession objectForKey:my_shyft_id_Key];
    }
    
    NSString *dwnAmazonPhotoPath = [myGeneralMethods getPathwithID:amzPhotoID];
    NSUInteger indexOfPhotoReceived = [myGeneralMethods indexOfPhotoID:messageID];
    
    if(![dwnAmazonPhotoPath isEqualToString:@"pathError"]){//-----------if photoPath exist------
        
        UIImage *imageInKeo;
        UIImage *imageInKeoIfExists = [myGeneralMethods loadImageAtPath:[NSString stringWithFormat:@"%@/%@",myCurrentPhotoPath,amzPhotoID]];
        if(imageInKeoIfExists != nil){
            imageInKeo = imageInKeoIfExists;
        }
        else{
            imageInKeo = [UIImage imageNamed:default_image_name];
        }
        
        if(amzPhotoID && (imageInKeoIfExists != nil)){
            [shyftFromSession setObject:amzPhotoID forKey:my_photo_Key];
            [shyftFromSession setObject:@"" forKey:my_message_Key];
        }
        else{
            [shyftFromSession setObject:image_not_downloaded_string forKey:my_photo_Key];
            if(amzPhotoID){
                [shyftFromSession setObject:amzPhotoID forKey:my_message_Key];
            }
            else{
                [shyftFromSession setObject:@"" forKey:my_message_Key];
            }
        }
        APLLog(@"replace downloaded photo");
        
        /*if([[shyftFromSession objectForKey:my_loaded_Key] isEqualToString:@"yes"]){
            if(indexOfPhotoReceived != -1){
                [myGeneralMethods replaceMessage:shyftFromSession andDeleteLoadBoxAtIndex:indexOfPhotoReceived];//TO DEBUG
            }
        }
        else{
            [shyftFromSession setObject:@"yes" forKey:my_loaded_Key];
            [myGeneralMethods replaceMessage:shyftFromSession];
            return shyftFromSession;
        }*/
        
        
        [shyftFromSession setObject:@"yes" forKey:my_loaded_Key];

        [myGeneralMethods replaceMessage:shyftFromSession andDeleteLoadBoxAtIndex:indexOfPhotoReceived];
        
        return shyftFromSession;
    }
    else{//--------------------if photoPath is false------------------------------
        if([[shyftFromSession objectForKey:my_loaded_Key] isEqualToString:@"yes"]){
            if(indexOfPhotoReceived != -1){
                [loadBox removeObjectAtIndex:indexOfPhotoReceived];
                //[myGeneralMethods skipCurrentLoadBoxMessage:indexOfPhotoReceived];
            }
        }
    }
    return nil;
}



//-------------once the photo is downloaded, we delete the message from the loadbox and replace it in messagesDataFile---------------------

+(void)replaceMessage:(NSMutableDictionary *)replacingMessage andDeleteLoadBoxAtIndex:(NSUInteger)deleteIndex{
    [myGeneralMethods replaceMessage:replacingMessage];
    if(deleteIndex != -1){
        [loadBox removeObjectAtIndex:deleteIndex];
        APLLog(@"remove object from loadBox: %@", [loadBox description]);
    }

}


+(void)replaceMessage:(NSMutableDictionary *)replacingMessage{
    NSMutableArray *changeIndexes = [[NSMutableArray alloc] init];
    for(NSMutableDictionary *loadDic in messagesDataFile){
        if([loadDic objectForKey:my_received_at_Key]){
            if([[loadDic objectForKey:my_received_at_Key] isEqualToString:[replacingMessage objectForKey:my_received_at_Key]]){
                if([loadDic objectForKey:my_shyft_id_Key]){
                    if([[loadDic objectForKey:my_shyft_id_Key] isEqualToString:[replacingMessage objectForKey:my_shyft_id_Key]]){
                        [changeIndexes addObject:[NSString stringWithFormat:@"%lu",(unsigned long)[messagesDataFile indexOfObject:loadDic]]];
                    }
                }
            }
        }
    }
    APLLog(@"changeIndex description: %@", [changeIndexes description]);
    if([changeIndexes count] > 0){
        for(NSString *indexAsString in changeIndexes){
            [messagesDataFile replaceObjectAtIndex:[indexAsString intValue] withObject:replacingMessage];
        }
    }
    else{
        APLLog(@"no messages to replace");
    }
    if(messagesDataFile){
        [myGeneralMethods saveMessagesData];
    }
}


//-------------------Save image in the memory of the phone-------------------(called from KeoMessages.m)--------------------

+ (NSString *)saveImageReceived: (UIImage*)imageInKeo atKey:(NSString *)myKey{
    APLLog(@"saveImage");
    if (imageInKeo != nil)
    {
        UIImageWriteToSavedPhotosAlbum(imageInKeo, nil, nil, nil);
        NSError *error;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString* pathMK = [documentsDirectory stringByAppendingPathComponent:@"/Keo"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:pathMK]){
            [[NSFileManager defaultManager] createDirectoryAtPath:pathMK withIntermediateDirectories:NO attributes:nil error:&error];
        }
        pathMK = [pathMK stringByAppendingPathComponent:myKey];
        NSData* data = UIImagePNGRepresentation(imageInKeo);
        APLLog([NSString stringWithFormat:@"Save photo: %@ at path: %@", myKey, pathMK]);
        [data writeToFile:pathMK atomically:YES];
        APLLog(@"PATH3: %@",pathMK);
        return pathMK;
    }
    return @"";
}


//---------------save messagesDataFiles-------------------------
+(void)saveImportContatcsData{
    if(importContactsData){
        APLLog(@"Save contacts data with length: %d",[importContactsData count]);
        //NSLog(@"aaaaaaaaaaaa: %@", [importContactsData description]);
        NSMutableArray *importContactsDataSavingCopy = [myGeneralMethods cleanImportContatcs:[importContactsData mutableCopy]];
        //NSLog(@"bbbbbbbbbb: %@", [importContactsData description]);
        [prefs setObject:importContactsDataSavingCopy forKey:my_prefs_contacts_data_key];
        
        //NSLog(@"iiiiiiiiiiii: %@", [importContactsData description]);
    }
}

+(NSMutableArray *)cleanImportContatcs:(NSMutableArray *)myAdressBook{//-----problems occur when saving without this
    NSLog(@"cleanImportContatcs");
    NSMutableArray *answerArrayContact = [[NSMutableArray alloc] init];
    for(NSMutableDictionary *locDic in myAdressBook){
        //NSLog(@"ccccc: %@", [locDic description]);
        [answerArrayContact insertObject:[locDic mutableCopy] atIndex:[answerArrayContact count]];
    }
    
    for(NSMutableDictionary *locDic in answerArrayContact){
        //NSLog(@"ddddd: %@", [locDic description]);
        if([locDic objectForKey:@"image"]){
            [locDic removeObjectForKey:@"image"];
        }
    }
    return answerArrayContact;
}


//---------------save messagesDataFiles-------------------------
+(void)saveMessagesData{
    if(messagesDataFile){
        [myGeneralMethods cleanMessageDataFile];
        APLLog(@"Save DataFile with length: %d",[messagesDataFile count]);
        [prefs setObject:messagesDataFile forKey:@"messagesDataFile"];
    }
}

+(void)cleanMessageDataFile{//-----problems occur when saving without this
    for(NSMutableDictionary *locDic in messagesDataFile){
        [locDic removeObjectForKey:@"UIControl"];
        [locDic removeObjectForKey:@"color"];
    }
}


//----------------prepares the string to send in the field "keo_choice" of the message to send ----------------------------
+(NSString *)stringForKeoChoicePh:(NSString *)choice withParameter:(NSString *)parameter{
    float timezoneoffset = ([[NSTimeZone systemTimeZone] secondsFromGMT] / 3600.0);
    NSString *timeZoneOffsetAsString = [NSString stringWithFormat:@"%.0f",timezoneoffset];
    
    
    NSMutableDictionary *choiceDic = [[NSMutableDictionary alloc] init];
    [choiceDic setObject:choice forKey:@"type"];
    [choiceDic setObject:timeZoneOffsetAsString forKey:@"timezone"];
    
    if([choice isEqualToString:@"calendar"]){
        [choiceDic setObject:parameter forKey:@"parameters"];
    }
    else{
        [choiceDic setObject:@"" forKey:@"parameters"];
    }
    
    NSError *errorKeoChoice = nil;
    NSData* jsonData2 = [NSJSONSerialization dataWithJSONObject:choiceDic options:NSJSONWritingPrettyPrinted error:&errorKeoChoice];
    
    NSString *jsonAsString = [[NSString alloc] initWithData:jsonData2 encoding:NSUTF8StringEncoding];
    
    return jsonAsString;
}



//---------------scale image for tableview (such that it has the same width as the screen of the device)------------------
+ (UIImage*) scaleImage:(UIImage*)image{
    
    CGSize scaledSize = CGSizeMake(image.size.width, image.size.height);
    CGFloat scaleFactor = scaledSize.height / scaledSize.width;
    
    scaledSize.width = screenWidth;
    scaledSize.height = screenWidth * scaleFactor;
    
    UIGraphicsBeginImageContextWithOptions( scaledSize, NO, 0.0 );
    CGRect scaledImageRect = CGRectMake( 0.0, 0.0, scaledSize.width, scaledSize.height );
    [image drawInRect:scaledImageRect];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return scaledImage;
}


//--------------scale image by multiplying its dimensions with a certain factor--------------

+ (UIImage*) scaleImage3:(UIImage*)image withFactor:(CGFloat)myFactor{
    CGSize scaledSize = CGSizeMake(image.size.width, image.size.height);
    
    scaledSize.width = scaledSize.width / myFactor ;
    scaledSize.height = scaledSize.height / myFactor;
    
    UIGraphicsBeginImageContextWithOptions( scaledSize, NO, 0.0 );
    CGRect scaledImageRect = CGRectMake( 0.0, 0.0, scaledSize.width, scaledSize.height );
    [image drawInRect:scaledImageRect];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}


//-----------convert an array into a string------------------------------------
+(NSString *)stringFromArrayPh:(NSMutableArray *)array{
    
    NSError *errorC = nil;
    NSData* jsonData10 = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:&errorC];
    NSMutableString * contactArrString = [[NSMutableString alloc] initWithData:jsonData10 encoding:NSUTF8StringEncoding];
    if(!contactArrString){
        contactArrString = [[NSMutableString alloc] initWithString:@""];
    }
    return contactArrString;
}


//-----------We create the array of phone numbers to send to the server------------------------
+(NSMutableArray *)createJsonArrayOfContacts{
    APLLog(@"createJsonOfContacts");
    
    NSMutableArray *jsonContactArray = [[NSMutableArray alloc] init];
    
    for(NSDictionary *contact in importContactsData){
        
        if([contact objectForKey:@"phoneNumber1"]){
            if(![[contact objectForKey:@"phoneNumber1"] isEqualToString:@""]){
                [jsonContactArray addObject:[contact objectForKey:@"phoneNumber1"]];
            }
        }
        if([contact objectForKey:@"phoneNumber2"]){
            if(![[contact objectForKey:@"phoneNumber2"] isEqualToString:@""]){
                [jsonContactArray addObject:[contact objectForKey:@"phoneNumber2"]];
            }
        }
    }
    
    APLLog(@"createJsonOfContacts-end");
    
    return jsonContactArray;
}


//-------------------deal with the new message received and add them to messagesDataFile (and inform the user)--------------

+(void)receiveAllMessagesTogether:(NSArray *)res withTimeStamp:(NSString *)timeStampToSave{
    
    APLLog([NSString stringWithFormat:@"You received %lu new messages!",(unsigned long)[res count]]);
    
    //bool thereIsPhotoShyft = false;
    
    ////WE RECEIVE ALL THE NEW SMS
    for(id sms in res) {
        
        NSMutableDictionary *newMessage = [[NSMutableDictionary alloc] init];
        
        id shyft_id = [sms objectForKey:my_shyft_id_Key];
        id from = [sms objectForKey:my_from_email_Key];
        id identification = [sms objectForKey:my_from_id_Key];
        id message = [sms objectForKey:my_message_Key];
        id expDate = [sms objectForKey:my_created_at_Key];
        id photoString = [sms objectForKey:@"photo_id"];
        id number = [sms objectForKey:my_from_numero_Key];
        id receivedLabel = [sms objectForKey:my_receive_label_Key];
        id receiveColor = [sms objectForKey:my_receive_color_Key];
        id received_at = [sms objectForKey:my_received_at_Key];
        id facebook_id = [sms objectForKey:my_from_facebook_id_key];
        id facebook_name = [sms objectForKey:my_from_facebook_name_key];
        
        NSString *shyft_idAsString;
        NSString *fromAsString;
        NSString *idAsString;
        NSString *messageAsString;
        NSString *expDateAsString;
        NSString *photoStringAsString = (NSString *)photoString;
        NSString *numberAsString;
        NSString *receivedLabelAsString;
        NSString *receiveColorAsString;
        NSString *received_atAsString;
        NSString *facebook_idAsString;
        NSString *facebook_nameAsString;
        
        if(![shyft_id isKindOfClass:[NSNull class]]){
            shyft_idAsString = (NSString *)shyft_id;
            [newMessage setObject:shyft_idAsString forKey:my_shyft_id_Key];}
        else{
            [newMessage setObject:@"" forKey:my_from_email_Key];}
        if(![from isKindOfClass:[NSNull class]]){
            fromAsString = (NSString *)from;
            fromAsString =[fromAsString stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
            [newMessage setObject:fromAsString forKey:my_from_email_Key];}
        else{
            [newMessage setObject:@"" forKey:my_from_email_Key];}
        if(![identification isKindOfClass:[NSNull class]]){
            idAsString = (NSString *)identification;
            [newMessage setObject:idAsString forKey:my_from_id_Key];}
        else{
            [newMessage setObject:@"" forKey:my_from_id_Key];}
        if(![message isKindOfClass:[NSNull class]]){
            messageAsString = (NSString *)message;
            [newMessage setObject:messageAsString forKey:my_message_Key];}
        else{
            [newMessage setObject:@"" forKey:my_message_Key];}
        if(![expDate isKindOfClass:[NSNull class]]){
            expDateAsString = (NSString *)expDate;
            [newMessage setObject:expDateAsString forKey:my_created_at_Key];}
        else{
            [newMessage setObject:@"" forKey:my_created_at_Key];}
        if(![received_at isKindOfClass:[NSNull class]]){
            received_atAsString = (NSString *)received_at;
            [newMessage setObject:received_atAsString forKey:my_received_at_Key];}
        else{
            [newMessage setObject:@"" forKey:my_received_at_Key];}
        if(![number isKindOfClass:[NSNull class]]){
            numberAsString = (NSString *)number;
            [newMessage setObject:numberAsString forKey:my_from_numero_Key];}
        else{
            [newMessage setObject:@"" forKey:my_from_numero_Key];}
        if(![receivedLabel isKindOfClass:[NSNull class]]){
            receivedLabelAsString = (NSString *)receivedLabel;
            [newMessage setObject:receivedLabelAsString forKey:my_receive_label_Key];}
        else{
            [newMessage setObject:@"" forKey:my_receive_label_Key];}
        if(![receiveColor isKindOfClass:[NSNull class]]){
            receiveColorAsString = (NSString *)receiveColor;
            [newMessage setObject:receiveColorAsString forKey:my_receive_color_Key];}
        else{
            [newMessage setObject:@"" forKey:my_receive_color_Key];}
        
        if(![facebook_id isKindOfClass:[NSNull class]]){
            facebook_idAsString = (NSString *)facebook_id;
            [newMessage setObject:facebook_idAsString forKey:my_from_facebook_id_key];}
        else{
            [newMessage setObject:@"" forKey:my_from_facebook_id_key];}
        
        if(![facebook_name isKindOfClass:[NSNull class]]){
            facebook_nameAsString = (NSString *)facebook_name;
            [newMessage setObject:facebook_nameAsString forKey:my_from_facebook_name_key];}
        else{
            [newMessage setObject:@"" forKey:my_from_facebook_name_key];}
        
        if([photoStringAsString isEqualToString:@""]){//------------text message-----
            [newMessage setObject:photoStringAsString forKey:my_photo_Key];
            [newMessage setObject:@"yes" forKey:my_loaded_Key];
        }
        else{//-------------photo message---------
            [newMessage setObject:image_not_downloaded_string forKey:my_photo_Key];
            if(photoStringAsString){
                [newMessage setObject:photoStringAsString forKey:my_message_Key];
            }
            else{
                [newMessage setObject:@"" forKey:my_message_Key];
            }
            [newMessage setObject:@"no" forKey:my_loaded_Key];
        }
        
        APLLog(@"newmessage: %@",messageAsString);
        //APLLog(messageAsString);
        APLLog(photoStringAsString);
        //APLLog(fromAsString);
        //APLLog(idAsString);
        //APLLog(numberAsString);
        //APLLog(dateRecueAsString);
        
        APLLog(@"insert: %@ in messagesdatafile",[newMessage description]);
        [messagesDataFile insertObject:[newMessage mutableCopy] atIndex:0];
        
        
        if(messagesDataFile){
            [myGeneralMethods saveMessagesData];
        }
        
        //------------get the name of the contact associated to this phonenumber--------------
        [myGeneralMethods checkAccountName:numberAsString];
        
        
        [prefs setObject:importKeoContacts forKey:@"importKeoContacts"];
        
        
        
        if(![[photoStringAsString stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]){//-----------photo message
            APLLog(@"-----new photo message");
            dispatch_async(dispatch_get_main_queue(), ^{
                APLLog(@"send notif startLoadingAnimation");
                [[NSNotificationCenter defaultCenter] postNotificationName:@"startLoadingAnimation" object: nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"downloadPhotoOnNewBucket" object:self userInfo:[newMessage mutableCopy]];
            });
        }
        else{
            APLLog(@"-----new text message");
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"vibrateForNewShyft" object:self userInfo:[newMessage mutableCopy]];
            });
        }
        
        
        
    }
    
    if(timeStampToSave){
        APLLog(@"save timeStamp: %@", timeStampToSave);
        mytimeStamp = timeStampToSave;
        [prefs setObject:timeStampToSave forKey:my_prefs_timestamp_key];
        
    }
    else{
        APLLog(@"wrong timeStamp");
    }
    
}


//------------get the name of the contact associated to this phonenumber--------------

+(void)checkAccountName:(NSString *)phNumber1{
    if(phNumber1){
        NSMutableArray *copyImportContactsData = [importContactsData mutableCopy];
        
        NSString *indexString = @"No";
        for(int i = 0; i < [copyImportContactsData count]; i++){
            
            NSMutableDictionary *searchContact = [copyImportContactsData objectAtIndex:i];
            
            if([[searchContact objectForKey:@"phoneNumber1"] isEqualToString:phNumber1]){
                APLLog(@"We found the number: %@", phNumber1);
                indexString = [NSString stringWithFormat:@"%d",i];
            }
            if([[searchContact objectForKey:@"phoneNumber2"] isEqualToString:phNumber1]){
                APLLog(@"We found the number: %@", phNumber1);
                indexString = [NSString stringWithFormat:@"%d",i];
            }
        }
        if(![indexString isEqualToString:@"No"]){
            if([importKeoContacts objectForKey:phNumber1]){
                NSMutableDictionary *replacementContact = [[importKeoContacts objectForKey:phNumber1] mutableCopy];
                NSMutableDictionary *contactForName = [copyImportContactsData objectAtIndex:[indexString intValue]];
                
                [replacementContact setObject:[contactForName objectForKey:@"firstNames"] forKey:@"firstNames"];
                [replacementContact setObject:[contactForName objectForKey:@"lastNames"] forKey:@"lastNames"];
                APLLog(@"REPLACEMENT contact: %@",[replacementContact description]);
                [importKeoContacts setObject:replacementContact forKey:phNumber1];
            }
        }
    }
}



//-----------------convert NSDate into a string---------------------------

+(NSString *) getStringToPrint: (NSDate *)dateToPrint{
    NSString *answerString = @"";
    
    APLLog(@"DATE-getstringtoprint: %@",[dateToPrint description]);
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSString *dateToPrintAsString = [dateFormatter stringFromDate:dateToPrint];
    
    NSString *time= @"";
    NSString *day = @"";
    NSString *month = @"";
    NSString *year=@"";
    if([dateToPrintAsString length] > 15){
        time= [dateToPrintAsString substringWithRange:NSMakeRange(11,5)];
        day = [dateToPrintAsString substringWithRange:NSMakeRange(8,2)];
        month = [dateToPrintAsString substringWithRange:NSMakeRange(5,2)];
        year=[dateToPrintAsString substringWithRange:NSMakeRange(0,4)];
    }
    
    
    NSDate *currentDate = [NSDate date];
    
    NSString *currentDateAsString = [dateFormatter stringFromDate:currentDate];
    
    NSString *currentDay = @"";
    NSString *currentMonth = @"";
    NSString *currentYear= @"";
    if([currentDateAsString length] > 15){
        currentDay = [currentDateAsString substringWithRange:NSMakeRange(8,2)];
        currentMonth = [currentDateAsString substringWithRange:NSMakeRange(5,2)];
        currentYear=[currentDateAsString substringWithRange:NSMakeRange(0,4)];
    }
    
    if([year isEqualToString:currentYear]){
        if([month isEqualToString:currentMonth]){
            if([day isEqualToString:currentDay]){
                answerString = [NSString stringWithFormat:@"Today %@",time];
                return answerString;
            }
            else if ([day intValue] == ([currentDay intValue]-1)){
                answerString = [NSString stringWithFormat:@"Yesterday %@",time];
                return answerString;
            }
        }
    }
    
    
    if ([month isEqualToString:@"01"]) {
        month = @"January";
    }if ([month isEqualToString:@"02"]) {
        month = @"February";
    }if ([month isEqualToString:@"03"]) {
        month = @"Marsch";
    }if ([month isEqualToString:@"04"]) {
        month = @"April";
    }if ([month isEqualToString:@"05"]) {
        month = @"May";
    }if ([month isEqualToString:@"06"]) {
        month = @"June";
    }if ([month isEqualToString:@"07"]) {
        month = @"July";
    }if ([month isEqualToString:@"08"]) {
        month = @"August";
    }if ([month isEqualToString:@"09"]) {
        month = @"September";
    }if ([month isEqualToString:@"10"]) {
        month = @"October";
    }if ([month isEqualToString:@"11"]) {
        month = @"November";
    }if ([month isEqualToString:@"12"]) {
        month = @"December";
    }
    
    
    if(([day isEqualToString:@"20"])&&([day isEqualToString:@"30"])){
        day = [day stringByReplacingOccurrencesOfString:@"0" withString:@""];
    }
    answerString = [NSString stringWithFormat:@"%@%@ %@",answerString,day,month];
    if(![year isEqualToString:currentYear]){
        answerString = [NSString stringWithFormat:@"%@ %@",answerString,year];
    }
    answerString = [NSString stringWithFormat:@"%@ %@",answerString,time];
    
    return answerString;
}

+(NSString *) getStringToPrint2: (NSDate *)dateToPrint{
    NSString *answerString = @"";
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSString *dateToPrintAsString = [dateFormatter stringFromDate:dateToPrint];
    
    NSString *time= @"";
    NSString *day = @"";
    NSString *month = @"";
    NSString *year=@"";
    
    if([dateToPrintAsString length] > 15){
        time= [dateToPrintAsString substringWithRange:NSMakeRange(11,5)];
        day = [dateToPrintAsString substringWithRange:NSMakeRange(8,2)];
        if([[day substringWithRange:NSMakeRange(1,1)] isEqualToString:@"0"]){
            day = [day stringByReplacingOccurrencesOfString:@"0" withString:@""];
        }
        month = [dateToPrintAsString substringWithRange:NSMakeRange(5,2)];
        year=[dateToPrintAsString substringWithRange:NSMakeRange(0,4)];
    }
    
    NSDate *currentDate = [NSDate date];
    NSString *currentDateAsString = [dateFormatter stringFromDate:currentDate];
    
    NSString *currentMinute = @"";
    NSString *currentHour = @"";
    //NSString *currentDay = @"";
    //NSString *currentMonth = @"";
    //NSString *currentYear= @"";
    NSTimeInterval currentMinuteDouble = 0;
    NSTimeInterval currentHourDouble = 0;
    
    if([currentDateAsString length] > 15){
        currentMinute = [currentDateAsString substringWithRange:NSMakeRange(14,2)];
        currentMinuteDouble = [currentMinute doubleValue];
        currentHour = [currentDateAsString substringWithRange:NSMakeRange(11,2)];
        currentHourDouble = [currentHour doubleValue];
        //currentDay = [currentDateAsString substringWithRange:NSMakeRange(8,2)];
        //currentMonth = [currentDateAsString substringWithRange:NSMakeRange(5,2)];
        //currentYear=[currentDateAsString substringWithRange:NSMakeRange(0,4)];
    }
    
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:usLocale];
    [dateFormatter setDateFormat: @"EEEE"];
    NSString *dayOfWeek = [dateFormatter stringFromDate:dateToPrint];
    
    //NSTimeInterval currentDateTimeStamp = [currentDate timeIntervalSince1970];
    NSTimeInterval timeSinceYesterday = (currentMinuteDouble*60)+(currentHourDouble*60*60);
    //NSDate *todayMidnight = [NSDate dateWithTimeIntervalSince1970:currentDateTimeStamp-timeSinceYesterday];
    
    NSTimeInterval timeSpacing = [currentDate timeIntervalSinceDate:dateToPrint];
    if(timeSpacing < 60){
        answerString = [NSString stringWithFormat:@"%.0f seconds ago",timeSpacing];
        return answerString;
    }
    if(timeSpacing < 60*60){
        double numberOfMinutes = floor(timeSpacing/60);
        if(numberOfMinutes == 1){
            answerString = [NSString stringWithFormat:@"%.0f minute ago", numberOfMinutes];
        }
        else{
            answerString = [NSString stringWithFormat:@"%.0f minutes ago", numberOfMinutes];
        }
        return answerString;
    }
    if(timeSpacing < timeSinceYesterday){
        double numberOfHours = floor(timeSpacing/(60*60));
        if(numberOfHours == 1){
            answerString = [NSString stringWithFormat:@"%.0f hour ago",numberOfHours];
        }
        else{
            answerString = [NSString stringWithFormat:@"%.0f hours ago",numberOfHours];
        }
        return answerString;
    }
    if(timeSpacing < 2*24*60*60){
        return [NSString stringWithFormat:@"Yesterday, %@",time];
    }
    if(timeSpacing < 7*24*60*60){
        return [NSString stringWithFormat:@"%@, %@",dayOfWeek ,time];
    }
    
    if ([month isEqualToString:@"01"]) {
        month = @"January";
    }if ([month isEqualToString:@"02"]) {
        month = @"February";
    }if ([month isEqualToString:@"03"]) {
        month = @"Marsch";
    }if ([month isEqualToString:@"04"]) {
        month = @"April";
    }if ([month isEqualToString:@"05"]) {
        month = @"May";
    }if ([month isEqualToString:@"06"]) {
        month = @"June";
    }if ([month isEqualToString:@"07"]) {
        month = @"July";
    }if ([month isEqualToString:@"08"]) {
        month = @"August";
    }if ([month isEqualToString:@"09"]) {
        month = @"September";
    }if ([month isEqualToString:@"10"]) {
        month = @"October";
    }if ([month isEqualToString:@"11"]) {
        month = @"November";
    }if ([month isEqualToString:@"12"]) {
        month = @"December";
    }
    
    if(timeSpacing < 365*24*60*60){
        return [NSString stringWithFormat:@"%@ %@, %@",day ,month ,time];
    }
    
    return [NSString stringWithFormat:@"%@ %@ %@",day ,month ,year];
    
}


@end

//
//  TakePicture3.h
//  Keo
//
//  Created by Gauthier Petetin on 10/06/2014.
//  Copyright (c) 2014 Gauthier Petetin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>

@class myConstants;
@class myGeneralMethods;

@class ShyftMessage;

/////APPLAUSE
#import <Applause/APLLogger.h>


#import <MessageUI/MessageUI.h>//to send SMS

@interface TakePicture3 : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, MFMessageComposeViewControllerDelegate, UIActionSheetDelegate, UITextFieldDelegate>

-(void)switchScreenToMessages;

-(void)switchScreenToKeo;

-(void)messagesPressed;

-(void)keoPressed;

- (NSString *)saveImage: (UIImage*)image atKey:(NSString *)myKey;

- (UIImage*) scaleImage2:(UIImage*)image;

-(void)timePressed;

-(void)contactPressed;

-(void)sendPressed;

-(void)switchScreenToContacts;

- (IBAction)respondToTapGesture:(UITapGestureRecognizer *)recognizer;

-(void) sendPostRequestAtDate:(NSString *) theDateToSend toRecipient:(NSString *)recipientArr withUrlContent:(NSString *)securedUrlOfKeo withKeoTime:(NSString *)lccPhKeoTime;

@end
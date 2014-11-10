//
//  WriteMessage2.h
//  Keo
//
//  Created by Gauthier Petetin on 23/06/2014.
//  Copyright (c) 2014 Gauthier Petetin. All rights reserved.
//

#import <UIKit/UIKit.h>

/////APPLAUSE
#import <Applause/APLLogger.h>

#import <MessageUI/MessageUI.h>//to send SMS

#import <AudioToolbox/AudioServices.h>


@class myGeneralMethods;

@interface WriteMessage2 : UIViewController  <MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UIActionSheetDelegate>

- (IBAction)settingsPressed2:(id)sender;

-(NSString *)stringFromArray:(NSMutableArray *)array;

-(NSString *)stringForKeoChoice:(NSString *)choice withParameter:(NSString *)parameter;

-(void) askNewMessages2;

-(void)cancelPressed2;

- (IBAction)respondToTapGesture2:(UITapGestureRecognizer *)recognizer;

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo: (void *)contextInfo;

-(void)initializeView;


@end

//
//  WelcomeScreen.h
//  Keo
//
//  Created by Gauthier Petetin on 10/06/2014.
//  Copyright (c) 2014 Gauthier Petetin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ShyftMessage;
@class myGeneralMethods;
@class ShyftSet;

/////APPLAUSE
#import <Applause/APLLogger.h>

#import <FacebookSDK/FacebookSDK.h>

@interface WelcomeScreen : UIViewController <UIAlertViewDelegate, FBLoginViewDelegate>

-(void)signUpPressed;

@end

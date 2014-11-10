//
//  RegisterScreen.h
//  Keo
//
//  Created by Gauthier Petetin on 14/03/2014.
//  Copyright (c) 2014 Gauthier Petetin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LogInScreen.h"

/////APPLAUSE
#import <Applause/APLLogger.h>

@interface RegisterScreen : UIViewController <UITextFieldDelegate>{
    
}

//action appui sur le bouton logIn

- (IBAction)myActionLogIn:(id)sender;


- (BOOL)textFieldShouldReturn:(UITextField *)textField;


- (IBAction)respondToTapGesture2:(UITapGestureRecognizer *)recognizer;


@end

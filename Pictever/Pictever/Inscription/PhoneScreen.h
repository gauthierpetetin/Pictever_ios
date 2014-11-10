//
//  PhoneScreen.h
//  Keo
//
//  Created by Gauthier Petetin on 14/03/2014.
//  Copyright (c) 2014 Gauthier Petetin. All rights reserved.
//

#import <UIKit/UIKit.h>

/////APPLAUSE
#import <Applause/APLLogger.h>

@interface PhoneScreen : UIViewController <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>{
    
}

//action appui sur le bouton logIn

- (IBAction)myActionLogIn:(id)sender;

//-(IBAction)myActionConfirmCode:(id)sender;



- (IBAction)respondToTapGesture2:(UITapGestureRecognizer *)recognizer;



@end

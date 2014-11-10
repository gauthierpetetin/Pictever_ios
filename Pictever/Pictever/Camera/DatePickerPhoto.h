//
//  DatePickerPhoto.h
//  Keo
//
//  Created by Gauthier Petetin on 31/05/2014.
//  Copyright (c) 2014 Gauthier Petetin. All rights reserved.
//

#import <UIKit/UIKit.h>

//-------APPLAUSE
#import <Applause/APLLogger.h>

@class myGeneralMethods;

@interface DatePickerPhoto : UIViewController

@property (weak, nonatomic) IBOutlet UIDatePicker *myDatePickerPhoto;


-(void) sendKeo;

- (IBAction)cancelPressed4:(id)sender;


@end

//
//  PhotoDetail.h
//  Keo
//
//  Created by Gauthier Petetin on 14/07/2014.
//  Copyright (c) 2014 Gauthier Petetin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ShyftMessage;
@class myGeneralMethods;

/////APPLAUSE
#import <Applause/APLLogger.h>

@interface PhotoDetail : UIViewController

@property (strong, nonatomic) ShyftMessage * shyftToDetail;

- (IBAction)respondToTapGesture4:(UITapGestureRecognizer *)recognizer;

+ (UIImage*) scaleImageForDetail:(UIImage*)image;

@end

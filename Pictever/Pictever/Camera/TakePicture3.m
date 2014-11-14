//
//  TakePicture3.m
//  Keo
//
//  Created by Gauthier Petetin on 10/06/2014.
//  Copyright (c) 2014 Gauthier Petetin. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////(GO TO APPDELEGATE.M FOR MORE INFO ABOUT THE GLOBAL VARIABLES)/////////////////////////////////


#import "TakePicture3.h"

#import "ShyftMessage.h"
#import "ShyftSet.h"

#import "myConstants.h"
#import "myGeneralMethods.h"

#import "GPRequests.h"
#import "GPSession.h"

#import <AWSiOSSDKv2/AWSCore.h>
#import <AWSiOSSDKv2/S3.h>
#import <AWSiOSSDKv2/DynamoDB.h>
#import <AWSiOSSDKv2/SQS.h>
#import <AWSiOSSDKv2/SNS.h>
#import <AWSiOSSDKv2/AWSMobileAnalytics.h>


@interface TakePicture3 ()

@property (nonatomic, strong) NSArray *colorArray;

@end

@implementation TakePicture3

bool firstUseEver;


float uploadProgress;//global

NSString* lastLabelSelected;//global

ShyftSet *myShyftSet;//global

NSString *myCurrentPhotoPath;

//--------Amazon-----------
AWSMobileAnalytics* analytics;
AWSCognitoCredentialsProvider *credentialsProvider;
NSString *S3BucketName;


//----tools for the camera--------
AVCaptureSession *session;
AVCaptureStillImageOutput *stillImageOutput;
AVCaptureVideoPreviewLayer *previewLayer;
AVCaptureDevice *inputDevice;

UIView *cameraView;

NSUserDefaults *prefs;

NSString *myUserID;//global
NSString *myStatus;//global

bool logIn;//global

NSMutableArray *sendBox;

NSString *galleryOrCamera;
CGRect galleryFrame;

bool firstGlobalOpening; //global
bool appOpenedOnNotification;//global
bool viewJustDidLoad;
bool frontCameraActivated;
bool pictureIsTaken;

NSMutableArray *importKeoChoices;//global

//-----------size if the screen---------
CGFloat screenWidth;//global
CGFloat screenHeight;//global


NSString *storyboardName;//global
int openingWindow;//global

//---------info about user account----------
NSString *adresseIp2;//global
NSString *username;//global
NSString *hashPassword;//global


UIImage *myKeoImage;//global

UIActivityIndicatorView *spinner2; //spinner when the photo is taken

UIProgressView *progressView;// progress view when the photo is uploaded on amazon

NSTimer *mySendTimer;// this timer is just a detail to have a better fluidity in the app


UIButton *messagesButtonPh;
UIButton *shootButtonPh;
UIButton *keoButtonPh;
UIButton *sendButtonPh;
UIButton *flashButtonPh;
UIButton *frontButtonPh;
UIButton *cancelButtonPh;
UIButton *imagePickerButton;
UIButton *colorButton;
int xButton;
int yButton;
int xButton2;
int yButton2;
UIImageView *myImageViewPh; //important to capture the photo!
UITextField *keoTextFieldPh;
UILabel *labelChatPh;
UILabel *labelKeoPh;
UILabel *labelCancelPh;
UIImage *theKeoImage;
UIImage *imageSaved;



NSMutableArray *sendToMail;//global
NSString *sendToName;//global
NSString *sendToDate;//global
NSString *sendToDateAsText;//global
NSString *sendToTimeStamp;//global

bool showDatePicker;//global


NSString *recipientArrayAsString;
NSString *theSecuredUrlOfKeo;
NSString *thePublicIdOfKeo;


bool uploadPhotoOnCloudinary;//global
bool sendKeo;//global
bool sendSMS;//global

//-------colors----------
UIColor *theBackgroundColor;//global
UIColor *theKeoOrangeColor;//global

CGFloat localTabbarheight;
int xButton2;
int yButton2;
CGPoint originalShooterposition;
int xButton15;
int yButton15;
CGPoint originalPickerposition;

int colorCounter;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



// a param to describe the state change, and an animated flag
// optionally add a completion block which matches UIView animation
- (void)setTabBarVisible:(BOOL)visible animated:(BOOL)animated {
    
    // bail if the current state matches the desired state
    if ([self tabBarIsVisible] == visible) return;
    
    // get a frame calculation ready
    CGRect frame = self.tabBarController.tabBar.frame;
    CGFloat height = frame.size.height;
    CGFloat offsetY = (visible)? -height : height;
    
    // zero duration means no animation
    CGFloat duration = (animated)? 0.3 : 0.0;
    
    [UIView animateWithDuration:duration animations:^{
        self.tabBarController.tabBar.frame = CGRectOffset(frame, 0, offsetY);
    }];
}

// know the current state
- (BOOL)tabBarIsVisible {
    return self.tabBarController.tabBar.frame.origin.y < CGRectGetMaxY(self.view.frame);
}

/*
 // illustration of a call to toggle current state
 - (IBAction)pressedButton:(id)sender {
 
 [self setTabBarVisible:![self tabBarIsVisible] animated:YES];
 }*/


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    //create sections with alphabetical order
    self.colorArray = [NSArray arrayWithObjects:@"F6591E", @"483d8b", @"008B8B", @"008000", @"FFCC00", @"EA160B", @"8A2BE2", @"e9967a",@"f41690", @"000000", nil];

    colorCounter = 0;
    
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
        
    }
    else{
        APLLog(@"NO CAMERA ON THIS DEVICE");
    }
    
    if(firstGlobalOpening){
        APLLog(@"FIRST PICTURE OPENING");
        
        //----------creation of the progressview---------------
        progressView = [[UIProgressView alloc] init];
        progressView.frame = CGRectMake(0,3,screenWidth,2);
        [progressView setProgressTintColor:theKeoOrangeColor];
        [progressView setUserInteractionEnabled:NO];
        [progressView setProgressViewStyle:UIProgressViewStyleBar];
        [progressView setTrackTintColor:[UIColor clearColor]];
        
        if(firstUseEver){
            UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Tap screen see the menu bar!"
                                                                  message:@""
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles: nil];
            
            [myAlertView show];
        }
        
    }
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(restartCamera) name:@"restartCamera" object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(takepictureWorked) name:@"takepictureWorked" object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(switchScreenToKeo) name:@"switchViewToKeo" object: nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"hideProgressBars" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(hideProgressBar) name:@"hideProgressBars" object: nil];
    
    
    //-------------tabbar movement------------------
    CGRect frame = self.tabBarController.tabBar.frame;
    localTabbarheight = frame.size.height;
    xButton2 = 100;
    yButton2 = 100;
    originalShooterposition = CGPointMake(0.5*screenWidth,screenHeight-110+0.5*yButton2);
    
    xButton15 = 100;
    yButton15 = 100;
    originalPickerposition = CGPointMake(0.88*screenWidth,0.92*screenHeight);
    
    viewJustDidLoad = true;
    pictureIsTaken = false;
    sendToDate = @"0";
    theSecuredUrlOfKeo = @"";
    thePublicIdOfKeo = @"";
    
    galleryOrCamera = @"";
    galleryFrame = CGRectMake(0, 0, screenWidth, screenHeight);
    
    myKeoImage = [[UIImage alloc] init];
    
    sendToMail = [[NSMutableArray alloc] init];
    recipientArrayAsString = [[NSString alloc] init];
    
    spinner2 = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner2.center = CGPointMake(0.5*screenWidth, 0.5*screenHeight);
    spinner2.color = [UIColor whiteColor];
    spinner2.hidesWhenStopped = YES;
    
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // iOS 7
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    } else {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
    
    
    //-----------Create tap gesture recognizer (to add textfield on the photo)----------------
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondToTapGesture:)];
    tapRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tapRecognizer];
    
    
    self.view.backgroundColor = [[UIColor alloc] initWithCGColor:[UIColor blackColor].CGColor];
    
    
    
    //----------initialize all label and buttons----------
    [self initializeView];
    
    
    //----------if some pictures weren't sent last time, we try to send them again
    if(sendBox){
        if([sendBox count] > 0){
            if(!uploadPhotoOnCloudinary){
                APLLog(@"SENDBOX NOT EMPTY: SEND LEFT MESSAGES");
                [self uploadNextPhotoOnAmazon];
            }
            else{
                APLLog(@"STILL SENDING SHYFT");
            }
        }
    }
    
    //------------progressview to see when a photo is being uploaded (already created above)--------------
    [progressView setProgress:uploadProgress animated:NO];
    [self.view addSubview:progressView];
    
    if(uploadPhotoOnCloudinary){
        APLLog(@"showProgressview");
        progressView.hidden = NO;
    }
    else{
        APLLog(@"hideProgressView");
        progressView.hidden = YES;
    }
    
    APLLog(@"TakePicture3 did load");
}

-(void)hideProgressBar{
    APLLog(@"hideProgressBar");
    progressView.hidden = YES;
}


-(void)updateUploadProgress:(NSNumber *)number{
    APLLog(@"updateUploadProgress: %f",number.floatValue);
    [progressView setProgress:number.floatValue animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"uploadProgress" object: nil];
}


//---------method to resize images before to send them in order to have a faster upload (photos around 250Ko)
- (UIImage *)normalResizeImage:(UIImage *)image{
    // Determine output size
    CGFloat maxSize = 360.0f;
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    CGFloat newWidth = width;
    CGFloat newHeight = height;
    
    // If any side exceeds the maximun size, reduce the greater side to 360px and proportionately the other one
    if (width > maxSize || height > maxSize) {
        if (width > height) {
            newWidth = maxSize;
            newHeight = (height*maxSize)/width;
        } else {
            newHeight = maxSize;
            newWidth = (width*maxSize)/height;
        }
    }
    
    // Resize the image
    CGSize newSize = CGSizeMake(newWidth, newHeight);
    
    
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 1.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


//------------Flashlight----------------------
- (void) turnTorchOn: (bool) on {
    
    // check if flashlight available
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch] && [device hasFlash]){
            
            [device lockForConfiguration:nil];
            if (on) {
                [device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];
                UIImage *flashButtonImage = [UIImage imageNamed:@"flash_on.png"];
                flashButtonImage = [myGeneralMethods scaleImage3:flashButtonImage withFactor:1.7];
                [flashButtonPh setImage:flashButtonImage forState:UIControlStateNormal];
                //torchIsOn = YES; //define as a variable/property if you need to know status
            } else {
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
                UIImage *flashButtonImage = [UIImage imageNamed:@"flash_off.png"];
                flashButtonImage = [myGeneralMethods scaleImage3:flashButtonImage withFactor:1.7];
                [flashButtonPh setImage:flashButtonImage forState:UIControlStateNormal];
                //torchIsOn = NO;
            }
            [device unlockForConfiguration];
        }
    }
}



//--------------move the text on the photo---------------------------
- (void)wasDragged:(UITextField *)button withEvent:(UIEvent *)event
{
    APLLog(@"was dragged");
    // get the touch
    UITouch *touch = [[event touchesForView:button] anyObject];
    
    // get delta
    CGPoint previousLocation = [touch previousLocationInView:button];
    CGPoint location = [touch locationInView:button];
    CGFloat delta_x = location.x - previousLocation.x;
    CGFloat delta_y = location.y - previousLocation.y;
    
    // move button
    button.center = CGPointMake(button.center.x + delta_x,
                                button.center.y + delta_y);
}

/*
 -(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{//maybe not used
 UITouch *touch = [[event allTouches] anyObject];
 CGPoint location = [touch locationInView:touch.view];
 }*/


//------------------tap gesture recognizer to show or hide the textfield on the photo---------------
- (IBAction)respondToTapGesture:(UITapGestureRecognizer *)recognizer {
    if(myImageViewPh.image == nil){
        if (![self tabBarIsVisible]){
            NSLog(@"tabBar IS HIDDEN");
            [self setTabBarVisible:YES animated:YES];
            [UIView animateWithDuration:0.3 animations:^{
                shootButtonPh.center = CGPointMake(shootButtonPh.center.x, originalShooterposition.y-localTabbarheight);
                imagePickerButton.center = CGPointMake(imagePickerButton.center.x, originalPickerposition.y-localTabbarheight);
            }];
        }
        else
        {
            NSLog(@"tabBar IS VISIBLE");
            [self setTabBarVisible:NO animated:YES];
            [UIView animateWithDuration:0.3 animations:^{
                shootButtonPh.center = CGPointMake(shootButtonPh.center.x, originalShooterposition.y);
                imagePickerButton.center = CGPointMake(imagePickerButton.center.x, originalPickerposition.y);
            }];
        }
    }
    if(keoTextFieldPh.isFirstResponder){
        [keoTextFieldPh resignFirstResponder];
    }
    else{
        if([[self.view subviews] containsObject:keoTextFieldPh]){
            [keoTextFieldPh removeFromSuperview];
            [colorButton removeFromSuperview];
        }
        else{
            if(pictureIsTaken){
                [self.view addSubview:keoTextFieldPh];
                [self.view addSubview:colorButton];
                [keoTextFieldPh becomeFirstResponder];
            }
        }
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [keoTextFieldPh resignFirstResponder];
    return YES;
}

//-----------go to messages--------------
-(void)messagesPressed{
    [self switchScreenToMessages];
}

//------------go to shyft gallery----------
-(void)keoPressed{
    [self switchScreenToKeo];
}


//-------------switch front/back camera--------
-(void)frontCameraPressed{
    
    [self stopCamera];
    if(frontCameraActivated){
        [self startCameraWithFrontCamera:NO];
    }
    else{
        [self startCameraWithFrontCamera:YES];
    }
}


//------------turn the flashlight on/off--------
-(void)flashPressed{
    if(!inputDevice.torchActive){
        if(!frontCameraActivated){
            [self turnTorchOn:YES];
        }
    }
    else{
        [self turnTorchOn:NO];
    }
}

//------------delete the photo taken and take a new photo-------
-(void)cancelPressed{
    //[messagesButtonPh removeFromSuperview];
    //[keoButtonPh removeFromSuperview];
    [sendButtonPh removeFromSuperview];
    myImageViewPh.image = nil;
    [myImageViewPh removeFromSuperview];
    [keoTextFieldPh removeFromSuperview];
    [colorButton removeFromSuperview];
    
    [cancelButtonPh removeFromSuperview];
    [labelCancelPh removeFromSuperview];
    
    [self initializeView];
    if(frontCameraActivated){
        [self startCameraWithFrontCamera:YES];
    }
    else{
        [self startCameraWithFrontCamera:NO];
    }
}


-(void)stopCamera{
    [session stopRunning];
    [session removeOutput:stillImageOutput];
    [previewLayer removeFromSuperlayer];
}

-(void)startCameraWithFrontCamera:(bool)frCam{
    session = [[AVCaptureSession alloc] init];
    [session setSessionPreset:AVCaptureSessionPresetPhoto];
    
    if(frCam){
        inputDevice = [self frontCamera];
        frontCameraActivated = true;
        [prefs setBool:frontCameraActivated forKey:@"frontCamera"];
    }
    else{
        inputDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        frontCameraActivated = false;
        [prefs setBool:frontCameraActivated forKey:@"frontCamera"];
    }
    
    NSError *error;
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:inputDevice error:&error];
    
    if([session canAddInput:deviceInput]){
        [session addInput:deviceInput];
    }
    
    previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    CALayer *rootLayer = [[self view] layer];
    [rootLayer setMasksToBounds:YES];
    CGRect frame = cameraView.frame;
    
    [previewLayer setFrame:frame];
    
    [rootLayer insertSublayer:previewLayer atIndex:0];
    
    stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [stillImageOutput setOutputSettings:outputSettings];
    
    [session addOutput:stillImageOutput];
    
    [session startRunning];
}


//--------------not used (screen capture in higher quality)-----------
-(UIImage *)captureScreenInRectHighQuality:(CGRect)captureFrame {
    CALayer *layer;
    layer = self.view.layer;
    //UIGraphicsBeginImageContext(self.view.bounds.size);
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
    CGContextClipToRect (UIGraphicsGetCurrentContext(),captureFrame);
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *screenImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return screenImage;
}

//-------------screen capture used to add the text on the photo-----------
-(UIImage *)captureScreenInRect:(CGRect)captureFrame {
    CALayer *layer;
    layer = self.view.layer;
    UIGraphicsBeginImageContext(self.view.bounds.size);
    //UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
    CGContextClipToRect (UIGraphicsGetCurrentContext(),captureFrame);
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *screenImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return screenImage;
}

//-------------checks if the recipient and the date is selected, if yes, it sends the photo-------------
-(void)sendPressed{
    APLLog(@"SENDPRESSED");
    
    if(!uploadPhotoOnCloudinary){
        if([GPRequests connected]){
            if([sendToName isEqualToString:@""]){
                [self switchScreenToContacts];
            }
            else{
                if([sendToDateAsText isEqualToString:@""]){
                    [self timePressed];
                }
                else{
                    [self send];
                    
                }
                
            }
        }
        else{
            UIAlertView *alert5 = [[UIAlertView alloc]
                                   initWithTitle:@"Connection problem"
                                   message:@"You have no internet connection" delegate:self
                                   cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert5 show];
        }
    }
    else{
        UIAlertView *alert5 = [[UIAlertView alloc]
                               initWithTitle:@"The app is still sending your previous message"
                               message:@"Please wait a few seconds" delegate:self
                               cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert5 show];
    }
    
}


//------------does the screen capture and sends the photo----------------
-(void)send{
    
    ///////SceenShot
    [sendButtonPh removeFromSuperview];
    //[messagesButtonPh removeFromSuperview];
    //[keoButtonPh removeFromSuperview];
    //[labelChatPh removeFromSuperview];
    //[labelKeoPh removeFromSuperview];
    
    [cancelButtonPh removeFromSuperview];
    [labelCancelPh removeFromSuperview];
    [colorButton removeFromSuperview];
    
    //myKeoImage = [self captureScreenInRectHighQuality:self.view.frame];
    //myImageViewPh.image = myKeoImage;
    if([galleryOrCamera isEqualToString:@"Gallery"]){
        NSLog(@"gallery frame: %f %f",galleryFrame.origin.y, galleryFrame.size.height);
        myKeoImage = [self captureScreenInRect:galleryFrame];
    }
    else{
        NSLog(@"full screen capt");
        myKeoImage = [self captureScreenInRect:self.view.frame];
    }
    
    APLLog([NSString stringWithFormat:@"ScreenShot Photo size:%f %f",[myKeoImage size].width, [myKeoImage size].height]);
    
    [self.view addSubview:sendButtonPh];
    
    
    [self.view addSubview:cancelButtonPh];
    [self.view addSubview:labelCancelPh];
    
    [self.view bringSubviewToFront:keoTextFieldPh];
    [self.view bringSubviewToFront:colorButton];
    ////////
    
    APLLog(@"SEND");
    if([sendToMail count] > 0){
        if(![sendToDate isEqualToString:@"0"]){
            
            
            if(!uploadPhotoOnCloudinary){
                APLLog([NSString stringWithFormat:@"Send to friend: %@  at date: %@", [sendToMail description], sendToDateAsText]);
                
                
                NSString *myKeoReferenceString = [NSString stringWithFormat:@"%@",[[NSDate date] description]];
                myKeoReferenceString = [myKeoReferenceString stringByReplacingOccurrencesOfString:@" " withString:@""];
                myKeoReferenceString = [myKeoReferenceString stringByReplacingOccurrencesOfString:@"+" withString:@""];
                myKeoReferenceString = [myKeoReferenceString stringByReplacingOccurrencesOfString:@"-" withString:@""];
                myKeoReferenceString = [myKeoReferenceString stringByReplacingOccurrencesOfString:@":" withString:@""];
                APLLog(@"image size: %f %f", myKeoImage.size.height, myKeoImage.size.width);
                //myKeoImage = [self normalResizeImage:myKeoImage];//-----------reduce image size-------
                APLLog(@"resized image size: %f %f", myKeoImage.size.height, myKeoImage.size.width);
                NSString *imagePathSend = [self saveImage:myKeoImage atKey:myKeoReferenceString];
                NSRange theRange2 = [imagePathSend rangeOfString:@"Keo"];
                NSString *imageKeySend = [imagePathSend substringFromIndex:(1+theRange2.location+theRange2.length)];
                
                APLLog(@"imagepathtosend: %@ sendToDate: %@",imagePathSend, sendToDate);
                
                recipientArrayAsString = [myGeneralMethods stringFromArrayPh:sendToMail];
                
                
                NSMutableDictionary *keoToSend = [[NSMutableDictionary alloc] init];
                [keoToSend setObject:imageKeySend forKey:my_sendbox_path];
                [keoToSend setObject:sendToDate forKey:my_sendbox_date];
                [keoToSend setObject:recipientArrayAsString forKey:my_sendbox_recipient];
                [keoToSend setObject:[myGeneralMethods stringForKeoChoicePh:sendToDate withParameter:sendToTimeStamp] forKey:my_sendbox_keoTime];
                
                NSString *hashKeyName = [NSString stringWithFormat:@"%@.jpg",imageKeySend];
                if(myUserID){
                    if(![[myUserID stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]){
                        hashKeyName = [NSString stringWithFormat:@"%@%@",[GPRequests sha256HashFor:myUserID],hashKeyName];
                    }
                }
                APLLog(@"hashKeyName: %@",hashKeyName);
                [keoToSend setObject:hashKeyName forKey:my_sendbox_key];
                
                //[sendBox addObject:keoToSend];
                [sendBox insertObject:keoToSend atIndex:0];
                [prefs setObject:sendBox forKey:@"sendBox"];
                
                [self uploadNextPhotoOnAmazon];
                
                
                [self sendSMSAlert];
                
                
                //[messagesButtonPh removeFromSuperview];
                //[keoButtonPh removeFromSuperview];
                [sendButtonPh removeFromSuperview];
                myImageViewPh.image = nil;
                [myImageViewPh removeFromSuperview];
                [keoTextFieldPh removeFromSuperview];
                [colorButton removeFromSuperview];
                
                [cancelButtonPh removeFromSuperview];
                [labelCancelPh removeFromSuperview];
                
                [self initializeView];
                if(frontCameraActivated){
                    [self startCameraWithFrontCamera:YES];
                }
                else{
                    [self startCameraWithFrontCamera:NO];
                }
                
            }
            else{
                UIAlertView *alert5 = [[UIAlertView alloc]
                                       initWithTitle:@"The app is still sending your previous message"
                                       message:@"Please wait a few seconds" delegate:self
                                       cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert5 show];
            }
            
        }
        else{
            UIAlertView *alert4 = [[UIAlertView alloc]
                                   initWithTitle:@"No date selected"
                                   message:@"Pick a date first!" delegate:self
                                   cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert4 show];
        }
    }
    else{
        UIAlertView *alert3 = [[UIAlertView alloc]
                               initWithTitle:@"No contact selected"
                               message:@"Pick a contact first!" delegate:self
                               cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert3 show];
    }
    
}


//------if contacts that don't have the app where selected, alert them with a sms

-(void)sendSMSAlert{
    
    if(sendSMS){
        NSMutableArray *sendToSMS = [[NSMutableArray alloc] init];
        for(NSString *contNnumber in sendToMail){
            APLLog(@"contNumber: %@", contNnumber);
            if([[contNnumber substringToIndex:3] isEqualToString:@"num"]){
                [sendToSMS addObject:[contNnumber substringFromIndex:3]];
            }
        }
        APLLog(@"sendToSMS: %@", [sendToSMS description]);
        
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
        if([MFMessageComposeViewController canSendText])
        {
            controller.body = @"Hello! I just sent you a message in the future on Pictever! Download the app to receive it: http://pictever.com";
            controller.recipients = sendToSMS;
            controller.messageComposeDelegate = self;
            [self presentViewController:controller animated:YES completion:nil];
        }
        sendSMS = false;
    }
    
    
}


//------------uploads photo on amazon in background task----------------
-(void)uploadNextPhotoOnAmazon{
    
    UIBackgroundTaskIdentifier taskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^(void) {
        // Uh-oh - we took too long. Stop task.
    }];
    
    [self backgroundUploadNextPhotoOnAmazon];
    
    if (taskId != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:taskId];
    }
    
}


//------------uploads photo on amazon and once it is done it sends the message to server--------------------------------------------------------
//--------(the message sent to the server contains the name of the uploaded photo in the field "message" and the word "on" in the field "photo")--
-(void)backgroundUploadNextPhotoOnAmazon{
    
    uploadPhotoOnCloudinary = true;
    ////////AMAZON
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    
    AWSS3TransferManagerUploadRequest *uploadRequest;
    uploadRequest = [AWSS3TransferManagerUploadRequest new];
    APLLog(@"Bucket name: %@", S3BucketName);
    uploadRequest.bucket = S3BucketName;
    
    NSString *locPath = [NSString stringWithFormat:@"%@/%@",myCurrentPhotoPath ,[sendBox[0] objectForKey:my_sendbox_path] ];
    NSString *theKey = [sendBox[0] objectForKey:my_sendbox_key];
    
    APLLog(@"uploadPath: %@", locPath);
    APLLog(@"uploadKey: %@", theKey);
    uploadRequest.key = theKey;
    NSURL *amazonUrl = [NSURL fileURLWithPath:locPath];
    uploadRequest.body = amazonUrl;
    
    progressView.hidden = NO;
    uploadProgress = 0.0;
    progressView.progress = uploadProgress;
    
    
    __unsafe_unretained typeof(uploadRequest) uploadRequestWeak = uploadRequest;
    uploadRequest.uploadProgress = ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        
        AZNetworkingRequest *internalRequest = [uploadRequestWeak valueForKey:@"internalRequest"];
        if (internalRequest.uploadProgress) {
            //int64_t previousSentDataLengh = [[uploadRequest valueForKey:@"totalSuccessfullySentPartsDataLength"] longLongValue];
            uploadProgress = (float)totalBytesSent / (float)totalBytesExpectedToSend;
            
            [self performSelectorOnMainThread:@selector(updateUploadProgress:) withObject:[NSNumber numberWithFloat:uploadProgress] waitUntilDone:NO];
            APLLog(@"progress: %f",(float)totalBytesSent / (float)totalBytesExpectedToSend);
        }
    };
    
    [[transferManager upload:uploadRequest] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        
        if (task.error != nil) {
            APLLog(@"AWS upload Error: [%@]", task.error);
            uploadPhotoOnCloudinary  =false;
            uploadProgress = 0;
            
        } else {
            APLLog(@"OK FOR AMAZON SEND");
            recipientArrayAsString = [myGeneralMethods stringFromArrayPh:sendToMail];
            
            [self sendAssociatedMessage];
            
            uploadPhotoOnCloudinary = false;
        }
        return nil;
    }];
}


-(void)sendAssociatedMessage{
    APLLog([sendBox[0] objectForKey:my_sendbox_key]);
    NSString *lccDate2=@"";
    NSString *lccRecipient2=@"";
    NSString *lccKey2=@"";
    NSString *lccKeoTime2=@"";
    if([sendBox[0] objectForKey:my_sendbox_date]){
        lccDate2 = [sendBox[0] objectForKey:my_sendbox_date];
    }
    if([sendBox[0] objectForKey:my_sendbox_recipient]){
        lccRecipient2 = [sendBox[0] objectForKey:my_sendbox_recipient];
    }
    if([sendBox[0] objectForKey:my_sendbox_key]){
        lccKey2 = [sendBox[0] objectForKey:my_sendbox_key];
    }
    if([sendBox[0] objectForKey:my_sendbox_keoTime]){
        lccKeoTime2 = [sendBox[0] objectForKey:my_sendbox_keoTime];
    }
    [self sendPostRequestAtDate:lccDate2 toRecipient:lccRecipient2 withUrlContent:lccKey2 withKeoTime:lccKeoTime2];
}




//--------------------method to send the message to the server once the photo was successfully uploaded--------------
//--(the message sent to the server contains the name of the uploaded photo in the field "message" and the word "on" in the field "photo")--
-(void) sendPostRequestAtDate:(NSString *) theDateToSend toRecipient:(NSString *)recipientArr withUrlContent:(NSString *)securedUrlOfKeo withKeoTime:(NSString *)lccPhKeoTime{
    APLLog(@"sendPostRequestAtDate");
    if([lccPhKeoTime isEqualToString:@""]){
        APLLog(@"Refind keo time");
        lccPhKeoTime = [myGeneralMethods stringForKeoChoicePh:theDateToSend withParameter:sendToTimeStamp];
    }
    //[GPRequests sendMessage:securedUrlOfKeo to:recipientArr withPhotoString:@"on" withKeoTime:lccPhKeoTime for:self];
    
    [[[GPSession alloc] init] sendRequest:@"" to:recipientArr withPhotoString:securedUrlOfKeo withKeoTime:lccPhKeoTime for:self];
    
    [self alertAnalyticsPhotoSent];
}

//---------for every sent message, we alert amazon analytics for our own statistics----------------------
-(void)alertAnalyticsPhotoSent{
    APLLog(@"alertAnalytics photos");
    id<AWSMobileAnalyticsEventClient> eventClient = analytics.eventClient;
    NSString *analyticsEventName = [NSString stringWithFormat:@"iosSendPhotoMessageFrom%@",galleryOrCamera];
    id<AWSMobileAnalyticsEvent> levelEvent = [eventClient createEventWithEventType:analyticsEventName];
    [levelEvent addAttribute:[NSString stringWithFormat:@"%lu",(unsigned long)[sendToMail count]] forKey:@"number_of_receivers"];
    [levelEvent addAttribute:lastLabelSelected forKey:@"send_label"];
    [eventClient recordEvent:levelEvent];
    [eventClient submitEvents];
}


//------------if the user has not selected a send_choice (in 3 days, in 3 weeks...), we show him an action sheet-----------------
//--(the send_choices are given directly by the server and saved in importKeoChoices)--
-(void)timePressed{
    APLLog(@"timePressedP");
    sendToTimeStamp = @"";
    UIActionSheet *actionSheet;
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    NSMutableArray *choiceArray = [[NSMutableArray alloc] init];
    [choiceArray addObject:@"opp1"];
    [choiceArray addObject:@"opp2"];
    [choiceArray addObject:@"opp3"];
    APLLog(@"importKeoChoicesSize: %d",[importKeoChoices count]);
    
    ////new
    actionSheet = [[UIActionSheet alloc] initWithTitle:@"Pick a date!"
                                              delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil
                                     otherButtonTitles:@"Calendar", nil];
    
    
    if([importKeoChoices count] > 0){
        for (NSMutableDictionary *choiceDictionnary in importKeoChoices) {
            [actionSheet addButtonWithTitle:[choiceDictionnary objectForKey:@"send_label"]];
        }
    }
    
    [actionSheet addButtonWithTitle:@"Cancel"];
    
    actionSheet.destructiveButtonIndex = 0;
    //[actionSheet showInView:self.view];
    [actionSheet showInView:[[UIApplication sharedApplication].delegate window]];
}

//------------------the user selects a send_choice-----------------------
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    sendToDate = @"0";
    
    if (!(buttonIndex == ([importKeoChoices count]+1))) { // Cancel
        
        if(!(buttonIndex == 0)){ // pickDate
            if(buttonIndex > 0){
                if([importKeoChoices count] > (buttonIndex-1)){
                    sendToDate = [[importKeoChoices objectAtIndex:(buttonIndex-1)] objectForKey:@"key"];
                    sendToDateAsText = [[importKeoChoices objectAtIndex:(buttonIndex-1)] objectForKey:@"send_label"];
                }
            }
            
            sendButtonPh.hidden = YES;
            cancelButtonPh.hidden = YES;
            labelCancelPh.hidden = YES;
            mySendTimer = [NSTimer scheduledTimerWithTimeInterval: 0.2 target: self selector: @selector(send) userInfo: nil repeats: NO];
            //[self send];
            
            
        }
        else{ //open calendar
            APLLog(@"Calendar selectedP");
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
            UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"DatePickerPhotoController"];
            APLLog(@"YES");
            [self presentViewController:vc animated:YES completion:nil];
            
            sendToDate = @"calendar";
        }
        
    }
    else{
        APLLog(@"CancelPressedP");
        sendToDate = @"";
        sendToMail = [[NSMutableArray alloc] init];
        sendToName = @"";
        sendToDateAsText = @"";
    }
    
}

//-------------change of the color of the UIactionSheet (not working on iOS 8)
- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    for (UIView *subview in actionSheet.subviews) {
        //APLLog(@"NEW OPTION %@",[[subview class] description]);
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subview;
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
    }
}

//----------we stop the camera when we lieve the view to avoid memory pressure errors--------------
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    APLLog(@"TakePicture3 will disappear");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"insertNewRow" object:nil];
    [self stopCamera];
}

//---------------insert new message from notification---------------------

-(void)insertNewRow:(NSNotification *)notification{
    APLLog(@"insertNewRow: %@",[notification.userInfo description]);
    NSMutableDictionary *newPhotoMessage = [notification.userInfo mutableCopy];
    ShyftMessage *shyftToInsert = [[ShyftMessage alloc] initWithShyft:newPhotoMessage];
    if(![myShyftSet containsShyft:shyftToInsert]){
        [myShyftSet insertNewShyft:shyftToInsert];
    }
}


//------------we start the camera when we arrive on the view--------------------
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    APLLog(@"TakePicture3 will appear");
    shootButtonPh.center = CGPointMake(shootButtonPh.center.x, originalShooterposition.y-localTabbarheight);
    imagePickerButton.center = CGPointMake(imagePickerButton.center.x, originalPickerposition.y-localTabbarheight);
    
    if(myImageViewPh.image == nil){
        APLLog(@"STARTCAMERA");
        if(frontCameraActivated){
            [self startCameraWithFrontCamera:YES];
        }
        else{
            [self startCameraWithFrontCamera:NO];
        }
    }
    
    [self.view bringSubviewToFront:keoTextFieldPh];
    [self.view bringSubviewToFront:colorButton];
}

//to keep
- (BOOL)prefersStatusBarHidden {
    return YES;
}//to keep

-(void) awakeFromNib {
    //[self presentViewController:self.cameraUI animated:YES completion:nil];
}

-(IBAction)callCamera{
    APLLog(@"callCamera");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    APLLog(@"TakePicture3 did appear");
    [super viewDidAppear:animated];
    [self setTabBarVisible:NO animated:YES];
    [UIView animateWithDuration:0.3 animations:^{
        shootButtonPh.center = CGPointMake(shootButtonPh.center.x, originalShooterposition.y);
        imagePickerButton.center = CGPointMake(imagePickerButton.center.x, originalPickerposition.y);
    }];
    
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(insertNewRow:) name:@"insertNewRow" object: nil];
    
    if(firstGlobalOpening){
        firstGlobalOpening = false;
    }
    //---------when we come back from the PickContact view, we directly show the UIactionSheet with the send_choices-----------
    if(showDatePicker && [sendToDateAsText isEqualToString:@""]&&([sendToMail count]>0)){
        [self timePressed];//show the UIactionSheet with the send_choices
    }
    if(sendKeo){
        [self sendPressed];
        sendKeo = false;
    }
    else{
        
    }
    showDatePicker = false;
}


//---------------different methods to switch the view---------------------
-(void)switchScreenToContacts{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:my_storyboard_pickContact_Name];
    [self presentViewController:vc animated:YES completion:nil];
}

-(void)switchScreenToMessages{

    [self.tabBarController setSelectedIndex:0];
}

-(void)switchScreenToKeo{

    [self.tabBarController setSelectedIndex:2];
}

-(void)switchScreenToCamera{
    openingWindow = 1;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:my_storyboard_master_controller];
    [self presentViewController:vc animated:NO completion:nil];
}

-(void)contactPressed{
    [self switchScreenToContacts];
}


//--------------scale method to adapt an image to the screen------------------------
- (UIImage*) scaleImage2:(UIImage*)image{
    CGSize scaledSize = CGSizeMake(image.size.width, image.size.height);
    
    CGFloat scaleFactor = image.size.height / image.size.width;
    
    scaledSize.width = screenHeight / scaleFactor ;
    scaledSize.height = screenHeight;
    
    UIGraphicsBeginImageContextWithOptions( scaledSize, NO, 0.0 );
    CGRect scaledImageRect = CGRectMake( 0.0, 0.0, scaledSize.width, scaledSize.height );
    [image drawInRect:scaledImageRect];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}



//-----------------take a picture------------------------------------------------
-(void)pressTakePictureButton{
    
    galleryOrCamera = @"Camera";
    shootButtonPh.enabled = NO;
    
    if([self tabBarIsVisible]){
        NSLog(@"tabBar IS VISIBLE");
        [self setTabBarVisible:NO animated:YES];
        [UIView animateWithDuration:0.3 animations:^{
            shootButtonPh.center = CGPointMake(shootButtonPh.center.x, originalShooterposition.y);
            imagePickerButton.center = CGPointMake(imagePickerButton.center.x, originalPickerposition.y);
        }];
    }
    
    AVCaptureConnection *videoConnection = nil;
    
    for (AVCaptureConnection *connection in stillImageOutput.connections) {
        for(AVCaptureInputPort *port in [connection inputPorts]){
            if([[port mediaType] isEqual:AVMediaTypeVideo]){
                videoConnection = connection;
                break;
            }
        }
        if(videoConnection){
            break;
        }
    }
    
    [self.view addSubview:spinner2];
    [spinner2 startAnimating];
    
    [stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if(error){
            APLLog(@"PAS DE MISE AU POINT");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"restartCamera" object: nil];
        }
        else if(imageDataSampleBuffer != NULL){
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            
            myImageViewPh.contentMode = UIViewContentModeScaleAspectFill;
            //CGFloat monfloat= 1159266304/(screenHeight*screenWidth);
            
            imageSaved = [UIImage imageWithData:imageData];
            imageSaved = [self scaleImage2:imageSaved];
            //APLLog([NSString stringWithFormat:@"ImageSizeBeforeCustom: %f  %f", screenWidth ,screenHeight]);
            myImageViewPh.image = imageSaved;
            APLLog(@"MISE AU POINT %f %f", imageSaved.size.height, imageSaved.size.width);
            
            if(frontCameraActivated){
                imageSaved = [UIImage imageWithCGImage:imageSaved.CGImage scale:imageSaved.scale orientation:UIImageOrientationUpMirrored];
                myImageViewPh.image = imageSaved;
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"takepictureWorked" object: nil];
            ///size of image : 2448.000000  3264.000000   factor = 1.33333
            ///size of screen : 320   480  factor = 1.5
        }
        else{
            APLLog(@"autre erreur");
        }
    }];
    
}

//-----------called in case taking a picture did not work----------------
-(void)restartCamera{
    shootButtonPh.enabled = YES;
    APLLog(@"restartCAMERA");
    
    // viewController is visible
    [spinner2 stopAnimating];
    [spinner2 removeFromSuperview];
    [self stopCamera];
    [self initializeView];
    if(frontCameraActivated){
        [self startCameraWithFrontCamera:YES];
    }
    else{
        [self startCameraWithFrontCamera:NO];
    }
}

//-----------called in case taking a picture did work----------------
-(void)takepictureWorked{
    shootButtonPh.enabled = YES;
    if(self.isViewLoaded){
        APLLog(@"ISVIEWLOADED");
    }
    if(self.view.window){
        APLLog(@"WINDOW");
    }
    // viewController is visible
    
    [self stopCamera];
    APLLog(@"takepictureworked");
    
    [spinner2 stopAnimating];
    [spinner2 removeFromSuperview];
    
    pictureIsTaken = true;
    
    [imagePickerButton removeFromSuperview];
    [flashButtonPh removeFromSuperview];
    [frontButtonPh removeFromSuperview];
    [shootButtonPh removeFromSuperview];
    //[keoButtonPh removeFromSuperview];
    //[messagesButtonPh removeFromSuperview];
    //[labelChatPh removeFromSuperview];
    //[labelKeoPh removeFromSuperview];
    
    [self.view addSubview:myImageViewPh];
    [self.view addSubview:sendButtonPh];
    [self.view addSubview:cancelButtonPh];
    [self.view addSubview:labelCancelPh];
    
    sendToDateAsText = @"";
    sendToName = @"";
    
    if(firstUseEver){
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Tap the screen to add some text!"
                                                              message:@""
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
    }
    
    APLLog(@"takepictureworkedOver");
}


//---------------save an image in the memory of the app and returns the path where it was saved----------------------
- (NSString *)saveImage: (UIImage*)image atKey:(NSString *)myKey{
    APLLog(@"saveImage");
    if (image != nil)
    {
        NSError *error;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString* path = [documentsDirectory stringByAppendingPathComponent:@"/Keo"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:path]){
            [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&error];
        }
        path = [path stringByAppendingPathComponent:myKey];
        NSData* data = UIImagePNGRepresentation(image);
        APLLog([NSString stringWithFormat:@"Save photo: %@ at path: %@", myKey, path]);
        [data writeToFile:path atomically:YES];
        return path;
    }
    return @"";
}

//------------returns the complete path where the image called "myKey3" was saved -----------------
-(NSString *)getPathOfImageWithKey:(NSString *)myKey3{
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:@"/Keo"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]){
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&error];
    }
    path = [path stringByAppendingPathComponent:myKey3];
    return path;
}


//---------------------initializes all the labels and buttons-------------------------------
-(void)initializeView{
    sendToName = @"";
    sendToDateAsText = @"";
    pictureIsTaken = false;
    
    cameraView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    
    
    myImageViewPh = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    myImageViewPh.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:myImageViewPh];
    
    keoTextFieldPh = [[UITextField alloc] initWithFrame:CGRectMake(0.25*screenWidth, 0.35*screenHeight, 0.25*screenWidth, 30)];
    keoTextFieldPh.delegate = self;
    //keoTextFieldPh.alpha = 0.75;
    keoTextFieldPh.alpha = 1.0;
    [keoTextFieldPh setTag:101];
    keoTextFieldPh.textAlignment = NSTextAlignmentCenter;
    keoTextFieldPh.textColor = [UIColor whiteColor];
    keoTextFieldPh.backgroundColor = [myGeneralMethods getColorFromHexString:self.colorArray[colorCounter]];
    [keoTextFieldPh.layer setBorderColor:[UIColor whiteColor].CGColor];
    [keoTextFieldPh.layer setBorderWidth:1.0];
    [keoTextFieldPh setFont:[UIFont systemFontOfSize:16]];
    //keoTextFieldPh.lineBreakMode = NSLineBreakByWordWrapping;
    //keoTextFieldPh.numberOfLines = 0;
    
    keoTextFieldPh.clipsToBounds = YES;
    keoTextFieldPh.layer.cornerRadius = 10.0f;
    // add drag listener
    [keoTextFieldPh addTarget:self action:@selector(wasDragged:withEvent:) forControlEvents:UIControlEventTouchDragInside];
    
    /*
    int xButton = 100;
    int yButton = 100;
    //Creation of Messages button
    messagesButtonPh = [UIButton buttonWithType:UIButtonTypeCustom];
    messagesButtonPh.frame = CGRectMake(0.15*screenWidth-0.5*xButton,screenHeight-52-0.5*yButton,xButton,yButton);
    messagesButtonPh.backgroundColor = [UIColor clearColor];
    //[shootButton setTitle:@"Shoot" forState:UIControlStateNormal];
    //[shootButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    UIImage *messagesButtonImage = [UIImage imageNamed:@"Message.png"];
    messagesButtonImage = [myGeneralMethods scaleImage3:messagesButtonImage withFactor:2];
    [messagesButtonPh setImage:messagesButtonImage forState:UIControlStateNormal];
    [messagesButtonPh addTarget:self action:@selector(messagesPressed) forControlEvents:UIControlEventTouchUpInside];*/
    
    
    //Creation of TakePicture button
    shootButtonPh = [UIButton buttonWithType:UIButtonTypeCustom];
    shootButtonPh.frame = CGRectMake(0.5*screenWidth-0.5*xButton2,screenHeight-110,xButton2,yButton2);
    shootButtonPh.backgroundColor = [UIColor clearColor];
    //[shootButton setTitle:@"Shoot" forState:UIControlStateNormal];
    //[shootButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    UIImage *shootButtonImage = [UIImage imageNamed:@"CameraShootSmall.png"];
    shootButtonImage = [myGeneralMethods scaleImage3:shootButtonImage withFactor:1.5];
    [shootButtonPh setImage:shootButtonImage forState:UIControlStateNormal];
    shootButtonPh.enabled = YES;
    [shootButtonPh addTarget:self action:@selector(pressTakePictureButton) forControlEvents:UIControlEventTouchUpInside];
    
    int xButton3 = 100;
    int yButton3 = 100;
    //Creation of flash button
    flashButtonPh = [UIButton buttonWithType:UIButtonTypeCustom];
    flashButtonPh.frame = CGRectMake(0.15*screenWidth-0.5*xButton3,50-0.5*yButton3,xButton3,yButton3);
    flashButtonPh.backgroundColor = [UIColor clearColor];
    //[shootButton setTitle:@"Shoot" forState:UIControlStateNormal];
    //[shootButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    UIImage *flashButtonImage = [UIImage imageNamed:@"flash_off.png"];
    flashButtonImage = [myGeneralMethods scaleImage3:flashButtonImage withFactor:1.7];
    [flashButtonPh setImage:flashButtonImage forState:UIControlStateNormal];
    [flashButtonPh addTarget:self action:@selector(flashPressed) forControlEvents:UIControlEventTouchUpInside];
    
    
    int xButton4 = 100;
    int yButton4 = 100;
    //Creation of frontCamera
    frontButtonPh = [UIButton buttonWithType:UIButtonTypeCustom];
    frontButtonPh.frame = CGRectMake(0.84*screenWidth-0.5*xButton4,50-0.5*yButton4,xButton4,yButton4);
    frontButtonPh.backgroundColor = [UIColor clearColor];
    UIImage *frontButtonImage = [UIImage imageNamed:@"front.png"];
    frontButtonImage = [myGeneralMethods scaleImage3:frontButtonImage withFactor:2.65];
    [frontButtonPh setImage:frontButtonImage forState:UIControlStateNormal];
    [frontButtonPh addTarget:self action:@selector(frontCameraPressed) forControlEvents:UIControlEventTouchUpInside];
    
    /*
    int xButton5 = 100;
    int yButton5 = 100;
    //Creation of Keo button
    keoButtonPh = [UIButton buttonWithType:UIButtonTypeCustom];
    keoButtonPh.frame = CGRectMake(0.84*screenWidth-0.5*xButton5,screenHeight-52-0.5*yButton5,xButton5,yButton5);
    keoButtonPh.backgroundColor = [UIColor clearColor];
    UIImage *keoButtonImage = [UIImage imageNamed:@"spirale-white.png"];
    keoButtonImage = [myGeneralMethods scaleImage3:keoButtonImage withFactor:2.4];
    [keoButtonPh setImage:keoButtonImage forState:UIControlStateNormal];
    [keoButtonPh addTarget:self action:@selector(keoPressed) forControlEvents:UIControlEventTouchUpInside];*/
    
    int xButton6 = 100;
    int yButton6 = 100;
    //Creation of Send button
    sendButtonPh = [UIButton buttonWithType:UIButtonTypeCustom];
    sendButtonPh.frame = CGRectMake(0.5*screenWidth-0.5*xButton6,screenHeight-110,xButton6,yButton6);
    sendButtonPh.backgroundColor = [UIColor clearColor];
    UIImage *sendButtonImage = [UIImage imageNamed:@"Send.png"];
    sendButtonImage = [myGeneralMethods scaleImage3:sendButtonImage withFactor:1.5];
    [sendButtonPh setImage:sendButtonImage forState:UIControlStateNormal];
    [sendButtonPh.titleLabel setFont:[UIFont systemFontOfSize:20]];
    sendButtonPh.hidden = NO;
    [sendButtonPh addTarget:self action:@selector(sendPressed) forControlEvents:UIControlEventTouchUpInside];
    
    /*
    int xButton11 = 200;
    int yButton11 = 25;
    //creation of label chat
    CGRect rectLabChat = CGRectMake(0.07*screenWidth,screenHeight-1.08*yButton11,xButton11,yButton11);
    labelChatPh = [[UILabel alloc] initWithFrame: rectLabChat];
    [labelChatPh setTextAlignment:NSTextAlignmentLeft];
    [labelChatPh setTextColor:[UIColor whiteColor]];
    [labelChatPh setFont:[UIFont systemFontOfSize:14]];
    labelChatPh.text = @"Message";
    
    
    int xButton12 = 200;
    int yButton12 = 25;
    //creation of label timeline
    CGRect rectLabKeo = CGRectMake(0.84*screenWidth-0.5*xButton12,screenHeight-1.08*yButton12,xButton12,yButton12);
    labelKeoPh = [[UILabel alloc] initWithFrame: rectLabKeo];
    [labelKeoPh setTextAlignment:NSTextAlignmentCenter];
    [labelKeoPh setTextColor:[UIColor whiteColor]];
    [labelKeoPh setFont:[UIFont systemFontOfSize:14]];
    labelKeoPh.text = @"Timeline";*/
    
    int xButton13 = 100;
    int yButton13 = 50;
    //Creation of Cancel button
    cancelButtonPh = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButtonPh.frame = CGRectMake(0.12*screenWidth-0.5*xButton13,15,xButton13,yButton13);
    cancelButtonPh.backgroundColor = [UIColor clearColor];
    UIImage *cancelButtonImage = [UIImage imageNamed:@"croix-annuler4.png"];
    cancelButtonImage = [myGeneralMethods scaleImage3:cancelButtonImage withFactor:3.5];
    [cancelButtonPh setImage:cancelButtonImage forState:UIControlStateNormal];
    cancelButtonPh.hidden = NO;
    [cancelButtonPh addTarget:self action:@selector(cancelPressed) forControlEvents:UIControlEventTouchUpInside];
    
    int xButton14 = 100;
    int yButton14 = 25;
    //creation of label Cancel
    CGRect rectLabCancel = CGRectMake(0.12*screenWidth-0.52*xButton14,42+0.5*yButton14,xButton14,yButton14);
    labelCancelPh = [[UILabel alloc] initWithFrame: rectLabCancel];
    [labelCancelPh setTextAlignment:NSTextAlignmentCenter];
    [labelCancelPh setTextColor:[UIColor whiteColor]];
    [labelCancelPh setFont:[UIFont systemFontOfSize:14]];
    labelCancelPh.text = @"Cancel";
    labelCancelPh.hidden = NO;
    //labelCancel.shadowColor = [UIColor blackColor];
    //labelCancel.shadowOffset = CGSizeMake(0, 0);
    //[labelCancel setHighlighted:YES];
    //labelCancel.highlightedTextColor = [UIColor blackColor];
    
    
    //Creation of ImagePicker button
    imagePickerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    imagePickerButton.frame = CGRectMake(0.88*screenWidth-0.5*xButton15,0.92*screenHeight-0.5*yButton15,xButton15,yButton15);
    imagePickerButton.backgroundColor = [UIColor clearColor];
    UIImage *imagePickerButtonImage = [UIImage imageNamed:@"galleryImage.png"];
    imagePickerButtonImage = [myGeneralMethods scaleImage3:imagePickerButtonImage withFactor:5];
    [imagePickerButton setImage:imagePickerButtonImage forState:UIControlStateNormal];
    [imagePickerButton addTarget:self action:@selector(pickImageFromGallery) forControlEvents:UIControlEventTouchUpInside];
    
    
    int colorButtonSize = 40;
    colorButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [colorButton addTarget:self action:@selector(colorButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    colorButton.frame = CGRectMake(screenWidth-50, 20, colorButtonSize,colorButtonSize);
    colorButton.clipsToBounds = YES;
    colorButton.backgroundColor = [myGeneralMethods getColorFromHexString:self.colorArray[colorCounter]];
    colorButton.layer.cornerRadius = colorButtonSize/2.0f;
    colorButton.layer.borderColor=[UIColor whiteColor].CGColor;
    colorButton.layer.borderWidth=2.0f;
    
    [self.view addSubview:imagePickerButton];
    [self.view addSubview:shootButtonPh];
    //[self.view addSubview:messagesButtonPh];
    [self.view addSubview:frontButtonPh];
    //[self.view addSubview:keoButtonPh];
    [self.view addSubview:flashButtonPh];
    
    //[self.view addSubview:labelChatPh];
    //[self.view addSubview:labelKeoPh];
    
    [self.view bringSubviewToFront:keoTextFieldPh];
    [self.view bringSubviewToFront:colorButton];
    
}

//--------------------change color of textfield---------------------
-(void)colorButtonTapped{
    colorCounter +=1;
    if(!(colorCounter < [self.colorArray count])){
        colorCounter = 0;
    }
    UIColor *newColor = [myGeneralMethods getColorFromHexString:self.colorArray[colorCounter]];
    keoTextFieldPh.backgroundColor = newColor;
    colorButton.backgroundColor = newColor;
}


//-------------------pick image from gallery------------------------------

-(void)pickImageFromGallery{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    myImageViewPh.image = chosenImage;
    
    chosenImage = [myGeneralMethods scaleImage:chosenImage];
    galleryFrame = CGRectMake(0, 0.5*screenHeight-0.5*chosenImage.size.height, screenWidth, chosenImage.size.height);
    galleryOrCamera = @"Gallery";
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"takepictureWorked" object: nil];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

//------------searches the front camera--------------------------------------
- (AVCaptureDevice *)frontCamera {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == AVCaptureDevicePositionFront) {
            return device;
        }
    }
    return nil;
}



//--------------------adapt the size of the textfield to the text contained (not very fluid)-------------------------
#define MAXLENGTH 50
- (BOOL)textField:(UITextField *) textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    
    BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
    
    //-----adapt size of textfield
    
    UIFont *lfont = [UIFont systemFontOfSize:16];
    
    CGSize textViewSize = [myGeneralMethods text:keoTextFieldPh.text sizeWithFont:lfont constrainedToSize:CGSizeMake(screenWidth-20, 30)];
    
    keoTextFieldPh.frame = CGRectMake(keoTextFieldPh.frame.origin.x, keoTextFieldPh.frame.origin.y, textViewSize.width+30, textViewSize.height+10);
    //
    
    return newLength <= MAXLENGTH || returnKey;
}


//---------SMS (in order to alert people who don't have the app)------------
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end

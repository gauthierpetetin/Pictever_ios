//
//  PhotoDetail.m
//  Keo
//
//  Created by Gauthier Petetin on 14/07/2014.
//  Copyright (c) 2014 Gauthier Petetin. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////(GO TO APPDELEGATE.M FOR MORE INFO ABOUT THE GLOBAL VARIABLES)/////////////////////////////////

#import "PhotoDetail.h"
#import "myGeneralMethods.h"
#import "ShyftMessage.h"

@interface PhotoDetail ()

@end

@implementation PhotoDetail

//-----size if the screen-----------
CGFloat screenWidth;//global
CGFloat screenHeight;//global

NSMutableDictionary * selectedLocalDic;//global    ---------message that has to be shown in full screen

UIImageView *bigPhotoImgV;
UITextView *bigKeoTextView;

//----colors---------------------
UIColor *theBackgroundColor;//global
UIColor *theBackgroundColorDarker;//global
UIColor *theKeoOrangeColor;//global

bool zoomOn;//global

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    // Do any additional setup after loading the view.
    bigPhotoImgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    bigPhotoImgV.contentMode = UIViewContentModeCenter;
    
    int textViewHeight = screenHeight;
    bigKeoTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, 0.5*screenHeight - 0.5*textViewHeight, screenWidth-20, textViewHeight)];
    bigKeoTextView.textAlignment = NSTextAlignmentCenter;
    [bigKeoTextView setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:20]];
    bigKeoTextView.textColor = [UIColor whiteColor];
    bigKeoTextView.backgroundColor = [UIColor clearColor];
    bigKeoTextView.editable = NO;
    [bigKeoTextView addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
    
    [self.view addSubview:bigPhotoImgV];
    
    if(_shyftToDetail){
        if(_shyftToDetail.message){
            //------------------if message is a photo---------------------------------
            if([_shyftToDetail.message isEqualToString:@""]){
                if(_shyftToDetail.uiControl){
                    APLLog([_shyftToDetail getDescription]);
                    
                    bigPhotoImgV.image = [PhotoDetail scaleImageForDetail:_shyftToDetail.uiControl];
                    //bigPhotoImgV.image = [PhotoDetail scaleImageForDetail:[KeoMessages prepareImageForExport:_shyftToDetail.uiControl withLabel:_shyftToDetail.receive_label]];
                }
            }
            //-----------------if messages is a text message------------------------
            else{
                UIColor *colorForBackground = _shyftToDetail.color;
                if(!colorForBackground){
                    APLLog(@"no color for background");
                    colorForBackground = [myGeneralMethods getColorFromHexString:@"008b8b"];
                }
                UIImage *receivedImage2 = [PhotoDetail imageWithColor:colorForBackground];
                [self.view addSubview:bigPhotoImgV];
                bigPhotoImgV.image = receivedImage2;
                
                if([_shyftToDetail.photo isEqualToString:@"download_error"]){
                    bigKeoTextView.text = @"Download Error";
                }
                else{
                    bigKeoTextView.text = _shyftToDetail.message;
                }
                [self.view addSubview:bigKeoTextView];
            }
        }
    }
    
    ////////Create tap gesture recognizer
    UITapGestureRecognizer *tapRecognizer4 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondToTapGesture4:)];
    tapRecognizer4.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tapRecognizer4];
    //////////
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {//maybe not used
    UITextView *txtview = object;
    CGFloat topoffset = ([txtview bounds].size.height - [txtview contentSize].height * [txtview zoomScale])/2.0;
    topoffset = ( topoffset < 0.0 ? 0.0 : topoffset );
    txtview.contentOffset = (CGPoint){.x = 0, .y = -topoffset};
}

//------------scale image-----------------------------

+ (UIImage*) scaleImageForDetail:(UIImage*)image{
    CGSize scaledSize = CGSizeMake(image.size.width, image.size.height);
    
    CGFloat scaleFactor = scaledSize.height / scaledSize.width;
    
    CGFloat screenScaleFactor = screenHeight / screenWidth;
    
    if(scaleFactor < screenScaleFactor){
        scaledSize.width = screenWidth;
        scaledSize.height = screenWidth * scaleFactor;
    }
    else{
        scaledSize.height = screenHeight;
        scaledSize.width = screenHeight / scaleFactor;
    }
    UIGraphicsBeginImageContextWithOptions( scaledSize, NO, 0.0 );
    CGRect scaledImageRect = CGRectMake( 0.0, 0.0, scaledSize.width, scaledSize.height );
    [image drawInRect:scaledImageRect];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //zoomOn = false;
    [bigKeoTextView removeObserver:self forKeyPath:@"contentSize"];
    [bigKeoTextView removeFromSuperview];
    [bigPhotoImgV removeFromSuperview];
}

//---------------leave full screen by touching the screen --------------------------------

- (IBAction)respondToTapGesture4:(UITapGestureRecognizer *)recognizer{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//---------------creates background image for the text messages-------------------------

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, screenWidth, screenHeight);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

@end

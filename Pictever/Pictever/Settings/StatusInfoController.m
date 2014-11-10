//
//  StatusInfoController.m
//  Shyft
//
//  Created by Gauthier Petetin on 16/08/2014.
//  Copyright (c) 2014 Gauthier Petetin. All rights reserved.
//

#import "StatusInfoController.h"

@interface StatusInfoController ()

@end

@implementation StatusInfoController


NSString *backgroundImage;//global

CGFloat screenWidth;//global
CGFloat screenHeight;//global

UILabel *infoTitleLabel;

UILabel *infoLabel1;
UILabel *infoLabel2;
UILabel *infoLabel3;
UILabel *infoLabel4;

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
    // Do any additional setup after loading the view.
    
    
    //--------------We print the information for the user about how he can increase his status------------------------
    
    self.view.backgroundColor=[[UIColor alloc] initWithPatternImage:[UIImage imageNamed:backgroundImage]];
    
    /*
    int buttonWidth11 = 0.85*screenWidth;
    infoTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.5*screenWidth-0.5*buttonWidth11, 35, buttonWidth11,60)];
    infoTitleLabel.textAlignment = NSTextAlignmentCenter;
    infoTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    infoTitleLabel.numberOfLines = 0;
    infoTitleLabel.textColor = [UIColor orangeColor];
    infoTitleLabel.font = [infoTitleLabel.font fontWithSize:26];
    infoTitleLabel.backgroundColor = [UIColor clearColor];
    infoTitleLabel.text = @"Status Info";
    
    [self.view addSubview:infoTitleLabel];*/
    
    
    int buttonWidth12 = 0.85*screenWidth;
    infoLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(0.5*screenWidth-0.5*buttonWidth12, 95, buttonWidth12,60)];
    infoLabel1.textAlignment = NSTextAlignmentCenter;
    infoLabel1.lineBreakMode = NSLineBreakByWordWrapping;
    infoLabel1.numberOfLines = 0;
    infoLabel1.textColor = [UIColor grayColor];
    infoLabel1.font = [infoTitleLabel.font fontWithSize:20];
    infoLabel1.backgroundColor = [UIColor clearColor];
    infoLabel1.text = @"Your status depends on your Pictever counter:";
    
    [self.view addSubview:infoLabel1];
    
    int buttonWidth13 = 0.85*screenWidth;
    infoLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(0.5*screenWidth-0.5*buttonWidth13, 175, buttonWidth13,60)];
    infoLabel2.textAlignment = NSTextAlignmentCenter;
    infoLabel2.lineBreakMode = NSLineBreakByWordWrapping;
    infoLabel2.numberOfLines = 0;
    infoLabel2.textColor = [UIColor grayColor];
    infoLabel2.font = [infoTitleLabel.font fontWithSize:20];
    infoLabel2.backgroundColor = [UIColor clearColor];
    infoLabel2.text = @"- your counter increases when you send a message in the future";
    
    [self.view addSubview:infoLabel2];
    
    int buttonWidth14 = 0.85*screenWidth;
    infoLabel3 = [[UILabel alloc] initWithFrame:CGRectMake(0.5*screenWidth-0.5*buttonWidth14, 240, buttonWidth14,60)];
    infoLabel3.textAlignment = NSTextAlignmentCenter;
    infoLabel3.lineBreakMode = NSLineBreakByWordWrapping;
    infoLabel3.numberOfLines = 0;
    infoLabel3.textColor = [UIColor grayColor];
    infoLabel3.font = [infoTitleLabel.font fontWithSize:20];
    infoLabel3.backgroundColor = [UIColor clearColor];
    infoLabel3.text = @"- your counter decreases when these messages are received";
    
    [self.view addSubview:infoLabel3];
    
    int buttonWidth15 = 0.85*screenWidth;
    
    
    infoLabel4 = [[UILabel alloc] initWithFrame:CGRectMake(0.5*screenWidth-0.5*buttonWidth15, 375, buttonWidth15,100)];
    infoLabel4.textAlignment = NSTextAlignmentCenter;
    infoLabel4.lineBreakMode = NSLineBreakByWordWrapping;
    infoLabel4.numberOfLines = 0;
    infoLabel4.textColor = [UIColor grayColor];
    infoLabel4.font = [infoTitleLabel.font fontWithSize:20];
    infoLabel4.backgroundColor = [UIColor clearColor];
    infoLabel4.text = @"Tip: the best way to reach the next status is to send messages to many people in a far-distant future;)";
    
    NSMutableAttributedString *text =
    [[NSMutableAttributedString alloc]
     initWithAttributedString: infoLabel4.attributedText];
    
    [text addAttribute:NSForegroundColorAttributeName
                 value:[UIColor orangeColor]
                 range:NSMakeRange(49, 52)];
    [infoLabel4 setAttributedText: text];
    
    [self.view addSubview:infoLabel4];
    
    
    ////////Create tap gesture recognizer
    UITapGestureRecognizer *tapRecognizer5 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondToTapGesture5:)];
    tapRecognizer5.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tapRecognizer5];
    //////////
}

- (IBAction)respondToTapGesture5:(UITapGestureRecognizer *)recognizer{
    //[self dismissViewControllerAnimated:NO completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

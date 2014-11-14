//
//  WriteMessage2.m
//  Keo
//
//  Created by Gauthier Petetin on 23/06/2014.
//  Copyright (c) 2014 Gauthier Petetin. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////(GO TO APPDELEGATE.M FOR MORE INFO ABOUT THE GLOBAL VARIABLES)/////////////////////////////////

#import "WriteMessage2.h"


#import "ShyftSet.h"
#import "ShyftMessage.h"

#import "NewBucketRequest.h"
#import "GPSession.h"
#import "GPRequests.h"

#import "myConstants.h"
#import "myGeneralMethods.h"

#import <AWSiOSSDKv2/AWSMobileAnalytics.h>
#import <AWSiOSSDKv2/AWSCore.h>
@interface WriteMessage2 ()

@end

@implementation WriteMessage2

AWSMobileAnalytics* analytics;//global

ShyftSet *myShyftSet;//global

NSUserDefaults *prefs;//global

NSString *username;//global
bool logIn;
NSString *myStatus;//global
NSString *adresseIp2;//global
NSString *hashPassword;//global

NSString *mytimeStamp;//global

NSMutableArray *messagesDataFile;

NSString *storyboardName;//global

bool appOpenedOnNotification;//global

GPSession *myUploadContactSession;//global

//size if the screen
CGFloat screenWidth;//global
CGFloat screenHeight;//global
CGFloat tabBarHeight;//global

NSString *backgroundImage;//global
bool firstGlobalOpening;//global

NSMutableArray *sendToMail;//global
NSString *sendToName;//global
NSString *sendToDate;//global
NSString *sendToDateAsText;//global
NSString *sendToTimeStamp;//global

NSMutableDictionary *importKeoOccurences;//global
NSMutableArray *importContactsData; //global
NSMutableArray *importKeoChoices;//global
NSMutableDictionary *importKeoContacts;//global
NSMutableDictionary *importKeoPhotos;//global

int openingWindow;//global

UITextView *myTextView;
UILabel *hideRectangle;
UIButton *sendButton;

NSString *destinataire3;

float uploadProgress;//global

NSString *alertTitle;
NSString *alertMessage;

bool messageIsKeoPhoto;
bool photoLoaded;
bool showDatePicker;//global

int initialOriginY;

//-----colors-------
UIColor *theBackgroundColor;//global
UIColor *theKeoOrangeColor;//global
UIColor *theBackgroundColorDarker;//global

int topBarHeight;

NSTimer *testTimer;
NSTimer *vibrateTimer;

bool userCanAskNewMessages;

bool sendKeo;//global

bool uploadPhotoOnCloudinary;//global

UIProgressView *progressView3;

NSString* lastLabelSelected;//global

NSString *textViewInitialMessage;

bool sendSMS;

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
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:backgroundImage]];
    
    textViewInitialMessage = @"Share a thought to remember!";
    
    if(firstGlobalOpening){
        APLLog(@"FIRST MESSAGE OPENING");
        userCanAskNewMessages = true;
        [self.tabBarController setSelectedIndex:2]; //load Keo at first opening
        [[NSNotificationCenter defaultCenter]removeObserver:self];
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(askNewMessages2) name:@"askNewMessages2" object: nil];
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(hideProgressBar3) name:@"hideProgressBars" object: nil];
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(updateUploadProgress3:) name:@"uploadProgress" object: nil];
        
        //[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(receiveAllMessagesTogether:) name:@"receiveAllMessagesTogether" object: nil];
        
        //-------------progressview to inform the user a photo is actually being uploaded (in Takepicture2.m)
        progressView3 = [[UIProgressView alloc] init];
        progressView3.frame = CGRectMake(0,64,screenWidth,2);
        [progressView3 setProgressTintColor:[UIColor orangeColor]];
        [progressView3 setUserInteractionEnabled:NO];
        [progressView3 setProgressViewStyle:UIProgressViewStyleBar];
        [progressView3 setTrackTintColor:[UIColor clearColor]];
    }
    
    // If the app just opened, we switch directly to the chat view
    
    if(openingWindow == 1){
        [self.tabBarController setSelectedIndex:1];
        openingWindow = 0;
    }
    if(openingWindow == 2){
        [self.tabBarController setSelectedIndex:2];
        openingWindow = 0;
    }
    
    
    //--------------------text view to type the message---------------------
    //topBarHeight = 62;
    topBarHeight = 0;
    //myTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, topBarHeight+100, screenWidth, screenHeight-tabBarHeight-topBarHeight-100)];//41
    myTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, topBarHeight+70, screenWidth-20, 180)];
    myTextView.backgroundColor = [UIColor clearColor];
    myTextView.text  = textViewInitialMessage;
    myTextView.textColor = [UIColor grayColor];
    myTextView.textAlignment = NSTextAlignmentCenter;
    myTextView.returnKeyType = UIReturnKeyDone;
    
    initialOriginY = myTextView.frame.origin.y;
    myTextView.delegate = self;
    [myTextView setFont:[UIFont systemFontOfSize:19]];
    [self.view addSubview:myTextView];
    
    //--------------initialize labels and buttons--------
    [self initializeView];
    
    //------------------ask the server if new messages have been received------------
    [self askNewMessages2];
}

-(void)hideProgressBar3{
    APLLog(@"hideProgressBar3");
    progressView3.hidden = YES;
}

//-------------progressview to inform the user a photo is actually being uploaded (in Takepicture2.m)-----
-(void)updateUploadProgress3:(NSNumber *)number{
    APLLog(@"updateUploadProgress3: %f",uploadProgress);
    [progressView3 setProgress:uploadProgress animated:YES];
}


-(void)viewDidAppear:(BOOL)animated{
    APLLog(@"WriteMessage2 did appear");
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(initializeView) name:@"initializeViewM" object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(insertNewRow:) name:@"insertNewRow" object: nil];
    //[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(receiveAllMessagesTogether:) name:@"receiveAllMessagesTogether" object: nil];
    
    //[self setTabBarVisible:YES animated:YES];
    
    //------------------replace the tabbar in case it is not--------------
    CGRect frame2 = self.tabBarController.tabBar.frame;
    CGFloat height2 = frame2.size.height;
    
    // zero duration means no animation
    CGFloat duration = (animated)? 0.3 : 0.0;
    [UIView animateWithDuration:duration animations:^{
        self.tabBarController.tabBar.frame = CGRectMake(0, screenHeight-height2, frame2.size.width, frame2.size.height);
    }];
    
    
    APLLog(@"WriteMessage2 did appear over");
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"initializeViewM" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"insertNewRow" object:nil];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"receiveAllMessagesTogether" object:nil];
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

//-----------switch view, go to the gallery------------------
-(void)switchScreenToKeo{
    openingWindow = 2;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:my_storyboard_master_controller];
    
    [self presentViewController:vc animated:NO completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//-------------timer such that we don't ask 2 times for new messages within 3 seconds (if we do we can receive a message twice)---------
-(void)canAskNewMessages:(NSTimer*) tt{
    userCanAskNewMessages = true;
}

//-------------adapt the size of the text view to its content -------- show contacts when return is pressed-----------------
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]) {
        [myTextView resignFirstResponder];
        
        if(![myTextView.text isEqualToString:@""]){
            if(![myTextView.text isEqualToString:textViewInitialMessage]){
                //[self.view addSubview:sendButton];
                
                sendToDateAsText = @"";
                sendToName = @"";
                
                [self sendPressed];
            }
        }
        else{
            myTextView.text = textViewInitialMessage;
            myTextView.textColor = [UIColor grayColor];
        }
        
        
        return NO;
    }
    
    //NSUInteger oldLength = [myTextView.text length];
    //NSUInteger replacementLength = [text length];
    //NSUInteger rangeLength = range.length;
    
    //adapt size of textfield
    //CGSize textViewSize = [myTextView.text sizeWithFont:[UIFont fontWithName:@"Marker Felt" size:20]
    //                                    constrainedToSize:CGSizeMake(screenWidth-100, 180)
    //                                        lineBreakMode:NSLineBreakByTruncatingTail];
    
    /*if([myTextView.text isEqualToString:@""]){
     //myTextView.frame = CGRectMake(0.5*screenWidth-0.5*150, initialOriginY,MAX(textViewSize.width+70,150), MAX(21,textViewSize.height+10));
     APLLog(@"if");
     }
     else{
     if(textViewSize.height > 100){
     myTextView.frame = CGRectMake(0.5*screenWidth-0.5*myTextView.frame.size.width, initialOriginY+86-textViewSize.height, MAX(textViewSize.width+70,150), MAX(21,textViewSize.height+10));
     APLLog(@"else if");
     }
     else{
     myTextView.frame = CGRectMake(0.5*screenWidth-0.5*myTextView.frame.size.width, initialOriginY,MAX(textViewSize.width+70,150), MAX(21,textViewSize.height+10));
     APLLog(@"else else");
     }
     }*/
    //APLLog(@"myTextView frame: %f %f %f %f", myTextView.frame.origin.x, myTextView.frame.origin.y, myTextView.frame.size.width, myTextView.frame.size.height);
    
    return YES;
}


//--------------text view is edited----------------------
- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([myTextView.text isEqualToString:textViewInitialMessage]) {
        myTextView.text = @"";
        myTextView.textColor = [UIColor blackColor]; //optional
    }
    [textView becomeFirstResponder];
}

//-------------show the UIactionsheet with the send_choices (imported by the server in importKeoChoices)-----------------
-(void)timePressed{
    APLLog(@"timePressed");
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
    
    NSLog(@"actionsheet with all buttons ok");
    
    //[actionSheet showInView:self.view];
    
    //[actionSheet showFromTabBar:self.tabBarController.tabBar];
    
    [actionSheet showInView:[[UIApplication sharedApplication].delegate window]];
    
    NSLog(@"timepressed over");
}



//--------------change the colors of the UIActionSheet choices (not working on iOS 8)

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    for (UIView *subview in actionSheet.subviews) {
        APLLog(@"NEW OPTION %@",[[subview class] description]);
        if ([subview isKindOfClass:[UIButton class]]) {
            APLLog(@"change color");
            UIButton *button = (UIButton *)subview;
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        }
        
    }
}



//------------------present contacts to choose recipient----------------------------
-(void)switchScreenToContacts{
    NSMutableArray *jsonOfContatPhonesArray = [myGeneralMethods createJsonArrayOfContacts];//array containing all the phonenumbers to send to the server
    
    APLLog(@"Size of json contact array: %d",[jsonOfContatPhonesArray count]);
    APLLog([NSString stringWithFormat:@"importcontactsdata length : %lu", (unsigned long)[importContactsData count]]);
    
    
    
    //we send the array to the server to ask him which contact have the application
    [myUploadContactSession uploadContacts:jsonOfContatPhonesArray withTableViewReload:YES for:self];
    
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:my_storyboard_pickContact_Name];
    [self presentViewController:vc animated:YES completion:nil];
}


-(void)viewWillAppear:(BOOL)animated{
    APLLog(@"WriteMessage2 will appear");
    [super viewWillAppear:animated];
    
    //-------------progressview to inform the user a photo is actually being uploaded (in Takepicture2.m)-----
    [progressView3 setProgress:uploadProgress animated:NO];
    if(uploadPhotoOnCloudinary){
        APLLog(@"showProgressview3: %f",uploadProgress);
        progressView3.hidden = NO;
    }
    else{
        APLLog(@"hideProgressView3");
        progressView3.hidden = YES;
    }
    [self.view addSubview:progressView3];
    
    //--------when the user has chosen the recipients, he arrives back on the view and we need to show him the UIactionsheet with the send_choices
    
    if(showDatePicker && [sendToDateAsText isEqualToString:@""]&&([sendToMail count]>0)){
        [self timePressed];
    }
    else if(sendKeo){
        [self sendPressed];
        sendKeo = false;
    }
    else{
        [myTextView becomeFirstResponder];
    }
    showDatePicker = false;
    
}

//---------------------------if the recipient and the send send_choice (in 3 days, in 3 weeks) are chosen, send the message!------------
-(void)sendPressed{
    
    APLLog(@"SENDPRESSED");
    if([GPRequests connected]){
        if(![myTextView.text isEqualToString:textViewInitialMessage]){
            if([sendToName isEqualToString:@""]){
                [self switchScreenToContacts];
            }
            else{
                if([sendToDateAsText isEqualToString:@""]){
                    [self timePressed];
                }
                else{
                    if([sendToMail count] > 0){
                        destinataire3 = [self stringFromArray:sendToMail];
                        if(![sendToDate isEqualToString:@""]){
                            APLLog([NSString stringWithFormat:@"Send to friend: %@  at date: %@", destinataire3, sendToDateAsText]);
                            
                            [self sendPostRequestAtDate:sendToDate];
                            
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
            }
        }
        else{
            UIAlertView *alert5 = [[UIAlertView alloc]
                                   initWithTitle:@"Empty text"
                                   message:@"Please type your message first" delegate:self
                                   cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert5 show];
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

//-------------inform amazon analytics a message was sent (for our own statistics)---------------------------
-(void)alertAnalyticsTextMessageSent{
    APLLog(@"alertAnalytics message");
    id<AWSMobileAnalyticsEventClient> eventClient = analytics.eventClient;
    id<AWSMobileAnalyticsEvent> levelEvent = [eventClient createEventWithEventType:@"iosTextMessageSent"];
    [levelEvent addAttribute:[NSString stringWithFormat:@"%lu",(unsigned long)[sendToMail count]] forKey:@"number_of_receivers"];
    [levelEvent addAttribute:lastLabelSelected forKey:@"send_label"];
    APLLog(@"levelevent:%@",[[levelEvent allAttributes] description]);
    [eventClient recordEvent:levelEvent];
    [eventClient submitEvents];
}


//----------------------Send the message--------------------------------------------
-(void) sendPostRequestAtDate:(NSString *) theDateToSend{
    
    NSString *locKeoTime = [self stringForKeoChoice:sendToDate withParameter:sendToTimeStamp];
    [[[GPSession alloc] init] sendRequest:myTextView.text to:destinataire3 withPhotoString:@"" withKeoTime:locKeoTime for:self];
    
    //[sendButton removeFromSuperview];
    
    [self alertNonShyftUsersPerSMS];
    
    [self alertAnalyticsTextMessageSent];
}


//------if contacts that don't have the app where selected, alert them with a sms-------
-(void)alertNonShyftUsersPerSMS{
    
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
            //[self presentModalViewController:controller animated:YES];
            [self presentViewController:controller animated:YES completion:nil];
        }
        sendSMS = false;
    }
    
}


//-------------------initialize the button and the variables------------------------

-(void)initializeView{
    sendToMail = [[NSMutableArray alloc] init];
    sendToName = @"";
    sendToDate = @"";
    sendToDateAsText = @"";
    
    //myTextView.backgroundColor = [UIColor whiteColor];
    myTextView.textColor = [UIColor grayColor];
    myTextView.text = textViewInitialMessage;
    //[myTextView setFrame:CGRectMake(0, topBarHeight+100, screenWidth, screenHeight-tabBarHeight-topBarHeight-100)];//41
    [myTextView setFrame:CGRectMake(10, topBarHeight+70, screenWidth-20, 180)];
    myTextView.userInteractionEnabled = YES;
    myTextView.textColor = [UIColor grayColor];
    myTextView.returnKeyType = UIReturnKeySend;
    UITapGestureRecognizer *tapRecognizer3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondToTapGesture2:)];
    tapRecognizer3.numberOfTapsRequired = 1;
    [myTextView addGestureRecognizer:tapRecognizer3];
    
    
    hideRectangle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    hideRectangle.backgroundColor = [UIColor blackColor];
    hideRectangle.alpha = 0.75;
    
    int xButton6 = 100;
    int yButton6 = 100;
    //Creation of Send button
    sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sendButton.frame = CGRectMake(0.5*screenWidth-0.5*xButton6,screenHeight-110-tabBarHeight,xButton6,yButton6);
    sendButton.backgroundColor = [UIColor clearColor];
    UIImage *sendButtonImage = [UIImage imageNamed:@"Send-grey2.png"];
    sendButtonImage = [myGeneralMethods scaleImage3:sendButtonImage withFactor:6];
    [sendButton setImage:sendButtonImage forState:UIControlStateNormal];
    //[sendButton setFont:[UIFont systemFontOfSize:20]];
    [sendButton addTarget:self action:@selector(sendPressed) forControlEvents:UIControlEventTouchUpInside];
    
    ////////Create tap gesture recognizer
    //UITapGestureRecognizer *tapRecognizer2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondToTapGesture2:)];
    //tapRecognizer2.numberOfTapsRequired = 1;
    //[self.view addGestureRecognizer:tapRecognizer2];
    //////////
    
    
}


//--------------the screen is taped to show/hide the keyboard------------------------------

- (IBAction)respondToTapGesture2:(UITapGestureRecognizer *)recognizer{
    APLLog(@"respondToTapGesture2");
    if(myTextView.isFirstResponder){
        [myTextView resignFirstResponder];
        //[self.view addSubview:sendButton];
        sendToDateAsText = @"";
        sendToName = @"";
        if([myTextView.text isEqualToString:@""]){
            myTextView.textColor = [UIColor grayColor];
            myTextView.text = textViewInitialMessage;
        }
    }
    else{
        [myTextView becomeFirstResponder];
    }
}

-(void)cancelPressed2{
    //[sendButton removeFromSuperview];
    [myTextView becomeFirstResponder];
}


//-------------------save the occurences (for the favorites)--------------------------------------------
-(void)saveOccurences:(NSArray *)favContacts{
    for(NSString *idString in favContacts){
        if ([[idString substringToIndex:2] isEqualToString:@"id"]) {
            NSString *idString2 = [idString substringFromIndex:2];
            int occurenceCounter = 0;
            if([importKeoOccurences objectForKey:idString2]){
                if(![[importKeoOccurences objectForKey:idString2] isEqualToString:@""]){
                    occurenceCounter = [[importKeoOccurences objectForKey:idString2] intValue];
                }
            }
            occurenceCounter +=1;
            [importKeoOccurences setObject:[NSString stringWithFormat:@"%d",occurenceCounter] forKey:idString2];
            [prefs setObject:importKeoOccurences forKey:my_prefs_keo_occurences_key];
        }
    }
}

//------------------select a send_choice (in 3 days, in 3 weeks, in a year) in the UIActionSheet--------------

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    sendToDate = @"0";
    if (!(buttonIndex == ([importKeoChoices count]+1))) { // Cancel
        
        if(!(buttonIndex == 0)){ // pickDate
            if(buttonIndex > 0){
                if([importKeoChoices count] > (buttonIndex-1)){
                    sendToDate = [[importKeoChoices objectAtIndex:(buttonIndex-1)] objectForKey:@"key"];
                    sendToDateAsText = [[importKeoChoices objectAtIndex:(buttonIndex-1)] objectForKey:@"send_label"];
                }
            }
            if([sendToMail count] > 0){
                destinataire3 = [self stringFromArray:sendToMail];
                if(![sendToDate isEqualToString:@""]){
                    APLLog([NSString stringWithFormat:@"Send to friend: %@  at date: %@", destinataire3, sendToDateAsText]);
                    lastLabelSelected = sendToDateAsText;
                    [self saveOccurences:sendToMail];
                    [self sendPostRequestAtDate:sendToDate];
                    
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
        else{ //open calendar
            APLLog(@"Calendar selected");
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
            UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"DatePickerPhotoController"];
            APLLog(@"YES");
            [self presentViewController:vc animated:YES completion:nil];
            
            sendToDate = @"calendar";
        }
        
    }
    else{
        APLLog(@"CancelPressed");
        sendToDate = @"";
        sendToMail = [[NSMutableArray alloc] init];
        sendToName = @"";
        sendToDateAsText = @"";
    }
    
}



//-----------------------------Ask for new messages to the server---------------------------

-(void) askNewMessages2{
    APLLog(@"ASKMESSAGES2");
    
    if(logIn){
        if(userCanAskNewMessages){
            userCanAskNewMessages = false;
            testTimer = [NSTimer scheduledTimerWithTimeInterval: 2.0 target: self selector: @selector(canAskNewMessages:) userInfo: nil repeats: NO];
            //[GPRequests askMessagesfor:self withTimeStamp:mytimeStamp];
            [[[GPSession alloc] init] receiveRequest:self];
        }
    }
    APLLog(@"askMessages END");
}




- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo: (void *)contextInfo
{
    APLLog(@"didFinishSavingWithError");
    if (error != nil)
    {
        APLLog(@"Image Can not be saved");
    }
    else
    {
        APLLog(@"Successfully saved Image");
    }
}


//-----------user presses settings-------------------------
- (IBAction)settingsPressed2:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"SettingsScreen"];
    [self presentViewController:vc animated:YES completion:nil];
}

-(NSString *)stringFromArray:(NSMutableArray *)array{
    
    NSError *errorC = nil;
    NSData* jsonData10 = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:&errorC];
    NSMutableString * contactArrString = [[NSMutableString alloc] initWithData:jsonData10 encoding:NSUTF8StringEncoding];
    if(!contactArrString){
        contactArrString = [[NSMutableString alloc]initWithString:@""];
    }
    return contactArrString;
}

//-----------prepare the keo_choice json for the request---------------------------------------

-(NSString *)stringForKeoChoice:(NSString *)choice withParameter:(NSString *)parameter{
    float timezoneoffset = ([[NSTimeZone systemTimeZone] secondsFromGMT] / 3600.0);
    //provisoire (heure d'été)
    timezoneoffset = timezoneoffset - 1;
    //
    NSString *timeZoneOffsetAsString = [NSString stringWithFormat:@"%.0f",timezoneoffset];
    
    
    NSMutableDictionary *choiceDic = [[NSMutableDictionary alloc] init];
    [choiceDic setObject:choice forKey:@"type"];
    [choiceDic setObject:timeZoneOffsetAsString forKey:@"timezone"];
    
    if([choice isEqualToString:@"calendar"]){
        [choiceDic setObject:parameter forKey:@"parameters"];
    }
    else{
        [choiceDic setObject:@"" forKey:@"parameters"];
    }
    
    NSError *errorKeoChoice = nil;
    NSData* jsonData2 = [NSJSONSerialization dataWithJSONObject:choiceDic options:NSJSONWritingPrettyPrinted error:&errorKeoChoice];
    
    NSString *jsonAsString = [[NSString alloc] initWithData:jsonData2 encoding:NSUTF8StringEncoding];
    //APLLog(@"My Keo choices JSON: %@",jsonAsString);
    
    return jsonAsString;
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


//---------------hide/show the tabbar------------------------


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


@end

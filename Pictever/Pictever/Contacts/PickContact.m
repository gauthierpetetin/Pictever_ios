//
//  PickContact.m
//  Keo
//
//  Created by Gauthier Petetin on 25/05/2014.
//  Copyright (c) 2014 Gauthier Petetin. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////(GO TO APPDELEGATE.M FOR MORE INFO ABOUT THE GLOBAL VARIABLES)/////////////////////////////////


#import "PickContact.h"

#import "myConstants.h"

//Amazon analytics
#import <AWSiOSSDKv2/AWSMobileAnalytics.h>
#import <AWSiOSSDKv2/AWSCore.h>

@interface PickContact ()

@property (nonatomic, strong) NSArray *sections;//-------------very usefull, for all the sections
@property (nonatomic, strong) NSArray *sections2;//-------------for alphabet on the side

@end

@implementation PickContact

NSUserDefaults *prefs;

NSString *myCurrentPhoneNumber;//global


//Request
NSString *uploadRequestName;//global
NSInteger uploadLocalErrorCode;//error code response to the request

bool firstContactOpening;//global
bool showDatePicker;//global

NSString *username;//global
NSString *hashPassword;//global
NSString *myStatus;//global

int openingWindow; // glogal
NSString * backgroundImage; //global
NSString *adresseIp2;//global

//size if the screen
CGFloat screenWidth;//global
CGFloat screenHeight;//global
CGFloat tabBarHeight;//global

NSMutableDictionary *importKeoContactsCopy;//local

NSMutableDictionary *importKeoOccurences;//global
NSMutableArray *importContactsData; //global
NSMutableArray *importContactPhones;//global
NSMutableArray *importContactMails;//global
NSMutableArray *importContactIDs;//global
NSMutableDictionary *importKeoContacts;//global
NSMutableArray *localKeoContacts;//global
NSMutableArray *selectedContactArray;//local

NSMutableArray *jsonOfContatPhonesArray;//local  array of all the phone numbers (sent to the server to ask which contact also have the app)

NSMutableDictionary *importKeoPhotos;//global   contains the photos of contacts (the keys are the phone numbers)

NSMutableArray *sendToMail;//global
NSMutableArray *sendToMailCopy;//global
NSString *sendToName;//global
NSString *sendToName2;//local

//------sections-----------
NSMutableArray *importContactsNames;


//-----colors------------
UIColor *theBackgroundColor;//global
UIColor *theKeoOrangeColor;//global
UIColor *lightGrayColor;


bool sendSMS;


- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    // If the app just opened, we switch directly to the chat view

    
    //create sections with alphabetical order
    self.sections = [NSArray arrayWithObjects:@"Pictever", @"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j", @"k", @"l", @"m", @"n", @"o", @"p", @"q", @"r", @"s", @"t", @"u", @"v", @"w", @"x", @"y", @"z", nil];

    self.sections2 = [NSArray arrayWithObjects:@"*", @"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j", @"k", @"l", @"m", @"n", @"o", @"p", @"q", @"r", @"s", @"t", @"u", @"v", @"w", @"x", @"y", @"z", nil];

    
    //-----initialisation of variables-----------
    uploadLocalErrorCode = 0;
    sendToMailCopy = [[NSMutableArray alloc] init];
    lightGrayColor = [UIColor colorWithRed:211/255.0f green:211/255.0f blue:211/255.0f alpha:1.0f];
    
    //we initialize the array containing the contacts who already have the app in order to place them at the top of the tableview
    [PickContact initLocalKeoContacts];
    
    if([importContactsNames count] == 0){
        [PickContact initImportContactNames];
    }
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.parentViewController.view.backgroundColor = theBackgroundColor;
    
    APLLog(@"myContacts-viewdidload-end");
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reloadContactTableView) name:@"reloadContactTableView" object: nil];
    [self.tableView reloadData];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"reloadContactTableView" object:nil];
}

-(void)reloadContactTableView{
    [self.tableView reloadData];
}


+(void)initImportContactNames{
    importContactsNames = [[NSMutableArray alloc] init];
    if(importContactsData){
        for(NSMutableDictionary *dicForFullName in importContactsData){
            if([dicForFullName objectForKey:@"fullName"]){
                [importContactsNames insertObject:[dicForFullName objectForKey:@"fullName"] atIndex:[importContactsNames count]];
            }
            else{
                APLLog(@"EMPTY FULL NAME");
                [importContactsNames insertObject:@"" atIndex:[importContactsNames count]];
            }
        }
    }
}

//---------creates localKeoContacts (array of contacts having the app) and sorts it alphabetically---------
+(void)initLocalKeoContacts{
    localKeoContacts = [[NSMutableArray alloc] init];
    for(NSMutableDictionary *ccc in [importKeoContacts allKeys]){
        NSMutableDictionary *addContact = [[importKeoContacts objectForKey:ccc] mutableCopy];
        [localKeoContacts addObject:addContact];
    }
    
    [PickContact sortLocalKeoContacts];
}

//---------sorts localKeoContacts alphabetically----------------------
+(void)sortLocalKeoContacts{
    APLLog(@"sortLocalKeoContacts: %d",[localKeoContacts count]);
    localKeoContacts = [[PickContact alpabetLocBubbleSort:localKeoContacts] mutableCopy];
    localKeoContacts = [[PickContact favoriteLocBubbleSort:localKeoContacts] mutableCopy];
}

+(NSMutableArray *)alpabetLocBubbleSort: (NSMutableArray *)myKeoContacts{
    APLLog(@"locBubblesort");
    NSMutableArray * myKeoContactsAlphabet = [myKeoContacts mutableCopy];
    NSUInteger num = [myKeoContactsAlphabet count];
    if(num < 2){
        return myKeoContactsAlphabet;
    }
    bool changeDone = true;
    while (changeDone) {
        changeDone=false;
        for(int j =0; j<num-1; j++){
            NSString *firstname1 = [[myKeoContactsAlphabet objectAtIndex:j] objectForKey:@"firstNames"];
            NSString *firstname2 = [[myKeoContactsAlphabet objectAtIndex:(j+1)] objectForKey:@"firstNames"];
            NSString *lastname1 = [[myKeoContactsAlphabet objectAtIndex:j] objectForKey:@"lastNames"];
            NSString *lastname2 = [[myKeoContactsAlphabet objectAtIndex:(j+1)] objectForKey:@"lastNames"];
            if([[lastname1 stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]){
                lastname1 = firstname1;
            }
            if([[lastname2 stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]){
                lastname2 = firstname2;
            }
            if([lastname1 compare:lastname2] == NSOrderedDescending){
                [self locSwitchElements:myKeoContactsAlphabet index1:j index2:j+1];
                changeDone=true;
            }
        }
        num=num-1;
    }
    
    APLLog(@"locBubblesort fin");
    //myKeoContacts = [PickContact placeMyselfOnTop:myKeoContacts];
    
    return myKeoContactsAlphabet;
    
}

+(NSMutableArray *)favoriteLocBubbleSort: (NSMutableArray *)myKeoContacts{
    APLLog(@"locfavBubblesort");
    NSMutableArray * myKeoContactsFavorite = [myKeoContacts mutableCopy];
    NSUInteger num = [myKeoContactsFavorite count];
    if(num < 2){
        return myKeoContacts;
    }
    bool changeDone = true;
    while (changeDone) {
        changeDone=false;
        for(int j =0; j<num-1; j++){
            NSString *user_id1 = [[myKeoContactsFavorite objectAtIndex:j] objectForKey:@"user_id"];
            NSString *user_id2 = [[myKeoContactsFavorite objectAtIndex:(j+1)] objectForKey:@"user_id"];
            int user_id_occurence1 = 0;
            int user_id_occurence2 = 0;
            
            if([importKeoOccurences objectForKey:user_id1]){
                user_id_occurence1 = [[importKeoOccurences objectForKey:user_id1] intValue];
            }
            if([importKeoOccurences objectForKey:user_id2]){
                user_id_occurence2 = [[importKeoOccurences objectForKey:user_id2] intValue];
            }
            
            if(user_id_occurence1 < user_id_occurence2){
                [self locSwitchElements:myKeoContactsFavorite index1:j index2:j+1];
                changeDone=true;
            }
        }
        num=num-1;
    }
    
    APLLog(@"locfavBubblesort fin");
    myKeoContactsFavorite = [PickContact placeMyselfOnTop:myKeoContactsFavorite];
    
    return myKeoContactsFavorite;
    
}


+(void)locSwitchElements: (NSMutableArray *)myArray index1: (int) firstint index2: (int) secondint{
    if(([myArray count] > firstint)&&([myArray count]>secondint)){
        id firstObject = [myArray objectAtIndex:firstint];
        id secondObject = [myArray objectAtIndex:secondint];
        [myArray replaceObjectAtIndex:firstint withObject:secondObject];
        [myArray replaceObjectAtIndex:secondint withObject:firstObject];
    }
}




//-----------the contact "Myself" has to be at the top of the tableview----------------------
+(NSMutableArray *)placeMyselfOnTop:(NSMutableArray *)myKeoContacts3{
//@" Myself" forKey:@"firstNames"
    APLLog(@"placeMyselfOnTop");
    int indexT = [PickContact indexOfContactMyselfInMutableArray:myKeoContacts3];
    NSMutableDictionary *contMyself = [[NSMutableDictionary alloc] init];
    
    if(indexT != -1){
        if([myKeoContacts3 count]>indexT){
            contMyself = [myKeoContacts3 objectAtIndex:indexT];
        }
        
        [myKeoContacts3 removeObjectAtIndex:indexT];
        [myKeoContacts3 insertObject:contMyself atIndex:0];

    }
    return myKeoContacts3;
}

+(NSInteger)indexOfContactMyselfInMutableArray:(NSMutableArray *)myKeoContacts2{
    int indexM = -1;
    if([myKeoContacts2 count]>0){
        for(int k=0; k<[myKeoContacts2 count];k++){
            if([[myKeoContacts2 objectAtIndex:k] objectForKey:@"firstNames"]){
                if([[[myKeoContacts2 objectAtIndex:k] objectForKey:@"firstNames"] isEqualToString:@"Myself"]){
                    indexM = k;
                }
            }
        }
    }
    return indexM;
}





//---------------recipient selected by the user----------------------------------
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    APLLog(@"didSelectRowAtIndexPath");
    NSArray *sectionArray;
    NSInteger myIndex;
    NSMutableDictionary *contactInfoDict2;
    
    //-------people already having the app-----------------
    if(indexPath.section == 0){
        sectionArray = [localKeoContacts copy];
        APLLog(@"section array copied");
        if([sectionArray count]>indexPath.row){
            APLLog(@"indexpath OK");
            //myIndex = [localKeoContacts indexOfObject:[sectionArray objectAtIndex:indexPath.row]];
            //contactInfoDict2 = [localKeoContacts objectAtIndex:myIndex];
            contactInfoDict2 = [sectionArray objectAtIndex:indexPath.row];
            APLLog(@"contactselected: %@", [contactInfoDict2 description]);
        }
    }
    //---------people who don't have the app-----------------
    else{
        sectionArray = [importContactsNames filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF beginswith[c] %@", [self.sections objectAtIndex:indexPath.section]]];
        if([sectionArray count]>indexPath.row){
            myIndex = [importContactsNames indexOfObject:[sectionArray objectAtIndex:indexPath.row]];
            if([importContactsData count]>myIndex){
                contactInfoDict2 = [importContactsData objectAtIndex:myIndex];
            }
            else{//---------------should never happen-------------------
                contactInfoDict2 = [[NSMutableDictionary alloc] init];
                [contactInfoDict2 setObject:@"" forKey:@"firstNames"];
                [contactInfoDict2 setObject:@"" forKey:@"user_id"];
                [contactInfoDict2 setObject:@"" forKey:@"phoneNumber1"];
            }
        }
    }
    

    sendToName2 = [NSString stringWithFormat:@"%@ %@", [contactInfoDict2 objectForKey:@"firstNames"], [contactInfoDict2 objectForKey:@"lastNames"]];

    
    
    //---------if the user has the app we select his user_id and add "id" in front of it---------------
    if([[contactInfoDict2 objectForKey:@"user_id"] length] > 0){
        NSString *pCont = [NSString stringWithFormat:@"id%@",[contactInfoDict2 objectForKey:@"user_id"]];
        if(![selectedContactArray containsObject:sendToName2]){
            [sendToMailCopy addObject:pCont];
            [selectedContactArray addObject:sendToName2];
        }
        else{
            [sendToMailCopy removeObject:pCont];
            [selectedContactArray removeObject:sendToName2];
        }
        
        
        [self.tableView reloadData];
    }
    //---------if the user oesn't have the app we select his user_id and add "num" in front of it---------------
    else{
        //---for the moment we forbid to send messages to users that don't have the app---------------
        if([contactInfoDict2 objectForKey:@"phoneNumber1"]){
            NSString *pCont = [NSString stringWithFormat:@"num%@",[contactInfoDict2 objectForKey:@"phoneNumber1"]];
            if(![selectedContactArray containsObject:sendToName2]){
                [sendToMailCopy addObject:pCont];
                [selectedContactArray addObject:sendToName2];
            }
            else{
                [sendToMailCopy removeObject:pCont];
                [selectedContactArray removeObject:sendToName2];
            }
            [self.tableView reloadData];
            
        }
        
        /*UIAlertView *alert3 = [[UIAlertView alloc]
                               initWithTitle:@"No Shyft Account!"
                               message:@"Invite your friend on Shyft first!" delegate:self
                               cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert3 show];*/
    }
}



//-----------------we update all the contacts after the reception of the answer of the request----------------------
+(void)updateAllContacts:(NSArray *)updateArray{
    APLLog(@"update all contacts");
    importKeoContactsCopy = [[NSMutableDictionary alloc] init];
    for(NSDictionary *oneContact in updateArray){
        NSString *lFbID = @"";
        NSString *lFbName = @"";
        if([oneContact objectForKey:my_uploadContact_facebook_id]){
            lFbID = [oneContact objectForKey:my_uploadContact_facebook_id];
        }
        if([oneContact objectForKey:my_uploadContact_facebook_name]){
            lFbName = [oneContact objectForKey:my_uploadContact_facebook_name];
        }
        [PickContact addKeoAccount:[oneContact objectForKey:my_uploadContact_email] addUserId:[oneContact objectForKey:my_uploadContact_user_id] ToContact:[oneContact objectForKey:my_uploadContact_phoneNumber] andAddStatus:[oneContact objectForKey:my_uploadContact_status] andAddFbID:lFbID andAddFbName:lFbName];
    }
    importKeoContacts = [importKeoContactsCopy mutableCopy];
    [prefs setObject:importKeoContacts forKey:@"importKeoContacts"];
}


//---------------------thanks to the info received (user_id, email, phonenumber), we update the particular user)------------------
+(void)addKeoAccount:(NSString *)keoAccountAdress addUserId:(NSString *)userId ToContact:(NSString *)contactPhoneNumber andAddStatus:(NSString *)contStatus andAddFbID:(NSString*)contactFbId andAddFbName:(NSString *)contactFbName{
    //------------we search in importcontacts data which contact has the same phone number---------
    NSMutableArray *copyImportContactsData = [importContactsData mutableCopy];
    NSMutableArray *indexArray = [[NSMutableArray alloc] init];
    for(int i = 0; i < [copyImportContactsData count]; i++){
        NSMutableDictionary *searchContact = [copyImportContactsData objectAtIndex:i];
        if([[searchContact objectForKey:@"phoneNumber1"] isEqualToString:contactPhoneNumber]){
            NSString *intAsString = [NSString stringWithFormat:@"%d",i];
            [indexArray addObject:intAsString];
        }
        if([[searchContact objectForKey:@"phoneNumber2"] isEqualToString:contactPhoneNumber]){
            NSString *intAsString = [NSString stringWithFormat:@"%d",i];
            [indexArray addObject:intAsString];
        }
    }
    //----------For the contact(s) found, we update the info------------------------
    if([indexArray count]>0){
        for(NSString *myString in indexArray){
            NSMutableDictionary *previousContact = [importContactsData objectAtIndex:[myString intValue]];
            NSMutableDictionary *replacementContact = [[NSMutableDictionary alloc] init];
            [replacementContact setObject:keoAccountAdress forKey:my_uploadContact_email];
            [replacementContact setObject:contactPhoneNumber forKey:my_uploadContact_phoneNumber];
            [replacementContact setObject:userId forKey:my_uploadContact_user_id];
            [replacementContact setObject:contStatus forKey:my_uploadContact_status];
            [replacementContact setObject:contactFbId forKey:my_uploadContact_facebook_id];
            [replacementContact setObject:contactFbName forKey:my_uploadContact_facebook_name];
            if([previousContact objectForKey:@"firstNames"]){
                [replacementContact setObject:[previousContact objectForKey:@"firstNames"] forKey:@"firstNames"];
            }
            if([previousContact objectForKey:@"lastNames"]){
                [replacementContact setObject:[previousContact objectForKey:@"lastNames"] forKey:@"lastNames"];
            }
            if([previousContact objectForKey:@"fullName"]){
                [replacementContact setObject:[previousContact objectForKey:@"fullName"] forKey:@"fullName"];
            }
            
            ///We save the keo contacts in a separate dictionary
            
            [importKeoContactsCopy setObject:replacementContact forKey:contactPhoneNumber];
            /////
            
            NSMutableDictionary *replacementContact2 = [replacementContact mutableCopy];
            
            NSMutableDictionary *photoContact = [PickContact addPhotosToContact2:replacementContact2];
            if([photoContact objectForKey:@"image"]){
                [replacementContact2 setObject:[photoContact objectForKey:@"image"] forKey:@"image"];
            }
            else{
                [replacementContact2 setObject:[UIImage imageNamed:@"NoPhoto.png"] forKey:@"image"];
            }
            
            [importContactsData replaceObjectAtIndex:[myString intValue] withObject:replacementContact2];
        }
    }
    //APLLog(@"addKeoAccount done");
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table View


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    UILabel *myName;
    myName = (UILabel *)[cell viewWithTag:1];
    
    UILabel *keoLabel;
    keoLabel = (UILabel *)[cell viewWithTag:2];
    keoLabel.lineBreakMode = NSLineBreakByWordWrapping;
    keoLabel.numberOfLines = 0;
    
    UIImageView *selectPic;
    selectPic = (UIImageView *)[cell viewWithTag:3];
    [selectPic setImage:nil];
    selectPic.contentMode = UIViewContentModeCenter;
    
    UIImageView *profilePic;
    profilePic = (UIImageView *)[cell viewWithTag:4];
    [profilePic setImage:nil];
    profilePic.contentMode = UIViewContentModeScaleAspectFill;
    profilePic.clipsToBounds = YES;
    profilePic.layer.cornerRadius = profilePic.frame.size.width / 2;
    profilePic.layer.masksToBounds = YES;
    profilePic.image = [UIImage imageNamed:@"NoPhoto.png"];

    NSArray *sectionArray;
    NSMutableDictionary *contactInfoDict;
    
    //-----------if the user already has the app----------------
    if(indexPath.section == 0){
        sectionArray = localKeoContacts;
        NSInteger myIndex = [localKeoContacts indexOfObject:[sectionArray objectAtIndex:indexPath.row]];
        
        contactInfoDict = [localKeoContacts objectAtIndex:myIndex];
        if([importKeoPhotos objectForKey:[contactInfoDict objectForKey:@"phoneNumber1"]]){
            profilePic.image = [importKeoPhotos objectForKey:[contactInfoDict objectForKey:@"phoneNumber1"]];
        }
    }
    //-------------if the user doesn't have the app--------------
    else{
       sectionArray = [importContactsNames filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF beginswith[c] %@", [self.sections objectAtIndex:indexPath.section]]];
        NSInteger myIndex = [importContactsNames indexOfObject:[sectionArray objectAtIndex:indexPath.row]];
        
        contactInfoDict = [importContactsData objectAtIndex:myIndex];
        
        if([contactInfoDict objectForKey:@"image"]){
            profilePic.image = [contactInfoDict objectForKey:@"image"];
        }
        else{
            profilePic.image = [UIImage imageNamed:@"NoPhoto.png"];
        }
    }
    NSString *myFullName = @"";
    NSString *contactPhNum = @"";
    if([contactInfoDict objectForKey:@"firstNames"]||[contactInfoDict objectForKey:@"lastNames"]){
        myFullName = [NSString stringWithFormat:@"%@ %@", [contactInfoDict objectForKey:@"firstNames"], [contactInfoDict objectForKey:@"lastNames"]];
    }
    if([contactInfoDict objectForKey:@"phoneNumber1"]){
        contactPhNum = [contactInfoDict objectForKey:@"phoneNumber1"];
    }
    if(![[myFullName stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]){
        myName.text = myFullName;
    }
    else if(![contactPhNum isEqualToString:@""]){
            myName.text = contactPhNum;
    }
    else{
        if([contactInfoDict objectForKey:@"email"]){
            myName.text = [contactInfoDict objectForKey:@"email"];
        }
    }

    
    if([selectedContactArray containsObject:myFullName]){
        cell.backgroundColor = lightGrayColor;
    }
    else{
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    if([importKeoContacts objectForKey:[contactInfoDict objectForKey:@"phoneNumber1"]]){
        NSMutableDictionary *nbieContact = [importKeoContacts objectForKey:[contactInfoDict objectForKey:@"phoneNumber1"]];
        if([nbieContact objectForKey:@"status"]){
            NSString * statusToPrint = [nbieContact objectForKey:@"status"];
            if(![statusToPrint isEqualToString:@""]){
                keoLabel.text = [nbieContact objectForKey:@"status"];
            }
            else{
                keoLabel.text = @"No status";
            }
        }
        else{
            keoLabel.text = @"No status";
        }
    }
    else{
        keoLabel.text=@"";
    }
    
    return cell;
}


//------------------create sections with alphabetical order---------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 27;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.sections2;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString*)title atIndex:(NSInteger)index
{
    return index;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.sections objectAtIndex:section];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //NSLog(@"importcontactsdata: %d", [importContactsData count]);
    NSInteger rowCount;
    if (importContactsData) {
        if([[self.sections objectAtIndex:section] isEqualToString:@"Pictever"]){
            rowCount = [localKeoContacts count];
        }
        else{
            NSArray *sectionArray = [importContactsNames filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF beginswith[c] %@", [self.sections objectAtIndex:section]]];
            rowCount = [sectionArray count];
        }
        //APLLog([NSString stringWithFormat:@"rowCount%d",rowCount]);
        return rowCount;
    }
    else{
        return 0;
    }
}



//------------------the button confirm is pressed------------------------------
- (IBAction)confirmPressed:(id)sender {
    sendToMail = [[NSMutableArray alloc] init];
    for(NSString *cont in sendToMailCopy){
        if([[cont substringToIndex:3] isEqualToString:@"num"]){
            sendSMS = true;
        }
        [sendToMail addObject:cont];
    }
    APLLog(@"selectedContactArray: %@",[selectedContactArray description]);
    sendToName = [self getSendToName:selectedContactArray];
    APLLog(@"sendToname: %@",sendToName);
    showDatePicker = true;
    [self dismissViewControllerAnimated:YES completion:nil];
}

//------------------the button cancel is pressed------------------------------
- (IBAction)cancelPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


//--------------we prepare the array of recipients (convertion into a string) in order to send our message to this array of recipients---------
-(NSString *)getSendToName:(NSArray *)sendArr{
     NSString *sendStr = @"";
    if([sendArr count] > 0){
        sendStr = [sendArr objectAtIndex:0];
        for(int i=1; i < [sendArr count]; i++){
            if([sendArr count]>i){
                sendStr = [NSString stringWithFormat:@"%@, %@",sendStr,[sendArr objectAtIndex:i]];
            }
        }
    }
    else{
        return @"";
    }
    return sendStr;
}

//-------------every time the view appears, no contact is selected-----------------------
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    selectedContactArray = [[NSMutableArray alloc] init];
}


//----------add photo to one contact------------------------
+(NSMutableDictionary *)addPhotosToContact2:(NSMutableDictionary *)kContact{

    for(NSMutableDictionary *contact2 in importContactsData){
        if([[contact2 objectForKey:@"phoneNumber1"] isEqualToString:[kContact objectForKey:@"phoneNumber1"]]){
            if([contact2 objectForKey:@"image"]){
                return contact2;
            }
        }
    }
    return [[NSMutableDictionary alloc] init];
}


//-----------add photos to all contacts -----------------------------------
+(NSMutableDictionary *)addPhotosToAllContacts{
    NSMutableDictionary *importKeoPhotosLocal = [[NSMutableDictionary alloc] init];
    for(NSString *sKey in [importKeoContacts allKeys]){
        NSMutableDictionary *contWithPhoto = [self addPhotosToContact:[importKeoContacts objectForKey:sKey] atKey:sKey];

        if([contWithPhoto objectForKey:@"image"]){
            [importKeoPhotosLocal setObject:[contWithPhoto objectForKey:@"image"] forKey:sKey];
        }
        if([[contWithPhoto objectForKey:@"phoneNumber1"] isEqualToString:myCurrentPhoneNumber]){
            [importKeoPhotosLocal setObject:[UIImage imageNamed:@"my_keo_image.png"] forKey:sKey];
        }
    }
    return importKeoPhotosLocal;
}

//----------add photo to one contact------------------------
+(NSMutableDictionary *)addPhotosToContact:(NSMutableDictionary *)kContact atKey:(NSString *)tKey{

    for(NSMutableDictionary *contact2 in importContactsData){

        if([[contact2 objectForKey:@"phoneNumber1"] isEqualToString:[kContact objectForKey:@"phoneNumber1"]]){
            if([contact2 objectForKey:@"image"]){
                return contact2;
            }
        }
    }
    return [[NSMutableDictionary alloc] init];
}

//----------------update status--------------------------------
+(void)updateMyStatus{
    APLLog(@"updateMyStatus");
    NSMutableDictionary *importKeoContactsCopy = [importKeoContacts mutableCopy];
    for(NSString *contKey in [importKeoContactsCopy allKeys]){
        //NSLog(@"contKey: %@", contKey);
        NSMutableDictionary *contToUpdate = [[importKeoContactsCopy objectForKey:contKey] mutableCopy];
        if([contToUpdate objectForKey:@"phoneNumber1"]){
            NSString *phoneToUpadate = [contToUpdate objectForKey:@"phoneNumber1"];
            //NSLog(@"phoneToUpadate: %@", phoneToUpadate);
            if([phoneToUpadate isEqualToString:myCurrentPhoneNumber]){
                //NSLog(@"setStatus: %@ to contact: %@",myStatus, [contToUpdate description]);
                [contToUpdate setObject:myStatus forKey:@"status"];
                [importKeoContactsCopy setObject:contToUpdate forKey:contKey];
            }
        }
    }
    //NSLog(@"importKeoContactsCopy description: %@", [importKeoContactsCopy description]);
    importKeoContacts = [importKeoContactsCopy mutableCopy];
    [prefs setObject:importKeoContacts forKey:@"importKeoContacts"];
    APLLog(@"updateMyStatus-end");
}


@end

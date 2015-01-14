//
//  PhoneScreen.m
//  Keo
//
//  Created by Gauthier Petetin on 14/03/2014.
//  Copyright (c) 2014 Gauthier Petetin. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////(GO TO APPDELEGATE.M FOR MORE INFO ABOUT THE GLOBAL VARIABLES)/////////////////////////////////

#import "PhoneScreen.h"
#import "GPRequests.h"
#import "PickContact.h"
#import <AWSiOSSDKv2/AWSMobileAnalytics.h>
#import <AWSiOSSDKv2/AWSCore.h>
#import "myConstants.h"

#import "myGeneralMethods.h"

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface PhoneScreen ()

@property (nonatomic, strong) NSMutableData *responseDataDefinePhNumber;


@end

@implementation PhoneScreen


bool firstUseEver;

NSMutableArray *allMyCountries;
//NSDictionary *codeForCountryDictionary;
NSDictionary *numberForCountryDictionary;
NSArray *sortedArrayOfCountries;
NSArray *sortedArrayOfCodes;
NSArray *pickerArray;
UIPickerView *myPickerView;

NSString *myFacebookName;
NSString *myFacebookID;
NSString *myFacebookBirthDay;

NSString *adresseIp2;//global

bool openingWindow;
NSString *storyboardName;

//size if the screen
CGFloat screenWidth;//global
CGFloat screenHeight;//global
CGFloat tabBarHeight;//global

NSUserDefaults *prefs;


CGRect rect;

UIActivityIndicatorView *phoneSpinner;

UIImageView *flagImageView;
UIImageView *triangleView;
UITextField *textFieldCountry;
UITextField *textFieldPhoneNumber;
UITextField *textFieldCode;

NSMutableArray *importContactsData; //global
NSMutableDictionary *importKeoContacts;

//UILabel *myWelcomeLabel;
UILabel *myInformationLabel;
UILabel *myInformationLabel2;
UILabel *monLabelPassword1;


UIButton *backButton3;


UIButton *logInButton;
UIButton *confirmCodeButton;//to confirm phonenumber with sms code (not used now)

NSString *phoneNumberToCheck;

NSString *myLocaleString;
NSString *username;//global
NSString *hashPassword;//global
NSString *myCurrentPhoneNumber;//global
NSString *myCountryCode;//global
NSString *localCountryCode;//local

NSString *password1;
NSString *reponseLogIn;
NSString *myDeviceToken;

bool logIn;

NSString *localPhoneNum;

int height;
int yInitial;
int xPassword;
int xButton;
int xUsername;
int yUsername;
int yEspace;
int elevation;

NSInteger definePhoneErrorCode;

//-------------ask contacts-----------
UILabel *blackLabel;
UILabel *whiteTextLabel;
UILabel *whiteTextLabel2;

UIColor *theKeoOrangeColor;//global
UIColor *thePicteverGreenColor;//global
UIColor *thePicteverYellowColor;//global
UIColor *thePicteverRedColor;//global
UIColor *thePicteverGrayColor;//global

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[myGeneralMethods scaleImage:[UIImage imageNamed:@"RegisterBackground@2x.png"]]];
    
    numberForCountryDictionary = @{
                                       @"Canada"                                       : @"+1",
                                       @"China"                                        : @"+86",
                                       @"France"                                       : @"+33",
                                       @"Germany"                                      : @"+49",
                                       @"India"                                        : @"+91",
                                       @"Japan"                                        : @"+81",
                                       @"Pakistan"                                     : @"+92",
                                       @"United Kingdom"                               : @"+44",
                                       @"United States"                                : @"+1",
                                       @"Abkhazia"                                     : @"+7 840",
                                       @"Abkhazia"                                     : @"+7 940",
                                       @"Afghanistan"                                  : @"+93",
                                       @"Albania"                                      : @"+355",
                                       @"Algeria"                                      : @"+213",
                                       @"American Samoa"                               : @"+1 684",
                                       @"Andorra"                                      : @"+376",
                                       @"Angola"                                       : @"+244",
                                       @"Anguilla"                                     : @"+1 264",
                                       @"Antigua and Barbuda"                          : @"+1 268",
                                       @"Argentina"                                    : @"+54",
                                       @"Armenia"                                      : @"+374",
                                       @"Aruba"                                        : @"+297",
                                       @"Ascension"                                    : @"+247",
                                       @"Australia"                                    : @"+61",
                                       @"Australian External Territories"              : @"+672",
                                       @"Austria"                                      : @"+43",
                                       @"Azerbaijan"                                   : @"+994",
                                       @"Bahamas"                                      : @"+1 242",
                                       @"Bahrain"                                      : @"+973",
                                       @"Bangladesh"                                   : @"+880",
                                       @"Barbados"                                     : @"+1 246",
                                       @"Barbuda"                                      : @"+1 268",
                                       @"Belarus"                                      : @"+375",
                                       @"Belgium"                                      : @"+32",
                                       @"Belize"                                       : @"+501",
                                       @"Benin"                                        : @"+229",
                                       @"Bermuda"                                      : @"+1 441",
                                       @"Bhutan"                                       : @"+975",
                                       @"Bolivia"                                      : @"+591",
                                       @"Bosnia and Herzegovina"                       : @"+387",
                                       @"Botswana"                                     : @"+267",
                                       @"Brazil"                                       : @"+55",
                                       @"British Indian Ocean Territory"               : @"+246",
                                       @"British Virgin Islands"                       : @"+1 284",
                                       @"Brunei"                                       : @"+673",
                                       @"Bulgaria"                                     : @"+359",
                                       @"Burkina Faso"                                 : @"+226",
                                       @"Burundi"                                      : @"+257",
                                       @"Cambodia"                                     : @"+855",
                                       @"Cameroon"                                     : @"+237",
                                       @"Canada"                                       : @"+1",
                                       @"Cape Verde"                                   : @"+238",
                                       @"Cayman Islands"                               : @"+ 345",
                                       @"Central African Republic"                     : @"+236",
                                       @"Chad"                                         : @"+235",
                                       @"Chile"                                        : @"+56",
                                       @"China"                                        : @"+86",
                                       @"Christmas Island"                             : @"+61",
                                       @"Cocos-Keeling Islands"                        : @"+61",
                                       @"Colombia"                                     : @"+57",
                                       @"Comoros"                                      : @"+269",
                                       @"Congo"                                        : @"+242",
                                       @"Congo, Dem. Rep. of (Zaire)"                  : @"+243",
                                       @"Cook Islands"                                 : @"+682",
                                       @"Costa Rica"                                   : @"+506",
                                       @"Ivory Coast"                                  : @"+225",
                                       @"Croatia"                                      : @"+385",
                                       @"Cuba"                                         : @"+53",
                                       @"Curacao"                                      : @"+599",
                                       @"Cyprus"                                       : @"+537",
                                       @"Czech Republic"                               : @"+420",
                                       @"Denmark"                                      : @"+45",
                                       @"Diego Garcia"                                 : @"+246",
                                       @"Djibouti"                                     : @"+253",
                                       @"Dominica"                                     : @"+1 767",
                                       @"Dominican Republic"                           : @"+1 809",
                                       @"Dominican Republic"                           : @"+1 829",
                                       @"Dominican Republic"                           : @"+1 849",
                                       @"East Timor"                                   : @"+670",
                                       @"Easter Island"                                : @"+56",
                                       @"Ecuador"                                      : @"+593",
                                       @"Egypt"                                        : @"+20",
                                       @"El Salvador"                                  : @"+503",
                                       @"Equatorial Guinea"                            : @"+240",
                                       @"Eritrea"                                      : @"+291",
                                       @"Estonia"                                      : @"+372",
                                       @"Ethiopia"                                     : @"+251",
                                       @"Falkland Islands"                             : @"+500",
                                       @"Faroe Islands"                                : @"+298",
                                       @"Fiji"                                         : @"+679",
                                       @"Finland"                                      : @"+358",
                                       @"France"                                       : @"+33",
                                       @"French Antilles"                              : @"+596",
                                       @"French Guiana"                                : @"+594",
                                       @"French Polynesia"                             : @"+689",
                                       @"Gabon"                                        : @"+241",
                                       @"Gambia"                                       : @"+220",
                                       @"Georgia"                                      : @"+995",
                                       @"Germany"                                      : @"+49",
                                       @"Ghana"                                        : @"+233",
                                       @"Gibraltar"                                    : @"+350",
                                       @"Greece"                                       : @"+30",
                                       @"Greenland"                                    : @"+299",
                                       @"Grenada"                                      : @"+1 473",
                                       @"Guadeloupe"                                   : @"+590",
                                       @"Guam"                                         : @"+1 671",
                                       @"Guatemala"                                    : @"+502",
                                       @"Guinea"                                       : @"+224",
                                       @"Guinea-Bissau"                                : @"+245",
                                       @"Guyana"                                       : @"+595",
                                       @"Haiti"                                        : @"+509",
                                       @"Honduras"                                     : @"+504",
                                       @"Hong Kong SAR China"                          : @"+852",
                                       @"Hungary"                                      : @"+36",
                                       @"Iceland"                                      : @"+354",
                                       @"India"                                        : @"+91",
                                       @"Indonesia"                                    : @"+62",
                                       @"Iran"                                         : @"+98",
                                       @"Iraq"                                         : @"+964",
                                       @"Ireland"                                      : @"+353",
                                       @"Israel"                                       : @"+972",
                                       @"Italy"                                        : @"+39",
                                       @"Jamaica"                                      : @"+1 876",
                                       @"Japan"                                        : @"+81",
                                       @"Jordan"                                       : @"+962",
                                       @"Kazakhstan"                                   : @"+7 7",
                                       @"Kenya"                                        : @"+254",
                                       @"Kiribati"                                     : @"+686",
                                       @"North Korea"                                  : @"+850",
                                       @"South Korea"                                  : @"+82",
                                       @"Kuwait"                                       : @"+965",
                                       @"Kyrgyzstan"                                   : @"+996",
                                       @"Laos"                                         : @"+856",
                                       @"Latvia"                                       : @"+371",
                                       @"Lebanon"                                      : @"+961",
                                       @"Lesotho"                                      : @"+266",
                                       @"Liberia"                                      : @"+231",
                                       @"Libya"                                        : @"+218",
                                       @"Liechtenstein"                                : @"+423",
                                       @"Lithuania"                                    : @"+370",
                                       @"Luxembourg"                                   : @"+352",
                                       @"Macau SAR China"                              : @"+853",
                                       @"Macedonia"                                    : @"+389",
                                       @"Madagascar"                                   : @"+261",
                                       @"Malawi"                                       : @"+265",
                                       @"Malaysia"                                     : @"+60",
                                       @"Maldives"                                     : @"+960",
                                       @"Mali"                                         : @"+223",
                                       @"Malta"                                        : @"+356",
                                       @"Marshall Islands"                             : @"+692",
                                       @"Martinique"                                   : @"+596",
                                       @"Mauritania"                                   : @"+222",
                                       @"Mauritius"                                    : @"+230",
                                       @"Mayotte"                                      : @"+262",
                                       @"Mexico"                                       : @"+52",
                                       @"Micronesia"                                   : @"+691",
                                       @"Midway Island"                                : @"+1 808",
                                       @"Micronesia"                                   : @"+691",
                                       @"Moldova"                                      : @"+373",
                                       @"Monaco"                                       : @"+377",
                                       @"Mongolia"                                     : @"+976",
                                       @"Montenegro"                                   : @"+382",
                                       @"Montserrat"                                   : @"+1664",
                                       @"Morocco"                                      : @"+212",
                                       @"Myanmar"                                      : @"+95",
                                       @"Namibia"                                      : @"+264",
                                       @"Nauru"                                        : @"+674",
                                       @"Nepal"                                        : @"+977",
                                       @"Netherlands"                                  : @"+31",
                                       @"Netherlands Antilles"                         : @"+599",
                                       @"Nevis"                                        : @"+1 869",
                                       @"New Caledonia"                                : @"+687",
                                       @"New Zealand"                                  : @"+64",
                                       @"Nicaragua"                                    : @"+505",
                                       @"Niger"                                        : @"+227",
                                       @"Nigeria"                                      : @"+234",
                                       @"Niue"                                         : @"+683",
                                       @"Norfolk Island"                               : @"+672",
                                       @"Northern Mariana Islands"                     : @"+1 670",
                                       @"Norway"                                       : @"+47",
                                       @"Oman"                                         : @"+968",
                                       @"Pakistan"                                     : @"+92",
                                       @"Palau"                                        : @"+680",
                                       @"Palestinian Territory"                        : @"+970",
                                       @"Panama"                                       : @"+507",
                                       @"Papua New Guinea"                             : @"+675",
                                       @"Paraguay"                                     : @"+595",
                                       @"Peru"                                         : @"+51",
                                       @"Philippines"                                  : @"+63",
                                       @"Poland"                                       : @"+48",
                                       @"Portugal"                                     : @"+351",
                                       @"Puerto Rico"                                  : @"+1 787",
                                       @"Puerto Rico"                                  : @"+1 939",
                                       @"Qatar"                                        : @"+974",
                                       @"Reunion"                                      : @"+262",
                                       @"Romania"                                      : @"+40",
                                       @"Russia"                                       : @"+7",
                                       @"Rwanda"                                       : @"+250",
                                       @"Samoa"                                        : @"+685",
                                       @"San Marino"                                   : @"+378",
                                       @"Saudi Arabia"                                 : @"+966",
                                       @"Senegal"                                      : @"+221",
                                       @"Serbia"                                       : @"+381",
                                       @"Seychelles"                                   : @"+248",
                                       @"Sierra Leone"                                 : @"+232",
                                       @"Singapore"                                    : @"+65",
                                       @"Slovakia"                                     : @"+421",
                                       @"Slovenia"                                     : @"+386",
                                       @"Solomon Islands"                              : @"+677",
                                       @"South Africa"                                 : @"+27",
                                       @"South Georgia and the South Sandwich Islands" : @"+500",
                                       @"Spain"                                        : @"+34",
                                       @"Sri Lanka"                                    : @"+94",
                                       @"Sudan"                                        : @"+249",
                                       @"Suriname"                                     : @"+597",
                                       @"Swaziland"                                    : @"+268",
                                       @"Sweden"                                       : @"+46",
                                       @"Switzerland"                                  : @"+41",
                                       @"Syria"                                        : @"+963",
                                       @"Taiwan"                                       : @"+886",
                                       @"Tajikistan"                                   : @"+992",
                                       @"Tanzania"                                     : @"+255",
                                       @"Thailand"                                     : @"+66",
                                       @"Timor Leste"                                  : @"+670",
                                       @"Togo"                                         : @"+228",
                                       @"Tokelau"                                      : @"+690",
                                       @"Tonga"                                        : @"+676",
                                       @"Trinidad and Tobago"                          : @"+1 868",
                                       @"Tunisia"                                      : @"+216",
                                       @"Turkey"                                       : @"+90",
                                       @"Turkmenistan"                                 : @"+993",
                                       @"Turks and Caicos Islands"                     : @"+1 649",
                                       @"Tuvalu"                                       : @"+688",
                                       @"Uganda"                                       : @"+256",
                                       @"Ukraine"                                      : @"+380",
                                       @"United Arab Emirates"                         : @"+971",
                                       @"United Kingdom"                               : @"+44",
                                       @"United States"                                : @"+1",
                                       @"Uruguay"                                      : @"+598",
                                       @"U.S. Virgin Islands"                          : @"+1 340",
                                       @"Uzbekistan"                                   : @"+998",
                                       @"Vanuatu"                                      : @"+678",
                                       @"Venezuela"                                    : @"+58",
                                       @"Vietnam"                                      : @"+84",
                                       @"Wake Island"                                  : @"+1 808",
                                       @"Wallis and Futuna"                            : @"+681",
                                       @"Yemen"                                        : @"+967",
                                       @"Zambia"                                       : @"+260",
                                       @"Zanzibar"                                     : @"+255",
                                       @"Zimbabwe"                                     : @"+263"
                                       };
    
    allMyCountries = [self initializeCountries];

    
    sortedArrayOfCountries = [[numberForCountryDictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];;
    
    logIn = false;
    
    localCountryCode = @"";
    
    self.responseDataDefinePhNumber = [NSMutableData data];

    
    [self initializeControls];
    
    
    [self addPickerView];
    
    if([allMyCountries count]>0){
        NSString *cNumber = [[allMyCountries objectAtIndex:0] objectForKey:@"number"];
        [textFieldPhoneNumber setText:[NSString stringWithFormat:@"%@ ",cNumber]];
        UIImage *flagImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",[[allMyCountries objectAtIndex:0] objectForKey:@"code"]]];
        [flagImageView setImage:flagImage];
    }
}

-(void)hideContactInformation{
    APLLog(@"hideContactInformation");
    [blackLabel removeFromSuperview];
    [whiteTextLabel removeFromSuperview];
    [whiteTextLabel2 removeFromSuperview];
    
    [textFieldPhoneNumber becomeFirstResponder];
}



-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(hideContactInformation) name:@"hideInformation" object: nil];
    
    //-----------in case of first use, inform user that we will access his contacts--------------
    
    blackLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    blackLabel.backgroundColor = [UIColor blackColor];
    blackLabel.alpha = 0.75;
    
    whiteTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 30, screenWidth-30, 180)];
    whiteTextLabel.textColor = [UIColor whiteColor];
    whiteTextLabel.font = [UIFont fontWithName:@"GothamRounded-Bold" size:16];
    whiteTextLabel.numberOfLines = 0;
    whiteTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    whiteTextLabel.backgroundColor = [UIColor clearColor];
    whiteTextLabel.textAlignment = NSTextAlignmentCenter;
    whiteTextLabel.text = @"Pictever uses the phone numbers in your adress book to help you find your friends :)";
    
    whiteTextLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(15, screenHeight-150, screenWidth-30, 100)];
    whiteTextLabel2.textColor = [UIColor whiteColor];
    whiteTextLabel2.font = [UIFont fontWithName:@"GothamRounded-Bold" size:16];
    whiteTextLabel2.numberOfLines = 0;
    whiteTextLabel2.lineBreakMode = NSLineBreakByWordWrapping;
    whiteTextLabel2.backgroundColor = [UIColor clearColor];
    whiteTextLabel2.textAlignment = NSTextAlignmentCenter;
    whiteTextLabel2.text = @"We won't spam or auto-add your friends.";
    
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        [self.view addSubview:blackLabel];
        [self.view addSubview:whiteTextLabel];
        [self.view addSubview:whiteTextLabel2];
        
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"hideInformation" object:nil];
            });
            if (granted) {
                APLLog(@"access to contacts authorized for the first time");
                // First time access has been granted, add the contact
            } else {
                APLLog(@"accessToContactsDenied for the first time");
                // User denied access
                // Display an alert telling user the contact could not be added
            }
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        // The user has previously given access, add the contact
        APLLog(@"access to contacts authorized");
        [textFieldPhoneNumber becomeFirstResponder];

    }
    else {
        APLLog(@"accessToContactsDenied");
        [textFieldPhoneNumber becomeFirstResponder];
        // The user has previously denied access
        // Send an alert telling user to change privacy setting in settings app
    }
}

-(void)addPickerView{
    pickerArray = sortedArrayOfCountries;

    myPickerView = [[UIPickerView alloc]init];
    myPickerView.backgroundColor = thePicteverGrayColor;
    myPickerView.dataSource = self;
    myPickerView.delegate = self;
    myPickerView.showsSelectionIndicator = YES;

    textFieldCountry.inputView = myPickerView;

}



#pragma mark - Text field delegates

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if ([textFieldCountry.text isEqualToString:@""]) {
        
    }
}
#pragma mark - Picker View Data source
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component{
    return [allMyCountries count];
}

#pragma mark- Picker View Delegate

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:
(NSInteger)row inComponent:(NSInteger)component{
    NSString *cNumber = [[allMyCountries objectAtIndex:row] objectForKey:@"number"];
    [textFieldPhoneNumber setText:[NSString stringWithFormat:@"%@ ",cNumber]];
    UIImage *flagImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",[[allMyCountries objectAtIndex:row] objectForKey:@"code"]]];
    [flagImageView setImage:flagImage];
    
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:
(NSInteger)row forComponent:(NSInteger)component{
    return [[allMyCountries objectAtIndex:row] objectForKey:@"country"];
}


-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row
          forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *firstLabel = [[UILabel alloc] initWithFrame:CGRectMake(130, 0, screenWidth-130, 32)];
    firstLabel.text = [[allMyCountries objectAtIndex:row] objectForKey:@"country"];
    firstLabel.font = [UIFont fontWithName:@"GothamRounded-Bold" size:16];
    firstLabel.textAlignment = NSTextAlignmentLeft;
    firstLabel.textColor = [UIColor whiteColor];
    firstLabel.backgroundColor = [UIColor clearColor];
    
    UILabel *secondLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, 60, 32)];
    secondLabel.text = [[allMyCountries objectAtIndex:row] objectForKey:@"number"];
    secondLabel.font = [UIFont fontWithName:@"GothamRounded-Bold" size:16];
    secondLabel.textAlignment = NSTextAlignmentLeft;
    secondLabel.textColor = [UIColor whiteColor];
    secondLabel.backgroundColor = [UIColor clearColor];
    
    UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",[[allMyCountries objectAtIndex:row] objectForKey:@"code"]]];
    UIImageView *icon = [[UIImageView alloc] initWithImage:img];
    icon.contentMode = UIViewContentModeScaleAspectFit;
    icon.layer.cornerRadius = 2;
    icon.layer.masksToBounds = YES;
    //temp.frame = CGRectMake(170, 0, 30, 30);
    icon.frame = CGRectMake(20, 6, 28, 19);
    
    
    
    UIView *tmpView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 290, 32)];
    [tmpView insertSubview:icon atIndex:0];
    [tmpView insertSubview:firstLabel atIndex:0];
    [tmpView insertSubview:secondLabel atIndex:0];
    //[tmpView insertSubview:secondLabel atIndex:0];
    [tmpView setUserInteractionEnabled:NO];
    [tmpView setTag:row];

    return tmpView;
    
    
}





-(NSMutableArray *)initializeCountries{
    APLLog(@"initializeCountries");
    
    NSLocale *mylocale = [NSLocale currentLocale];//-----my locale
    NSString *mymyCountryCode = [mylocale objectForKey: NSLocaleCountryCode];
    NSString *mymyCountry = [mylocale displayNameForKey: NSLocaleCountryCode value: mymyCountryCode];
    bool myCountryIsOk = false;
    if(mymyCountry){
        APLLog(@"my country is ok");
        myCountryIsOk = true;
    }
    else{
        APLLog(@"my country is not ok");
    }
    APLLog(@"mycontrycode: %@ mycountry: %@", mymyCountryCode, mymyCountry);

    NSMutableDictionary* Spain = [[NSMutableDictionary alloc] init];
    NSMutableDictionary* Italy = [[NSMutableDictionary alloc] init];
    NSMutableDictionary* Germany = [[NSMutableDictionary alloc] init];
    NSMutableDictionary* UnitedStates = [[NSMutableDictionary alloc] init];
    NSMutableDictionary* France = [[NSMutableDictionary alloc] init];
    NSMutableDictionary* UnitedKingdom = [[NSMutableDictionary alloc] init];
    
    NSMutableDictionary* MyOwnCountry = [[NSMutableDictionary alloc] init];
    
    
    NSMutableArray *returnCountries = [[NSMutableArray alloc] init];
    
    NSArray *countryCodes = [NSLocale ISOCountryCodes];
    
    for (NSString *countryCode in countryCodes){
        NSString *identifier = [NSLocale localeIdentifierFromComponents: [NSDictionary dictionaryWithObject: countryCode forKey: NSLocaleCountryCode]];

        NSString *country = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_UK"] displayNameForKey: NSLocaleIdentifier value: identifier];
        
        NSString *countryNum = @"";
        if([numberForCountryDictionary objectForKey:country]){
            countryNum = [numberForCountryDictionary objectForKey:country];
            NSMutableDictionary* countryDic = [[NSMutableDictionary alloc] init];
            [countryDic setObject:country forKey:@"country"];
            [countryDic setObject:[countryCode lowercaseString] forKey:@"code"];
            [countryDic setObject:countryNum forKey:@"number"];
            
            if([countryNum isEqualToString:@"+39"]){
                Italy = [countryDic mutableCopy];
            }
            if([countryNum isEqualToString:@"+34"]){
                Spain = [countryDic mutableCopy];
            }
            if([countryNum isEqualToString:@"+49"]){
                Germany = [countryDic mutableCopy];
            }
            if([countryNum isEqualToString:@"+1"]){
                UnitedStates = [countryDic mutableCopy];
            }
            if([countryNum isEqualToString:@"+33"]){
                France = [countryDic mutableCopy];
            }
            if([countryNum isEqualToString:@"+44"]){
                UnitedKingdom = [countryDic mutableCopy];
            }
            
            if([country isEqualToString:mymyCountry]){
                MyOwnCountry = [countryDic mutableCopy];
            }
            
            [returnCountries insertObject:countryDic atIndex:[returnCountries count]];
        }
    }
    [returnCountries removeObject:Italy];
    [returnCountries removeObject:Spain];
    [returnCountries removeObject:Germany];
    [returnCountries removeObject:UnitedStates];
    [returnCountries removeObject:France];
    [returnCountries removeObject:UnitedKingdom];
    
    [returnCountries insertObject:Italy atIndex:0];
    [returnCountries insertObject:Spain atIndex:0];
    [returnCountries insertObject:Germany atIndex:0];
    [returnCountries insertObject:UnitedKingdom atIndex:0];
    [returnCountries insertObject:France atIndex:0];
    [returnCountries insertObject:UnitedStates atIndex:0];
    
    if(myCountryIsOk){
        [returnCountries removeObject:MyOwnCountry];
        [returnCountries insertObject:MyOwnCountry atIndex:0];
    }

    return returnCountries;
}



//-----------------go back to login screen------------------------------

-(void) backPressed3{
    [myGeneralMethods initializeAllAccountVariables];
    [self dismissViewControllerAnimated:YES completion:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setUsername" object: nil];
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    
    [backButton3 removeFromSuperview];
    //[myWelcomeLabel removeFromSuperview];
    [textFieldCountry removeFromSuperview];
    [textFieldPhoneNumber removeFromSuperview];
    [logInButton removeFromSuperview];
    [phoneSpinner removeFromSuperview];
    [flagImageView removeFromSuperview];
    [triangleView removeFromSuperview];
    [myInformationLabel removeFromSuperview];
    [myInformationLabel2 removeFromSuperview];
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"hideInfromation" object:nil];
}



//---------------hide keyboard when screen is touched---------------

- (IBAction)respondToTapGesture2:(UITapGestureRecognizer *)recognizer {
    [textFieldPhoneNumber resignFirstResponder];
    [textFieldCountry resignFirstResponder];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//----------------------confirm phone number is pressed-------the country code format validity is first tested----------------------------

- (IBAction)myActionLogIn:(id)sender{
    NSString *selectedCountryCode = @"";
    NSString *selectedPhoneNumber = textFieldPhoneNumber.text;
    NSInteger roww = [myPickerView selectedRowInComponent:0];
    if ([allMyCountries count]>roww) {
        if ([allMyCountries objectAtIndex:roww]) {
            if ([[allMyCountries objectAtIndex:roww] objectForKey:@"number"]) {
                selectedCountryCode = [[allMyCountries objectAtIndex:roww] objectForKey:@"number"];
            }
        }
    }
    selectedCountryCode = [selectedCountryCode stringByReplacingOccurrencesOfString:@" " withString:@""];
    selectedPhoneNumber = [selectedPhoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSUInteger selectedCountryCodeLength = [selectedCountryCode length];
    NSUInteger selectedPhoneNumberLength = [selectedPhoneNumber length];
    APLLog(@"selectedCountryCode: %@",selectedCountryCode);
    NSString *phoneWithoutCountryCode = @"";
    NSString *finalPhoneNumber = @"";
    NSString *bigSelectedCoutryCode = [selectedCountryCode stringByReplacingOccurrencesOfString:@"+" withString:@"00"];
    
    
    
    if([selectedPhoneNumber length]>4){
        if(selectedPhoneNumberLength>selectedCountryCodeLength){ // ...4454254
            if ([[selectedPhoneNumber substringToIndex:selectedCountryCodeLength] isEqualToString:selectedCountryCode]) { //+334454254
                phoneWithoutCountryCode = [selectedPhoneNumber substringFromIndex:selectedCountryCodeLength];
                if ([[phoneWithoutCountryCode substringToIndex:1] isEqualToString:@"0"]) { // +3304454254
                    phoneWithoutCountryCode = [phoneWithoutCountryCode substringFromIndex:1];
                    selectedCountryCode = [selectedCountryCode stringByReplacingOccurrencesOfString:@"+" withString:@"00"];
                    finalPhoneNumber = [NSString stringWithFormat:@"%@%@",selectedCountryCode,phoneWithoutCountryCode];
                }
                else{ // +334454254
                    
                    finalPhoneNumber = [NSString stringWithFormat:@"%@%@",bigSelectedCoutryCode,phoneWithoutCountryCode];
                }
            }
            else{
                if ([[selectedPhoneNumber substringToIndex:2] isEqualToString:@"00"]){// 00334454254
                    if([[selectedPhoneNumber substringToIndex:[bigSelectedCoutryCode length]] isEqualToString:bigSelectedCoutryCode]){// 00334454
                        phoneWithoutCountryCode = [selectedPhoneNumber substringFromIndex:[bigSelectedCoutryCode length]];
                        if([[phoneWithoutCountryCode substringToIndex:1] isEqualToString:@"0"]){// 003304454254
                            phoneWithoutCountryCode = [phoneWithoutCountryCode substringFromIndex:1];
                            finalPhoneNumber = [NSString stringWithFormat:@"%@%@",bigSelectedCoutryCode,phoneWithoutCountryCode];
                        }
                        else{// 00334454254
                            finalPhoneNumber = [NSString stringWithFormat:@"%@%@",bigSelectedCoutryCode,phoneWithoutCountryCode];
                        }
                    }
                    else{// 00394454254
                        finalPhoneNumber = [NSString stringWithFormat:@"%@",selectedPhoneNumber];
                    }
                }
                else if ([[selectedPhoneNumber substringToIndex:1] isEqualToString:@"0"]){//064454254
                    selectedPhoneNumber = [selectedPhoneNumber substringFromIndex:1];
                    finalPhoneNumber = [NSString stringWithFormat:@"%@%@",bigSelectedCoutryCode,selectedPhoneNumber];
                }
                else{// 4454254
                    finalPhoneNumber = [NSString stringWithFormat:@"%@%@",bigSelectedCoutryCode,selectedPhoneNumber];
                }
            }
        }
        else{
            if ([[selectedPhoneNumber substringToIndex:2] isEqualToString:@"00"]){// 00334454254
                if([[selectedPhoneNumber substringToIndex:[bigSelectedCoutryCode length]] isEqualToString:bigSelectedCoutryCode]){// 00334454
                    phoneWithoutCountryCode = [selectedPhoneNumber substringFromIndex:[bigSelectedCoutryCode length]];
                    if([[phoneWithoutCountryCode substringToIndex:1] isEqualToString:@"0"]){// 003304454254
                        phoneWithoutCountryCode = [phoneWithoutCountryCode substringFromIndex:1];
                        finalPhoneNumber = [NSString stringWithFormat:@"%@%@",bigSelectedCoutryCode,phoneWithoutCountryCode];
                    }
                    else{// 00334454254
                        finalPhoneNumber = [NSString stringWithFormat:@"%@%@",bigSelectedCoutryCode,phoneWithoutCountryCode];
                    }
                }
                else{// 00394454254
                    finalPhoneNumber = [NSString stringWithFormat:@"%@",selectedPhoneNumber];
                }
            }
            else if ([[selectedPhoneNumber substringToIndex:1] isEqualToString:@"0"]){//064454254
                selectedPhoneNumber = [selectedPhoneNumber substringFromIndex:1];
                finalPhoneNumber = [NSString stringWithFormat:@"%@%@",bigSelectedCoutryCode,selectedPhoneNumber];
            }
            else{// 4454254
                finalPhoneNumber = [NSString stringWithFormat:@"%@%@",bigSelectedCoutryCode,selectedPhoneNumber];
            }
        }
        APLLog(@"finalNumber: %@",finalPhoneNumber);
        phoneNumberToCheck = finalPhoneNumber;
        localCountryCode = bigSelectedCoutryCode;
        [self saveNumberAndContinue];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Sorry"
                              message:@"Invalid phone number" delegate:self
                              cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
}



//----------------the number is sent to the server to be associated to the account------------------------
//----------------(it has to have the followinf format: 0033612010959)------------------------------------

-(void)saveNumberAndContinue{
    APLLog(@"saveNumberAndContinue");

    if([GPRequests connected]){
        [GPRequests asynchronousDefine_first_phone_number:phoneNumberToCheck for:self];
        logInButton.highlighted = YES;
        logInButton.enabled = NO;
        [phoneSpinner startAnimating];
    }
    else{
        UIAlertView *alert5 = [[UIAlertView alloc]
                               initWithTitle:@"Connection problem"
                               message:@"You have no internet connection" delegate:self
                               cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert5 show];
    }

    
}


//------------------------------------------------------------------------------------------------
//------------------------------------Requests answers--------------------------------------------

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSInteger myErrorCode = [httpResponse statusCode];
    NSString *connectionString = [[[connection currentRequest] URL] absoluteString];
    APLLog(@"didReceiveResponse: %@",connectionString);
    
    NSString *urlCheckDefinePhoneNumberString = connectionString;
    
    NSString *definePhoneNumberString = [NSString stringWithFormat:@"%@%@",adresseIp2,my_defineFirstPhoneRequestName ];
    
    if([connectionString length] > [definePhoneNumberString length]){
        urlCheckDefinePhoneNumberString = [connectionString substringToIndex:[definePhoneNumberString length]];
    }
    
    
    if([urlCheckDefinePhoneNumberString isEqualToString:definePhoneNumberString]){
        APLLog([NSString stringWithFormat:@"definePhone error code: %ld",(long)myErrorCode]);
        definePhoneErrorCode = myErrorCode;
        if(myErrorCode != 200){
        }
        else{
            APLLog(@"definePhoneNumber200");
            [self.responseDataDefinePhNumber setLength:0];
        }
    }
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseDataDefinePhNumber appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSString *connectionString = [[[connection currentRequest] URL] absoluteString];
    
    NSString *urlCheckDefinePhoneNumberString = connectionString;
    
    NSString *definePhoneNumberString = [NSString stringWithFormat:@"%@%@",adresseIp2,my_defineFirstPhoneRequestName];
    
    if([connectionString length] > [definePhoneNumberString length]){
        urlCheckDefinePhoneNumberString = [connectionString substringToIndex:[definePhoneNumberString length]];
    }
    
    if([urlCheckDefinePhoneNumberString isEqualToString:definePhoneNumberString]){
        APLLog([NSString stringWithFormat:@"Connection definePhone failed: %@", [error description]]);
        logInButton.highlighted = NO;
        logInButton.enabled = YES;
        [phoneSpinner stopAnimating];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *connectionString = [[[connection currentRequest] URL] absoluteString];
    
    NSString *urlCheckDefinePhoneNumberString = connectionString;
    
    NSString *definePhoneNumberString = [NSString stringWithFormat:@"%@%@",adresseIp2,my_defineFirstPhoneRequestName];
    
    if([connectionString length] > [definePhoneNumberString length]){
        urlCheckDefinePhoneNumberString = [connectionString substringToIndex:[definePhoneNumberString length]];
    }
    
    if([urlCheckDefinePhoneNumberString isEqualToString:definePhoneNumberString]){
        APLLog(@"Succeeded! Received %d bytes of data",[self.responseDataDefinePhNumber length]);
        
        if(definePhoneErrorCode != 200){
            if(definePhoneErrorCode == 500){
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"Error define_phone"
                                      message:@"Server Error" delegate:self
                                      cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
            }

            if(definePhoneErrorCode == 401){
                NSInteger loginCheckAnswer =[GPRequests loginWithEmail:username withPassWord:hashPassword for:self];
                if(loginCheckAnswer == 200){
                    [GPRequests asynchronousDefine_first_phone_number:phoneNumberToCheck for:self];
                }
                else{
                    UIAlertView *alert = [[UIAlertView alloc]
                                          initWithTitle:@"Error"
                                          message:@"Please login first" delegate:self
                                          cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alert show];
                    //// Switch screen
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
                        UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"WelcomeScreen"];
                        [self presentViewController:vc animated:NO completion:nil];
                    });
                    ////////////////////////////////////////////////////////////////////
                }
            }
            if(definePhoneErrorCode == 404){
                [GPRequests goBackToFirstServer];
            }
            if(definePhoneErrorCode == 406){
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"Sorry"
                                      message:@"This phone number is already taken by another account" delegate:self
                                      cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
            }
            if(definePhoneErrorCode == 0){
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc]
                                          initWithTitle:@"Connection error"
                                          message:@"Please login again" delegate:self
                                          cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alert show];
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
                    UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"logInScreen"];
                    [self presentViewController:vc animated:NO completion:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"setUsername" object: nil];
                });
            }
        }
        else{
            //------------------------once the request worked, we save the phone number and start using the Shyft application-------------
            
            APLLog(@"definePhone200");
            logIn = true;
            [prefs setBool:logIn forKey:my_prefs_login_key];
            myCurrentPhoneNumber = phoneNumberToCheck;
            
            //--------------Save Number
            [prefs setObject:myCurrentPhoneNumber forKey:my_prefs_phoneNumber_key];
            
            //--------------save regional code
            myCountryCode = localCountryCode;
            [prefs setObject:localCountryCode forKey:my_prefs_countryCode_key];
            
            
            
            APLLog(@"Phone number is saved: %@",[prefs objectForKey:my_prefs_phoneNumber_key]);
            dispatch_async(dispatch_get_main_queue(), ^{
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
                UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"WelcomeScreen"];
                [self presentViewController:vc animated:NO completion:nil];
            });
        }
        
        logInButton.highlighted = NO;
        logInButton.enabled = YES;
        [phoneSpinner stopAnimating];
    }
    
   
    
}


-(void)initializeControls{
    yInitial=160;
    xPassword=190;
    xUsername=screenWidth-50;
    yEspace=50;
    xButton=160;
    yUsername=40;
    
    
    rect = self.view.frame;
    height = rect.size.height;
    
    
    //------------Create tap gesture recognizer
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondToTapGesture2:)];
    tapRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tapRecognizer];
    
    
    
    
    //----------------------------CREATION OF CONTROLS------------------------------------------------
    
    //--------------creation of label PHONE NUMBER
    /*CGRect rectLabUsername = CGRectMake(0.5*screenWidth-(0.5*xUsername),50-15,xUsername,60);
    myWelcomeLabel = [[UILabel alloc] initWithFrame: rectLabUsername];
    [myWelcomeLabel setTextAlignment:NSTextAlignmentCenter];
    //[myWelcomeLabel setFont:[UIFont systemFontOfSize:30]];
    myWelcomeLabel.textColor = theKeoOrangeColor;
    [myWelcomeLabel setFont:[UIFont fontWithName:@"Gabriola" size:42]];
    myWelcomeLabel.text = @"Phone Number";*/
    
    //--------------creation of label information
    CGRect rectLabInformation = CGRectMake(0.5*screenWidth-(0.5*(xUsername+20)),100,(xUsername+20),60);
    myInformationLabel = [[UILabel alloc] initWithFrame: rectLabInformation];
    [myInformationLabel setTextAlignment:NSTextAlignmentCenter];
    [myInformationLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:16]];
    myInformationLabel.textColor = [UIColor whiteColor];
    myInformationLabel.numberOfLines = 0;
    myInformationLabel.lineBreakMode = NSLineBreakByWordWrapping;
    myInformationLabel.text = @"Enter your phone number to make it easy for your friends to find you.";
    
    //---------------Creation of country number textField
    CGRect rectTFUsername = CGRectMake(0.5*screenWidth-(0.5*xUsername),yInitial,xUsername,yUsername);
    textFieldCountry = [[UITextField alloc] initWithFrame:rectTFUsername];
    textFieldCountry.textAlignment = NSTextAlignmentLeft;
    //textFieldCountry.borderStyle = UITextBorderStyleLine;
    textFieldCountry.delegate=self;
    textFieldCountry.backgroundColor = [UIColor clearColor];
    //textFieldCountry.placeholder = @"Ex: 0033";
    [textFieldCountry setFont:[UIFont systemFontOfSize:18]];
    textFieldCountry.keyboardType = UIKeyboardTypeNumberPad;
    //textFieldCountry.borderStyle = UITextBorderStyleRoundedRect;
    textFieldCountry.layer.cornerRadius = 4.0f;
    textFieldCountry.layer.borderWidth = 2.0f;
    textFieldCountry.layer.borderColor = [UIColor whiteColor].CGColor;
    
    int xflag = 31;
    int yflag = 21;
    flagImageView =[[UIImageView alloc] initWithFrame:CGRectMake(0.5*screenWidth-(0.5*xUsername)+(0.09*xUsername-0.5*xflag),yInitial+0.5*(yUsername-yflag),xflag,yflag)];//55,37
    flagImageView.clipsToBounds = YES;
    flagImageView.layer.cornerRadius = 4;
    flagImageView.contentMode = UIViewContentModeScaleAspectFit;
    flagImageView.image = [UIImage imageNamed:@"us.png"];
    
    int xtriangle = 17;
    int ytriangle = 17;
    triangleView =[[UIImageView alloc] initWithFrame:CGRectMake(flagImageView.frame.origin.x+flagImageView.frame.size.width+5,flagImageView.frame.origin.y+0.5*(flagImageView.frame.size.height-ytriangle),xtriangle,ytriangle)];//55,37
    triangleView.contentMode=UIViewContentModeScaleAspectFit;
    triangleView.image = [UIImage imageNamed:@"triangle.png"];
    
    //-----------------Creation of phone number textField
    CGRect rectTFPassword1 = CGRectMake(0.5*screenWidth-(0.5*xUsername)+0.28*xUsername,yInitial,0.72*xUsername,yUsername);
    textFieldPhoneNumber = [[UITextField alloc] initWithFrame:rectTFPassword1];
    textFieldPhoneNumber.textAlignment = NSTextAlignmentLeft;
    //textFieldPhoneNumber.borderStyle = UITextBorderStyleLine;
    textFieldPhoneNumber.delegate=self;
    textFieldPhoneNumber.backgroundColor = [UIColor clearColor];
    textFieldPhoneNumber.placeholder = @"enter your phone num";
    //textFieldPhoneNumber.borderStyle = UITextBorderStyleRoundedRect;
    textFieldPhoneNumber.keyboardType = UIKeyboardTypeNumberPad;
    textFieldPhoneNumber.layer.cornerRadius = 4;
    textFieldPhoneNumber.font = [UIFont fontWithName:@"GothamRounded-Bold" size:16];
    textFieldPhoneNumber.textColor = [UIColor whiteColor];
    
    
    //-----------------Creation of "Confirm number" button
    logInButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    logInButton.frame = CGRectMake(0.5*screenWidth-(0.5*xButton),yInitial+yUsername+10,xButton,yUsername-10);
    logInButton.backgroundColor = thePicteverYellowColor;
    logInButton.layer.cornerRadius = 4;
    logInButton.clipsToBounds = YES;
    [logInButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [logInButton setTitle:@"Start" forState:UIControlStateNormal];
    [logInButton.titleLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:16]];
    [logInButton addTarget:self
                    action:@selector(myActionLogIn:)
          forControlEvents:UIControlEventTouchUpInside];
    
    
    phoneSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    phoneSpinner.center = CGPointMake(0.5*screenWidth+0.5*xButton+15,yInitial+yUsername+10+0.5*(yUsername-10));
    phoneSpinner.color = [UIColor whiteColor];
    phoneSpinner.hidesWhenStopped = YES;
    
    //--------------creation of label information 2
    CGRect rectLabInformation2 = CGRectMake(0.5*screenWidth-(0.5*xUsername),yInitial+2*yUsername-15,xUsername,60);
    myInformationLabel2 = [[UILabel alloc] initWithFrame: rectLabInformation2];
    [myInformationLabel2 setTextAlignment:NSTextAlignmentCenter];
    [myInformationLabel2 setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:12]];
    myInformationLabel2.textColor = [UIColor whiteColor];
    myInformationLabel2.numberOfLines = 0;
    myInformationLabel2.lineBreakMode = NSLineBreakByCharWrapping;
    myInformationLabel2.text = @"(We will never misuse it)";
    
    
    //-------------------Creation of back button
    backButton3 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    backButton3.frame = CGRectMake(5,screenHeight-45,70,30);
    [backButton3 setTitle:@"Back" forState:UIControlStateNormal];
    [backButton3 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton3.titleLabel setFont:[UIFont fontWithName:@"GothamRounded-Bold" size:16]];
    backButton3.backgroundColor = thePicteverGreenColor;
    backButton3.layer.cornerRadius = 4;
    backButton3.clipsToBounds = YES;
    backButton3.alpha = 1;
    [backButton3 addTarget:self
                    action:@selector(backPressed3)
          forControlEvents:UIControlEventTouchUpInside];
    
    
    //----------------show subviews
    [self.view addSubview: backButton3];
    //[self.view addSubview: myWelcomeLabel];
    [self.view addSubview: textFieldCountry];
    [self.view addSubview: textFieldPhoneNumber];
    [self.view addSubview: logInButton];
    [self.view addSubview:phoneSpinner];
    [self.view addSubview:flagImageView];
    [self.view addSubview:triangleView];
    [self.view addSubview:myInformationLabel];
    [self.view addSubview:myInformationLabel2];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end




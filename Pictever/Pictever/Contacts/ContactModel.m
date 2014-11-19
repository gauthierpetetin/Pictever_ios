//
//  ContactModel.m
//  Shyft
//
//  Created by Gauthier Petetin on 26/10/2014.
//  Copyright (c) 2014 Gauthier Petetin. All rights reserved.
//
#import "ContactModel.h"
#import <Foundation/Foundation.h>
#import "PickContact.h"


#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>


@interface ContactModel ()


@end

@implementation ContactModel

NSUserDefaults *prefs;

NSString *myCurrentPhoneNumber;
NSString *username;
NSString *myCountryCode;

bool loadAllcontacts;

NSMutableArray *importContactsData; //Array that contains all the contacts from the phone
NSMutableDictionary *importKeoPhotos;//Array that contains all the photos of my contacts

///////info given by the server about the shyft users (answer of "upload_contacts" request)/////
NSMutableArray *importContactPhones;
NSMutableArray *importContactMails;
NSMutableArray *importContactIDs;
/////////////////////////////////////////////////////////


- (instancetype)init{
    if ((self = [super init])) {
        APLLog(@"initContactWithName");
        if([prefs objectForKey:@"allKeoNumbers"]){
            NSArray *importContactPhonesCopy;
            importContactPhonesCopy = [prefs objectForKey:@"allKeoNumbers"];
            importContactPhones = [importContactPhonesCopy mutableCopy];
        }
        if([prefs objectForKey:@"allKeoMails"]){
            NSArray *importContactMailsCopy;
            importContactMailsCopy = [prefs objectForKey:@"allKeoMails"];
            importContactMails = [importContactMailsCopy mutableCopy];
        }
        if([prefs objectForKey:@"allKeoIDs"]){
            NSArray *importContactIDsCopy;
            importContactIDsCopy = [prefs objectForKey:@"allKeoIDs"];
            importContactIDs = [importContactIDsCopy mutableCopy];
        }
        
        importContactsData = [self getAllContacts];
        while(!loadAllcontacts){
            APLLog(@"loading contacts");
        }
        APLLog(@"addPhotosToContact");
        
        importKeoPhotos = [PickContact addPhotosToAllContacts];
        
        //-----------prepare the contacts tableview such that we don't have to wait for it later
        [PickContact initImportContactNames];
    }
    return self;
}

-(bool)contactsLoaded{
    return loadAllcontacts;
}


-(NSMutableArray *)getAllContacts{
    
    CFErrorRef *error = nil;
    
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    
    __block BOOL accessGranted = NO;
    if (ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        
    }
    else { // we're on iOS 5 or older
        accessGranted = YES;
    }
    
    if (accessGranted) {
        
#ifdef DEBUG
        APLLog(@"Fetching contact info ----> ");
#endif
        
        
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
        //ABRecordRef source = ABAddressBookCopyDefaultSource(addressBook);
        //CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, source, kABPersonSortByLastName);
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople (addressBook);
        CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
        NSMutableArray* items = [NSMutableArray arrayWithCapacity:nPeople];
        NSMutableArray *nnnPeople = (__bridge NSMutableArray *)allPeople;
        
        
        for (int i = 0; i < [nnnPeople count]; i++){
            
            bool contactNotEmpty = false;
            NSMutableDictionary *contacts = [[NSMutableDictionary alloc] init];
            
            ABRecordRef person = ABPersonCreate();
            
            id personid = [nnnPeople objectAtIndex:i];
            if(![personid isKindOfClass:[NSNull class]]){
                person = (__bridge ABRecordRef)personid;
            }
            
            NSString *firstNames = @"";
            
            if(person){
                firstNames = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
            }
            
            
            NSString *lastNames = @"";
            if(person){
                lastNames =  (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
            }
            
            
            NSString *fullName = @"";
            
            if (!firstNames) {
                firstNames = @"";
                if(!lastNames){
                    lastNames = @"";
                    fullName = @"";
                }
                else{
                    fullName = lastNames;
                }
            }
            else if (!lastNames) {
                lastNames = @"";
                fullName = firstNames;
            }
            else{
                fullName = [NSString stringWithFormat:@"%@ %@", lastNames, firstNames];
            }
            
            
            [contacts setObject:fullName forKey:@"fullName"];
            
            
            if(![firstNames isEqualToString:@""]){
                contactNotEmpty = true;
            }
            if(![lastNames isEqualToString:@""]){
                contactNotEmpty = true;
            }
            
            [contacts setObject:firstNames forKey:@"firstNames"];
            [contacts setObject:lastNames forKey:@"lastNames"];
            
            
            
            // get contacts picture, if pic doesn't exists, show standart one
            
            NSData  *imgData = [[NSData alloc] init];
            if(person){
                imgData = (__bridge NSData *)ABPersonCopyImageData(person);
            }
            
            
            UIImage *image;
            if(imgData){
                image = [UIImage imageWithData:imgData];
            }
            else{
                image = nil;
            }
            
            
            if (!image) {
                image = [UIImage imageNamed:@"NoPhoto.png"];
            }
            if(image){
                [contacts setObject:image forKey:@"image"];
            }
            
    
            //get Phone Numbers
            
            NSMutableArray *phoneNumbers = [[NSMutableArray alloc] init];
            
            ABMultiValueRef multiPhones = ABRecordCopyValue(person, kABPersonPhoneProperty);
            for(CFIndex i=0;i<ABMultiValueGetCount(multiPhones);i++) {
                
                CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(multiPhones, i);
                NSString *phoneNumber = (__bridge NSString *) phoneNumberRef;
                phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
                phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"." withString:@""];
                phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
                phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
                phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"+" withString:@"00"];
                phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"(0)" withString:@""];
                phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
                phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
                if([phoneNumber length] > 1){
                    if(![[phoneNumber substringToIndex:2] isEqualToString:@"00"]){
                        phoneNumber = [NSString stringWithFormat:@"%@%@", myCountryCode,[phoneNumber substringFromIndex:1]];
                    }
                }
                
                [phoneNumbers addObject:phoneNumber];
                
                CFRelease(phoneNumberRef);
                
            }
            
            if([phoneNumbers count]>0){
                [contacts setObject:[phoneNumbers objectAtIndex:0] forKey:@"phoneNumber1"];
                if([self checkPhoneNumber:[phoneNumbers objectAtIndex:0]]){
                    NSArray *phCheckAnswer = [self checkPhoneNumber:[phoneNumbers objectAtIndex:0]];
                    if([phCheckAnswer count]>2){
                        [contacts setObject:[phCheckAnswer objectAtIndex:0] forKey:@"email"];
                        [contacts setObject:[phCheckAnswer objectAtIndex:1] forKey:@"user_id"];
                    }
                }
                if([phoneNumbers count]>1){
                    [contacts setObject:[phoneNumbers objectAtIndex:1] forKey:@"phoneNumber2"];
                    if([self checkPhoneNumber:[phoneNumbers objectAtIndex:1]]){
                        NSArray *phCheckAnswer = [self checkPhoneNumber:[phoneNumbers objectAtIndex:1]];
                        if([phCheckAnswer count]){
                            [contacts setObject:[phCheckAnswer objectAtIndex:0] forKey:@"email"];
                            [contacts setObject:[phCheckAnswer objectAtIndex:1] forKey:@"user_id"];
                        }
                    }
                }
                else{
                    [contacts setObject:@"" forKey:@"phoneNumber2"];
                    [contacts setObject:@"" forKey:@"user_id"];
                    [contacts setObject:@"" forKey:@"email"];
                }
            }
            else{
                [contacts setObject:@"" forKey:@"phoneNumber1"];
                [contacts setObject:@"" forKey:@"phoneNumber2"];
                [contacts setObject:@"" forKey:@"user_id"];
                [contacts setObject:@"" forKey:@"email"];
            }
            
            
            if(contactNotEmpty){
                [items addObject:contacts];
            }
            
            
            CFRelease(multiPhones);
            
#ifdef DEBUG
            
#endif
            
        }
        
        CFRelease(allPeople);
        CFRelease(addressBook);
        
        //CFRelease(source);
        
        if(myCurrentPhoneNumber){
            NSMutableDictionary * contactMe = [[NSMutableDictionary alloc] init];
            [contactMe setObject:@"Myself" forKey:@"firstNames"];
            [contactMe setObject:@"" forKey:@"lastNames"];
            [contactMe setObject:@"Myself" forKey:@"fullName"];
            [contactMe setObject:[UIImage imageNamed:@"my_keo_image.png"] forKey:@"image"];
            if(myCurrentPhoneNumber){
                [contactMe setObject:myCurrentPhoneNumber forKey:@"phoneNumber1"];
            }
            else{
                [contactMe setObject:@"" forKey:@"phoneNumber1"];
            }
            [contactMe setObject:@"" forKey:@"phoneNumber2"];
            if(username){
                [contactMe setObject:username forKey:@"email"];
            }
            else{
                [contactMe setObject:@"" forKey:@"email"];
            }
            [contactMe setObject:@"" forKey:@"user_id"];
            
            [items insertObject:contactMe atIndex:[items count]];
        }
        
        loadAllcontacts = true;
        APLLog(@"--->end fetching contacts");
        
        return items;
        
        
    }
    else {
#ifdef DEBUG
        APLLog(@"Cannot fetch Contacts :( ");
#endif
        return nil;
        
        
    }
}

-(NSArray *)checkPhoneNumber:(NSString *)pho{
    if([importContactPhones containsObject:pho]){
        NSString *mail = [importContactMails objectAtIndex:[importContactPhones indexOfObject:pho]];
        NSString *ID = [importContactIDs objectAtIndex:[importContactPhones indexOfObject:pho]];
        NSMutableArray *answer = [[NSMutableArray alloc] init];
        [answer insertObject:mail atIndex:0];
        [answer insertObject:ID atIndex:1];
        return answer;
    }
    return nil;
}


@end
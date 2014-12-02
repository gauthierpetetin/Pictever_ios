//
//  PickContact.h
//  Keo
//
//  Created by Gauthier Petetin on 25/05/2014.
//  Copyright (c) 2014 Gauthier Petetin. All rights reserved.
//

/////APPLAUSE
#import <Applause/APLLogger.h>

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
@class GPRequests;
@class GPSession;

@interface PickContact : UITableViewController <ABPeoplePickerNavigationControllerDelegate>

- (IBAction)confirmPressed:(id)sender;
- (IBAction)cancelPressed:(id)sender;

+(void)initImportContactNames;
+(NSMutableDictionary *)addPhotosToContact2:(NSMutableDictionary *)kContact;
+(void)initLocalKeoContacts;
+(void)updateAllContacts:(NSArray *)updateArray;
+(void)addKeoAccount:(NSString *)keoAccountAdress addUserId:(NSString *)userId ToContact:(NSString *)contactPhoneNumber andAddStatus:(NSString *)contStatus andAddFbID:(NSString*)contactFbId andAddFbName:(NSString *)contactFbName;
+(NSMutableDictionary *)addPhotosToAllContacts;
+(NSMutableDictionary *)addPhotosToContact:(NSMutableDictionary *)kContact atKey:(NSString *)tKey;
+(NSMutableArray *)placeMyselfOnTop:(NSMutableArray *)myKeoContacts3;
+(NSInteger)indexOfContactMyselfInMutableArray:(NSMutableArray *)myKeoContacts2;
+(void)updateMyStatus;
@end





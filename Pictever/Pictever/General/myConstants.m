//
//  myConstants.m
//  Shyft
//
//  Created by Gauthier Petetin on 17/10/2014.
//  Copyright (c) 2014 Gauthier Petetin. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "myConstants.h"



@implementation myConstants


//------------messages in the UITableview timeline--------
NSString *const my_shyft_id_Key = @"message_id";
NSString *const my_from_email_Key = @"from_email";
NSString *const my_from_id_Key = @"from_id";
NSString *const my_from_numero_Key = @"from_numero";
NSString *const my_message_Key = @"message";
NSString *const my_created_at_Key = @"created_at";
NSString *const my_received_at_Key = @"received_at";
NSString *const my_photo_Key = @"photo";
NSString *const my_receive_label_Key = @"receive_label";
NSString *const my_receive_color_Key = @"receive_color";
NSString *const my_loaded_Key = @"loaded";//"yes", "no" or "in_progress"
NSString *const my_color_Key = @"color";
NSString *const my_uicontrol_Key = @"UIControl";
NSString *const my_first_name_Key = @"firstNames";
NSString *const my_last_name_Key = @"lastNames";
NSString *const my_full_name_Key = @"fullName";
NSString *const my_from_facebook_id_key = @"from_facebook_id";
NSString *const my_from_facebook_name_key = @"from_facebook_name";

NSString *const my_inprogress_string = @"in_progress";

//--------Request Names----------------
NSString *const my_sendRequestName = @"send";
NSString *const my_receiveRequestName = @"receive_all";
NSString *const my_uploadRequestName = @"upload_contacts";
NSString *const my_addressBookRequestName = @"upload_address_book";
NSString *const my_getABRequestName = @"get_address_book";
NSString *const my_keoChoiceRequestName = @"get_send_choices";
NSString *const my_loginRequestName = @"login";
NSString *const my_registerRequestName = @"signup";
NSString *const my_defineFirstPhoneRequestName = @"define_first_phone_number";
NSString *const my_futureMessagesRequestName = @"get_number_of_future_messages";
NSString *const my_getStatusRequestName = @"get_my_status";
NSString *const my_resendRequestName = @"resend";
NSString *const my_sendResetMail = @"send_reset_mail";
NSString *const my_defineNewPassword = @"define_new_password";

//-------------ABREquest-----------------
NSString *const my_AB_tel_Key = @"tel";
NSString *const my_AB_name_Key = @"name";

NSString *const my_default_adresseIp=@"http://instant-pictever.herokuapp.com/";

NSString *const my_facebook_page_adress = @"https://www.facebook.com/pictever";


//------------string if the field "photo" if the message is a text message--------
NSString *const no_photo_string = @"None";

//-------------default color code (turquoise)-------------------------------------
NSString *const default_color_code = @"008b8b";

//-------------placed in field "photo" of if the photo is not downnloaded---------
NSString *const image_not_downloaded_string = @"download_error";
//-------------name of default image if the photo is not downnloaded--------------
NSString *const default_image_name = @"image_not_available.png";

//--------------cropped image height-----------------------------------------------
const int default_cropped_image_heigth = 300;

//----------------timeline dimensions---------------------------------------------
const int timeline_marge_width = 10;


//----------------saving constants------------------------------------------------
NSString *const my_status_saving_Key = @"myStatus";


//-------------------storyboard names--------------------------------------------
NSString *const my_storyboard_message_Name = @"WriteMessage";
NSString *const my_storyboard_picture_Name = @"TakePicture3";
NSString *const my_storyboard_timeline_Name = @"KeoMessages";
NSString *const my_storyboard_pickContact_Name = @"PickContact";
NSString *const my_storyboard_master_controller = @"MasterController";
NSString *const my_storyboard_phone_screen = @"phoneScreen";
NSString *const my_storyboard_password_recovery = @"passwordRecovery";


//------------------send request fields-------------------------------------------
NSString *const my_message_send_request_field = @"message";
NSString *const my_receiver_ids_send_request_field = @"receiver_ids";
NSString *const my_photo_send_request_field = @"photo";
NSString *const my_keo_choice_send_request_field = @"keo_choice";

//----------------background color for text messages (almost white)---------------
NSString * const whiteColorString = @"f0f8ff";


//----------------uploadContact answer--------------------------------------------
NSString *const my_uploadContact_email = @"email";
NSString *const my_uploadContact_phoneNumber = @"phoneNumber1";
NSString *const my_uploadContact_user_id = @"user_id";
NSString *const my_uploadContact_status = @"status";
NSString *const my_uploadContact_facebook_id = @"facebook_id";
NSString *const my_uploadContact_facebook_name = @"facebook_name";

//--------------------send choices labels-----------------------------------------
NSString *const my_sendChoice_order_id = @"order_id";
NSString *const my_sendChoice_key = @"key";
NSString *const my_sendChoice_send_label = @"send_label";

//----------------------login answer----------------------------------------------
NSString *const my_downloadPhotoRequestName_key = @"downloadPhotoRequestName";
NSString *const my_aws_account_id_key = @"aws_account_id";
NSString *const my_cognito_pool_id_key = @"cognito_pool_id";
NSString *const my_cognito_role_auth_key = @"cognito_role_auth";
NSString *const my_cognito_role_unauth_key = @"cognito_role_unauth";
NSString *const my_login_bucket_name_key = @"bucket_name";

NSString *const my_login_user_id_key = @"user_id";
NSString *const my_login_web_app_url_key = @"web_app_url";
NSString *const my_login_ios_version_needed_key = @"ios_version_needed";
NSString *const my_login_ios_update_link_key = @"ios_update_link";
NSString *const my_login_force_update_key = @"force_update";

//-------------------------preferences saving--------------------------------------
NSString *const my_prefs_S3BucketName_key = @"S3BucketName";
NSString *const my_prefs_keo_occurences_key = @"importKeoOccurences";
NSString *const my_prefs_timestamp_key = @"timeStamp";
NSString *const my_prefs_login_key = @"logIn";
NSString *const my_prefs_username_key = @"username";
NSString *const my_prefs_password_key = @"password";
NSString *const my_prefs_phoneNumber_key = @"phoneNumber";
NSString *const my_prefs_countryCode_key = @"countryCode";
NSString *const my_prefs_send_tips_key = @"sendTips";
NSString *const my_prefs_receive_tips_key = @"receiveTips";
NSString *const my_prefs_fb_name_key = @"fb_name";
NSString *const my_prefs_fb_id_key = @"fb_id";
NSString *const my_prefs_fb_birthday_key = @"fb_birthday";
NSString *const my_prefs_contacts_data_key = @"importcontactsdata";
NSString *const my_prefs_userid_key = @"myUserID";
NSString *const my_prefs_numberoffuturemessages_key = @"numberOfMessagesInTheFuture";
NSString *const my_prefs_mystatus_key = @"myStatus";
NSString *const my_prefs_sendbox_key = @"sendBox";
NSString *const my_prefs_resendbox_key = @"resendBox";


//-------------------------sendBoxContent------------------------------------------
NSString *const my_sendbox_date = @"date";
NSString *const my_sendbox_recipient = @"recipient";
NSString *const my_sendbox_key = @"key";
NSString *const my_sendbox_keoTime = @"keoTime";
NSString *const my_sendbox_path = @"path";


//---------------------------actionsheet titles----------------------------------
NSString *const my_actionsheet_pick_a_date = @"Pick a date!";
NSString *const my_actionsheet_wanna_help_us = @"You like us?";
NSString *const my_actionsheet_wanna_help_us_french = @"Tu nous aimes bien?";
NSString *const my_actionsheet_you_are_great = @"You like us a lot?";
NSString *const my_actionsheet_you_are_great_french = @"Tu nous aimes beaucoup?";
NSString *const my_actionsheet_want_to_remember = @"Want to remember this message?";
NSString *const my_actionsheet_want_to_remember_french = @"Envie de te souvenir de ce message?";
NSString *const my_actionsheet_install_it_now = @"Do you want to install it now?";


//---------------------------notification names------------------------
NSString *const my_notif_showBilly_name = @"showBilly";
NSString *const my_notif_messageSentSuccessfully_name = @"messageSentSuccessfully";
NSString *const my_notif_messageResentSuccessfully_name = @"messageResentSuccessfully";

@end


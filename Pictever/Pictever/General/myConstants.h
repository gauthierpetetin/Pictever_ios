//
//  myConstants.h
//  Shyft
//
//  Created by Gauthier Petetin on 17/10/2014.
//  Copyright (c) 2014 Gauthier Petetin. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const my_shyft_id_Key;
extern NSString *const my_from_email_Key;
extern NSString *const my_from_id_Key;
extern NSString *const my_from_numero_Key;
extern NSString *const my_message_Key;
extern NSString *const my_created_at_Key;
extern NSString *const my_received_at_Key;
extern NSString *const my_photo_Key;
extern NSString *const my_receive_label_Key;
extern NSString *const my_receive_color_Key;
extern NSString *const my_loaded_Key;
extern NSString *const my_color_Key;
extern NSString *const my_uicontrol_Key;
extern NSString *const my_first_name_Key;
extern NSString *const my_last_name_Key;
extern NSString *const my_full_name_Key;

extern NSString *const my_inprogress_string;


//--------Request Names----------------
extern NSString *const my_sendRequestName;
extern NSString *const my_receiveRequestName;
extern NSString *const my_uploadRequestName;
extern NSString *const my_keoChoiceRequestName;
extern NSString *const my_loginRequestName;
extern NSString *const my_registerRequestName;
extern NSString *const my_defineFirstPhoneRequestName;
extern NSString *const my_futureMessagesRequestName;
extern NSString *const my_getStatusRequestName;
extern NSString *const my_resendRequestName;
extern NSString *const my_sendResetMail;
extern NSString *const my_defineNewPassword;

extern NSString *const my_default_adresseIp;

extern NSString *const my_facebook_page_adress;

extern NSString *const no_photo_string;

extern NSString *const default_color_code;

extern NSString *const image_not_downloaded_string;

extern NSString *const default_image_name;

const int default_cropped_image_heigth;

//----------------saving constants------------------------------------------------
extern NSString *const my_status_saving_Key;

//-------------------storyboard names-------------------------------------------
extern NSString *const my_storyboard_message_Name;
extern NSString *const my_storyboard_picture_Name;
extern NSString *const my_storyboard_timeline_Name;
extern NSString *const my_storyboard_pickContact_Name;
extern NSString *const my_storyboard_master_controller;
extern NSString *const my_storyboard_phone_screen;
extern NSString *const my_storyboard_password_recovery;

//------------------send request fields-------------------------------------------
extern NSString *const my_message_send_request_field;
extern NSString *const my_receiver_ids_send_request_field;
extern NSString *const my_photo_send_request_field;
extern NSString *const my_keo_choice_send_request_field;

//----------------background color for text messages (almost white)---------------
extern NSString * const whiteColorString;

//----------------uploadContact answer--------------------------------------------
extern NSString *const my_uploadContact_email;
extern NSString *const my_uploadContact_phoneNumber;
extern NSString *const my_uploadContact_user_id;
extern NSString *const my_uploadContact_status;

//--------------------send choices labels-------------------------------------------
extern NSString *const my_sendChoice_order_id;
extern NSString *const my_sendChoice_key;
extern NSString *const my_sendChoice_send_label;

//----------------------login answer----------------------------------------------
extern NSString *const my_downloadPhotoRequestName_key;
extern NSString *const my_aws_account_id_key;
extern NSString *const my_cognito_pool_id_key;
extern NSString *const my_cognito_role_auth_key;
extern NSString *const my_cognito_role_unauth_key;
extern NSString *const my_login_bucket_name_key;

extern NSString *const my_login_user_id_key;
extern NSString *const my_login_web_app_url_key;
extern NSString *const my_login_ios_version_needed_key;
extern NSString *const my_login_ios_update_link_key;
extern NSString *const my_login_force_update_key;

//-------------------------preferences saving--------------------------------------
extern NSString *const my_prefs_S3BucketName_key;
extern NSString *const my_prefs_keo_occurences_key;
extern NSString *const my_prefs_timestamp_key;
extern NSString *const my_prefs_login_key;
extern NSString *const my_prefs_username_key;
extern NSString *const my_prefs_password_key;
extern NSString *const my_prefs_phoneNumber_key;
extern NSString *const my_prefs_countryCode_key;
extern NSString *const my_prefs_send_tips_key;
extern NSString *const my_prefs_receive_tips_key;

//-------------------------sendBoxContent------------------------------------------
extern NSString *const my_sendbox_date;
extern NSString *const my_sendbox_recipient;
extern NSString *const my_sendbox_key;
extern NSString *const my_sendbox_keoTime;
extern NSString *const my_sendbox_path;

//---------------------------actionsheet titles----------------------------------
extern NSString *const my_actionsheet_pick_a_date;
extern NSString *const my_actionsheet_wanna_help_us;
extern NSString *const my_actionsheet_you_are_great;
extern NSString *const my_actionsheet_want_to_remember;
extern NSString *const my_actionsheet_install_it_now;


@interface myConstants: NSObject

@end
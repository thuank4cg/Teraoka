//
//  APPConstants.h
//  Teraoka
//
//  Created by Thuan on 11/8/17.
//  Copyright © 2017 ss. All rights reserved.
//

#ifndef APPConstants_h
#define APPConstants_h

#import "AppDelegate.h"
#define appDelegate ((AppDelegate *)[UIApplication sharedApplication].delegate)

#define HOST_NAME @"192.168.1.100"
#define PORT 9088
#define USERNAME @"root"
#define PASSWORD @"teraoka"

#define KEY_SAVED_DATA @"IS_SAVED_DATA"
#define KEY_SAVED_SETTING @"IS_SAVED_SETTING"
#define KEY_CURRENT_LANGUAGE @"KEY_CURRENT_LANGUAGE"

#define KEY_FONT_BOLD @"SFUIDisplay-Bold"
#define KEY_FONT_REGULAR @"SFUIDisplay-Regular"

#define KEY_SURFFIX_FILE @"txt"
#define KEY_PRODUCT_TABLE_FILE_NAME @"plu"
#define KEY_CATEGORY_TABLE_FILE_NAME @"menu_category"
#define KEY_MENU_CONTENT_TABLE_FILE_NAME @"menu_contents"

//menu_category
#define KEY_CATEGORY_ID @"category_no"
#define KEY_CATEGORY_NAME @"category_name"

//plu
#define KEY_PRODUCT_ID @"plu_no"
#define KEY_PRODUCT_PRICE @"price"
#define KEY_PRODUCT_NAME @"item_name"

//byte size
#define REPLY_HEADER 4
#define REPLY_COMMAND_SIZE 4
#define REPLY_COMMAND_ID 4
#define REPLY_REQUEST_ID 4
#define REPLY_STORE_STATUS 2
#define REPLY_LAST_EVENT_ID 4
#define REPLY_STATUS 4
#define REPLY_DATA_SIZE 4

//error id
#define ERROR_ID_OUT_OF_STOCK @"0401"

//language
#define KEY_LANG_EN @"en"
#define KEY_LANG_CH @"zh-Hans"

#define KEY_LANGUAGE_ARR @[@"English", @"Chinese"]

#endif /* APPConstants_h */

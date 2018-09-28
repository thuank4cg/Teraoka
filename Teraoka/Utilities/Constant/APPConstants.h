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

#define KEY_NOTIFY_OUT_OF_STOCK @"out_of_stock_notification"

#define KEY_SURFFIX_FILE @"txt"
#define KEY_PRODUCT_TABLE_FILE_NAME @"plu"
#define KEY_CATEGORY_TABLE_FILE_NAME @"menu_category"
#define KEY_MENU_CONTENT_TABLE_FILE_NAME @"menu_contents"
#define KEY_OPTION_GROUP_HEADER_TABLE_FILE_NAME @"option_group_header"
#define KEY_OPTION_GROUP_TABLE_FILE_NAME @"option_group"
#define KEY_COMMENT_GROUP_HEADER_TABLE_FILE_NAME @"comment_group_header"
#define KEY_COMMENT_GROUP_TABLE_FILE_NAME @"comment_group"
#define KEY_COMMENT_TABLE_FILE_NAME @"comment"
#define KEY_COMMENT_SET_TABLE_FILE_NAME @"comment_set"
#define KEY_SERVING_SET_TABLE_FILE_NAME @"serving_set"
#define KEY_SERVING_GROUP_HEADER_TABLE_FILE_NAME @"serving_group_header"
#define KEY_SERVING_GROUP_TABLE_FILE_NAME @"serving_group"
#define KEY_SERVING_TIMING_TABLE_FILE_NAME @"serving_timing"
#define KEY_OPTION_SET_TABLE_FILE_NAME @"option_set"

#define PLU_TABLE_NAME @"Plu"
#define MENU_CATEGORY_TABLE_NAME @"MenuCategory"
#define MENU_CONTENTS_TABLE_NAME @"MenuContents"
#define OPTION_GROUP_HEADER_TABLE_NAME @"OptionGroupHeader"
#define OPTION_GROUP_TABLE_NAME @"OptionGroup"
#define COMMENT_GROUP_HEADER_TABLE_NAME @"CommentGroupHeader"
#define COMMENT_GROUP_TABLE_NAME @"CommentGroup"
#define COMMENT_TABLE_NAME @"Comment"
#define COMMENT_SET_TABLE_NAME @"CommentSet"
#define SERVING_SET_TABLE_NAME @"ServingSet"
#define SERVING_GROUP_HEADER_TABLE_NAME @"ServingGroupHeader"
#define SERVING_GROUP_TABLE_NAME @"ServingGroup"
#define SERVING_TIMING_TABLE_NAME @"ServingTiming"
#define OPTION_SET_TABLE_NAME @"OptionSet"

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
#define KEY_LANG_EN @"English"
#define KEY_LANG_CH @"Chinese"

#define KEY_LANGUAGE_ARR @[@"English", @"Chinese"]

#endif /* APPConstants_h */

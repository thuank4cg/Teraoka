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

#define ROOT_API_URL @"http://dmc.teraoka.com.sg:8081/"

//#define HOST_NAME @"192.168.1.100"
#define PORT 9088
#define USERNAME @"root"
#define PASSWORD @"teraoka"

#define DOCUMENT_DIRECTORY_ROOT [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject].path
#define PLU_IMAGE_DIRECTORY_PATH @"/opt/pcscale/files/img/plu"

#define STATUS_REPLY_OK @"00000000"

#define KEY_SAVED_DATA @"IS_SAVED_DATA"
#define KEY_SAVED_SETTING @"IS_SAVED_SETTING"
#define KEY_CURRENT_CONTENT_LANGUAGE @"KEY_CURRENT_CONTENT_LANGUAGE"
#define KEY_LICENSE_VALID @"KEY_LICENSE_VALID"
#define KEY_SAVED_BILL_NO @"KEY_SAVED_BILL_NO"
#define KEY_LATEST_FILE_NAME @"KEY_LATEST_FILE_NAME"
#define KEY_LAST_SYNCED_TIME @"KEY_LAST_SYNCED_TIME"

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
#define KEY_TABLE_NO_TABLE_FILE_NAME @"table_no"

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
#define TABLE_NO_TABLE_NAME @"TableNo"

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

//Protocol
#define ERROR_ID_INVALID_COMMAND @"0101"
#define ERROR_ID_SIZE_ERROR @"0102"
#define ERROR_ID_VER_MISMATCH @"0103"

//Ordering
#define ERROR_ID_NO_ITEM_DETAIL @"0201"
#define ERROR_ID_OVER_QTY @"0202"
#define ERROR_ID_INVALID_COUPON @"0203"
#define ERROR_ID_INVALID_COUPON_COMB @"0204"

//Bill
#define ERROR_ID_VACANT @"0301"
#define ERROR_ID_CHECKOUTED @"0302"
#define ERROR_ID_INVALID_BILL @"0303"
#define ERROR_ID_CHECKOUTING @"0304"
#define ERROR_ID_BILL_CHANGED @"0305"
#define ERROR_ID_BILL_LOCKED @"0306"

//LOQ
#define ERROR_ID_OUT_OF_STOCK @"0401"

//Master
#define ERROR_ID_TABLE @"0501"
#define ERROR_ID_STAFF @"0502"
#define ERROR_ID_PLU @"0503"
#define ERROR_ID_MEALSET @"0504"
#define ERROR_ID_OPTION @"0505"
#define ERROR_ID_COMMENT @"0506"
#define ERROR_ID_SERVING_TIME @"0507"
#define ERROR_ID_BUFFET @"0508"
#define ERROR_ID_INVALID_PRINTER_GROUP @"0509"

//DB
#define ERROR_ID_ACCESSING @"0601"
#define ERROR_ID_DB_COLLAPSE @"0602"

//Application
#define ERROR_ID_NO_APPL @"0701"

//Authority
#define ERROR_ID_NO_AUTHORITY @"0801"

//Unknown
#define ERROR_ID_NO_UNKNOW_ERROR @"6363"

#endif /* APPConstants_h */

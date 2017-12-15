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

#define HOST_NAME @"ftp://192.69.69.69"
#define USERNAME @"root"
#define PASSWORD @"teraoka"

#define KEY_SAVED_DATA @"IS_SAVED_DATA"

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

#endif /* APPConstants_h */

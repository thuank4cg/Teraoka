//
//  Util.h
//  Teraoka
//
//  Created by Thuan on 11/9/17.
//  Copyright © 2017 ss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ProductModel.h"
#import <CoreData/CoreData.h>
#import "SettingModel.h"

@interface Util : NSObject

+ (NSString *)convertDataToString:(NSData *)myData;
+ (void)saveFileToDocumentDirectory:(NSString *)dataStr;
+ (NSString *)hexadecimalString:(NSData *)receivedData;
+ (void)showAlert:(NSString *)msg vc:(UIViewController *)vc;
+ (int)hexStringToInt:(NSString *)hex;
+ (void)setLanguage:(NSString *)content;
+ (void)showError:(NSString *)errorId vc:(UIViewController *)vc;
+ (BOOL)isConnectionInternet;
+ (BOOL)checkLicenseKeyValid;
+ (ProductModel *)getPlu:(NSManagedObject *)plu tax:(NSArray *)taxList;
+ (SettingModel *)getSetting;
+ (void)saveSetting:(SettingModel *)setting;

@end

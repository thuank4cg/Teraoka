//
//  Util.h
//  Teraoka
//
//  Created by Thuan on 11/9/17.
//  Copyright © 2017 ss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Util : NSObject
+ (NSString *)convertDataToString:(NSData *)myData;
+ (void)saveFileToDocumentDirectory:(NSString *)dataStr;
+ (NSString *)hexadecimalString:(NSData *)receivedData;
+ (void)showAlert:(NSString *)msg vc:(UIViewController *)vc;
+ (int)hexStringToInt:(NSString *)hex;
@end

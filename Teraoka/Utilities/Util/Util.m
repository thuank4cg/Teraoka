//
//  Util.m
//  Teraoka
//
//  Created by Thuan on 11/9/17.
//  Copyright © 2017 ss. All rights reserved.
//

#import "Util.h"
#import <SIAlertView.h>
#import "LanguageModel.h"
#import "ShareManager.h"
#import "APPConstants.h"
#import "Reachability.h"

@implementation Util

+ (NSString *)convertDataToString:(NSData *)myData {
    NSString *dataStr = [[NSString alloc] initWithData:myData encoding:NSUTF8StringEncoding];
    return dataStr;
}

+ (void)saveFileToDocumentDirectory:(NSString *)dataStr {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *appFile = [documentsDirectory stringByAppendingPathComponent:@"myData.zip"];
    [dataStr writeToFile:appFile atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

+ (NSString *)hexadecimalString:(NSData *)receivedData {
    /* Returns hexadecimal string of NSData. Empty string if data is empty.   */
    
    const unsigned char *dataBuffer = (const unsigned char *)[receivedData bytes];
    
    if (!dataBuffer)
    {
        return [NSString string];
    }
    
    NSUInteger          dataLength  = [receivedData length];
    NSMutableString     *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
    
    for (int i = 0; i < dataLength; ++i)
    {
        [hexString appendFormat:@"%02x", (unsigned int)dataBuffer[i]];
    }
    
    return [NSString stringWithString:hexString];
}

+ (void)showAlert:(NSString *)msg vc:(UIViewController *)vc {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        
    }];
    [alert addAction:okAction];
    [vc presentViewController:alert animated:YES completion:nil];
}

+ (int)hexStringToInt:(NSString *)hex {
    NSScanner* pScanner = [NSScanner scannerWithString: hex];
    
    unsigned int iValue;
    [pScanner scanHexInt: &iValue];
    return iValue;
}

+ (void)setLanguage:(NSString *)content {
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName.lowercaseString ofType:@"csv"];
//    NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    NSArray *rows = [content componentsSeparatedByString:@"\n"];
    
    NSMutableArray *languages = [NSMutableArray new];
    
    for (NSString *row in rows){
        NSArray *data = [row componentsSeparatedByString:@","];
        if (data.count > 1) {
            LanguageModel *language = [[LanguageModel alloc] init];
            language.key = [data objectAtIndex:0];
            language.value = [[data objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
            [languages addObject:language];
        }
    }
    
    [ShareManager shared].languages = languages;
}
    
+ (void)showError:(NSString *)errorID vc:(UIViewController *)vc {
    NSString *msg;
    
    if ([errorID isEqualToString:ERROR_ID_INVALID_COMMAND]) {
        msg = @"Invalid command.";
    } else if ([errorID isEqualToString:ERROR_ID_SIZE_ERROR]) {
        msg = @"Invalid command/data size.";
    } else if ([errorID isEqualToString:ERROR_ID_VER_MISMATCH]) {
        msg = @"Invalid version.";
    } else if ([errorID isEqualToString:ERROR_ID_NO_ITEM_DETAIL]) {
        msg = @"There is no order items.";
    } else if ([errorID isEqualToString:ERROR_ID_OVER_QTY]) {
        msg = @"Over quantity.";
    } else if ([errorID isEqualToString:ERROR_ID_INVALID_COUPON]) {
        msg = @"Invalid coupon.";
    } else if ([errorID isEqualToString:ERROR_ID_INVALID_COUPON_COMB]) {
        msg = @"Invalid coupon combination.";
    } else if ([errorID isEqualToString:ERROR_ID_VACANT]) {
        msg = @"There is no items.";
    } else if ([errorID isEqualToString:ERROR_ID_CHECKOUTED]) {
        msg = @"Bill was already checkouted.";
    } else if ([errorID isEqualToString:ERROR_ID_INVALID_BILL]) {
        msg = @"Invalid Bill.";
    } else if ([errorID isEqualToString:ERROR_ID_CHECKOUTING]) {
        msg = @"Bill is checkouting now.";
    } else if ([errorID isEqualToString:ERROR_ID_BILL_CHANGED]) {
        msg = @"Bill record is changed at server side";
    } else if ([errorID isEqualToString:ERROR_ID_BILL_LOCKED]) {
        msg = @"Bill record is locked at server side";
    } else if ([errorID isEqualToString:ERROR_ID_OUT_OF_STOCK]) {
        msg = @"Out of stock.";
    } else if ([errorID isEqualToString:ERROR_ID_TABLE]) {
        msg = @"Missing Table.";
    } else if ([errorID isEqualToString:ERROR_ID_STAFF]) {
        msg = @"Missing Staff.";
    } else if ([errorID isEqualToString:ERROR_ID_PLU]) {
        msg = @"Missing PLU.";
    } else if ([errorID isEqualToString:ERROR_ID_MEALSET]) {
        msg = @"Missing Mealset Parent.";
    } else if ([errorID isEqualToString:ERROR_ID_OPTION]) {
        msg = @"Missing Option.";
    } else if ([errorID isEqualToString:ERROR_ID_COMMENT]) {
        msg = @"Missing Comment.";
    } else if ([errorID isEqualToString:ERROR_ID_SERVING_TIME]) {
        msg = @"Missing Servint Time.";
    } else if ([errorID isEqualToString:ERROR_ID_BUFFET]) {
        msg = @"Missing Buffet Parent.";
    } else if ([errorID isEqualToString:ERROR_ID_INVALID_PRINTER_GROUP]) {
        msg = @"Printer group not exist";
    } else if ([errorID isEqualToString:ERROR_ID_ACCESSING]) {
        msg = @"Could not access to DB. Please try again.";
    } else if ([errorID isEqualToString:ERROR_ID_DB_COLLAPSE]) {
        msg = @"DB may be collapsed.";
    } else if ([errorID isEqualToString:ERROR_ID_NO_APPL]) {
        msg = @"There is no application.";
    } else if ([errorID isEqualToString:ERROR_ID_NO_AUTHORITY]) {
        msg = @"You do not have the authority";
    } else {
        msg = @"Unknown error was occurred.";
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        
    }];
    [alert addAction:okAction];
    [vc presentViewController:alert animated:YES completion:nil];
}

+ (BOOL)isConnectionInternet {
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        return NO;
    }
    else {
        return YES;
    }
}

+ (BOOL)checkLicenseKeyValid {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:KEY_LICENSE_EXPIRY_DATE]) {
        NSString *expiryDateStr = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_LICENSE_EXPIRY_DATE];
        
//        NSDateFormatter *df = [[NSDateFormatter alloc] init];
//        df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
//
//        NSDate *expiryDate = [df dateFromString:expiryDateStr];
        
//        if ([expiryDate compare:[NSDate date]] == NSOrderedAscending) {
//            [[NSUserDefaults standardUserDefaults] removeObjectForKey:KEY_LICENSE_VALID];
//            [[NSUserDefaults standardUserDefaults] removeObjectForKey:KEY_LICENSE_EXPIRY_DATE];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//            return NO;
//        }
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        
        NSDate *expiryDate = [df dateFromString:expiryDateStr];
        NSDate *currentDate = [NSDate date];
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSInteger comps = (NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear);
        
        NSDateComponents *date1Components = [calendar components:comps
                                                        fromDate:expiryDate];
        NSDateComponents *date2Components = [calendar components:comps
                                                        fromDate:currentDate];
        
        expiryDate = [calendar dateFromComponents:date1Components];
        currentDate = [calendar dateFromComponents:date2Components];
        
        NSComparisonResult result = [expiryDate compare:currentDate];
        if (result == NSOrderedAscending) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:KEY_LICENSE_VALID];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:KEY_LICENSE_EXPIRY_DATE];
            [[NSUserDefaults standardUserDefaults] synchronize];
            return YES;
        }
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:KEY_LICENSE_VALID]) {
        return YES;
    }
    
    return YES;
}

+ (ProductModel *)getPlu:(NSManagedObject *)plu tax:(NSArray *)taxList {
    NSArray *directoryImageContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[NSString stringWithFormat:@"%@%@", DOCUMENT_DIRECTORY_ROOT, PLU_IMAGE_DIRECTORY_PATH] error:nil];
    
    ProductModel *product = [[ProductModel alloc] init];
    product.productNo = [plu valueForKey:@"plu_no"];
    
    product.image = [product getImageName:directoryImageContents];
    product.name = [NSString stringWithFormat:@"%@", [plu valueForKey:@"item_name"]];
    
    float price = [[plu valueForKey:@"price"] floatValue]/100;
    
    product.price = [NSString stringWithFormat:@"SGD %.2f", price];
    product.priceNumber = [NSString stringWithFormat:@"%.2f", price];
    
    product.originalPrice = [NSString stringWithFormat:@"%@", [plu valueForKey:@"price"]];
    product.qty = @"1";
    product.optionSource = [[plu valueForKey:@"option_source"] intValue];
    product.optionSourceNo = [[plu valueForKey:@"option_source_no"] intValue];
    product.servingSource = [[plu valueForKey:@"serving_source"] intValue];
    product.servingSourceNo = [[plu valueForKey:@"serving_source_no"] intValue];
    product.commentSource = [[plu valueForKey:@"comment_source"] intValue];
    product.commentSourceNo = [[plu valueForKey:@"comment_source_no"] intValue];
    product.options = [product getOptionGroupList];
    product.tax_no = [[plu valueForKey:@"tax_no"] intValue];
    product.rate = [product getRate:taxList];
    
    return product;
}

+ (SettingModel *)getSetting {
    NSString *json = [[NSUserDefaults standardUserDefaults] stringForKey:KEY_SAVED_SETTING];
    SettingModel *setting = [[SettingModel alloc] initWithString:json error:nil];
    
    if (!setting) setting = [[SettingModel alloc] init];
    
    return setting;
}

+ (void)saveSetting:(SettingModel *)setting {
    NSString *json = [setting toJSONString];
    [[NSUserDefaults standardUserDefaults] setObject:json forKey:KEY_SAVED_SETTING];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

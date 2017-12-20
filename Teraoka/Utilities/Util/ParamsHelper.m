//
//  ParamsHelper.m
//  Teraoka
//
//  Created by Thuan on 12/14/17.
//  Copyright © 2017 ss. All rights reserved.
//

#import "ParamsHelper.h"
#import "ShareManager.h"
#import "ProductModel.h"

#define MAX_VALUE 99999999
#define REQUEST_ID @"request_id"

@implementation ParamsHelper
+ (ParamsHelper *)shared {
    static ParamsHelper *_shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [[ParamsHelper alloc] init];
    });
    return _shared;
}

//- (NSString *)stringToHex:(NSString *)string
//{
//    char *utf8 = [string UTF8String];
//    NSMutableString *hex = [NSMutableString string];
//    while ( *utf8 ) [hex appendFormat:@"%02X" , *utf8++ & 0x00FF];
//
//    return [NSString stringWithFormat:@"%@", hex];
//}
//- (NSData *)dataFromHexString:(NSString *)string length:(int)length {
//    NSString *hexStr = [self stringToHex:string];
//    const char *chars = [hexStr UTF8String];
//    int i = 0, len = hexStr.length;
//
//    NSMutableData *data = [NSMutableData dataWithCapacity:len / 2];
//    char byteChars[3] = {'\0','\0','\0'};
//    unsigned long wholeByte;
//
//    while (i < len) {
//        byteChars[0] = chars[i++];
//        byteChars[1] = chars[i++];
//        wholeByte = strtoul(byteChars, NULL, 16);
//        [data appendBytes:&wholeByte length:length];
//    }
//
//    return data;
//}
//
//- (NSData *)intToData:(int)value length:(int)length {
//    return [NSData dataWithBytes:&value length:length];
//}

- (NSData *)convertStringToBytesArr:(NSString *)valueStr length:(int)length {
    NSString *hex = [NSString stringWithFormat:@"%08lX",
                        (unsigned long)[valueStr integerValue]];
//
//    unsigned char * myBuffer = (unsigned char *)malloc((int)[hexStr length] / 2 + 1);
//    bzero(myBuffer, [hexStr length] / 2 + 1);
//    for (int i = 0; i < [hexStr length] - 1; i += 2) {
//        unsigned int anInt;
//        NSString * hexCharStr = [hexStr substringWithRange:NSMakeRange(i, 2)];
//        NSScanner * scanner = [[NSScanner alloc] initWithString:hexCharStr];
//        [scanner scanHexInt:&anInt];
//        myBuffer[i / 2] = (char)anInt;
//    }
//    return myBuffer;
    NSMutableData* data = [NSMutableData data];
    int idx;
    int test = [hex length] - length*2;
    for (idx = test; idx+2 <= [hex length]; idx+=2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [hex substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    return data;
}

- (NSMutableData *)collectData {
    /**Header**/
    NSMutableData *mCollectData = [[NSMutableData alloc] init];
    [mCollectData appendBytes:"68" "71" "0" "0" length:4];
    
    //Command size
    int dataSize = (int)[self requestData].length;
    int commandSize = dataSize + 8;
    [mCollectData appendData:[self convertStringToBytesArr:@"13200" length:4]];

    //Command ID
    [mCollectData appendData:[self convertStringToBytesArr:[NSString stringWithFormat:@"%d", commandSize] length:2]];
    
    //Data size
    [mCollectData appendData:[self convertStringToBytesArr:[NSString stringWithFormat:@"%d", dataSize] length:4]];

    //Data
    [mCollectData appendData:[self requestData]];
    
    NSString *newLine = @"test\r\n";
    NSData *requestData = [newLine dataUsingEncoding:NSUTF8StringEncoding];
    [mCollectData appendData:requestData];
    
    return mCollectData;
}

- (NSMutableData *)requestData {
    NSMutableData *mCollectData = [[NSMutableData alloc] init];
    /**XRequestHeaderData**/
    //version
    [mCollectData appendBytes:"0" "1" "15" "0" length:4];
    
    //Request ID
    [mCollectData appendData:[self convertStringToBytesArr:[NSString stringWithFormat:@"%d", [self generatorRequestId]] length:4]];
    
    //Terminal No
    [mCollectData appendData:[self convertStringToBytesArr:@"1" length:2]];
    
    //Staff ID
    [mCollectData appendData:[self convertStringToBytesArr:@"1" length:4]];
    
    //Sending Date
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyymmdd";
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    [mCollectData appendData:[self convertStringToBytesArr:dateStr length:4]];
    
    //Sending Time
    formatter.dateFormat = @"hhmmss";
    NSString *timeStr = [formatter stringFromDate:[NSDate date]];
    [mCollectData appendData:[self convertStringToBytesArr:timeStr length:4]];
    
    /**XTransactionData**/
    //Number of object
    int numberOfObj = 0;
    int totalPrice = 0;
    for (ProductModel *product in [ShareManager shared].cartArr) {
        numberOfObj += [product.qty intValue];
        totalPrice += [product.originalPrice intValue];
    }
    [mCollectData appendData:[self convertStringToBytesArr:[NSString stringWithFormat:@"%d", numberOfObj] length:4]];
    
    /**XTransactionTotalData**/
    //Total price before item discount
    [mCollectData appendData:[self convertStringToBytesArr:[NSString stringWithFormat:@"%d", totalPrice] length:4]];
    
    //Total price before subtotal discount
    [mCollectData appendData:[self convertStringToBytesArr:[NSString stringWithFormat:@"%d", totalPrice] length:4]];
    
    //Discount amount
    [mCollectData appendData:[self convertStringToBytesArr:@"0" length:4]];
    
    //Surcharge amount
    [mCollectData appendData:[self convertStringToBytesArr:@"0" length:4]];
    
    //Total price after subtotal discount
    [mCollectData appendData:[self convertStringToBytesArr:[NSString stringWithFormat:@"%d", totalPrice] length:4]];
    
    //Taxable amount
    [mCollectData appendData:[self convertStringToBytesArr:@"0" length:4]];
    
    //Tax amount
    [mCollectData appendData:[self convertStringToBytesArr:@"0" length:4]];
    
    //Tax rate
    [mCollectData appendData:[self convertStringToBytesArr:@"0" length:4]];
    
    //Total price after tax
    [mCollectData appendData:[self convertStringToBytesArr:[NSString stringWithFormat:@"%d", totalPrice] length:4]];
    
    //Service chargable amount
    [mCollectData appendData:[self convertStringToBytesArr:@"0" length:4]];
    
    //Service charge amount
    [mCollectData appendData:[self convertStringToBytesArr:@"0" length:4]];
    
    //Service charge rate
    [mCollectData appendData:[self convertStringToBytesArr:@"0" length:2]];
    
    //Total price after service charge
    [mCollectData appendData:[self convertStringToBytesArr:[NSString stringWithFormat:@"%d", totalPrice] length:4]];
    
    //Extra chargable amount
    [mCollectData appendData:[self convertStringToBytesArr:@"0" length:4]];
    
    //Extra charge amount
    [mCollectData appendData:[self convertStringToBytesArr:@"0" length:4]];
    
    //Extra charge rate
    [mCollectData appendData:[self convertStringToBytesArr:@"0" length:2]];
    
    //Total price after extra charge
    [mCollectData appendData:[self convertStringToBytesArr:[NSString stringWithFormat:@"%d", totalPrice] length:4]];
    
    //Total price before rounding
    [mCollectData appendData:[self convertStringToBytesArr:[NSString stringWithFormat:@"%d", totalPrice] length:4]];
    
    //Total price after rounding
    [mCollectData appendData:[self convertStringToBytesArr:[NSString stringWithFormat:@"%d", totalPrice] length:4]];
    
    //Rounding amount
    [mCollectData appendData:[self convertStringToBytesArr:@"0" length:4]];
    
    //Tender amount
    [mCollectData appendData:[self convertStringToBytesArr:@"0" length:4]];
    
    //Change amount
    [mCollectData appendData:[self convertStringToBytesArr:@"0" length:4]];
    
    //Virtual change amount
    [mCollectData appendData:[self convertStringToBytesArr:@"0" length:4]];
    
    //pax
    [mCollectData appendData:[self convertStringToBytesArr:@"0" length:2]];
    
    //Total price paid
    [mCollectData appendData:[self convertStringToBytesArr:@"0" length:4]];
    
    /**XTransactionPaymentData[]**/
    for (ProductModel *product in [ShareManager shared].cartArr) {
        //Id
        [mCollectData appendData:[self convertStringToBytesArr:[NSString stringWithFormat:@"%@", product.ids] length:4]];
        //Quantity
        [mCollectData appendData:[self convertStringToBytesArr:[NSString stringWithFormat:@"%@", product.qty] length:2]];
        //Amount
        [mCollectData appendData:[self convertStringToBytesArr:[NSString stringWithFormat:@"%@", product.qty] length:4]];
        //Open % discount rate
        [mCollectData appendData:[self convertStringToBytesArr:@"0" length:4]];
        //Reference size
        [mCollectData appendData:[self convertStringToBytesArr:@"0" length:4]];
        //Reference
    }
    
    /**XTransactionItemData**/
    for (ProductModel *product in [ShareManager shared].cartArr) {
        //PLU No
        [mCollectData appendData:[self convertStringToBytesArr:[NSString stringWithFormat:@"%@", product.ids] length:4]];
        //Quantity
        [mCollectData appendData:[self convertStringToBytesArr:[NSString stringWithFormat:@"%@", product.qty] length:2]];
        //Weight
        [mCollectData appendData:[self convertStringToBytesArr:@"0" length:4]];
        //Item Flag
        [mCollectData appendBytes:"0" "0" "0" "0" length:4];
        //Item status
        [mCollectData appendBytes:"0" "0" "0" "0" length:4];
        //Unit price before discount
        [mCollectData appendData:[self convertStringToBytesArr:[NSString stringWithFormat:@"%@", product.originalPrice] length:4]];
        //Unit price after discount
        [mCollectData appendData:[self convertStringToBytesArr:[NSString stringWithFormat:@"%@", product.originalPrice] length:4]];
        //Unit price discount amount
        [mCollectData appendData:[self convertStringToBytesArr:[NSString stringWithFormat:@"%@", product.originalPrice] length:4]];
        //Original unit price
        [mCollectData appendData:[self convertStringToBytesArr:[NSString stringWithFormat:@"%@", product.originalPrice] length:4]];
        //Override unit price
        [mCollectData appendData:[self convertStringToBytesArr:[NSString stringWithFormat:@"%@", product.originalPrice] length:4]];
        //Price before discount
        int price = [product.qty intValue] * [product.originalPrice intValue];
        [mCollectData appendData:[self convertStringToBytesArr:[NSString stringWithFormat:@"%d", price] length:4]];
        //Price after discount
        [mCollectData appendData:[self convertStringToBytesArr:[NSString stringWithFormat:@"%d", price] length:4]];
        //Price after subtotal discount
        [mCollectData appendData:[self convertStringToBytesArr:[NSString stringWithFormat:@"%d", price] length:4]];
        //Price discount amount
        [mCollectData appendData:[self convertStringToBytesArr:@"0" length:4]];
        //Subtotal discount amount
        [mCollectData appendData:[self convertStringToBytesArr:@"0" length:4]];
        //Subtotal surcharge amount
        [mCollectData appendData:[self convertStringToBytesArr:@"0" length:4]];
        //Discount source
        [mCollectData appendData:[self convertStringToBytesArr:@"0" length:4]];
        //Discount flexkey Id
        [mCollectData appendData:[self convertStringToBytesArr:@"0" length:4]];
        //Discount level
        [mCollectData appendData:[self convertStringToBytesArr:@"0" length:2]];
        //Discount type
        [mCollectData appendData:[self convertStringToBytesArr:@"0" length:2]];
        //Item tax Id
        [mCollectData appendData:[self convertStringToBytesArr:@"0" length:2]];
        //Item tax type
        [mCollectData appendData:[self convertStringToBytesArr:@"0" length:2]];
        //Item tax rate
        [mCollectData appendData:[self convertStringToBytesArr:@"0" length:2]];
        //Item taxable amount
        [mCollectData appendData:[self convertStringToBytesArr:@"0" length:4]];
        //Item tax amount
        [mCollectData appendData:[self convertStringToBytesArr:@"0" length:4]];
        //Service charge amount
        [mCollectData appendData:[self convertStringToBytesArr:@"0" length:4]];
        //Price after subtotal discount and tax
        [mCollectData appendData:[self convertStringToBytesArr:[NSString stringWithFormat:@"%@", product.originalPrice] length:4]];
        //Set item addon price
        [mCollectData appendData:[self convertStringToBytesArr:@"0" length:4]];
        /**XItemOptionData**/
        /****XCondimentData**/
        [mCollectData appendData:[self convertStringToBytesArr:@"1" length:4]];
        [mCollectData appendData:[self convertStringToBytesArr:@"0" length:4]];
        [mCollectData appendData:[self convertStringToBytesArr:@"1" length:2]];
        /****XCookingInstructionData**/
        [mCollectData appendData:[self convertStringToBytesArr:@"1" length:4]];
        [mCollectData appendData:[self convertStringToBytesArr:@"0" length:2]];
        [mCollectData appendData:[self convertStringToBytesArr:@"1" length:2]];
        /****XServingTimeData**/
        [mCollectData appendData:[self convertStringToBytesArr:@"1" length:4]];
        [mCollectData appendData:[self convertStringToBytesArr:@"0" length:2]];
        [mCollectData appendData:[self convertStringToBytesArr:@"1" length:2]];
        /****XFreeInstructionData**/
        [mCollectData appendData:[self convertStringToBytesArr:@"0" length:4]];
    }
    return mCollectData;
}

- (int)generatorRequestId {
    int requestId = 0;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:REQUEST_ID]) {
        requestId = [[[NSUserDefaults standardUserDefaults] objectForKey:REQUEST_ID] intValue];
    }
    requestId ++;
    if (requestId > MAX_VALUE) {
        requestId = 0;
    }
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d", requestId] forKey:REQUEST_ID];
    [[NSUserDefaults standardUserDefaults] synchronize];

    return  requestId;
}
@end

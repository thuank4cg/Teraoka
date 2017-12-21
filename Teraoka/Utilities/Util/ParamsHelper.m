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

- (NSData *)convertStringToBytesArr:(NSString *)valueStr length:(int)length {
    NSString *hex = [NSString stringWithFormat:@"%08lX",
                        (unsigned long)[valueStr integerValue]];
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
//    const unsigned char header[] = {68, 71, 0, 0};
    [mCollectData appendBytes:"68" length:1];
    [mCollectData appendBytes:"71" length:1];
    [mCollectData appendBytes:"0" length:1];
    [mCollectData appendBytes:"0" length:1];
    
    /**Command Size**/
    [mCollectData appendBytes:"0" length:1];
    [mCollectData appendBytes:"0" length:1];
    [mCollectData appendBytes:"0" length:1];
    [mCollectData appendBytes:"32" length:1];
    
    /**Command Id**/
    [mCollectData appendBytes:"0" length:1];
    [mCollectData appendBytes:"0" length:1];
    [mCollectData appendBytes:"39" length:1];
    [mCollectData appendBytes:"118" length:1];
    
    /**Data Size**/
    [mCollectData appendBytes:"0" length:1];
    [mCollectData appendBytes:"0" length:1];
    [mCollectData appendBytes:"0" length:1];
    [mCollectData appendBytes:"26" length:1];
    
    /**
     *START [DATA] XRequestHeaderData
     */
    // - Version (4 bytes) 0.1.15.0
    [mCollectData appendBytes:"0" length:1];
    [mCollectData appendBytes:"1" length:1];
    [mCollectData appendBytes:"15" length:1];
    [mCollectData appendBytes:"0" length:1];
    // - RequestID (4 bytes)
    [mCollectData appendBytes:"0" length:1];
    [mCollectData appendBytes:"0" length:1];
    [mCollectData appendBytes:"0" length:1];
    [mCollectData appendBytes:"2" length:1];
    
    // - Terminal No (2 bytes) (Hex: 21)
    [mCollectData appendBytes:"0" length:1];
    [mCollectData appendBytes:"15" length:1];
    
    // - Staff ID (4 bytes)
    [mCollectData appendBytes:"0" length:1];
    [mCollectData appendBytes:"0" length:1];
    [mCollectData appendBytes:"0" length:1];
    [mCollectData appendBytes:"1" length:1];
    
    // - Sending Date (4 bytes) (20170301)
    [mCollectData appendBytes:"1" length:1];
    [mCollectData appendBytes:"51" length:1];
    [mCollectData appendBytes:"-58" length:1];
    [mCollectData appendBytes:"61" length:1];
    
    // - Sending Time (4 bytes) (17h15'00)
    [mCollectData appendBytes:"0" length:1];
    [mCollectData appendBytes:"2" length:1];
    [mCollectData appendBytes:"-99" length:1];
    [mCollectData appendBytes:"-20" length:1];
    
    /**
     * END [DATA] XRequestHeaderData
     * */
    
    // Table No:  00 00 00 01  (4 bytes)
    [mCollectData appendBytes:"0" length:1];
    [mCollectData appendBytes:"0" length:1];
    [mCollectData appendBytes:"0" length:1];
    [mCollectData appendBytes:"2" length:1];
    
    return mCollectData;
    /**
    //Command size
    int dataSize = (int)[self requestData].length;
    int commandSize = dataSize + 8;

//    //Command Id
    [mCollectData appendData:[self convertStringToBytesArr:@"13200" length:4]];

//    //Command ID
    [mCollectData appendData:[self convertStringToBytesArr:[NSString stringWithFormat:@"%d", commandSize] length:2]];

//    //Data size
    [mCollectData appendData:[self convertStringToBytesArr:[NSString stringWithFormat:@"%d", dataSize] length:4]];

//    //Data
//    [mCollectData appendData:[self requestData]];
    
    NSString *newLine = @"test\r\n";
    NSData *requestData = [newLine dataUsingEncoding:NSUTF8StringEncoding];
    [mCollectData appendData:requestData];
    
    return mCollectData;
     **/
}

- (NSMutableData *)requestData {
    NSMutableData *mCollectData = [[NSMutableData alloc] init];
    /**XRequestHeaderData**/
    //version
//    [mCollectData appendBytes:"0" "1" "15" "0" length:4];
    const unsigned char version[] = {0, 1, 15, 0};
    [mCollectData appendBytes:version length:4];
    
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
//        [mCollectData appendBytes:"0" "0" "0" "0" length:4];
        const unsigned char itemFlag[] = {0, 0, 0, 0};
        [mCollectData appendBytes:itemFlag length:4];
        //Item status
//        [mCollectData appendBytes:"0" "0" "0" "0" length:4];
        const unsigned char itemStatus[] = {0, 0, 0, 0};
        [mCollectData appendBytes:itemStatus length:4];
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

//
//  BaseController.m
//  Teraoka
//
//  Created by Thuan on 10/17/17.
//  Copyright © 2017 ss. All rights reserved.
//

#import "BaseController.h"
#import <GCDAsyncSocket.h>
#import "Reachability.h"
#import <ProgressHUD.h>
#import "ShareManager.h"
#import "APPConstants.h"
#import "ParamsHelper.h"
#import "Util.h"
#import "OrderConfirmController.h"
#import "ProductModel.h"
#import "ProductOption.h"
#import "ProductOptionValue.h"

#define STATUS_REPLY_OK @"00000000"
#define MSG_ERROR @"Submission failed due to connection error"

@interface BaseController () <GCDAsyncSocketDelegate, NSStreamDelegate>

@end

@implementation BaseController {
    GCDAsyncSocket* asyncSocket;
    NSOutputStream *outputStream;
    NSInputStream *inputStream;
    CFReadStreamRef readStream;
    CFReadStreamRef writeStream;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadLocalizable];
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadLocalizable {
    
}

- (void)sendTransaction {
    [ProgressHUD show:nil Interaction:NO];
    //    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
    //    {
    //        [Util showAlert:MSG_ERROR vc:self];
    //        return;
    //    }
    
    [ProgressHUD show:nil Interaction:NO];
    
    NSString *host = [ShareManager shared].setting.serverIP;
    uint16_t port = PORT;
    
    NSError *error = nil;
    
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
    asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:mainQueue];
    
    if (![asyncSocket connectToHost:host onPort:port withTimeout:10 error:&error])
    {
        NSLog(@"error");
        [ProgressHUD dismiss];
    }
}

- (void)getExistingOrder {
    if ([ShareManager shared].existingOrderArr.count == 0) {
        [ShareManager shared].existingOrderArr = [ShareManager shared].cartArr;
    } else {
        for (ProductModel *product in [ShareManager shared].cartArr) {
            BOOL isAdd = YES;
            for (ProductModel *existingProduct in [ShareManager shared].existingOrderArr) {
                if ([product.ids isEqualToString:existingProduct.ids]) {
                    isAdd = NO;
                    NSString *optionStr1 = @"";
                    for (ProductOption *option in product.options) {
                        for (ProductOptionValue *value in option.options) {
                            if (value.isCheck) {
                                optionStr1 = [optionStr1 stringByAppendingString:value.tittle];
                                optionStr1 = [optionStr1 stringByAppendingString:@"\n"];
                            }
                        }
                    }
                    
                    NSString *optionStr2 = @"";
                    for (ProductOption *option in existingProduct.options) {
                        for (ProductOptionValue *value in option.options) {
                            if (value.isCheck) {
                                optionStr2 = [optionStr2 stringByAppendingString:value.tittle];
                                optionStr2 = [optionStr2 stringByAppendingString:@"\n"];
                            }
                        }
                    }
                    
                    if ([optionStr1 isEqualToString:optionStr2]) {
                        int qty = [product.qty intValue];
                        qty += [existingProduct.qty intValue];
                        existingProduct.qty = [NSString stringWithFormat:@"%d", qty];
                    }else {
                        [[ShareManager shared].existingOrderArr addObject:product];
                    }
                    break;
                }
            }
            if (isAdd) [[ShareManager shared].existingOrderArr addObject:product];
        }
    }
}

//MARK: GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"didConnectToHost");
    [asyncSocket writeData:ParamsHelper.shared.collectData withTimeout:10 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    NSLog(@"didWriteDataWithTag");
    [asyncSocket readDataWithTimeout:10 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSLog(@"didReadData");
    [ProgressHUD dismiss];
    
    int location = REPLY_HEADER + REPLY_COMMAND_SIZE + REPLY_COMMAND_ID + REPLY_REQUEST_ID + REPLY_STORE_STATUS + REPLY_LAST_EVENT_ID;
    
    NSData *replyStatus = [data subdataWithRange:NSMakeRange(location, 4)];
    NSString *httpResponse = [Util hexadecimalString:replyStatus];
    if ([httpResponse isEqualToString:STATUS_REPLY_OK]){
        location = location + REPLY_STATUS + REPLY_DATA_SIZE;
        NSData *replyData = [data subdataWithRange:NSMakeRange(location, data.length - location)];
        //        httpResponse = [[NSString alloc] initWithData:replyData encoding:NSUTF8StringEncoding];
        NSData *dataReceipt = [replyData subdataWithRange:NSMakeRange(0, 4)];
        NSData *transactionNumber = [replyData subdataWithRange:NSMakeRange(4, 4)];
        
        int receiptResponse = [Util hexStringToInt:[Util hexadecimalString:dataReceipt]];
        int transactionNumberResponse = [Util hexStringToInt:[Util hexadecimalString:transactionNumber]];
        NSLog(@"%d %d", receiptResponse, transactionNumberResponse);
        
        [self getExistingOrder];
        
        [ShareManager shared].cartArr = nil;
        
        OrderConfirmController *vc = [[OrderConfirmController alloc] initWithNibName:@"OrderConfirmController" bundle:nil];
        vc.receipt = receiptResponse;
        vc.queueNumber = transactionNumberResponse;
        [self.navigationController pushViewController:vc animated:NO];
    } else {
        int replyDataSize = 0;
        
        replyDataSize += 2; //Store Status
        replyDataSize += 4; //Table Status
        replyDataSize += 4; //Bill Status
        replyDataSize += 4; //Item Flag 
        replyDataSize += 2; //Discount type
        replyDataSize += 4; //Event Type
        replyDataSize += 2; //Event state
        replyDataSize += 2; //Item preparation status
        
        /**XRequestHeaderData**/
        
        replyDataSize += 4; //Version
        replyDataSize += 4; //Request ID
        replyDataSize += 2; //Terminal No
        replyDataSize += 4; //Staff ID
        replyDataSize += 4; //Sending Date
        replyDataSize += 4; //Sending Time
        
        /**XTableStatusDataStruct**/
        
        replyDataSize += 4; //Table No
        replyDataSize += 4; //Table Status
        
        /**XBillIdData**/
        
        replyDataSize += 4; //Bill No
        replyDataSize += 4; //Primary Server Version
        replyDataSize += 4; //Backup Server Version
        
        /**XGuestPaxData**/
        
        replyDataSize += 2; //PAX
        
        location = location + REPLY_STATUS + replyDataSize;
        NSData *replyData = [data subdataWithRange:NSMakeRange(location, data.length - location)];
        NSData *dataNumOfObject= [replyData subdataWithRange:NSMakeRange(0, 4)];
        int numOfObject = [Util hexStringToInt:[Util hexadecimalString:dataNumOfObject]];
        
        replyDataSize += 4; //Number of object
        
        /**XGuestPaxDataStruct**/
        
        for (int i=0;i<numOfObject;i++) {
            replyDataSize += 2; //Guest Type
            replyDataSize += 2; //Number of object
        }
        
        /**XCouponData**/
        
        replyDataSize += 2; //Coupon status
        
        location = location + replyDataSize;
        replyData = [data subdataWithRange:NSMakeRange(location, data.length - location)];
        dataNumOfObject= [replyData subdataWithRange:NSMakeRange(0, 4)];
        numOfObject = [Util hexStringToInt:[Util hexadecimalString:dataNumOfObject]];
        
        replyDataSize += 4; //Number of object
        
        /**XCouponDataStruct**/
        
        for (int i=0;i<numOfObject;i++) {
            replyDataSize += 2; //Coupon No
            replyDataSize += 4; //Coupon Value
            replyDataSize += 2; //Coupon Qty
        }
        
        /**XSendOrderData**/
        
        location = location + replyDataSize;
        replyData = [data subdataWithRange:NSMakeRange(location, data.length - location)];
        dataNumOfObject= [replyData subdataWithRange:NSMakeRange(0, 4)];
        numOfObject = [Util hexStringToInt:[Util hexadecimalString:dataNumOfObject]];
        
        replyDataSize += 4; //Number of object
        
        /**XSendOrderDataStruct**/
        
        for (int i=0;i<numOfObject;i++) {
            replyDataSize += 4; //PLU No
            replyDataSize += 2; //Qty
            replyDataSize += 4; //Current Price (Overrided price, 0 is no overrided price)
            replyDataSize += 4; //Item Flag
            
            /**XItemOptionData**/
            
            //XCondimentData
            
            location = location + replyDataSize;
            replyData = [data subdataWithRange:NSMakeRange(location, data.length - location)];
            dataNumOfObject= [replyData subdataWithRange:NSMakeRange(0, 4)];
            numOfObject = [Util hexStringToInt:[Util hexadecimalString:dataNumOfObject]];
            
            replyDataSize += 4; //Number of object
            
            //XCondimentDataStruct
            for (int i=0;i<numOfObject;i++) {
                replyDataSize += 4; //Condiment No (PLU No)
                replyDataSize += 2; //Condiment Qty
            }
            
            //XCookingInstructionData
            
            location = location + replyDataSize;
            replyData = [data subdataWithRange:NSMakeRange(location, data.length - location)];
            dataNumOfObject= [replyData subdataWithRange:NSMakeRange(0, 4)];
            numOfObject = [Util hexStringToInt:[Util hexadecimalString:dataNumOfObject]];
            
            replyDataSize += 4; //Number of object
            
            //XCookingInstructionStruct
            for (int i=0;i<numOfObject;i++) {
                replyDataSize += 2; //Cooking Instruction No
                replyDataSize += 2; //Cooking Instruction Qty
            }
            
            //XServingTimeData
            
            location = location + replyDataSize;
            replyData = [data subdataWithRange:NSMakeRange(location, data.length - location)];
            dataNumOfObject= [replyData subdataWithRange:NSMakeRange(0, 4)];
            numOfObject = [Util hexStringToInt:[Util hexadecimalString:dataNumOfObject]];
            
            replyDataSize += 4; //Number of object
            
            //XServingTimeDataStruct
            for (int i=0;i<numOfObject;i++) {
                replyDataSize += 2; //Serving Time No
                replyDataSize += 2; //Serving Time Qty
            }
            
            //XFreeInstructionData
            replyDataSize += 4; //Free instruction data size
            replyDataSize += 0; //Free instruction data
        }
        
        /**XItemPreparationData**/
        
        replyDataSize += 2; //Item preparation status
        
        location = location + replyDataSize;
        replyData = [data subdataWithRange:NSMakeRange(location, data.length - location)];
        dataNumOfObject= [replyData subdataWithRange:NSMakeRange(0, 4)];
        numOfObject = [Util hexStringToInt:[Util hexadecimalString:dataNumOfObject]];
        
        replyDataSize += 4; //Number of object
        
        /**XItemPreparationDataStruct**/
        
        for (int i=0;i<numOfObject;i++) {
            replyDataSize += 4; //Item Id
            replyDataSize += 2; //Qty
        }
        
        /**XCompletedItemData**/
        
        replyDataSize += 4; //Table No
        
        //XBillIdData
        replyDataSize += 4; //Bill No
        replyDataSize += 4; //Primary Server Version
        replyDataSize += 4; //Backup Server Version
        
        location = location + replyDataSize;
        replyData = [data subdataWithRange:NSMakeRange(location, data.length - location)];
        dataNumOfObject= [replyData subdataWithRange:NSMakeRange(0, 4)];
        numOfObject = [Util hexStringToInt:[Util hexadecimalString:dataNumOfObject]];
        
        replyDataSize += 4; //Number of object
        
        /**XCompletedItemDataStruct**/
        
        for (int i=0;i<numOfObject;i++) {
            replyDataSize += 4; //Item Id
            replyDataSize += 2; //Qty
            replyDataSize += 2; //PLU No
        }
        
        /**XBillOptionData**/
        
        replyDataSize += 2; //Cooking instruction status
        
        /**XCookingInstructionData**/
        
        location = location + replyDataSize;
        replyData = [data subdataWithRange:NSMakeRange(location, data.length - location)];
        dataNumOfObject= [replyData subdataWithRange:NSMakeRange(0, 4)];
        numOfObject = [Util hexStringToInt:[Util hexadecimalString:dataNumOfObject]];
        
        replyDataSize += 4; //Number of object
        
        /**XCookingInstructionStruct**/
        
        for (int i=0;i<numOfObject;i++) {
            replyDataSize += 2; //Cooking Instruction No
            replyDataSize += 2; //Cooking Instruction Qty
        }
        
        /**XServingTimeData**/
        
        location = location + replyDataSize;
        replyData = [data subdataWithRange:NSMakeRange(location, data.length - location)];
        dataNumOfObject= [replyData subdataWithRange:NSMakeRange(0, 4)];
        numOfObject = [Util hexStringToInt:[Util hexadecimalString:dataNumOfObject]];
        
        replyDataSize += 4; //Number of object
        
        /**XServingTimeDataStruct**/
        
        for (int i=0;i<numOfObject;i++) {
            replyDataSize += 2; //Serving Time No
            replyDataSize += 2; //Serving Time Qty
        }
        
        /**XFreeInstructionData**/
        
        replyDataSize += 4; //Free instruction data size
        replyDataSize += 0; //Free instruction data
        
        /**XItemPreparationData**/
        
        replyDataSize += 2; //Item preparation status
        
        location = location + replyDataSize;
        replyData = [data subdataWithRange:NSMakeRange(location, data.length - location)];
        dataNumOfObject= [replyData subdataWithRange:NSMakeRange(0, 4)];
        numOfObject = [Util hexStringToInt:[Util hexadecimalString:dataNumOfObject]];
        
        replyDataSize += 4; //Number of object
        
        /**XItemPreparationDataStruct**/
        
        for (int i=0;i<numOfObject;i++) {
            replyDataSize += 4; //Item Id
            replyDataSize += 2; //Qty
        }
        
        /**XCompletedItemData**/
        
        replyDataSize += 4; //Table No
        
        /**XBillIdData**/
        
        replyDataSize += 4; //Bill No
        replyDataSize += 4; //Primary Server Version
        replyDataSize += 4; //Backup Server Version
        
        location = location + replyDataSize;
        replyData = [data subdataWithRange:NSMakeRange(location, data.length - location)];
        dataNumOfObject= [replyData subdataWithRange:NSMakeRange(0, 4)];
        numOfObject = [Util hexStringToInt:[Util hexadecimalString:dataNumOfObject]];
        
        replyDataSize += 4; //Number of object
        
        /**XCompletedItemDataStruct**/
        
        for (int i=0;i<numOfObject;i++) {
            replyDataSize += 4; //Item Id
            replyDataSize += 2; //Qty
            replyDataSize += 4; //PLU No
        }
        
        /**XBillOptionData**/
        
        replyDataSize += 2; //Cooking instruction status
        
        /**XCookingInstructionData**/
        
        location = location + replyDataSize;
        replyData = [data subdataWithRange:NSMakeRange(location, data.length - location)];
        dataNumOfObject= [replyData subdataWithRange:NSMakeRange(0, 4)];
        numOfObject = [Util hexStringToInt:[Util hexadecimalString:dataNumOfObject]];
        
        replyDataSize += 4; //Number of object
        
        /**XCookingInstructionStruct**/
        
        for (int i=0;i<numOfObject;i++) {
            replyDataSize += 2; //Cooking Instruction No
            replyDataSize += 2; //Cooking Instruction Qty
        }
        
        /**XFreeRemarkData**/
        
        replyDataSize += 2; //Free remark status
        replyDataSize += 4; //Free remark data size
        replyDataSize += 0; //Free remark data
        
        /**XSplitBillReplyItemData**/
        
        location = location + replyDataSize;
        replyData = [data subdataWithRange:NSMakeRange(location, data.length - location)];
        dataNumOfObject= [replyData subdataWithRange:NSMakeRange(0, 4)];
        numOfObject = [Util hexStringToInt:[Util hexadecimalString:dataNumOfObject]];
        
        replyDataSize += 4; //Number of object
        
        /**XSplitBillReplyItemDataStruct**/
        
        for (int i=0;i<numOfObject;i++) {
            replyDataSize += 4; //Item Id
            replyDataSize += 4; //Unit Price
        }
        
        /**XSplitBillAmountDataStruct**/
        
        replyDataSize += 2; //Split type
        replyDataSize += 4; //Split amount or pax
        
        /**XItemOptionCancelData**/
        
        location = location + replyDataSize;
        replyData = [data subdataWithRange:NSMakeRange(location, data.length - location)];
        dataNumOfObject= [replyData subdataWithRange:NSMakeRange(0, 4)];
        numOfObject = [Util hexStringToInt:[Util hexadecimalString:dataNumOfObject]];
        
        replyDataSize += 4; //Number of object
        
        /**XItemOptionCancelDataStruct**/
        
        for (int i=0;i<numOfObject;i++) {
            replyDataSize += 2; //Item Option Type
            replyDataSize += 4; //Item Option No
            replyDataSize += 2; //Item Option Qty
        }
        
        /**XEventStateData**/
        
        location = location + replyDataSize;
        replyData = [data subdataWithRange:NSMakeRange(location, data.length - location)];
        dataNumOfObject= [replyData subdataWithRange:NSMakeRange(0, 4)];
        numOfObject = [Util hexStringToInt:[Util hexadecimalString:dataNumOfObject]];
        
        replyDataSize += 4; //Number of object
        
        /**XEventStateDataStruct**/
        
        for (int i=0;i<numOfObject;i++) {
            replyDataSize += 4; //Event id
            replyDataSize += 2; //Event state
        }
        
        /**XEventData**/
        
        location = location + replyDataSize;
        replyData = [data subdataWithRange:NSMakeRange(location, data.length - location)];
        dataNumOfObject= [replyData subdataWithRange:NSMakeRange(0, 4)];
        numOfObject = [Util hexStringToInt:[Util hexadecimalString:dataNumOfObject]];
        
        replyDataSize += 4; //Number of object
        
        /**XEventDataStruct**/
        
        for (int i=0;i<numOfObject;i++) {
            replyDataSize += 4; //Event Id
            replyDataSize += 4; //Event type
            replyDataSize += 4; //Event Category
            replyDataSize += 2; //Event Level
            replyDataSize += 2; //Event Terminal No
            replyDataSize += 4; //Event Date
            replyDataSize += 4; //Event Time
            replyDataSize += 4; //Event type Data 1
            replyDataSize += 4; //Event type Data 2
            replyDataSize += 4; //Event type Data 3
            replyDataSize += 4; //Event type Data 4
            replyDataSize += 4; //Event type Data 5
            replyDataSize += 4; //Event type Data 6
            replyDataSize += 4; //Event type Data 7
            replyDataSize += 4; //Event type Data 8
            replyDataSize += 2; //Event state
            replyDataSize += 4; //Event Message Size
            replyDataSize += 0; //Event Message
        }
        
        /**XOutOfStockData**/
        
        location = location + replyDataSize;
        replyData = [data subdataWithRange:NSMakeRange(location, data.length - location)];
        dataNumOfObject= [replyData subdataWithRange:NSMakeRange(0, 4)];
        numOfObject = [Util hexStringToInt:[Util hexadecimalString:dataNumOfObject]];
        
        replyDataSize += 4; //Number of object
        
        /**XOutOfStockDataStruct**/
        
        for (int i=0;i<numOfObject;i++) {
            location = location + replyDataSize;
            replyData = [data subdataWithRange:NSMakeRange(location, data.length - location)];
            NSData *dataPluNo = [replyData subdataWithRange:NSMakeRange(0, 4)];
            int pluNo = [Util hexStringToInt:[Util hexadecimalString:dataPluNo]];
            
            replyDataSize += 4; //PLU No
            replyDataSize += 2; //Qty
        }
        
//        location = location + REPLY_STATUS + REPLY_DATA_SIZE;
//        NSData *replyData = [data subdataWithRange:NSMakeRange(location, data.length - location)];
//        httpResponse = [[NSString alloc] initWithData:replyData encoding:NSUTF8StringEncoding];
//        if (httpResponse.length == 0) {
//            httpResponse = MSG_ERROR;
//        }
//        [Util showAlert:httpResponse vc:self];
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    [ProgressHUD dismiss];
    
    if (err.domain == NSPOSIXErrorDomain) {
        [Util showAlert:MSG_ERROR vc:self];
    }
    
    NSLog(@"socketDidDisconnect");
}

@end

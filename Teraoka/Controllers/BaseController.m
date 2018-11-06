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
#import "Util.h"
#import "OrderConfirmController.h"
#import "ProductModel.h"
#import "OutOfStockModel.h"
#import "OptionGroupModel.h"
#import "OptionModel.h"

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
    CommandName commandName;
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

- (void)sendPOSRequest:(CommandName)_commandName {
    commandName = _commandName;
    
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
                if ([product.productNo isEqualToString:existingProduct.productNo]) {
                    isAdd = NO;
                    NSString *optionStr1 = @"";
                    for (OptionGroupModel *group in product.options) {
                        for (OptionModel *option in group.optionList) {
                            if (option.isCheck) {
                                optionStr1 = [optionStr1 stringByAppendingString:option.name];
                                optionStr1 = [optionStr1 stringByAppendingString:@"\n"];
                            }
                        }
                    }
                    
                    NSString *optionStr2 = @"";
                    for (OptionGroupModel *group in existingProduct.options) {
                        for (OptionModel *option in group.optionList) {
                            if (option.isCheck) {
                                optionStr2 = [optionStr2 stringByAppendingString:option.name];
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

- (void)showOrderConfirmScreen {
    [self getExistingOrder];
    
    [ShareManager shared].cartArr = nil;
    [ShareManager shared].outOfStockArr = nil;
    
    OrderConfirmController *vc = [[OrderConfirmController alloc] initWithNibName:@"OrderConfirmController" bundle:nil];
    [self.navigationController pushViewController:vc animated:NO];
}

//MARK: GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"didConnectToHost");
    switch (commandName) {
        case SendOrder:
            [asyncSocket writeData:[ParamsHelper.shared collectData:SendOrder] withTimeout:10 tag:0];
            break;
        case SendTransaction:
            [asyncSocket writeData:[ParamsHelper.shared collectData:SendTransaction] withTimeout:10 tag:0];
            break;
        case GetInventory:
            [asyncSocket writeData:[ParamsHelper.shared collectData:GetInventory] withTimeout:10 tag:0];
            break;
        case CallStaff:
            [asyncSocket writeData:[ParamsHelper.shared collectData:CallStaff] withTimeout:10 tag:0];
            break;
            
        default:
            break;
    }
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    NSLog(@"didWriteDataWithTag");
    [asyncSocket readDataWithTimeout:10 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSLog(@"didReadData");
    [ProgressHUD dismiss];
    
    switch (commandName) {
        case SendOrder:
            [self handleDataSendOrder:data];
            break;
        case SendTransaction:
            [self handleDataSendTransaction:data];
            break;
        case GetInventory:
            [self handleDataGetInventory:data];
            break;
        case CallStaff:
            [self handleDataCallStaff:data];
            break;
        default:
            break;
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    [ProgressHUD dismiss];
    
    if (err.domain == NSPOSIXErrorDomain) {
        [Util showAlert:MSG_ERROR vc:self];
    }
    
    NSLog(@"socketDidDisconnect");
}

- (void)handleDataSendOrder:(NSData *)data {
    int location = REPLY_HEADER + REPLY_COMMAND_SIZE + REPLY_COMMAND_ID + REPLY_REQUEST_ID + REPLY_STORE_STATUS + REPLY_LAST_EVENT_ID;
    
    NSData *replyStatus = [data subdataWithRange:NSMakeRange(location, 4)];
    NSString *httpResponse = [Util hexadecimalString:replyStatus];
    if ([httpResponse isEqualToString:STATUS_REPLY_OK]){
        [self showOrderConfirmScreen];
    } else {
        NSData *replyData = [data subdataWithRange:NSMakeRange(location, data.length - location)];
        NSData *dataErrorID = [replyData subdataWithRange:NSMakeRange(0, 2)];
        NSString *errorID = [Util hexadecimalString:dataErrorID];
        
        if ([errorID isEqualToString:ERROR_ID_OUT_OF_STOCK]) {
            location = location + REPLY_STATUS + REPLY_DATA_SIZE + 14;
            
            /**XOutOfStockData**/
            
            NSData *outOfStockData = [data subdataWithRange:NSMakeRange(location, data.length - location)];
            NSData *dataNumOfObject = [outOfStockData subdataWithRange:NSMakeRange(0, 4)];
            location += 4;
            
            int numOfObject = [Util hexStringToInt:[Util hexadecimalString:dataNumOfObject]];
            
            /**XOutOfStockDataStruct**/
            
            NSMutableArray *outOfStockArr = [NSMutableArray new];
            
            for (int i=0;i<numOfObject;i++) {
                NSData *dataPlu = [data subdataWithRange:NSMakeRange(location, data.length - location)];
                NSData *dataPluNo = [dataPlu subdataWithRange:NSMakeRange(0, 4)];
                NSData *dataPluQty = [dataPlu subdataWithRange:NSMakeRange(4, 2)];
                int pluNo = [Util hexStringToInt:[Util hexadecimalString:dataPluNo]];
                int pluQty = [Util hexStringToInt:[Util hexadecimalString:dataPluQty]];
                
                OutOfStockModel *model = [[OutOfStockModel alloc] init];
                model.productNo = [NSString stringWithFormat:@"%d", pluNo];
                model.qty = [NSString stringWithFormat:@"%d", pluQty];
                
                [outOfStockArr addObject:model];
                
                location += 6;
            }
            [ShareManager shared].outOfStockArr = outOfStockArr;
            [[NSNotificationCenter defaultCenter] postNotificationName:KEY_NOTIFY_OUT_OF_STOCK object:nil];
        } else {
            [Util showAlert:MSG_ERROR vc:self];
        }
    }
}

- (void)handleDataSendTransaction:(NSData *)data {
    int location = REPLY_HEADER + REPLY_COMMAND_SIZE + REPLY_COMMAND_ID + REPLY_REQUEST_ID + REPLY_STORE_STATUS + REPLY_LAST_EVENT_ID;
    
    NSData *replyStatus = [data subdataWithRange:NSMakeRange(location, 4)];
    NSString *httpResponse = [Util hexadecimalString:replyStatus];
    if ([httpResponse isEqualToString:STATUS_REPLY_OK]){
        location = location + REPLY_STATUS + REPLY_DATA_SIZE;
        NSData *replyData = [data subdataWithRange:NSMakeRange(location, data.length - location)];
        NSData *dataReceipt = [replyData subdataWithRange:NSMakeRange(0, 4)];
        NSData *dataTransactionNumber = [replyData subdataWithRange:NSMakeRange(4, 4)];
        
        int receipt = [Util hexStringToInt:[Util hexadecimalString:dataReceipt]];
        int transactionNumber = [Util hexStringToInt:[Util hexadecimalString:dataTransactionNumber]];
        
        [self showOrderConfirmScreen];
    } else {
        [Util showAlert:MSG_ERROR vc:self];
    }
}

- (void)handleDataGetInventory:(NSData *)data {
    int location = REPLY_HEADER + REPLY_COMMAND_SIZE + REPLY_COMMAND_ID + REPLY_REQUEST_ID + REPLY_STORE_STATUS + REPLY_LAST_EVENT_ID;
    
    NSData *replyStatus = [data subdataWithRange:NSMakeRange(location, 4)];
    NSString *httpResponse = [Util hexadecimalString:replyStatus];
    if ([httpResponse isEqualToString:STATUS_REPLY_OK]){
        location = location + REPLY_STATUS + REPLY_DATA_SIZE;
        
        /**XInventoryData**/
        NSData *inventoryData = [data subdataWithRange:NSMakeRange(location, data.length - location)];
        NSData *numberOfObjectData = [inventoryData subdataWithRange:NSMakeRange(0, 4)];
        location += 4;
        
        int numberOfObject = [Util hexStringToInt:[Util hexadecimalString:numberOfObjectData]];
        
        if (numberOfObject == 0) {
            [self sendPOSRequest:SendTransaction];
            return;
        }
        
        /**XInventoryItemData**/
        
        NSMutableArray *outOfStockArr = [NSMutableArray new];
        
        for (int i=0;i<numberOfObject;i++) {
            NSData *inventoryItemData = [data subdataWithRange:NSMakeRange(location, data.length - location)];
            NSData *pluNoData = [inventoryItemData subdataWithRange:NSMakeRange(0, 4)];
            NSData *leftOverData = [inventoryItemData subdataWithRange:NSMakeRange(4, 4)];
            NSData *totalInData = [inventoryItemData subdataWithRange:NSMakeRange(8, 4)];
            NSData *totalOutData = [inventoryItemData subdataWithRange:NSMakeRange(12, 4)];
            NSData *salesData = [inventoryItemData subdataWithRange:NSMakeRange(16, 4)];
            NSData *onHandData = [inventoryItemData subdataWithRange:NSMakeRange(20, 4)];
            
            int pluNo = [Util hexStringToInt:[Util hexadecimalString:pluNoData]];
            int leftOver = [Util hexStringToInt:[Util hexadecimalString:leftOverData]];
            int totalIn = [Util hexStringToInt:[Util hexadecimalString:totalInData]];
            int totalOut = [Util hexStringToInt:[Util hexadecimalString:totalOutData]];
            int sales = [Util hexStringToInt:[Util hexadecimalString:salesData]];
            int onHand = [Util hexStringToInt:[Util hexadecimalString:onHandData]];
            
            NSLog(@"(%d) - (%d) - (%d) - (%d) - (%d) - (%d)", pluNo, leftOver, totalIn, totalOut, sales, onHand);
            
            OutOfStockModel *model = [[OutOfStockModel alloc] init];
            model.productNo = [NSString stringWithFormat:@"%d", pluNo];
            model.qty = [NSString stringWithFormat:@"%d", (onHand < 0)?0:onHand];
            
            [outOfStockArr addObject:model];
            
            location += 24;
        }
        
        [ShareManager shared].outOfStockArr = outOfStockArr;
        [[NSNotificationCenter defaultCenter] postNotificationName:KEY_NOTIFY_OUT_OF_STOCK object:nil];
    } else {
        [Util showAlert:MSG_ERROR vc:self];
    }
}

- (void)handleDataCallStaff:(NSData *)data {
    int location = REPLY_HEADER + REPLY_COMMAND_SIZE + REPLY_COMMAND_ID + REPLY_REQUEST_ID + REPLY_STORE_STATUS + REPLY_LAST_EVENT_ID;
    
    NSData *replyStatus = [data subdataWithRange:NSMakeRange(location, 4)];
    NSString *httpResponse = [Util hexadecimalString:replyStatus];
    if ([httpResponse isEqualToString:STATUS_REPLY_OK]){
        NSLog(@"Ok");
    } else {
        [Util showAlert:MSG_ERROR vc:self];
    }
}

@end

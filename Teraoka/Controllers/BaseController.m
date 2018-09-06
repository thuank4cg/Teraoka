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
#import "ProductOption.h"
#import "ProductOptionValue.h"
#import "OutOfStockModel.h"

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
    switch (commandName) {
        case SendOrder:
            [asyncSocket writeData:[ParamsHelper.shared collectData:SendOrder] withTimeout:10 tag:0];
            break;
        case SendTransaction:
            [asyncSocket writeData:[ParamsHelper.shared collectData:SendTransaction] withTimeout:10 tag:0];
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
        [self sendPOSRequest:SendTransaction];
    } else {
        NSData *replyData = [data subdataWithRange:NSMakeRange(location, data.length - location)];
        NSData *dataErrorID = [replyData subdataWithRange:NSMakeRange(0, 4)];
        NSString *errorID = [Util hexadecimalString:dataErrorID];
        
        if ([errorID isEqualToString:ERROR_ID_OUT_OF_STOCK]) {
            [Util showAlert:@"Out of stock." vc:self];
            
            location = location + REPLY_STATUS + REPLY_DATA_SIZE + 14;
            
            /**XOutOfStockData**/
            
            NSData *outOfStockData = [data subdataWithRange:NSMakeRange(location, data.length - location)];
            NSData *dataNumOfObject = [outOfStockData subdataWithRange:NSMakeRange(0, 4)];
            int numOfObject = [Util hexStringToInt:[Util hexadecimalString:dataNumOfObject]];
            
            location += 4; //Number of object
            
            /**XOutOfStockDataStruct**/
            
            NSMutableArray *outOfStockArr = [NSMutableArray new];
            
            for (int i=0;i<numOfObject;i++) {
                NSData *dataPlu = [data subdataWithRange:NSMakeRange(location, data.length - location)];
                NSData *dataPluNo = [dataPlu subdataWithRange:NSMakeRange(0, 4)];
                NSData *dataPluQty = [dataPlu subdataWithRange:NSMakeRange(4, 2)];
                int pluNo = [Util hexStringToInt:[Util hexadecimalString:dataPluNo]];
                int pluQty = [Util hexStringToInt:[Util hexadecimalString:dataPluQty]];
                
                OutOfStockModel *model = [[OutOfStockModel alloc] init];
                model.ids = pluNo;
                model.qty = pluQty;
                
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
        [Util showAlert:MSG_ERROR vc:self];
    }
}

@end

//
//  OrderSummaryController.m
//  Teraoka
//
//  Created by Thuan on 10/18/17.
//  Copyright © 2017 ss. All rights reserved.
//

#import "OrderSummaryController.h"
#import "OrderSummaryCell.h"
#import "OrderConfirmController.h"
#import "ProductOption.h"
#import "ShareManager.h"
#import "CategoriesController.h"
#import "OrderConfirmController.h"
#import "ProductModel.h"
#import "ProductOptionValue.h"
#import "ProductOption.h"
#import "APPConstants.h"
#import "ParamsHelper.h"
#import "GCDAsyncSocket.h"

@interface OrderSummaryController () <UITableViewDelegate, UITableViewDataSource, GCDAsyncSocketDelegate, NSStreamDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@end

@implementation OrderSummaryController {
    NSMutableArray *products;
    GCDAsyncSocket* asyncSocket;
    
    NSOutputStream *outputStream;
    NSInputStream *inputStream;
    CFReadStreamRef readStream;
    CFReadStreamRef writeStream;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    products = [ShareManager shared].cartArr;
    [self setupView];
    
    CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, (__bridge CFStringRef) @"google.com", 80, &readStream, &writeStream);
    [self open];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view removeFromSuperview];
}

- (void)setupView {
    self.tblView.delegate = self;
    self.tblView.dataSource = self;
    [self.tblView registerNib:[UINib nibWithNibName:@"OrderSummaryCell" bundle:nil] forCellReuseIdentifier:@"OrderSummaryCellID"];
    
    self.containerView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.containerView.layer.shadowOffset = CGSizeMake(8.0f, 8.0f);
    self.containerView.layer.shadowOpacity = 0.5;
    self.containerView.layer.shadowRadius = 3.0;
    self.containerView.layer.masksToBounds = NO;
}
- (IBAction)backAction:(id)sender {
//    for (UIViewController *vc in self.navigationController.viewControllers) {
//        if ([vc isKindOfClass:[CategoriesController class]]) {
//            [self.navigationController popToViewController:vc animated:YES];
//            break;
//        }
//    }
    for (ProductModel *product in products) {
        if ([product.qty intValue] == 0) [products removeObject:product];
    }
    [self.delegate backDelegate];
    [self.view removeFromSuperview];
}
- (IBAction)sendOrder:(id)sender {
    if (products.count == 0) return;
    for (ProductModel *product in products) {
        if ([product.qty intValue] == 0) [products removeObject:product];
    }
//    if ([ShareManager shared].existingOrderArr.count == 0) {
//        [ShareManager shared].existingOrderArr = products;
//    }else {
//        for (ProductModel *product in products) {
//            BOOL isAdd = YES;
//            for (ProductModel *existingProduct in [ShareManager shared].existingOrderArr) {
//                if ([product.ids isEqualToString:existingProduct.ids]) {
//                    isAdd = NO;
//                    NSString *optionStr1 = @"";
//                    for (ProductOption *option in product.options) {
//                        for (ProductOptionValue *value in option.options) {
//                            if (value.isCheck) {
//                                optionStr1 = [optionStr1 stringByAppendingString:value.tittle];
//                                optionStr1 = [optionStr1 stringByAppendingString:@"\n"];
//                            }
//                        }
//                    }
//
//                    NSString *optionStr2 = @"";
//                    for (ProductOption *option in existingProduct.options) {
//                        for (ProductOptionValue *value in option.options) {
//                            if (value.isCheck) {
//                                optionStr2 = [optionStr2 stringByAppendingString:value.tittle];
//                                optionStr2 = [optionStr2 stringByAppendingString:@"\n"];
//                            }
//                        }
//                    }
//
//                    if ([optionStr1 isEqualToString:optionStr2]) {
//                        int qty = [product.qty intValue];
//                        qty += [existingProduct.qty intValue];
//                        existingProduct.qty = [NSString stringWithFormat:@"%d", qty];
//                    }else {
//                        [[ShareManager shared].existingOrderArr addObject:product];
//                    }
//                    break;
//                }
//            }
//            if (isAdd) [[ShareManager shared].existingOrderArr addObject:product];
//        }
//    }
    [ShareManager shared].cartArr = nil;
    [self sendTransaction];
    OrderConfirmController *vc = [[OrderConfirmController alloc] initWithNibName:@"OrderConfirmController" bundle:nil];
    [self.navigationController pushViewController:vc animated:NO];
}
#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return products.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OrderSummaryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OrderSummaryCellID" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setDataForCell:(int)indexPath.row product:products[indexPath.row]];
    cell.removeItem = ^(int row) {
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:nil
                                     message:@"Are you sure remove item?"
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"OKAY"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        [products removeObjectAtIndex:row];
                                        [self.tblView reloadData];
                                    }];
        
        UIAlertAction* noButton = [UIAlertAction
                                   actionWithTitle:@"NO"
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction * action) {
                                       //Handle no, thanks button
                                       ProductModel *model = products[row];
                                       model.qty = @"1";
                                       [self.tblView reloadData];
                                   }];
        
        [alert addAction:yesButton];
        [alert addAction:noButton];
        [self presentViewController:alert animated:YES completion:nil];
    };
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 150;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (products.count == 0) return [[UIView alloc] init];
    UIView *header = [[[NSBundle mainBundle] loadNibNamed:@"OrderSummaryHeader" owner:self options:nil] objectAtIndex:0];
    header.layer.shadowColor = [[UIColor blackColor] CGColor];
    header.layer.shadowOffset = CGSizeMake(0.5f, 0.4f);
    header.layer.shadowOpacity = 0.5;
    header.layer.shadowRadius = 3.0;
    header.layer.masksToBounds = NO;
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 60;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
//    UIView *footer = [[[NSBundle mainBundle] loadNibNamed:@"OrderSummaryFooter" owner:self options:nil] objectAtIndex:0];
//    
//    UIButton *btn = [footer viewWithTag:1];
//    [btn addTarget:self action:@selector(sendOrder) forControlEvents:UIControlEventTouchUpInside];
//    
//    btn = [footer viewWithTag:2];
//    [btn addTarget:self action:@selector(orderMore) forControlEvents:UIControlEventTouchUpInside];
//    
//    return footer;
    return [[UIView alloc] init];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

#pragma mark - Custom method
- (void)open {
    
    NSLog(@"Opening streams.");
    
    outputStream = (__bridge NSOutputStream *)writeStream;
    inputStream = (__bridge NSInputStream *)readStream;
    
    [outputStream setDelegate:self];
    [inputStream setDelegate:self];
    
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [outputStream open];
    [inputStream open];
}
- (void)sendTransaction {
//    NSString *host = @"google.com";
    NSString *host = @"192.168.1.100";
//    uint16_t port = 80;

//
//    NSError *error = nil;
//
//    dispatch_queue_t mainQueue = dispatch_get_main_queue();
//
//    asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:mainQueue];
//
//    if (![asyncSocket connectToHost:host onPort:port error:&error])
//    {
//        NSLog(@"error");
//    }
    [outputStream write:[ParamsHelper.shared.collectData bytes] maxLength:[ParamsHelper.shared.collectData length]];
}
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"didConnectToHost");
//    NSString *test = @"test\n";
//    NSData *requestData = [test dataUsingEncoding:NSUTF8StringEncoding];
    [asyncSocket writeData:ParamsHelper.shared.collectData withTimeout:-1 tag:0];
    [asyncSocket readDataWithTimeout:-1 tag:0];
}
//- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
//    NSLog(@"didWriteDataWithTag");
//}
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSLog(@"didReadData");
    NSString *httpResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@", httpResponse);
}
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    NSLog(@"socketDidDisconnect");
}

#pragma mark - NSStreamDelegate
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    NSLog(@"stream event %lu", eventCode);
    
    switch (eventCode) {
            
        case NSStreamEventOpenCompleted:
            NSLog(@"Stream opened");
            break;
            
        case NSStreamEventHasBytesAvailable:
            if (aStream == inputStream)
            {
                uint8_t buffer[1024];
                NSInteger len;
                
                while ([inputStream hasBytesAvailable])
                {
                    len = [inputStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0)
                    {
                        NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
                        
                        if (nil != output)
                        {
                            NSLog(@"server said: %@", output);
                        }
                    }
                }
            }
            break;
            
        case NSStreamEventHasSpaceAvailable:
            NSLog(@"Stream has space available now");
            break;
            
        case NSStreamEventErrorOccurred:
            NSLog(@"error: %@",[aStream streamError].localizedDescription);
            break;
            
        case NSStreamEventEndEncountered:
            [aStream close];
            [aStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            NSLog(@"close stream");
            break;
            
        default:
            NSLog(@"Unknown event");
    }
}

@end

//
//  ParamsHelper.h
//  Teraoka
//
//  Created by Thuan on 12/14/17.
//  Copyright © 2017 ss. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    SendOrder = 1,
    SendTransaction,
    GetInventory,
    CallStaff,
    PrintBill,
    SendSeated,
    GetBillDetails,
    GetBillHeader
} CommandName;

@interface ParamsHelper : NSObject
+ (ParamsHelper *)shared;
- (NSMutableData *)collectData:(CommandName)commandName;
- (NSMutableData *)requestSendOrderData;
@end

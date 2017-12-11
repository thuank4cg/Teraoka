//
//  OrderSummaryCell.h
//  Teraoka
//
//  Created by Thuan on 10/18/17.
//  Copyright © 2017 ss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductModel.h"

typedef void (^RemoveItem)(int row);

@interface OrderSummaryCell : UITableViewCell
@property (nonatomic, copy) RemoveItem removeItem;
- (void)setDataForCell:(int)row product:(ProductModel *)product;
@end

//
//  ExistingOrderCell.m
//  Teraoka
//
//  Created by Thuan on 10/18/17.
//  Copyright © 2017 ss. All rights reserved.
//

#import "ExistingOrderCell.h"
#import "ProductOption.h"
#import "ProductOptionValue.h"

@interface ExistingOrderCell()
@property (weak, nonatomic) IBOutlet UIImageView *productImage;
@property (weak, nonatomic) IBOutlet UILabel *lbOptions;
@property (weak, nonatomic) IBOutlet UILabel *lbQty;
@property (weak, nonatomic) IBOutlet UIButton *btnSent;
@property (weak, nonatomic) IBOutlet UILabel *lbPrice;

@end

@implementation ExistingOrderCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.productImage.layer.borderWidth = 1;
    self.productImage.layer.borderColor = [UIColor blackColor].CGColor;
}
- (void)setDataForCell:(ProductModel *)product {
    self.lbQty.text = product.qty;
    self.productImage.image = [UIImage imageNamed:product.image];
    
    NSString *optionStr = @"";
    for (ProductOption *option in product.options) {
        for (ProductOptionValue *value in option.options) {
            if (value.isCheck) {
                optionStr = [optionStr stringByAppendingString:value.tittle];
                optionStr = [optionStr stringByAppendingString:@"\n"];
            }
        }
    }
    self.lbOptions.text = [optionStr substringToIndex:[optionStr length] - 1];
    
    float price = [product.qty intValue] * [product.priceNumber floatValue];
    self.lbPrice.text = [NSString stringWithFormat:@"$%.2f", price];
}

@end

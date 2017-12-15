//
//  OrderSummaryCell.m
//  Teraoka
//
//  Created by Thuan on 10/18/17.
//  Copyright © 2017 ss. All rights reserved.
//

#import "OrderSummaryCell.h"
#import "TextfieldCustom.h"
#import "ProductOptionValue.h"
#import "ProductOption.h"

@interface OrderSummaryCell ()
@property (weak, nonatomic) IBOutlet TextfieldCustom *tfQty;
@property (weak, nonatomic) IBOutlet UIImageView *productImage;
@property (weak, nonatomic) IBOutlet UILabel *lbOptions;
@property (weak, nonatomic) IBOutlet UILabel *lbNotice;
@property (weak, nonatomic) IBOutlet UIView *decreaseBox;
@property (weak, nonatomic) IBOutlet UIView *increaseBox;
@property (weak, nonatomic) IBOutlet UILabel *lbProductName;

@end

@implementation OrderSummaryCell {
    ProductModel *_product;
    int _row;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
//    self.productImage.layer.borderWidth = 1;
//    self.productImage.layer.borderColor = [UIColor blackColor].CGColor;
    
    self.tfQty.layer.borderColor = [UIColor grayColor].CGColor;
    self.tfQty.backgroundColor = [UIColor whiteColor];
    
    self.increaseBox.clipsToBounds = YES;
    self.increaseBox.layer.borderColor = [UIColor grayColor].CGColor;
    self.increaseBox.layer.borderWidth = 1;
    self.increaseBox.layer.cornerRadius = CGRectGetHeight(self.increaseBox.frame)/2;
    
    self.decreaseBox.clipsToBounds = YES;
    self.decreaseBox.layer.borderColor = [UIColor grayColor].CGColor;
    self.decreaseBox.layer.borderWidth = 1;
    self.decreaseBox.layer.cornerRadius = CGRectGetHeight(self.decreaseBox.frame)/2;
}
- (void)setDataForCell:(int)row product:(ProductModel *)product {
    _row = row;
    _product = product;
    self.lbProductName.text = product.name;
//    if (product.qty == 0) [self.lbNotice setHidden:NO];
//    else [self.lbNotice setHidden:YES];
    self.tfQty.text = product.qty;
    if (product.image.length > 0) self.productImage.image = [UIImage imageNamed:product.image];
    
    NSString* optionStr = @"<p style='line-height:1.8;text-align:center'>";
    for (ProductOption *option in product.options) {
        for (ProductOptionValue *value in option.options) {
            if (value.isCheck) {
                optionStr = [optionStr stringByAppendingString:[NSString stringWithFormat:@"<span style='color:#000000;font-size:17px;font-family:SFUIDisplay-Bold'>%@:</span> <span style='color:#5A5A5A;font-size:17px;font-family:SFUIDisplay-Regular'>%@</span><br>", option.tittle, value.tittle]];
            }
        }
    }
    optionStr = [optionStr stringByAppendingString:@"</p>"];
    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[optionStr dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    
    self.lbOptions.attributedText = attrStr;
}
- (IBAction)qtyDecrease:(id)sender {
    int qty = [self.tfQty.text intValue];
    if (qty == 0) return;
    self.tfQty.text = [NSString stringWithFormat:@"%d", --qty];
    _product.qty = self.tfQty.text;
//    if (qty == 0) [self.lbNotice setHidden:NO];
    if (qty == 0) {
        self.removeItem(_row);
    }
}
- (IBAction)qtyIncrease:(id)sender {
    int qty = [self.tfQty.text intValue];
    self.tfQty.text = [NSString stringWithFormat:@"%d", ++qty];
    _product.qty = self.tfQty.text;
}
@end

//
//  OrderSummaryCell.m
//  Teraoka
//
//  Created by Thuan on 10/18/17.
//  Copyright © 2017 ss. All rights reserved.
//

#import "OrderSummaryCell.h"
#import "TextfieldCustom.h"
#import "NSString+KeyLanguage.h"
#import "OptionGroupModel.h"
#import "OptionModel.h"

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
    self.lbOptions.text = @"SC07_017".localizedString;
    
//    if (product.qty == 0) [self.lbNotice setHidden:NO];
//    else [self.lbNotice setHidden:YES];
    
    self.tfQty.text = product.qty;
    NSData *imageData = [NSData dataWithContentsOfFile:product.image];
    if (imageData) {
        self.productImage.image = [UIImage imageWithData:imageData];
    } else {
        self.productImage.image = [UIImage imageNamed:@"no_product_image"];
    }
    
    BOOL isSelectedOption = NO;
    NSString* optionStr = @"<p style='line-height:1.8'>";
    for (OptionGroupModel *optionGroup in product.options) {
        for (OptionModel *option in optionGroup.optionList) {
            if (option.isCheck) {
                isSelectedOption = YES;
                optionStr = [optionStr stringByAppendingString:[NSString stringWithFormat:@"<span style='color:#000000;font-size:17px;font-family:SFUIDisplay-Bold'>%@:</span> <span style='color:#5A5A5A;font-size:17px;font-family:SFUIDisplay-Regular'>%@</span><br>", (optionGroup.name.length > 0) ? optionGroup.name : @"Plu", option.name]];
            }
        }
    }
    
    optionStr = [optionStr stringByAppendingString:@"</p>"];
    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[optionStr dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    
    if (isSelectedOption) self.lbOptions.attributedText = attrStr;
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

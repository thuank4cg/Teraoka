//
//  ExistingOrderCell.m
//  Teraoka
//
//  Created by Thuan on 10/18/17.
//  Copyright © 2017 ss. All rights reserved.
//

#import "ExistingOrderCell.h"
#import "UIColor+HexString.h"
#import "NSString+KeyLanguage.h"
#import "OptionGroupModel.h"
#import "OptionModel.h"

@interface ExistingOrderCell()
@property (weak, nonatomic) IBOutlet UIImageView *productImage;
@property (weak, nonatomic) IBOutlet UILabel *lbOptions;
@property (weak, nonatomic) IBOutlet UILabel *lbPrice;
@property (weak, nonatomic) IBOutlet UILabel *lbStatus;
@property (weak, nonatomic) IBOutlet UITextField *tfQuantity;

@end

@implementation ExistingOrderCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.tfQuantity.layer.cornerRadius = self.tfQuantity.frame.size.height/2;
    self.tfQuantity.layer.borderWidth = 1.0;
    self.tfQuantity.layer.borderColor = [UIColor colorWithHexString:@"cccccc"].CGColor;
}
- (void)setDataForCell:(ProductModel *)product {
    self.tfQuantity.text = product.qty;
    self.productImage.image = [UIImage imageNamed:product.image];
    self.lbOptions.text = @"Not applicable";
    
    BOOL isSelectedOption = NO;
    NSString* optionStr = @"<p style='line-height:1.8;text-align:center'>";
    for (OptionGroupModel *optionGroup in product.options) {
        for (OptionModel *option in optionGroup.optionList) {
            if (option.isCheck) {
                isSelectedOption = YES;
                optionStr = [optionStr stringByAppendingString:[NSString stringWithFormat:@"<span style='color:#000000;font-size:17px;font-family:SFUIDisplay-Bold'>%@:</span> <span style='color:#5A5A5A;font-size:17px;font-family:SFUIDisplay-Regular'>%@</span><br>", optionGroup.name, option.name]];
            }
        }
    }
    optionStr = [optionStr stringByAppendingString:@"</p>"];
    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[optionStr dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    
    if (isSelectedOption) self.lbOptions.attributedText = attrStr;
    
    float price = [product.qty intValue] * [product.priceNumber floatValue];
    self.lbPrice.text = [NSString stringWithFormat:@"$%.2f", price];
    
    self.lbStatus.text = @"SC10_034".localizedString;
}

@end

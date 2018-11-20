//
//  OutOfStockCell.m
//  Teraoka
//
//  Created by Thuan on 8/23/18.
//  Copyright © 2018 ss. All rights reserved.
//

#import "OutOfStockCell.h"
#import "UIColor+HexString.h"
#import "ShareManager.h"
#import "NSString+KeyLanguage.h"

@interface OutOfStockCell()

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *productImage;
@property (weak, nonatomic) IBOutlet UILabel *lbProductName;
@property (weak, nonatomic) IBOutlet UILabel *lbAmount;
@property (weak, nonatomic) IBOutlet UILabel *lbAvailable;

@end

@implementation OutOfStockCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.containerView.clipsToBounds = YES;
    self.containerView.layer.cornerRadius = 3;
    self.containerView.layer.borderWidth = 1;
    self.containerView.layer.borderColor = [UIColor colorWithHexString:@"f2f2f2"].CGColor;
    
    self.lbAvailable.text = @"SC09_026".localizedString;
}

- (void)setupCell:(ProductModel *)product {
    self.lbProductName.text = product.name;
    NSData *imageData = [NSData dataWithContentsOfFile:product.image];
    if (imageData) {
        self.productImage.image = [UIImage imageWithData:imageData];
    }
    
    self.lbAmount.text = [NSString stringWithFormat:@"%@ of %@", product.qtyAvailable, product.qty];
}

@end

//
//  OutOfStockCell.m
//  Teraoka
//
//  Created by Thuan on 8/23/18.
//  Copyright © 2018 ss. All rights reserved.
//

#import "OutOfStockCell.h"
#import "UIColor+HexString.h"

@interface OutOfStockCell()

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *productImage;
@property (weak, nonatomic) IBOutlet UILabel *lbProductName;
@property (weak, nonatomic) IBOutlet UILabel *lbAmount;


@end

@implementation OutOfStockCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.containerView.clipsToBounds = YES;
    self.containerView.layer.cornerRadius = 3;
    self.containerView.layer.borderWidth = 1;
    self.containerView.layer.borderColor = [UIColor colorWithHexString:@"f2f2f2"].CGColor;
}

- (void)setupCell:(ProductModel *)product {
    self.lbProductName.text = product.name;
    if (product.image.length > 0) self.productImage.image = [UIImage imageNamed:product.image];
    self.lbAmount.text = [NSString stringWithFormat:@"%@ of %@", product.qty, product.qty];
}

@end

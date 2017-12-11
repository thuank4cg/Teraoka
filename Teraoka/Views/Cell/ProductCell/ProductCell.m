//
//  ProductCell.m
//  Teraoka
//
//  Created by Thuan on 10/17/17.
//  Copyright © 2017 ss. All rights reserved.
//

#import "ProductCell.h"
#import "UIColor+HexString.h"

@implementation ProductCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.wrapperView.clipsToBounds = YES;
    self.wrapperView.layer.cornerRadius = 3;
    
    self.containerView.layer.borderWidth = 1;
    self.containerView.layer.borderColor = [UIColor colorWithHexString:@"f2f2f2"].CGColor;
}

@end

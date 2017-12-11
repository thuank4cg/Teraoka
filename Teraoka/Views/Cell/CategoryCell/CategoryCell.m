//
//  CategoryCell.m
//  Teraoka
//
//  Created by Thuan on 10/17/17.
//  Copyright © 2017 ss. All rights reserved.
//

#import "CategoryCell.h"
#import "UIColor+HexString.h"

@implementation CategoryCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.bgView.clipsToBounds = YES;
    self.bgView.layer.cornerRadius = 10;
    self.bgView.backgroundColor = [UIColor colorWithHexString:@"1ca4fc"];
}
- (void)setDataForCell:(CategoryModel *)cateModel {
    self.lbTitle.text = cateModel.category_name;
    if (cateModel.isSelected) {
        self.bgView.backgroundColor = [UIColor colorWithHexString:@"117b76"];
    }else {
        self.bgView.backgroundColor = [UIColor colorWithHexString:@"1ca4fc"];
    }
}
@end

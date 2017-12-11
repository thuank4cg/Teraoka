//
//  CategoryCollectionCell.m
//  Teraoka
//
//  Created by Thuan on 11/15/17.
//  Copyright © 2017 ss. All rights reserved.
//

#import "CategoryCollectionCell.h"
#import "APPConstants.h"

@interface CategoryCollectionCell ()
@property (weak, nonatomic) IBOutlet UILabel *lbName;
@property (weak, nonatomic) IBOutlet UIView *lineView;

@end

@implementation CategoryCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)setDataForCell:(CategoryModel *)cate {
    self.lbName.text = cate.category_name.uppercaseString;
    
    if (cate.isSelected) {
        self.lbName.font = [UIFont fontWithName:KEY_FONT_BOLD size:20];
        [self.lineView setHidden:NO];
    }else {
        self.lbName.font = [UIFont fontWithName:KEY_FONT_REGULAR size:20];
        [self.lineView setHidden:YES];
    }
}
@end

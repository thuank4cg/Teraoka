//
//  OptionCollectionCell.m
//  Teraoka
//
//  Created by Thuan on 10/18/17.
//  Copyright © 2017 ss. All rights reserved.
//

#import "OptionCollectionCell.h"
#import "APPConstants.h"

@interface OptionCollectionCell ()
@property (weak, nonatomic) IBOutlet UIButton *radioBtn;
@property (weak, nonatomic) IBOutlet UILabel *optionTitle;

@end

@implementation OptionCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)setDataForCell:(ProductOptionValue *)optionValue {
    if (optionValue.isCheck) {
        [self.radioBtn setBackgroundImage:[UIImage imageNamed:@"ic_radio_checked"] forState:UIControlStateNormal];
    }else {
        [self.radioBtn setBackgroundImage:[UIImage imageNamed:@"ic_radio"] forState:UIControlStateNormal];
    }
    self.optionTitle.text = optionValue.tittle;
}

@end

//
//  FixedSetOptionTableCell.h
//  Teraoka
//
//  Created by Thuan Dinh on 3/6/19.
//  Copyright © 2019 ss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OptionGroupModel.h"

typedef void (^FixedSetOptionTableCellCallback)(void);

@interface FixedSetOptionTableCell : UITableViewCell

@property (nonatomic, copy) FixedSetOptionTableCellCallback fixedSetOptionTableCellCallback;

- (void)setDataForCell:(OptionGroupModel *)optionGroup;

@end

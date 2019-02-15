//
//  OptionSelectedTableCell.h
//  Teraoka
//
//  Created by Thuan Dinh on 2/13/19.
//  Copyright © 2019 ss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OptionGroupModel.h"

typedef void (^OptionSelectedTableCellCallback)(void);

@interface OptionSelectedTableCell : UITableViewCell

@property (nonatomic, copy) OptionSelectedTableCellCallback optionSelectedTableCellCallback;

- (void)setDataForCell:(OptionGroupModel *)optionGroup;

@end

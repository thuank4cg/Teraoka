//
//  OptionCollectionCell.h
//  Teraoka
//
//  Created by Thuan on 10/18/17.
//  Copyright © 2017 ss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OptionModel.h"

@interface OptionCollectionCell : UICollectionViewCell
- (void)setDataForCell:(OptionModel *)option;
@end

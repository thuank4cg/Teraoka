//
//  OptionCollectionCell.h
//  Teraoka
//
//  Created by Thuan on 10/18/17.
//  Copyright © 2017 ss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductOptionValue.h"

@interface OptionCollectionCell : UICollectionViewCell
- (void)setDataForCell:(ProductOptionValue *)optionValue;
@end

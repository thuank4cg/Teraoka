//
//  OptionTableCell.h
//  Teraoka
//
//  Created by Thuan on 10/18/17.
//  Copyright © 2017 ss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductOption.h"

@interface OptionTableCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UICollectionView *colView;
- (void)setDataForCell:(ProductOption *)productOption;
@end

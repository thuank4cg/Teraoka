//
//  OptionTableCell.m
//  Teraoka
//
//  Created by Thuan on 10/18/17.
//  Copyright © 2017 ss. All rights reserved.
//

#import "OptionTableCell.h"
#import "OptionCollectionCell.h"
#import "OptionModel.h"

@interface OptionTableCell () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@end

@implementation OptionTableCell {
    NSIndexPath *_indexPath;
    OptionGroupModel *_optionGroup;
    int selectedIndex;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.colView.delegate = self;
    self.colView.dataSource = self;
    self.colView.backgroundColor = [UIColor clearColor];
    [self.colView registerNib:[UINib nibWithNibName:@"OptionCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"OptionCollectionCellID"];
}

- (void)setDataForCell:(OptionGroupModel *)optionGroup {
    _optionGroup = optionGroup;
    [self.colView reloadData];
}

#pragma mark - UICollectionViewDataSource, UICollectionViewDelegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _optionGroup.optionList.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    OptionCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"OptionCollectionCellID" forIndexPath:indexPath];
    OptionModel *value = _optionGroup.optionList[indexPath.row];
    [cell setDataForCell:value];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(CGRectGetWidth(self.colView.frame)/3, 40);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    for (int i=0;i<_optionGroup.optionList.count;i++) {
        OptionModel *option = _optionGroup.optionList[i];
        if (i == indexPath.row) {
            option.isCheck = YES;
        } else {
            option.isCheck = NO;
        }
    }
    
    if (_optionGroup.type == TYPE_SELECTION) _optionGroup.isShowChild = YES;
    
//    [self.colView reloadData];
    self.optionTableCellCallback();
}

@end

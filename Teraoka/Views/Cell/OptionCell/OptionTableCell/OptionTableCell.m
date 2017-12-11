//
//  OptionTableCell.m
//  Teraoka
//
//  Created by Thuan on 10/18/17.
//  Copyright © 2017 ss. All rights reserved.
//

#import "OptionTableCell.h"
#import "OptionCollectionCell.h"
#import "ProductOptionValue.h"

@interface OptionTableCell () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@end

@implementation OptionTableCell {
    NSIndexPath *_indexPath;
    ProductOption *_productOption;
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

- (void)setDataForCell:(ProductOption *)productOption {
    _productOption = productOption;
}

#pragma mark - UICollectionViewDataSource, UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _productOption.options.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    OptionCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"OptionCollectionCellID" forIndexPath:indexPath];
    ProductOptionValue *value = _productOption.options[indexPath.row];
    [cell setDataForCell:value];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(CGRectGetWidth(self.colView.frame)/3, 40);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    for (int i=0;i<_productOption.options.count;i++) {
        ProductOptionValue *optionValue = _productOption.options[i];
        if (i == indexPath.row) optionValue.isCheck = YES;
        else optionValue.isCheck = NO;
    }
    [self.colView reloadData];
}

@end

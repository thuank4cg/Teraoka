//
//  FixedSetOptionTableCell.m
//  Teraoka
//
//  Created by Thuan Dinh on 3/6/19.
//  Copyright © 2019 ss. All rights reserved.
//

#import "FixedSetOptionTableCell.h"
#import "OptionCollectionCell.h"
#import "OptionModel.h"

@interface FixedSetOptionTableCell() <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UICollectionView *colView;

@end

@implementation FixedSetOptionTableCell {
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
    self.lbTitle.text = optionGroup.name;
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
            option.isCheck = !option.isCheck;
        } else {
            option.isCheck = NO;
        }
    }
    
    if (_optionGroup.type == TYPE_SELECTION) _optionGroup.isShowChild = YES;
    
    //    [self.colView reloadData];
    self.fixedSetOptionTableCellCallback();
}

@end

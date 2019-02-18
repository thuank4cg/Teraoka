//
//  OptionSelectedTableCell.m
//  Teraoka
//
//  Created by Thuan Dinh on 2/13/19.
//  Copyright © 2019 ss. All rights reserved.
//

#import "OptionSelectedTableCell.h"
#import "OptionCollectionCell.h"

@interface OptionSelectedTableCell () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *colView;
@property (weak, nonatomic) IBOutlet UILabel *lbSelected;

@end

@implementation OptionSelectedTableCell {
    OptionGroupModel *_optionGroup;
    OptionModel *optionSelected;
    NSMutableArray *options;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.colView.delegate = self;
    self.colView.dataSource = self;
    self.colView.backgroundColor = [UIColor clearColor];
    [self.colView registerNib:[UINib nibWithNibName:@"OptionCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"OptionCollectionCellID"];
}

- (IBAction)changeAction:(id)sender {
    for (OptionModel *option in _optionGroup.optionList) {
        if (option.product) option.isCheck = NO;
    }
    _optionGroup.isShowChild = NO;
    self.optionSelectedTableCellCallback();
}

- (void)setDataForCell:(OptionGroupModel *)optionGroup {
    _optionGroup = optionGroup;
    options = [NSMutableArray new];
    
    NSString *childName = @"";

    for (OptionModel *option in _optionGroup.optionList) {
        if (option.product && option.isCheck) {
            childName = option.name;
            optionSelected = option;
            break;
        }
    }
    
    for (OptionGroupModel *optionGroup in optionSelected.product.options) {
        for (OptionModel *option in optionGroup.optionList) {
            [options addObject:option];
        }
    }

    self.lbSelected.text = [NSString stringWithFormat:@"You selected: %@", childName];
    
    [self.colView reloadData];
}

#pragma mark - UICollectionViewDataSource, UICollectionViewDelegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return options.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    OptionCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"OptionCollectionCellID" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    [cell setDataForCell:options[indexPath.row]];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(CGRectGetWidth(self.colView.frame)/3, 40);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    for (int i=0;i<options.count;i++) {
        OptionModel *option = options[i];
        if (i == indexPath.row) {
            option.isCheck = YES;
        } else {
            option.isCheck = NO;
        }
    }
    
    //    [self.colView reloadData];
    self.optionSelectedTableCellCallback();
}

@end

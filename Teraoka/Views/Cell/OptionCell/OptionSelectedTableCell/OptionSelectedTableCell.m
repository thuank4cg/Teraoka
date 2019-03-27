//
//  OptionSelectedTableCell.m
//  Teraoka
//
//  Created by Thuan Dinh on 2/13/19.
//  Copyright © 2019 ss. All rights reserved.
//

#import "OptionSelectedTableCell.h"
#import "OptionCollectionCell.h"
#import <Masonry.h>

@interface OptionSelectedTableCell () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UILabel *lbSelected;
@property (weak, nonatomic) IBOutlet UIView *preferenceContentView;
@property (weak, nonatomic) IBOutlet UIView *optionContainerView;

@end

@implementation OptionSelectedTableCell {
    OptionGroupModel *_optionGroup;
    OptionModel *optionSelected;
    NSMutableArray *options;
    UICollectionView *optionCollectionView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (IBAction)changeAction:(id)sender {
    for (OptionModel *option in _optionGroup.optionList) {
        if (option.product) option.isCheck = NO;
    }
    
    for (OptionGroupModel *optionGroup in optionSelected.product.options) {
        for (OptionModel *option in optionGroup.optionList) {
            option.isCheck = NO;
        }
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
    
    [self.preferenceContentView setHidden:(options.count == 0)];

    self.lbSelected.text = [NSString stringWithFormat:@"You selected: %@", childName];
    
    if (optionCollectionView) [optionCollectionView removeFromSuperview];
    
    UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    optionCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    
    [self.optionContainerView addSubview:optionCollectionView];
    
    [optionCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(optionCollectionView.superview);
        make.leading.equalTo(optionCollectionView.superview);
        make.top.equalTo(optionCollectionView.superview);
    }];
    
    optionCollectionView.backgroundColor = [UIColor redColor];
    optionCollectionView.delegate = self;
    optionCollectionView.dataSource = self;
    optionCollectionView.backgroundColor = [UIColor clearColor];
    [optionCollectionView registerNib:[UINib nibWithNibName:@"OptionCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"OptionCollectionCellID"];
    
    [optionCollectionView reloadData];
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
    return CGSizeMake(CGRectGetWidth(self.optionContainerView.frame)/3, 40);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    for (int i=0;i<options.count;i++) {
        OptionModel *option = options[i];
        if (i == indexPath.row) {
            option.isCheck = !option.isCheck;
        } else {
            option.isCheck = NO;
        }
    }
    
    self.optionSelectedTableCellCallback();
}

@end

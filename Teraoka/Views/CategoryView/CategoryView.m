//
//  CategoryView.m
//  Teraoka
//
//  Created by Thuan on 11/15/17.
//  Copyright © 2017 ss. All rights reserved.
//

#import "CategoryView.h"
#import "CategoryCollectionCell.h"
#import "CategoryModel.h"

@interface CategoryView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *colView;

@end

@implementation CategoryView {
    NSMutableArray *categories;
}
- (void)awakeFromNib {
    [super awakeFromNib];
}
- (void)setupData:(NSMutableArray *)cateArr {
    categories = cateArr;
    [self.colView setShowsHorizontalScrollIndicator:NO];
    self.colView.delegate = self;
    self.colView.dataSource = self;
    [self.colView registerNib:[UINib nibWithNibName:@"CategoryCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"CategoryCollectionCellID"];
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return  categories.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CategoryCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CategoryCollectionCellID" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    CategoryModel *cate = categories[indexPath.row];
    [cell setDataForCell:cate];
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(200, 65);
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    CategoryModel *model = categories[self.categoryIndex];
    model.isSelected = NO;
    self.categoryIndex = (int)indexPath.row;
    self.chooseCategory(self.categoryIndex);
    model = categories[self.categoryIndex];
    model.isSelected = YES;
    [self.colView reloadData];
}
@end

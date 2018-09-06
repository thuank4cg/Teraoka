//
//  OutOfStockController.m
//  Teraoka
//
//  Created by Thuan on 8/23/18.
//  Copyright © 2018 ss. All rights reserved.
//

#import "OutOfStockController.h"
#import "OutOfStockCell.h"
#import "ProductModel.h"
#import "ShareManager.h"
#import "OutOfStockModel.h"

@interface OutOfStockController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@end

@implementation OutOfStockController {
    NSMutableArray *products;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    products = [NSMutableArray new];
    
    for (OutOfStockModel *model in [ShareManager shared].outOfStockArr) {
        for (ProductModel *product in [ShareManager shared].cartArr) {
            if ([model.ids isEqualToString:product.ids]) {
                [products addObject:product];
                product.qtyAvailable = model.qty;
            }
        }
    }
    
    [self setupView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view removeFromSuperview];
}

- (IBAction)noAction:(id)sender {
    [self.view removeFromSuperview];
}

- (IBAction)yesAction:(id)sender {
    for (OutOfStockModel *model in [ShareManager shared].outOfStockArr) {
        for (ProductModel *product in [ShareManager shared].cartArr) {
            if ([model.ids isEqualToString:product.ids]) {
                product.qty = model.qty;
            }
        }
    }
    
    [self sendPOSRequest:SendTransaction];
}

//MARK: Custom method

- (void)setupView {
    self.containerView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.containerView.layer.shadowOffset = CGSizeMake(8.0f, 8.0f);
    self.containerView.layer.shadowOpacity = 0.2;
    self.containerView.layer.shadowRadius = 3.0;
    self.containerView.layer.masksToBounds = NO;
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerNib:[UINib nibWithNibName:@"OutOfStockCell" bundle:nil] forCellWithReuseIdentifier:@"OutOfStockCellID"];
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return products.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    OutOfStockCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"OutOfStockCellID" forIndexPath:indexPath];
    ProductModel *product = products[indexPath.row];
    [cell setupCell:product];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(200, 280);
}

@end

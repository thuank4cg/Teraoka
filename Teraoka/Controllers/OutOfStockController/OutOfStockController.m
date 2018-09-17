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
#import "Util.h"
#import "NSString+KeyLanguage.h"

@interface OutOfStockController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle1;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle2;
@property (weak, nonatomic) IBOutlet UIButton *noBtn;
@property (weak, nonatomic) IBOutlet UIButton *yesBtn;

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

- (void)loadLocalizable {
    [super loadLocalizable];
    
    self.lbTitle1.text = @"SC09_024".localizedString;
    self.lbTitle2.text = @"SC09_025".localizedString;
    [self.noBtn setTitle:@"SC09_027".localizedString forState:UIControlStateNormal];
    [self.yesBtn setTitle:@"SC09_028".localizedString forState:UIControlStateNormal];
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
    
    products = [NSMutableArray new];
    
    for (ProductModel *product in [ShareManager shared].cartArr) {
        if ([product.qty intValue] > 0) {
            [products addObject:product];
        }
    }
    
    if (products.count == 0) {
        [Util showAlert:@"No product to proceed." vc:self];
        return;
    }
    
    [ShareManager shared].cartArr = products;
    
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

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    NSInteger cellCount = [collectionView.dataSource collectionView:collectionView numberOfItemsInSection:section];
    if (cellCount > 0) {
        CGFloat cellWidth = 200;
        CGFloat totalCellWidth = cellWidth * cellCount + 10 * (cellCount - 1);
        CGFloat contentWidth = collectionView.frame.size.width - collectionView.contentInset.left - collectionView.contentInset.right;
        if(totalCellWidth < contentWidth) {
            CGFloat padding = (contentWidth - totalCellWidth) / 2.0;
            return UIEdgeInsetsMake(0, padding, 0, padding);
        }
    }
    return UIEdgeInsetsZero;
}

@end

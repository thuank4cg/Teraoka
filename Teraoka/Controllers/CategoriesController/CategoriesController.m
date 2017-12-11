//
//  CategoriesController.m
//  Teraoka
//
//  Created by Thuan on 10/17/17.
//  Copyright © 2017 ss. All rights reserved.
//

#import "CategoriesController.h"
#import "CategoryCell.h"
#import "ProductCell.h"
#import "ViewExistingOrderController.h"
#import "NewOrderController.h"
#import "ShareManager.h"
#import "CategoryModel.h"
#import "ProductModel.h"
#import "OrderSummaryController.h"
#import "ShareManager.h"
#import "CategoryModel.h"
#import "ProductModel.h"
#import "ProductOption.h"
#import "ProductOptionValue.h"
#import "OrderSummaryController.h"
#import "CategoryView.h"
#import "WhiteRaccoon.h"
#import "Util.h"

#define KEY_PADDING_BOTTOM_CELL 65
#define CELL_SPACE 15

@interface CategoriesController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, WRRequestDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *productsColView;
@property (weak, nonatomic) IBOutlet UIView *containerCategoryView;
@property (weak, nonatomic) IBOutlet UIView *menuBoxView;
@property (weak, nonatomic) IBOutlet UIView *qtyBoxView;
@property (weak, nonatomic) IBOutlet UILabel *lbQty;

@end

@implementation CategoriesController  {
    CGFloat itemWidth;
    NSMutableArray *categories;
    int categoryIndex;
    NewOrderController *newOrderVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.qtyBoxView.layer.cornerRadius = CGRectGetWidth(self.qtyBoxView.frame)/2;
    
    WRRequestDownload *downloadFile = [[WRRequestDownload alloc] init];
    downloadFile.delegate = self;
    downloadFile.username = @"root";
    downloadFile.password = @"teraoka";
    
    [downloadFile start];
}

- (void)requestCompleted:(WRRequest *)request {
    WRRequestDownload * downloadFile = (WRRequestDownload *)request;
    
    NSString *dataStr = [Util convertDataToString:downloadFile.receivedData];
    [Util saveFileToDocumentDirectory:dataStr];
}
- (void)requestFailed:(WRRequest *)request {
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupQtyBoxView];
    [self dummyData];
}

- (void)setupQtyBoxView {
    if ([ShareManager shared].cartArr.count > 0) {
        self.qtyBoxView.hidden = NO;
        int qty = 0;
        for (ProductModel *product in [ShareManager shared].cartArr) {
            qty += [product.qty intValue];
        }
        self.lbQty.text = [NSString stringWithFormat:@"%d", qty];
    }else {
        self.qtyBoxView.hidden = YES;
        self.lbQty.text = @"0";
    }
}

- (void)setupView {
    // Shadow and Radius
    self.containerCategoryView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.containerCategoryView.layer.shadowOffset = CGSizeMake(0.0f, 4.0f);
    self.containerCategoryView.layer.shadowOpacity = 0.2;
    self.containerCategoryView.layer.shadowRadius = 3.0;
    self.containerCategoryView.layer.masksToBounds = NO;
    
    self.menuBoxView.clipsToBounds = YES;
    self.menuBoxView.layer.cornerRadius = 5;
    
    self.menuBoxView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.menuBoxView.layer.shadowOffset = CGSizeMake(4.0f, 4.0f);
    self.menuBoxView.layer.shadowOpacity = 0.2;
    self.menuBoxView.layer.shadowRadius = 3.0;
    self.menuBoxView.layer.masksToBounds = NO;
    
    CategoryView *cateView = [[[NSBundle mainBundle] loadNibNamed:@"CategoryView" owner:self options:nil] objectAtIndex:0];
    cateView.frame = CGRectMake(0, 0, CGRectGetWidth(self.containerCategoryView.frame), CGRectGetHeight(self.containerCategoryView.frame));
    cateView.categoryIndex = categoryIndex;
    [cateView setupData:categories];
    __weak CategoriesController *wSelf = self;
    cateView.chooseCategory = ^(int index) {
        categoryIndex = index;
        [wSelf.productsColView reloadData];
    };
    [self.containerCategoryView addSubview:cateView];
    
    itemWidth = (CGRectGetWidth(self.productsColView.frame) - CELL_SPACE*4)/4;
    
    self.productsColView.delegate = self;
    self.productsColView.dataSource = self;
    [self.productsColView registerNib:[UINib nibWithNibName:@"ProductCell" bundle:nil] forCellWithReuseIdentifier:@"ProductCellID"];
    [self.productsColView reloadData];
}
- (IBAction)homeAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)orderCart:(id)sender {
//    OrderSummaryController *vc = [[OrderSummaryController alloc] initWithNibName:@"OrderSummaryController" bundle:nil];
//    [self.navigationController pushViewController:vc animated:YES];
    [self showOrderCart];
}
- (IBAction)callWaiter:(id)sender {
}
- (IBAction)viewBill:(id)sender {
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:nil
                                 message:@"\"View Bill\" function is not applicable for Demo"
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Ok"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    //Handle your yes please button action here
                                }];
    
    [alert addAction:yesButton];
    [self presentViewController:alert animated:YES completion:nil];

}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    CategoryModel *cate = categories[categoryIndex];
    return cate.products.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ProductCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ProductCellID" forIndexPath:indexPath];
    CategoryModel *cate = categories[categoryIndex];
    ProductModel *product = cate.products[indexPath.row];
    
    cell.productName.text = product.name;
    cell.productImage.image = [UIImage imageNamed:product.image];
    cell.productPrice.text = product.price;
    
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(itemWidth, itemWidth + KEY_PADDING_BOTTOM_CELL);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    newOrderVC = [[NewOrderController alloc] initWithNibName:@"NewOrderController" bundle:nil];
    CategoryModel *cate = categories[categoryIndex];
    newOrderVC.product = cate.products[indexPath.row];
//    [self.navigationController pushViewController:vc animated:NO];
    newOrderVC.delegate = self;
    newOrderVC.view.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    [self addChildViewController:newOrderVC];
    [self.view addSubview:newOrderVC.view];
    [newOrderVC didMoveToParentViewController:self];
}

#pragma mark - Custom method
- (void)showOrderCart {
    [self setupQtyBoxView];
    if ([ShareManager shared].cartArr.count == 0) return;
    if (newOrderVC) {
        [newOrderVC.view removeFromSuperview];
        newOrderVC = nil;
    }
    OrderSummaryController *vc = [[OrderSummaryController alloc] initWithNibName:@"OrderSummaryController" bundle:nil];
    vc.view.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    vc.delegate = self;
    [self addChildViewController:vc];
    [self.view addSubview:vc.view];
    [vc didMoveToParentViewController:self];
}
- (void)backDelegate {
    [self setupQtyBoxView];
    [self dummyData];
}
// dummy data
- (void)dummyData {
    categories = [NSMutableArray new];
    NSArray *categoriesArr = @[@"Drinks", @"Bread", @"Cake", @"Chocolate", @"Soups", @"Fruits"];
    int i = 0;
    for (NSString *cate in categoriesArr) {
        i++;
        CategoryModel *cateModel = [[CategoryModel alloc] init];
        cateModel.ids = [NSString stringWithFormat:@"%d", i];
        cateModel.category_name = cate;
        if (i == 1) cateModel.isSelected = YES;
        else cateModel.isSelected = NO;
        
        cateModel.products = [NSMutableArray new];
        
        ProductModel *product = [[ProductModel alloc] init];
        product.ids = [NSString stringWithFormat:@"%d1", i];
        product.image = [NSString stringWithFormat:@"%@1.jpg", cate];
        product.name = [NSString stringWithFormat:@"%@ 1", cate];
        product.price = @"$3.00";
        product.priceNumber = @"3.00";
        product.qty = @"1";
        product.options = [[NSMutableArray alloc] init];
        NSArray *options = @[@"Add option 1", @"Add option 2", @"Add option 3"];
        for (NSString *tittle in options) {
            ProductOption *option = [[ProductOption alloc] init];
            option.tittle = tittle;
            
            option.options = [NSMutableArray new];
            
            ProductOptionValue *optionValue = [[ProductOptionValue alloc] init];
            optionValue.isCheck = NO;
            optionValue.tittle = @"Option A";
            [option.options addObject:optionValue];
            
            ProductOptionValue *optionValue2 = [[ProductOptionValue alloc] init];
            optionValue2.isCheck = NO;
            optionValue2.tittle = @"Option B";
            [option.options addObject:optionValue2];
            
            ProductOptionValue *optionValue3 = [[ProductOptionValue alloc] init];
            optionValue3.isCheck = NO;
            optionValue3.tittle = @"Option C";
            [option.options addObject:optionValue3];
            
            [product.options addObject:option];
        }
        
        [cateModel.products addObject:product];
        
        ProductModel *product2 = [[ProductModel alloc] init];
        product2.ids = [NSString stringWithFormat:@"%d2", i];;
        product2.image = [NSString stringWithFormat:@"%@2.jpg", cate];
        product2.name = [NSString stringWithFormat:@"%@ 2", cate];
        product2.price = @"$5.00";
        product2.priceNumber = @"5.00";
        product2.qty = @"1";
        product2.options = [[NSMutableArray alloc] init];
        for (NSString *tittle in options) {
            ProductOption *option = [[ProductOption alloc] init];
            option.tittle = tittle;
            
            option.options = [NSMutableArray new];
            
            ProductOptionValue *optionValue = [[ProductOptionValue alloc] init];
            optionValue.isCheck = NO;
            optionValue.tittle = @"Option A";
            [option.options addObject:optionValue];
            
            ProductOptionValue *optionValue2 = [[ProductOptionValue alloc] init];
            optionValue2.isCheck = NO;
            optionValue2.tittle = @"Option B";
            [option.options addObject:optionValue2];
            
            ProductOptionValue *optionValue3 = [[ProductOptionValue alloc] init];
            optionValue3.isCheck = NO;
            optionValue3.tittle = @"Option C";
            [option.options addObject:optionValue3];
            
            [product2.options addObject:option];
        }
        
        [cateModel.products addObject:product2];
        
        ProductModel *product3 = [[ProductModel alloc] init];
        product3.ids = [NSString stringWithFormat:@"%d3", i];;
        product3.image = [NSString stringWithFormat:@"%@3.jpg", cate];
        product3.name = [NSString stringWithFormat:@"%@ 3", cate];
        product3.price = @"$15.00";
        product3.priceNumber = @"15.00";
        product3.qty = @"1";
        product3.options = [[NSMutableArray alloc] init];
        for (NSString *tittle in options) {
            ProductOption *option = [[ProductOption alloc] init];
            option.tittle = tittle;
            
            option.options = [NSMutableArray new];
            
            ProductOptionValue *optionValue = [[ProductOptionValue alloc] init];
            optionValue.isCheck = NO;
            optionValue.tittle = @"Option A";
            [option.options addObject:optionValue];
            
            ProductOptionValue *optionValue2 = [[ProductOptionValue alloc] init];
            optionValue2.isCheck = NO;
            optionValue2.tittle = @"Option B";
            [option.options addObject:optionValue2];
            
            ProductOptionValue *optionValue3 = [[ProductOptionValue alloc] init];
            optionValue3.isCheck = NO;
            optionValue3.tittle = @"Option C";
            [option.options addObject:optionValue3];
            
            [product3.options addObject:option];
        }
        
        [cateModel.products addObject:product3];
        
        ProductModel *product4 = [[ProductModel alloc] init];
        product4.ids = [NSString stringWithFormat:@"%d4", i];;
        product4.image = [NSString stringWithFormat:@"%@3.jpg", cate];
        product4.name = [NSString stringWithFormat:@"%@ 4", cate];
        product4.price = @"$15.00";
        product4.priceNumber = @"15.00";
        product4.qty = @"1";
        product4.options = [[NSMutableArray alloc] init];
        for (NSString *tittle in options) {
            ProductOption *option = [[ProductOption alloc] init];
            option.tittle = tittle;
            
            option.options = [NSMutableArray new];
            
            ProductOptionValue *optionValue = [[ProductOptionValue alloc] init];
            optionValue.isCheck = NO;
            optionValue.tittle = @"Choice A";
            [option.options addObject:optionValue];
            
            ProductOptionValue *optionValue2 = [[ProductOptionValue alloc] init];
            optionValue2.isCheck = NO;
            optionValue2.tittle = @"Choice B";
            [option.options addObject:optionValue2];
            
            ProductOptionValue *optionValue3 = [[ProductOptionValue alloc] init];
            optionValue3.isCheck = NO;
            optionValue3.tittle = @"Choice C";
            [option.options addObject:optionValue3];
            
            [product4.options addObject:option];
        }
        
        [cateModel.products addObject:product4];
        
        ProductModel *product5 = [[ProductModel alloc] init];
        product5.ids = [NSString stringWithFormat:@"%d5", i];;
        product5.image = [NSString stringWithFormat:@"%@3.jpg", cate];
        product5.name = [NSString stringWithFormat:@"%@ 5", cate];
        product5.price = @"$15.00";
        product5.priceNumber = @"15.00";
        product5.qty = @"1";
        product5.options = [[NSMutableArray alloc] init];
        for (NSString *tittle in options) {
            ProductOption *option = [[ProductOption alloc] init];
            option.tittle = tittle;
            
            option.options = [NSMutableArray new];
            
            ProductOptionValue *optionValue = [[ProductOptionValue alloc] init];
            optionValue.isCheck = NO;
            optionValue.tittle = @"Choice A";
            [option.options addObject:optionValue];
            
            ProductOptionValue *optionValue2 = [[ProductOptionValue alloc] init];
            optionValue2.isCheck = NO;
            optionValue2.tittle = @"Choice B";
            [option.options addObject:optionValue2];
            
            ProductOptionValue *optionValue3 = [[ProductOptionValue alloc] init];
            optionValue3.isCheck = NO;
            optionValue3.tittle = @"Choice C";
            [option.options addObject:optionValue3];
            
            [product5.options addObject:option];
        }
        
        [cateModel.products addObject:product5];
        
        [categories addObject:cateModel];
    }
    
    categoryIndex = 0;
    [self setupView];
}

@end

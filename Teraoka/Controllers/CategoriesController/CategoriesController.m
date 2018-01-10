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
#import "Util.h"
#import "APPConstants.h"

#define KEY_PADDING_BOTTOM_CELL 65
#define CELL_SPACE 15

@interface CategoriesController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
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
    BOOL isBackDelegate;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.qtyBoxView.layer.cornerRadius = CGRectGetWidth(self.qtyBoxView.frame)/2;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupQtyBoxView];
    isBackDelegate = NO;
    [self setData];
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
    if (categoryIndex < categories.count) {
        CategoryModel *cate = categories[categoryIndex];
        return cate.products.count;
    }
    return 0;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ProductCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ProductCellID" forIndexPath:indexPath];
    
    if (categoryIndex < categories.count) {
        CategoryModel *cate = categories[categoryIndex];
        
        if (indexPath.row < cate.products.count) {
            ProductModel *product = cate.products[indexPath.row];
            
            cell.productName.text = product.name;
            if (product.image.length > 0) cell.productImage.image = [UIImage imageNamed:product.image];
            cell.productPrice.text = product.price;
        }
    }
    
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(itemWidth, itemWidth + KEY_PADDING_BOTTOM_CELL);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    newOrderVC = [[NewOrderController alloc] initWithNibName:@"NewOrderController" bundle:nil];
    if (categoryIndex < categories.count) {
        CategoryModel *cate = categories[categoryIndex];
        if (indexPath.row < cate.products.count) {
            newOrderVC.product = cate.products[indexPath.row];
        }
    }
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
    isBackDelegate = YES;
    [self setData];
}
- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}
// dummy data
- (void)setData {
    if (!isBackDelegate) categoryIndex = 0;
    categories = [NSMutableArray new];
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Category"];
    NSArray *categoriesArr = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    int i = 0;
    for (NSManagedObject *category in categoriesArr) {
        CategoryModel *cateModel = [[CategoryModel alloc] init];
        cateModel.ids = [category valueForKey:@"id"];
        cateModel.category_name = [category valueForKey:@"name"];
        if (i == categoryIndex) cateModel.isSelected = YES;
        else cateModel.isSelected = NO;
        i++;
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"MenuContent"];
        NSArray *contents = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
        
        NSMutableArray *productIds = [NSMutableArray new];
        for (NSManagedObject *content in contents) {
            NSString *categoryIdStr = [content valueForKey:@"category_id"];
            if ([categoryIdStr isEqualToString:cateModel.ids]) {
                [productIds addObject:[content valueForKey:@"product_id"]];
            }
        }
        
        cateModel.products = [NSMutableArray new];
        
        for (NSString *productId in productIds) {
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Product"];
            NSArray *products = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
            
            for (NSManagedObject *productObj in products) {
                NSString *productIdStr = [productObj valueForKey:@"id"];
                if ([productIdStr isEqualToString:productId]) {
                    ProductModel *product = [[ProductModel alloc] init];
                    product.ids = [productObj valueForKey:@"id"];
                    product.image = [NSString stringWithFormat:@"%@.png", [productObj valueForKey:@"id"]];
                    product.name = [NSString stringWithFormat:@"%@", [productObj valueForKey:@"name"]];
                    
                    float price = [[productObj valueForKey:@"price"] floatValue]/100;
                    
                    product.price = [NSString stringWithFormat:@"SGD %.2f", price];
                    product.priceNumber = [NSString stringWithFormat:@"%.2f", price];
                    product.originalPrice = [NSString stringWithFormat:@"%@", [productObj valueForKey:@"price"]];
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
                }
            }
        }
        
        [categories addObject:cateModel];
        
        if (i == categoriesArr.count) {
            [self setupView];
        }
    }
    
//    [self setupView];
}

@end

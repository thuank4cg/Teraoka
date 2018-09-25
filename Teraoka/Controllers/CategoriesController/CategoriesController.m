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
#import "ShareManager.h"
#import "EnterPassAccessSettingController.h"
#import <View+MASAdditions.h>
#import "SettingsController.h"
#import <ProgressHUD.h>
#import "OutOfStockController.h"
#import "LocalizeHelper.h"
#import "NSString+KeyLanguage.h"
#import "WaiterController.h"
#import "SplashController.h"

typedef NS_ENUM(NSInteger, MENU_ITEMS) {
    Home = 0,
    Order,
    Waiter,
    Bill
};

#define KEY_PADDING_BOTTOM_CELL 65
#define CELL_SPACE 15

@interface CategoriesController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, EnterPassAccessDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *productsColView;
@property (weak, nonatomic) IBOutlet UIView *containerCategoryView;
@property (weak, nonatomic) IBOutlet UIView *menuBoxView;
@property (weak, nonatomic) IBOutlet UIView *restartOrderView;
@property (weak, nonatomic) IBOutlet UIView *qtyBoxView;
@property (weak, nonatomic) IBOutlet UILabel *lbQty;
@property (weak, nonatomic) IBOutlet UIImageView *homeArrowIcon;
@property (weak, nonatomic) IBOutlet UIImageView *orderArrowIcon;
@property (weak, nonatomic) IBOutlet UIImageView *waiterArrowIcon;
@property (weak, nonatomic) IBOutlet UIImageView *billArrowIcon;
@property (weak, nonatomic) IBOutlet UIView *waiterMenuView;
@property (weak, nonatomic) IBOutlet UIImageView *billMenuIcon;
@property (weak, nonatomic) IBOutlet UIButton *settingBtn;
@property (weak, nonatomic) IBOutlet UILabel *headerMenuTitleLb;
@property (weak, nonatomic) IBOutlet UILabel *homeMenuTitleLb;
@property (weak, nonatomic) IBOutlet UILabel *orderMenuTitleLb;
@property (weak, nonatomic) IBOutlet UILabel *waiterMenuTitleLb;
@property (weak, nonatomic) IBOutlet UILabel *billMenuTitleLb;
@property (weak, nonatomic) IBOutlet UILabel *restartOrderLb;

@end

@implementation CategoriesController  {
    CGFloat itemWidth;
    NSMutableArray *menuIcons;
    NSMutableArray *categories;
    int categoryIndex;
    NewOrderController *newOrderVC;
    EnterPassAccessSettingController *enterPassSettingVC;
    BOOL isBackDelegate;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupView];
    [self setupQtyBoxView];
    isBackDelegate = NO;
    [self setData];
}

- (void)loadLocalizable {
    [super loadLocalizable];
    
    self.headerMenuTitleLb.text = @"SC04_004".localizedString;
    self.homeMenuTitleLb.text = @"SC04_006".localizedString;
    self.waiterMenuTitleLb.text = @"SC04_007".localizedString;
    self.orderMenuTitleLb.text = @"SC04_008".localizedString;
    self.billMenuTitleLb.text = @"SC04_009".localizedString;
    self.restartOrderLb.text = @"SC04_010".localizedString;
}

- (IBAction)homeAction:(id)sender {
    [self selectedMenuAt:Home];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)orderCart:(id)sender {
    //    OrderSummaryController *vc = [[OrderSummaryController alloc] initWithNibName:@"OrderSummaryController" bundle:nil];
    //    [self.navigationController pushViewController:vc animated:YES];
    [self showOrderCart];
}

- (IBAction)callWaiter:(id)sender {
    [self selectedMenuAt:Waiter];
    
    WaiterController *vc = [[WaiterController alloc] initWithNibName:@"WaiterController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
    
    [self addChildViewController:vc];
    [self.view addSubview:vc.view];
    [vc didMoveToParentViewController:self];
    
    [vc.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.equalTo(vc.view.superview);
        make.width.equalTo(vc.view.superview.mas_width);
        make.height.equalTo(vc.view.superview.mas_height);
    }];
}

- (IBAction)viewBill:(id)sender {
//    UIAlertController * alert = [UIAlertController
//                                 alertControllerWithTitle:nil
//                                 message:@"\"View Bill\" function is not applicable for Demo"
//                                 preferredStyle:UIAlertControllerStyleAlert];
//
//    UIAlertAction* yesButton = [UIAlertAction
//                                actionWithTitle:@"Ok"
//                                style:UIAlertActionStyleDefault
//                                handler:^(UIAlertAction * action) {
//                                    //Handle your yes please button action here
//                                }];
//
//    [alert addAction:yesButton];
//    [self presentViewController:alert animated:YES completion:nil];
    
    if ([ShareManager shared].existingOrderArr.count == 0) return;
    
    [self selectedMenuAt:Bill];
    
    ViewExistingOrderController *vc = [[ViewExistingOrderController alloc] initWithNibName:@"ViewExistingOrderController" bundle:nil];
    vc.view.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    [self addChildViewController:vc];
    [self.view addSubview:vc.view];
    [vc didMoveToParentViewController:self];
}

- (IBAction)restartOrderAction:(id)sender {
    if ([ShareManager shared].cartArr.count == 0) return;
    
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:nil
                                 message:@"Do you want to restart order?"
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* noButton = [UIAlertAction
                                actionWithTitle:@"Cancel"
                                style:UIAlertActionStyleDestructive
                                handler:^(UIAlertAction * action) {
                                    //Handle your yes please button action here
                                }];
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Ok"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    [ShareManager shared].cartArr = nil;
                                    [ShareManager shared].existingOrderArr = nil;
                                    [self setupQtyBoxView];
                                }];
    
    [alert addAction:noButton];
    [alert addAction:yesButton];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)setupView {
    self.qtyBoxView.layer.cornerRadius = CGRectGetWidth(self.qtyBoxView.frame)/2;
    
    menuIcons = [NSMutableArray new];
    [menuIcons addObject:self.homeArrowIcon];
    [menuIcons addObject:self.orderArrowIcon];
    [menuIcons addObject:self.waiterArrowIcon];
    [menuIcons addObject:self.billArrowIcon];
    
    // Shadow and Radius
    self.containerCategoryView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.containerCategoryView.layer.shadowOffset = CGSizeMake(0.0f, 4.0f);
    self.containerCategoryView.layer.shadowOpacity = 0.2;
    self.containerCategoryView.layer.shadowRadius = 3.0;
    self.containerCategoryView.layer.masksToBounds = NO;
    
    self.menuBoxView.clipsToBounds = YES;
    self.menuBoxView.layer.cornerRadius = 10;
    
    self.menuBoxView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.menuBoxView.layer.shadowOffset = CGSizeMake(4.0f, 4.0f);
    self.menuBoxView.layer.shadowOpacity = 0.2;
    self.menuBoxView.layer.shadowRadius = 3.0;
    self.menuBoxView.layer.masksToBounds = NO;
    
    self.restartOrderView.clipsToBounds = YES;
    self.restartOrderView.layer.cornerRadius = 5;
    
    self.restartOrderView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.restartOrderView.layer.shadowOffset = CGSizeMake(4.0f, 4.0f);
    self.restartOrderView.layer.shadowOpacity = 0.2;
    self.restartOrderView.layer.shadowRadius = 3.0;
    self.restartOrderView.layer.masksToBounds = NO;
    
    CGFloat heightWaiterMenu = 110;
    if ([ShareManager shared].setting.abilityRequestForBill) {
        [self.waiterMenuView setHidden:NO];
    } else {
        [self.waiterMenuView setHidden:YES];
        heightWaiterMenu = 0;
    }
    
    for (NSLayoutConstraint *constraint in self.waiterMenuView.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeHeight) {
            constraint.constant = heightWaiterMenu;
            break;
        }
    }
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(gotoSettingAction:)];
    [longPress setMinimumPressDuration:2];
    [self.settingBtn addGestureRecognizer:longPress];
}

- (void)setupQtyBoxView {
    if ([ShareManager shared].cartArr.count > 0) {
        self.qtyBoxView.hidden = NO;
        int qty = 0;
        for (ProductModel *product in [ShareManager shared].cartArr) {
            qty += [product.qty intValue];
        }
        self.lbQty.text = [NSString stringWithFormat:@"%d", qty];
    } else {
        self.qtyBoxView.hidden = YES;
        self.lbQty.text = @"0";
    }
    
    if ([ShareManager shared].existingOrderArr.count == 0) {
        self.billMenuIcon.alpha = 0.5;
    } else {
        self.billMenuIcon.alpha = 1.0;
    }
}

- (void)setupCategoryView {
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

- (void)gotoSettingAction:(id)sender {
    if (enterPassSettingVC) return;
    
    enterPassSettingVC = [[EnterPassAccessSettingController alloc] initWithNibName:@"EnterPassAccessSettingController" bundle:nil];
    enterPassSettingVC.delegate = self;
    [self addChildViewController:enterPassSettingVC];
    [self.view addSubview:enterPassSettingVC.view];
    [enterPassSettingVC didMoveToParentViewController:self];
    
    [enterPassSettingVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.equalTo(enterPassSettingVC.view.superview);
        make.width.equalTo(enterPassSettingVC.view.superview.mas_width);
        make.height.equalTo(enterPassSettingVC.view.superview.mas_height);
    }];
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
    
    [self selectedMenuAt:Order];
    
    OrderSummaryController *vc = [[OrderSummaryController alloc] initWithNibName:@"OrderSummaryController" bundle:nil];
    vc.view.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    vc.delegate = self;
    [self addChildViewController:vc];
    [self.view addSubview:vc.view];
    [vc didMoveToParentViewController:self];
}

- (void)backDelegate {
    if (newOrderVC) {
        newOrderVC = nil;
    }
    
    [self setupQtyBoxView];
    isBackDelegate = YES;
    [self setData];
}

- (void)showOutOfStockScreen {
    OutOfStockController *vc = [[OutOfStockController alloc] initWithNibName:@"OutOfStockController" bundle:nil];
    [self addChildViewController:vc];
    [self.view addSubview:vc.view];
    [vc didMoveToParentViewController:self];
    
    [vc.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.equalTo(vc.view.superview);
        make.width.equalTo(vc.view.superview.mas_width);
        make.height.equalTo(vc.view.superview.mas_height);
    }];
}

- (void)selectedMenuAt:(int)index {
    for (UIImageView *icon in menuIcons) {
        [icon setHidden:YES];
    }
    
    UIImageView *icon = (UIImageView *)[menuIcons objectAtIndex:index];
    [icon setHidden:NO];
}

- (NSManagedObjectContext *)managedObjectContext {
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
                    
                    NSArray *options = @[[NSString stringWithFormat:@"%@ 1", @"SC05_013".localizedString], [NSString stringWithFormat:@"%@ 2", @"SC05_013".localizedString], [NSString stringWithFormat:@"%@ 3", @"SC05_013".localizedString]];
                    for (NSString *tittle in options) {
                        ProductOption *option = [[ProductOption alloc] init];
                        option.tittle = tittle;
                        
                        option.options = [NSMutableArray new];
                        
                        ProductOptionValue *optionValue = [[ProductOptionValue alloc] init];
                        optionValue.isCheck = NO;
                        optionValue.tittle = [NSString stringWithFormat:@"%@ A", @"SC05_013".localizedString];
                        [option.options addObject:optionValue];
                        
                        ProductOptionValue *optionValue2 = [[ProductOptionValue alloc] init];
                        optionValue2.isCheck = NO;
                        optionValue2.tittle = [NSString stringWithFormat:@"%@ B", @"SC05_013".localizedString];
                        [option.options addObject:optionValue2];
                        
                        ProductOptionValue *optionValue3 = [[ProductOptionValue alloc] init];
                        optionValue3.isCheck = NO;
                        optionValue3.tittle = [NSString stringWithFormat:@"%@ C", @"SC05_013".localizedString];
                        [option.options addObject:optionValue3];
                        
                        [product.options addObject:option];
                    }
                    
                    [cateModel.products addObject:product];
                }
            }
        }
        
        [categories addObject:cateModel];
        
        if (i == categoriesArr.count) {
            [self setupCategoryView];
        }
    }
}

//MARK: EnterPassAccessDelegate

- (void)didEnterPassSuccess {
    enterPassSettingVC = nil;
//    SettingsController *vc = [[SettingsController alloc] initWithNibName:@"SettingsController" bundle:nil];
//    [self presentViewController:vc animated:YES completion:nil];
    SplashController *rootVC = [[SplashController alloc] initWithNibName:@"SplashController" bundle:nil];
    UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:rootVC];
    [navc setNavigationBarHidden:YES];
    appDelegate.window.rootViewController = navc;
}

@end

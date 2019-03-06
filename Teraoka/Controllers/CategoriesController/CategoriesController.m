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
#import "DeliousSelfOrderController.h"
#import "EnterLicenseController.h"

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
@property (weak, nonatomic) IBOutlet UIView *billMenuView;
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
    
    [self checkLicenseKey];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showOutOfStock:) name:KEY_NOTIFY_OUT_OF_STOCK object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doWhenEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}
    
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
//    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)orderCart:(id)sender {
    //    OrderSummaryController *vc = [[OrderSummaryController alloc] initWithNibName:@"OrderSummaryController" bundle:nil];
    //    [self.navigationController pushViewController:vc animated:YES];
    [self showOrderCart];
}

- (IBAction)callWaiter:(id)sender {
    [self selectedMenuAt:Waiter];
    
    WaiterController *vc = [[WaiterController alloc] initWithNibName:@"WaiterController" bundle:nil];
    vc.delegate = self;
    
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
    vc.delegate = self;
    [self addChildViewController:vc];
    [self.view addSubview:vc.view];
    [vc didMoveToParentViewController:self];
    
    [vc.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.equalTo(vc.view.superview);
        make.width.height.equalTo(vc.view.superview);
    }];
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
    
    [self selectedMenuAt:Home];
    
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

    SettingModel *setting = [ShareManager shared].setting;
    
    [self.waiterMenuView setHidden:(setting.abilityRequestForAssistance) ? NO : YES];
    for (NSLayoutConstraint *constraint in self.waiterMenuView.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeHeight) {
            constraint.constant = (setting.abilityRequestForAssistance) ? 110 : 0;
            break;
        }
    }
    
    [self.billMenuView setHidden:(setting.selectMode == Quick_Serve) ? YES : NO];
    for (NSLayoutConstraint *constraint in self.billMenuView.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeHeight) {
            constraint.constant = (setting.selectMode == Quick_Serve) ? 0 : 110;
            break;
        }
    }
    
    [self.settingBtn addTarget:self action:@selector(gotoSettingAction:) forControlEvents:UIControlEventTouchUpInside];
}
    
- (void)showOutOfStock:(NSNotification *)notification {
    [self showOutOfStockScreen];
}

- (void)doWhenEnterForeground:(NSNotification *)notification {
    [self checkLicenseKey];
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
    EnterPassAccessSettingController *enterPassSettingVC = [[EnterPassAccessSettingController alloc] initWithNibName:@"EnterPassAccessSettingController" bundle:nil];
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
            NSData *imageData = [NSData dataWithContentsOfFile:product.image];
            if (imageData) {
                cell.productImage.image = [UIImage imageWithData:imageData];
            } else {
                cell.productImage.image = [UIImage imageNamed:@"no_product_image"];
            }
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
            ProductModel *product = cate.products[indexPath.row];
            product.options = (NSMutableArray *)[[[product getOptionGroupList] arrayByAddingObjectsFromArray:[product getSelectionGroupList]] mutableCopy];
            newOrderVC.product = product;
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
    [self selectedMenuAt:Home];
    
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
- (void)setData {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setDataFromBackground];
    });
}

- (void)setDataFromBackground {
    if (!isBackDelegate) categoryIndex = 0;
    
    categories = [NSMutableArray new];
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:MENU_CATEGORY_TABLE_NAME];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"display_order" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    NSArray *categoriesArr = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    fetchRequest = [[NSFetchRequest alloc] initWithEntityName:TAX_TABLE_NAME];
    NSArray *taxArr = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    int i = 0;
    for (NSManagedObject *category in categoriesArr) {
        CategoryModel *cateModel = [[CategoryModel alloc] init];
        cateModel.category_no = [category valueForKey:@"category_no"];
        cateModel.category_name = [category valueForKey:@"category_name"];
        if (i == categoryIndex) cateModel.isSelected = YES;
        else cateModel.isSelected = NO;
        i++;
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:MENU_CONTENTS_TABLE_NAME];
        NSArray *contents = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
        
        NSMutableArray *productIds = [NSMutableArray new];
        for (NSManagedObject *content in contents) {
            NSString *categoryIdStr = [content valueForKey:@"category_no"];
            if ([categoryIdStr isEqualToString:cateModel.category_no]) {
                [productIds addObject:[content valueForKey:@"plu_no"]];
            }
        }
        
        cateModel.products = [NSMutableArray new];
        
        for (NSString *productId in productIds) {
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:PLU_TABLE_NAME];
            NSArray *products = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
            
            for (NSManagedObject *productObj in products) {
                NSString *productIdStr = [productObj valueForKey:@"plu_no"];
                if ([productIdStr isEqualToString:productId]) {
                    ProductModel *product = [Util getPlu:productObj tax:taxArr];
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

- (void)checkLicenseKey {
    if (![Util checkLicenseKeyValid]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"License has expired" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            EnterLicenseController *enterLicenseVC = [[EnterLicenseController alloc] initWithNibName:@"EnterLicenseController" bundle:nil];
            appDelegate.window.rootViewController = enterLicenseVC;
        }];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

//MARK: EnterPassAccessDelegate

- (void)didEnterPassSuccess {
    DeliousSelfOrderController *rootVC = [[DeliousSelfOrderController alloc] initWithNibName:@"DeliousSelfOrderController" bundle:nil];
    UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:rootVC];
    [navc setNavigationBarHidden:YES];
    appDelegate.window.rootViewController = navc;
}

@end

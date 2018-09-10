//
//  ViewExistingOrderController.m
//  Teraoka
//
//  Created by Thuan on 10/18/17.
//  Copyright © 2017 ss. All rights reserved.
//

#import "ViewExistingOrderController.h"
#import "ExistingOrderCell.h"
#import "ShareManager.h"
#import "BillCompleteController.h"
#import "CategoriesController.h"
#import "NSString+KeyLanguage.h"

@interface ViewExistingOrderController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (weak, nonatomic) IBOutlet UILabel *lbTotalBillTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbTotalBill;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIButton *callForBillBtn;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UIButton *callBtn;
@property (weak, nonatomic) IBOutlet UILabel *lbHeaderItem;
@property (weak, nonatomic) IBOutlet UILabel *lbHeaderOption;
@property (weak, nonatomic) IBOutlet UILabel *lbHeaderQty;
@property (weak, nonatomic) IBOutlet UILabel *lbHeaderPrice;

@end

@implementation ViewExistingOrderController {
    NSMutableArray *products;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    products = [ShareManager shared].existingOrderArr;
    
    [self setupView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view removeFromSuperview];
}

- (void)loadLocalizable {
    [super loadLocalizable];
    
    self.lbTotalBillTitle.text = @"SC10_029".localizedString;
    [self.backBtn setTitle:@"SC10_036".localizedString forState:UIControlStateNormal];
    [self.callBtn setTitle:@"SC10_037".localizedString forState:UIControlStateNormal];
    
    self.lbHeaderItem.text = @"SC10_030".localizedString;
    self.lbHeaderOption.text = @"SC10_031".localizedString;
    self.lbHeaderQty.text = @"SC10_032".localizedString;
    self.lbHeaderPrice.text = @"SC10_033".localizedString;
}

- (IBAction)backAction:(id)sender {
    [self.view removeFromSuperview];
}

- (IBAction)callForBillAction:(id)sender {
    if (products.count == 0) return;
    BillCompleteController *vc = [[BillCompleteController alloc] initWithNibName:@"BillCompleteController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)setupView {
    self.headerView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.headerView.layer.shadowOffset = CGSizeMake(0.5f, 0.4f);
    self.headerView.layer.shadowOpacity = 0.5;
    self.headerView.layer.shadowRadius = 3.0;
    self.headerView.layer.masksToBounds = NO;
    
    self.containerView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.containerView.layer.shadowOffset = CGSizeMake(8.0f, 8.0f);
    self.containerView.layer.shadowOpacity = 0.2;
    self.containerView.layer.shadowRadius = 3.0;
    self.containerView.layer.masksToBounds = NO;
    
    self.tblView.delegate = self;
    self.tblView.dataSource = self;
    [self.tblView registerNib:[UINib nibWithNibName:@"ExistingOrderCell" bundle:nil] forCellReuseIdentifier:@"ExistingOrderCellID"];
    
    float total = 0;
    for (ProductModel *product in products) {
        total += [product.qty intValue] * [product.priceNumber floatValue];
    }
    self.lbTotalBill.text = [NSString stringWithFormat:@"$%.2f", total];
    
    if (![ShareManager shared].setting.abilityRequestForBill) {
        [self.callForBillBtn setHidden:YES];
    }
}

- (void)onBack:(id)sender {
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[CategoriesController class]]) {
            [self.navigationController popToViewController:vc animated:YES];
            return;
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return products.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ExistingOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ExistingOrderCellID" forIndexPath:indexPath];
    ProductModel *product = products[indexPath.row];
    [cell setDataForCell:product];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 150;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

@end

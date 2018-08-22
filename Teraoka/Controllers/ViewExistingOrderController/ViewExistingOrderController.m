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

@interface ViewExistingOrderController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (weak, nonatomic) IBOutlet UILabel *lbTotalBill;

@end

@implementation ViewExistingOrderController {
    NSMutableArray *products;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    products = [ShareManager shared].existingOrderArr;
    
    float total = 0;
    for (ProductModel *product in products) {
        total += [product.qty intValue] * [product.priceNumber floatValue];
    }
    self.lbTotalBill.text = [NSString stringWithFormat:@"$%.2f", total];
    
    [self setupView];
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
    
    self.tblView.delegate = self;
    self.tblView.dataSource = self;
    [self.tblView registerNib:[UINib nibWithNibName:@"ExistingOrderCell" bundle:nil] forCellReuseIdentifier:@"ExistingOrderCellID"];
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

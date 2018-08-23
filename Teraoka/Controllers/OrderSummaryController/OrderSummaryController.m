//
//  OrderSummaryController.m
//  Teraoka
//
//  Created by Thuan on 10/18/17.
//  Copyright © 2017 ss. All rights reserved.
//

#import "OrderSummaryController.h"
#import "OrderSummaryCell.h"
#import "OrderConfirmController.h"
#import "ProductOption.h"
#import "ShareManager.h"
#import "CategoriesController.h"
#import "OrderConfirmController.h"
#import "ProductModel.h"
#import "ProductOptionValue.h"
#import "ProductOption.h"

@interface OrderSummaryController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIButton *btnSend;

@end

@implementation OrderSummaryController {
    NSMutableArray *products;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    products = [ShareManager shared].cartArr;
    
    [self setupView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view removeFromSuperview];
}

- (void)setupView {
    self.tblView.delegate = self;
    self.tblView.dataSource = self;
    [self.tblView registerNib:[UINib nibWithNibName:@"OrderSummaryCell" bundle:nil] forCellReuseIdentifier:@"OrderSummaryCellID"];
    
    self.containerView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.containerView.layer.shadowOffset = CGSizeMake(8.0f, 8.0f);
    self.containerView.layer.shadowOpacity = 0.5;
    self.containerView.layer.shadowRadius = 3.0;
    self.containerView.layer.masksToBounds = NO;
}

- (IBAction)backAction:(id)sender {
//    for (UIViewController *vc in self.navigationController.viewControllers) {
//        if ([vc isKindOfClass:[CategoriesController class]]) {
//            [self.navigationController popToViewController:vc animated:YES];
//            break;
//        }
//    }
    for (ProductModel *product in products) {
        if ([product.qty intValue] == 0) [products removeObject:product];
    }
    [self.delegate backDelegate];
    [self.view removeFromSuperview];
}

- (IBAction)sendOrder:(id)sender {
    if (products.count == 0) return;
    for (ProductModel *product in products) {
        if ([product.qty intValue] == 0) [products removeObject:product];
    }
    
    [ShareManager shared].cartArr = products;
    
//    [self sendTransaction];
    [self.delegate showOutOfStockScreen];
    [self.view removeFromSuperview];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return products.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OrderSummaryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OrderSummaryCellID" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setDataForCell:(int)indexPath.row product:products[indexPath.row]];
    cell.removeItem = ^(int row) {
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:nil
                                     message:@"Are you sure remove item?"
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"OKAY"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        [products removeObjectAtIndex:row];
                                        [self.tblView reloadData];
                                    }];
        
        UIAlertAction* noButton = [UIAlertAction
                                   actionWithTitle:@"NO"
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction * action) {
                                       //Handle no, thanks button
                                       ProductModel *model = products[row];
                                       model.qty = @"1";
                                       [self.tblView reloadData];
                                   }];
        
        [alert addAction:yesButton];
        [alert addAction:noButton];
        [self presentViewController:alert animated:YES completion:nil];
    };
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 150;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (products.count == 0) return [[UIView alloc] init];
    UIView *header = [[[NSBundle mainBundle] loadNibNamed:@"OrderSummaryHeader" owner:self options:nil] objectAtIndex:0];
    header.layer.shadowColor = [[UIColor blackColor] CGColor];
    header.layer.shadowOffset = CGSizeMake(0.5f, 0.4f);
    header.layer.shadowOpacity = 0.5;
    header.layer.shadowRadius = 3.0;
    header.layer.masksToBounds = NO;
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 60;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
//    UIView *footer = [[[NSBundle mainBundle] loadNibNamed:@"OrderSummaryFooter" owner:self options:nil] objectAtIndex:0];
//    
//    UIButton *btn = [footer viewWithTag:1];
//    [btn addTarget:self action:@selector(sendOrder) forControlEvents:UIControlEventTouchUpInside];
//    
//    btn = [footer viewWithTag:2];
//    [btn addTarget:self action:@selector(orderMore) forControlEvents:UIControlEventTouchUpInside];
//    
//    return footer;
    return [[UIView alloc] init];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

@end

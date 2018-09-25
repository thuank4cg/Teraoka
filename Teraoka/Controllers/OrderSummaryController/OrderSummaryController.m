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
#import "APPConstants.h"
#import "NSString+KeyLanguage.h"
#import "Util.h"

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

- (void)loadLocalizable {
    [super loadLocalizable];
    
    [self.btnBack setTitle:@"SC07_019".localizedString forState:UIControlStateNormal];
    [self.btnSend setTitle:@"SC07_020".localizedString forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showOutOfStock:) name:KEY_NOTIFY_OUT_OF_STOCK object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    SettingModel *setting = [ShareManager shared].setting;
    if (setting && setting.selectMode == Dine_in && setting.tableSelection == Fix_ed && setting.tableNo == 0) {
        [Util showAlert:@"Please enter table no in settings" vc:self];
        return;
    }
    
    if (products.count == 0) return;
    for (ProductModel *product in products) {
        if ([product.qty intValue] == 0) [products removeObject:product];
    }
    
    [ShareManager shared].cartArr = products;
    
    if ([ShareManager shared].setting.selectMode == Quick_Serve) {
        [self sendPOSRequest:GetInventory];
    } else {
        [self sendPOSRequest:SendOrder];
    }
}

//MARK: Custom method

- (void)showOutOfStock:(NSNotification *)notification {
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
    
    UILabel *lbl = (UILabel *)[header viewWithTag:1];
    lbl.text = @"SC07_014".localizedString;
    
    lbl = (UILabel *)[header viewWithTag:2];
    lbl.text = @"SC07_015".localizedString;
    
    lbl = (UILabel *)[header viewWithTag:3];
    lbl.text = @"SC07_016".localizedString;
    
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

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
#import "APPConstants.h"
#import "Util.h"
#import "OptionGroupModel.h"
#import "OptionModel.h"

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
//    products = [ShareManager shared].existingOrderArr;
    
    [self setupView];
    
    [self sendPOSRequest:GetBillHeader];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view removeFromSuperview];
}

- (void)handleDataGetBillHeader:(NSData *)data {
    int location = REPLY_HEADER + REPLY_COMMAND_SIZE + REPLY_COMMAND_ID + REPLY_REQUEST_ID + REPLY_STORE_STATUS + REPLY_LAST_EVENT_ID;
    
    NSData *replyStatus = [data subdataWithRange:NSMakeRange(location, 4)];
    NSString *httpResponse = [Util hexadecimalString:replyStatus];
    if ([httpResponse isEqualToString:STATUS_REPLY_OK]) {
        location = location + REPLY_STATUS + REPLY_DATA_SIZE;
        
        location += 12;//XBillIdData
        location += 4;//Bill Status
        location += 4;//Table No
        location += 4;//Seated Date
        location += 4;//Seated Time
        location += 8;//FirstOrderedTime&Date
        location += 4;//Last Ordered Date
        location += 4;//Last Ordered Time
        location += 2;//Total Item
        location += 2;//Total Qty
        
        NSData *headerData = [data subdataWithRange:NSMakeRange(location, data.length - location)];
        NSData *totalData = [headerData subdataWithRange:NSMakeRange(0, 4)];
        int total = [Util hexStringToInt:[Util hexadecimalString:totalData]];
        
        location += 4;//Total Amount
        
        float fTotal = (float)total/100;
        self.lbTotalBill.text = [NSString stringWithFormat:@"$%.2f", floor(fTotal*20)/20];
        [self sendPOSRequest:GetBillDetails];
    } else {
        NSData *errorData = [replyStatus subdataWithRange:NSMakeRange(0, 2)];
        NSString *errorID = [Util hexadecimalString:errorData];
        [Util showError:errorID vc:self];
    }
}

- (void)handleDataGetBillDetails:(NSData *)data {
    int location = REPLY_HEADER + REPLY_COMMAND_SIZE + REPLY_COMMAND_ID + REPLY_REQUEST_ID + REPLY_STORE_STATUS + REPLY_LAST_EVENT_ID;
    
    NSData *replyStatus = [data subdataWithRange:NSMakeRange(location, 4)];
    NSString *httpResponse = [Util hexadecimalString:replyStatus];
    if ([httpResponse isEqualToString:STATUS_REPLY_OK]) {
        location = location + REPLY_STATUS + REPLY_DATA_SIZE;
        location += 12;//XBillIdData
        location += 2;//Terminal No
        location += 4;//Staff ID
        
        /**XBillDetailsData**/
        
        //Number of object
        NSData *billDetailsData = [data subdataWithRange:NSMakeRange(location, data.length - location)];
        NSData *numberOfObjectData = [billDetailsData subdataWithRange:NSMakeRange(0, 4)];
        int numberOfObject = [Util hexStringToInt:[Util hexadecimalString:numberOfObjectData]];
        location += 4;
        
        /**XBillDetailsDataStruct[n]**/
        for (int i = 0;i<numberOfObject;i++) {
            NSData *billItemDetailData = [data subdataWithRange:NSMakeRange(location, data.length - location)];
            int itemDetailLength = 0;
            itemDetailLength += 4;//Item Id
            itemDetailLength += 4;//Order sequence
            
            NSData *pluNoData = [billItemDetailData subdataWithRange:NSMakeRange(itemDetailLength, 4)];//PLU No
            itemDetailLength += 4;
            
            NSData *qtyData = [billItemDetailData subdataWithRange:NSMakeRange(itemDetailLength, 2)];//Qty
            itemDetailLength += 2;
            
            itemDetailLength += 4;//Unit Price
            itemDetailLength += 4;//Current Price
            itemDetailLength += 4;//Item Flag
            itemDetailLength += 4;//Ordered Date
            itemDetailLength += 4;//Ordered Time
            itemDetailLength += 4;//Prepared Date
            itemDetailLength += 4;//Prepared Time
            itemDetailLength += 4;//Delivered Date
            itemDetailLength += 4;//Delivered Time
            itemDetailLength += 2;//Item preparation status
            
            NSData *servedQtyData = [billItemDetailData subdataWithRange:NSMakeRange(itemDetailLength, 2)];//Served Qty
            itemDetailLength += 2;
            
            int pluNo = [Util hexStringToInt:[Util hexadecimalString:pluNoData]];
            int qty = [Util hexStringToInt:[Util hexadecimalString:qtyData]];
            int servedQty = [Util hexStringToInt:[Util hexadecimalString:servedQtyData]];
            
            for (ProductModel *product in [ShareManager shared].existingOrderArr) {
                if ([product.productNo intValue] == pluNo) {
                    itemDetailLength += [self getProductOptionLength:product];//XItemOptionData
                    location += itemDetailLength;
                    
                    if (qty > servedQty) {
                        product.deliverStatus = Pending;
                    } else {
                        product.deliverStatus = Delivered;
                    }
                    break;
                }
            }
        }
        
        products = [ShareManager shared].existingOrderArr;
        [self.tblView reloadData];
//        [self calculateTotal];
    } else {
        NSData *errorData = [replyStatus subdataWithRange:NSMakeRange(0, 2)];
        NSString *errorID = [Util hexadecimalString:errorData];
        [Util showError:errorID vc:self];
    }
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
    [self.delegate selectedMenuAt:Home];
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
    self.tblView.estimatedRowHeight = 150;
    self.tblView.rowHeight = UITableViewAutomaticDimension;
    
    if (![ShareManager shared].setting.abilityRequestForBill) {
        [self.callForBillBtn setHidden:YES];
    }
}

- (void)calculateTotal {
//    float total = 0;
//    for (ProductModel *product in products) {
//        total += [product getTaxPrice];
//        for (OptionGroupModel *optionGroup in product.options) {
//            for (OptionModel *option in optionGroup.optionList) {
//                if (option.isCheck && option.type == TYPE_CONDIMENT) {
//                    total += option.price;
//                }
//            }
//        }
//    }
//    self.lbTotalBill.text = [NSString stringWithFormat:@"$%.2f", total];
}

//- (void)onBack:(id)sender {
//    for (UIViewController *vc in self.navigationController.viewControllers) {
//        if ([vc isKindOfClass:[CategoriesController class]]) {
//            [self.navigationController popToViewController:vc animated:YES];
//            return;
//        }
//    }
//    [self.navigationController popViewControllerAnimated:YES];
//}

- (int)getProductOptionLength:(ProductModel *)product {
    int optionLength = 0;
    
    /**XItemOptionData**/
    
    /**XCondimentData**/
    
    NSMutableArray *condiments = [NSMutableArray new];
    
    for (OptionGroupModel *optionGroup in product.options) {
        for (OptionModel *option in optionGroup.optionList) {
            if (option.isCheck && option.type == TYPE_CONDIMENT) {
                [condiments addObject:option];
            }
        }
    }
    
    optionLength += 4; //Number of object
    
    /**XCondimentDataStruct[n]**/
    
    optionLength += 4*condiments.count; //Condiment No (PLU No)
    optionLength += 2*condiments.count; //Condiment Qty
    
    /**XCookingInstructionData**/
    
    NSMutableArray *instructions = [NSMutableArray new];
    
    for (OptionGroupModel *optionGroup in product.options) {
        for (OptionModel *option in optionGroup.optionList) {
            if (option.isCheck && option.type == TYPE_COOKING_INSTRUCTION) {
                [instructions addObject:option];
            }
        }
    }
    
    optionLength += 4; //Number of object
    
    /**XCookingInstructionDataStruct[n]**/
    
    optionLength += 2*instructions.count; //Cooking Instruction No
    optionLength += 2*instructions.count; //Cooking Instruction Qty
    
    /**XServingTimeData**/
    
    NSMutableArray *servings = [NSMutableArray new];
    
    for (OptionGroupModel *optionGroup in product.options) {
        for (OptionModel *option in optionGroup.optionList) {
            if (option.isCheck && option.type == TYPE_SERVING_TIME) {
                [servings addObject:option];
            }
        }
    }
    
    optionLength += 4; //Number of object
    
    /**XServingTimeDataStruct[n]**/
    
    optionLength += 2*servings.count; //Serving Time No
    optionLength += 2*servings.count; //Serving Time Qty
    
    /**XFreeInstructionData**/
    
    optionLength += 4;
    
    return optionLength;
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

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return 150;
//}

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

//
//  NewOrderController.m
//  Teraoka
//
//  Created by Thuan on 10/17/17.
//  Copyright © 2017 ss. All rights reserved.
//

#import "NewOrderController.h"
#import "OptionTableCell.h"
#import "CategoryCell.h"
#import "TextfieldCustom.h"
#import "ShareManager.h"
#import "NewOrderAddedController.h"
#import "IncompleteItemController.h"
#import "ProductModel.h"
#import "OrderSummaryController.h"
#import "APPConstants.h"
#import "UIColor+HexString.h"
#import "ParamsHelper.h"
#import "Util.h"
#import "LocalizeHelper.h"
#import "NSString+KeyLanguage.h"
#import "OptionGroupModel.h"
#import "OptionModel.h"
#import "OptionSelectedTableCell.h"
#import "FixedSetOptionTableCell.h"

@interface NewOrderController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (weak, nonatomic) IBOutlet TextfieldCustom *tfQty;
@property (weak, nonatomic) IBOutlet UIImageView *productImage;
@property (weak, nonatomic) IBOutlet UILabel *productPrice;
@property (weak, nonatomic) IBOutlet UILabel *productName;
@property (weak, nonatomic) IBOutlet UIView *increaseBox;
@property (weak, nonatomic) IBOutlet UIView *decreaseBox;
@property (weak, nonatomic) IBOutlet UIView *containerHeaderView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *backBtnTitle;
@property (weak, nonatomic) IBOutlet UILabel *submitBtnTitle;

@end

@implementation NewOrderController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupView];
    
    self.tfQty.text = self.product.qty;
    if (self.product.image.length > 0) self.productImage.image = [UIImage imageNamed:self.product.image];
    self.productName.text = self.product.name;
    self.productPrice.text = self.product.price;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view removeFromSuperview];
}

- (void)loadLocalizable {
    [super loadLocalizable];
    
    self.backBtnTitle.text = @"SC05_011".localizedString;
    self.submitBtnTitle.text = @"SC05_012".localizedString;
}

- (void)setupView {
    self.tblView.delegate = self;
    self.tblView.dataSource = self;
    [self.tblView setSeparatorColor:[UIColor clearColor]];
    [self.tblView registerNib:[UINib nibWithNibName:@"OptionTableCell" bundle:nil] forCellReuseIdentifier:@"OptionTableCellID"];
    [self.tblView registerNib:[UINib nibWithNibName:@"OptionSelectedTableCell" bundle:nil] forCellReuseIdentifier:@"OptionSelectedTableCellID"];
    [self.tblView registerNib:[UINib nibWithNibName:@"FixedSetOptionTableCell" bundle:nil] forCellReuseIdentifier:@"FixedSetOptionTableCellID"];
    
    self.tfQty.layer.borderColor = [UIColor grayColor].CGColor;
    self.tfQty.backgroundColor = [UIColor whiteColor];
    
    self.increaseBox.clipsToBounds = YES;
    self.increaseBox.layer.borderColor = [UIColor grayColor].CGColor;
    self.increaseBox.layer.borderWidth = 1;
    self.increaseBox.layer.cornerRadius = CGRectGetHeight(self.increaseBox.frame)/2;
    
    self.decreaseBox.clipsToBounds = YES;
    self.decreaseBox.layer.borderColor = [UIColor grayColor].CGColor;
    self.decreaseBox.layer.borderWidth = 1;
    self.decreaseBox.layer.cornerRadius = CGRectGetHeight(self.decreaseBox.frame)/2;
    
    // Shadow and Radius
    self.containerHeaderView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.containerHeaderView.layer.shadowOffset = CGSizeMake(0.0f, 4.0f);
    self.containerHeaderView.layer.shadowOpacity = 0.2;
    self.containerHeaderView.layer.shadowRadius = 3.0;
    self.containerHeaderView.layer.masksToBounds = NO;
    
    self.containerView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.containerView.layer.shadowOffset = CGSizeMake(8.0f, 8.0f);
    self.containerView.layer.shadowOpacity = 0.2;
    self.containerView.layer.shadowRadius = 3.0;
    self.containerView.layer.masksToBounds = NO;
    
    CGFloat heightTblView = 420;
    
    int numberOfGroup = 0;
    if (self.product.isFixedSet) {
        OptionGroupModel *group = [self.product.options objectAtIndex:0];
        for (OptionModel *option in group.optionList) {
            option.isCheck = YES;
            numberOfGroup += option.product.options.count;
        }
    } else {
        for (int i = 0;i<self.product.options.count;i++) {
            OptionGroupModel *group = self.product.options[i];
            if (group.optionList.count > 0) numberOfGroup++;
        }
    }
    
    if (numberOfGroup == 0) {
        heightTblView = 100;
    } else if (numberOfGroup < 3) {
        heightTblView = numberOfGroup * 140;
    }
    
    for (NSLayoutConstraint *constraint in self.tblView.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeHeight) {
            constraint.constant = heightTblView;
            break;
        }
    }
}

- (IBAction)qtyDecrease:(id)sender {
    int qty = [self.tfQty.text intValue];
    if (qty == 1) return;
    self.tfQty.text = [NSString stringWithFormat:@"%d", --qty];
    self.product.qty = self.tfQty.text;
}

- (IBAction)qtyIncrease:(id)sender {
    int qty = [self.tfQty.text intValue];
    self.tfQty.text = [NSString stringWithFormat:@"%d", ++qty];
    self.product.qty = self.tfQty.text;
}

- (IBAction)backAction:(id)sender {
//    IncompleteItemController *vc = [[IncompleteItemController alloc] initWithNibName:@"IncompleteItemController" bundle:nil];
//    [self.navigationController pushViewController:vc animated:NO];
    [self.delegate backDelegate];
    [self.view removeFromSuperview];
}

- (IBAction)sendAction:(id)sender {
    BOOL isSelectedOption = NO;
    for (OptionGroupModel *optionGroup in self.product.options) {
        for (OptionModel *option in optionGroup.optionList) {
            if (option.isCheck) {
                isSelectedOption = YES;
                break;
            }
        }
    }
    
    if (!isSelectedOption && self.product.options.count > 0) {
        [Util showAlert:@"Please select at least one option" vc:self];
        return;
    }
    
    if (![ShareManager shared].cartArr) [ShareManager shared].cartArr = [NSMutableArray new];
    
    if ([ShareManager shared].cartArr.count > 0) {
        BOOL isAdd = YES;
        for (ProductModel *product in [ShareManager shared].cartArr) {
            if ([product.productNo isEqualToString:self.product.productNo]) {
                isAdd = NO;
                NSString *optionStr1 = @"";
                for (OptionGroupModel *optionGroup in product.options) {
                    for (OptionModel *option in optionGroup.optionList) {
                        if (option.isCheck) {
                            optionStr1 = [optionStr1 stringByAppendingString:option.name];
                            optionStr1 = [optionStr1 stringByAppendingString:@"\n"];
                            
                            if (option.product) {
                                for (OptionGroupModel *optionGroup in option.product.options) {
                                    for (OptionModel *option in optionGroup.optionList) {
                                        if (option.isCheck) {
                                            optionStr1 = [optionStr1 stringByAppendingString:option.name];
                                            optionStr1 = [optionStr1 stringByAppendingString:@"\n"];
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                NSString *optionStr2 = @"";
                for (OptionGroupModel *optionGroup in self.product.options) {
                    for (OptionModel *option in optionGroup.optionList) {
                        if (option.isCheck) {
                            optionStr2 = [optionStr2 stringByAppendingString:option.name];
                            optionStr2 = [optionStr2 stringByAppendingString:@"\n"];
                            
                            if (option.product) {
                                for (OptionGroupModel *optionGroup in option.product.options) {
                                    for (OptionModel *option in optionGroup.optionList) {
                                        if (option.isCheck) {
                                            optionStr2 = [optionStr2 stringByAppendingString:option.name];
                                            optionStr2 = [optionStr2 stringByAppendingString:@"\n"];
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                if ([optionStr1 isEqualToString:optionStr2]) {
                    int qty = [product.qty intValue];
                    qty += [self.product.qty intValue];
                    product.qty = [NSString stringWithFormat:@"%d", qty];
                }else {
                    [[ShareManager shared].cartArr addObject:self.product];
                }
                break;
            }
        }
        if (isAdd) [[ShareManager shared].cartArr addObject:self.product];
    } else {
        [[ShareManager shared].cartArr addObject:self.product];
    }
    
//    OrderSummaryController *vc = [[OrderSummaryController alloc] initWithNibName:@"OrderSummaryController" bundle:nil];
//    [self.navigationController pushViewController:vc animated:YES];
    [self.delegate backDelegate];
    [self.view removeFromSuperview];
//    [self.delegate showOrderCart];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.product.isFixedSet) {
        OptionGroupModel *group = [self.product.options objectAtIndex:0];
        return group.optionList.count;
    }
    return self.product.options.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.product.isFixedSet) {
        OptionGroupModel *group = [self.product.options objectAtIndex:0];
        OptionModel *option = [group.optionList objectAtIndex:section];
        return option.product.options.count;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.product.isFixedSet) {
        OptionGroupModel *group = [self.product.options objectAtIndex:0];
        OptionModel *option = [group.optionList objectAtIndex:indexPath.section];
        group = [option.product.options objectAtIndex:indexPath.row];
        
        FixedSetOptionTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FixedSetOptionTableCellID" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setDataForCell:group];
        
        __weak typeof(self) wSelf = self;
        cell.fixedSetOptionTableCellCallback = ^{
            [wSelf.tblView reloadData];
        };
        
        return cell;
    }
    
    OptionGroupModel *optionGroup = self.product.options[indexPath.section];
    __weak typeof(self) wSelf = self;
    
    if (optionGroup.isShowChild && optionGroup.type == TYPE_SELECTION) {
        OptionSelectedTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OptionSelectedTableCellID" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setDataForCell:optionGroup];
        
        cell.optionSelectedTableCellCallback = ^{
            [wSelf.tblView reloadData];
        };
        
        return cell;
    }
    
    OptionTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OptionTableCellID" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setDataForCell:optionGroup];
    
    cell.optionTableCellCallback = ^{
        [wSelf.tblView reloadData];
    };

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.product.isFixedSet) return 100;
    
    OptionGroupModel *optionGroup = self.product.options[indexPath.section];
    
    if (optionGroup.optionList.count == 0) return 0;
    for (OptionModel *option in optionGroup.optionList) {
        if (option.isCheck && option.product.options.count == 0) {
            return 70;
        }
    }
    if (optionGroup.isShowChild && optionGroup.type == TYPE_SELECTION) return 150;
    return 70;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tblView.frame), (self.product.isFixedSet) ? 40 : 70)];
    header.backgroundColor = [UIColor whiteColor];
    
    CGFloat originY = (self.product.isFixedSet) ? 2 : 10;
    UILabel *lbTitle = [[UILabel alloc] initWithFrame:CGRectMake((self.product.isFixedSet) ? 10 : 25, originY, CGRectGetWidth(header.frame), CGRectGetHeight(header.frame) - originY)];
    [lbTitle setTextColor:[UIColor colorWithHexString:@"272727"]];
    lbTitle.font = [UIFont fontWithName:KEY_FONT_BOLD size:17];
    [header addSubview:lbTitle];
    
    if (self.product.isFixedSet) {
        OptionGroupModel *group = [self.product.options objectAtIndex:0];
        OptionModel *option = [group.optionList objectAtIndex:section];
        lbTitle.text = option.name;
    } else {
        OptionGroupModel *optionGroup = self.product.options[section];
        lbTitle.text = optionGroup.name;
    }
    
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.product.isFixedSet) return 40;
    
    OptionGroupModel *optionGroup = self.product.options[section];
    if (optionGroup.optionList.count == 0 || optionGroup.name.length == 0) return 0;
    return 70;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (self.product.isFixedSet) return [[UIView alloc] init];
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tblView.frame), 1)];
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(footer.frame), 1)];
    if (section == self.product.options.count - 1) {
        line.backgroundColor = [UIColor clearColor];
    }else line.backgroundColor = [UIColor colorWithHexString:@"f2f2f2"];
    [footer addSubview:line];
    return  footer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

@end

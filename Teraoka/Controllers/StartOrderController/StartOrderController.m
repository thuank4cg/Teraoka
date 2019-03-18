//
//  StartOrderController.m
//  Teraoka
//
//  Created by Thuan on 9/24/18.
//  Copyright © 2018 ss. All rights reserved.
//

#import "StartOrderController.h"
#import "CommonButton.h"
#import "CommonTextfield.h"
#import "NSString+KeyLanguage.h"
#import "APPConstants.h"
#import <ActionSheetPicker.h>
#import "Util.h"
#import "SettingModel.h"
#import "ShareManager.h"
#import "TableSelectionView.h"
#import <View+MASAdditions.h>
#import "SettingsController.h"

@interface StartOrderController () <UITextFieldDelegate, TableSelectionViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet CommonTextfield *tfTableNo;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topSpaceTfTableNo;
//@property (weak, nonatomic) IBOutlet CommonButton *fixedBtn;
//@property (weak, nonatomic) IBOutlet CommonButton *preOrderBtn;
@property (weak, nonatomic) IBOutlet UIButton *submitBtn;

@end

@implementation StartOrderController {
    UIAlertController *alertController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupView];
}

- (void)handleDataSendSeated:(NSData *)data {
    int location = REPLY_HEADER + REPLY_COMMAND_SIZE + REPLY_COMMAND_ID + REPLY_REQUEST_ID + REPLY_STORE_STATUS + REPLY_LAST_EVENT_ID;
    
    NSData *replyStatus = [data subdataWithRange:NSMakeRange(location, 4)];
    NSString *httpResponse = [Util hexadecimalString:replyStatus];
    if ([httpResponse isEqualToString:STATUS_REPLY_OK]) {
        location = location + REPLY_STATUS + REPLY_DATA_SIZE;
        
        /**XBillIdData**/
        NSData *billIdData = [data subdataWithRange:NSMakeRange(location, data.length - location)];
        NSData *billNoData = [billIdData subdataWithRange:NSMakeRange(0, 4)];
        int billNo = [Util hexStringToInt:[Util hexadecimalString:billNoData]];
        NSLog(@"%d", billNo);
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d", billNo] forKey:KEY_SAVED_BILL_NO];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        SettingModel *setting = [ShareManager shared].setting;
        setting.tableNo = [setting getTableNo:self.tfTableNo.text];
        setting.tableName = [setting getTableName:self.tfTableNo.text];
        
        [Util saveSetting:setting];
        [ShareManager shared].setting = [Util getSetting];
        
        [self.delegate showCategoriesScreen];
    } else {
        NSData *errorData = [replyStatus subdataWithRange:NSMakeRange(0, 2)];
        NSString *errorID = [Util hexadecimalString:errorData];
        [Util showError:errorID vc:self];
    }
}

- (IBAction)backAction:(id)sender {
    [self.view removeFromSuperview];
}

- (IBAction)submitAction:(id)sender {
    if ([ShareManager shared].setting.tableSelection == Fix_ed) {
        SettingsController *vc = [[SettingsController alloc] initWithNibName:@"SettingsController" bundle:nil];
        [self.delegate presentViewController:vc animated:YES completion:^{
            [self.view removeFromSuperview];
        }];
        return;
        
    }
    
    if (self.tfTableNo.text.length == 0) {
        [Util showAlert:@"Please select table first." vc:self];
        return;
    }
    
    SettingModel *setting = [ShareManager shared].setting;
    int tableNo = [setting getTableNo:self.tfTableNo.text];
    
    [ShareManager shared].setting.tableNo = tableNo;
    
    [self sendPOSRequest:SendSeated];
}

//- (IBAction)selectModeAction:(id)sender {
//    UIButton *button = (UIButton *)sender;
//    
//    SettingModel *setting = [ShareManager shared].setting;
//    setting.tableSelection = button.tag;
//    
//    NSString *json = [setting toJSONString];
//    [[NSUserDefaults standardUserDefaults] setObject:json forKey:KEY_SAVED_SETTING];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    
//    switch (button.tag) {
//        case Fix_ed:
//            [self.fixedBtn selected];
//            [self.preOrderBtn unselected];
//            break;
//            
//        default:
//            [self.fixedBtn unselected];
//            [self.preOrderBtn selected];
//            break;
//    }
//}

- (void)loadLocalizable {
    [super loadLocalizable];
    
    self.tfTableNo.placeholder = @"SC12_061".localizedString;
    
//    [self.fixedBtn setTitle:@"SC12_059".localizedString forState:UIControlStateNormal];
//    [self.preOrderBtn setTitle:@"SC12_060".localizedString forState:UIControlStateNormal];
}

- (void)setupView {
//    self.fixedBtn.tag = Fix_ed;
//    self.preOrderBtn.tag = Pre_order;
    
//    if ([ShareManager shared].setting.tableSelection == Fix_ed) {
//        [self.fixedBtn selected];
//        [self.preOrderBtn unselected];
//    } else {
//        [self.fixedBtn unselected];
//        [self.preOrderBtn selected];
//    }
    
    if ([ShareManager shared].setting.tableSelection == Pre_order) {
        self.lbTitle.text = @"Please select table";
        [self.submitBtn setTitle:@"START ORDER" forState:UIControlStateNormal];
    } else {
        self.lbTitle.text = @"Please assign table number in SETTINGS before starting order";
        [self.submitBtn setTitle:@"SETTINGS" forState:UIControlStateNormal];
        [self.tfTableNo setHidden:YES];
        self.topSpaceTfTableNo.constant = 0;
        for (NSLayoutConstraint *constraint in self.tfTableNo.constraints) {
            if (constraint.firstAttribute == NSLayoutAttributeHeight) {
                constraint.constant = 0;
                break;
            }
        }
    }
    
    self.tfTableNo.delegate = self;
}

//MARK: UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self showTableNoList];
    return NO;
}

//MARK: Custom method

- (void)showTableNoList {
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:TABLE_NO_TABLE_NAME];
    NSArray *tableArr = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];

    NSMutableArray *items = [NSMutableArray new];

    for (NSManagedObject *table in tableArr) {
        [items addObject:[NSString stringWithFormat:@"%@ - %@", [table valueForKey:@"table_no"], [table valueForKey:@"table_name"]]];
    }
    
    UIViewController *controller = [[UIViewController alloc] init];
    CGRect rect = CGRectMake(0, 0, 270, 250);
    [controller setPreferredContentSize:rect.size];
    
    alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    TableSelectionView *selectionView = [[[NSBundle mainBundle] loadNibNamed:@"TableSelectionView" owner:self options:nil] objectAtIndex:0];
    [selectionView setupData:items];
    selectionView.delegate = self;
    [controller.view addSubview:selectionView];

    [selectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.equalTo(selectionView.superview);
        make.width.height.equalTo(selectionView.superview);
    }];

    [alertController setModalPresentationStyle:UIModalPresentationPopover];
    [alertController setValue:controller forKey:@"contentViewController"];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive
                                                         handler:^(UIAlertAction *action) {}];
    [alertController addAction:cancelAction];

    UIPopoverPresentationController *popPresenter = [alertController popoverPresentationController];
    popPresenter.sourceView = self.tfTableNo;
    popPresenter.sourceRect = self.tfTableNo.bounds;

    [self presentViewController:alertController animated:YES completion:^{}];
}

//MARK: TableSelectionViewDelegate

- (void)didSelectItem:(NSString *)tableNo {
    self.tfTableNo.text = tableNo;
    [alertController dismissViewControllerAnimated:YES completion:nil];
}

@end

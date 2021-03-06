//
//  SettingsController.m
//  Teraoka
//
//  Created by Thuan on 8/20/18.
//  Copyright © 2018 ss. All rights reserved.
//

#import "SettingsController.h"
#import "SwitchCustomView.h"
#import "APPConstants.h"
#import <ActionSheetPicker.h>
#import "CommonTextfield.h"
#import "CommonButton.h"
#import "SettingModel.h"
#import <JSONModel.h>
#import "Util.h"
#import "ShareManager.h"
#import "LocalizeHelper.h"
#import "NSString+KeyLanguage.h"
#import "UIColor+HexString.h"
#import "TableSelectionView.h"
#import <View+MASAdditions.h>

@interface SettingsController () <UITextFieldDelegate, TableSelectionViewDelegate>
@property (weak, nonatomic) IBOutlet CommonTextfield *tfIPAddress;
@property (weak, nonatomic) IBOutlet CommonTextfield *tfNewPassword;
@property (weak, nonatomic) IBOutlet CommonTextfield *tfConfirmPassword;
@property (weak, nonatomic) IBOutlet CommonButton *quickServeBtn;
@property (weak, nonatomic) IBOutlet CommonButton *dineinBtn;
@property (weak, nonatomic) IBOutlet CommonButton *fixedBtn;
@property (weak, nonatomic) IBOutlet CommonButton *preOrderBtn;
@property (weak, nonatomic) IBOutlet CommonTextfield *tfTableNo;
@property (weak, nonatomic) IBOutlet SwitchCustomView *requestForAssistanceView;
@property (weak, nonatomic) IBOutlet SwitchCustomView *requestForBillView;
@property (weak, nonatomic) IBOutlet UIStackView *requestTaleNoContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topPaddingTableNoContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightTableNoContainerView;
@property (weak, nonatomic) IBOutlet UILabel *languageValueLb;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbPleaseEnterIP;
@property (weak, nonatomic) IBOutlet UILabel *lbSelectLanguage;
@property (weak, nonatomic) IBOutlet CommonButton *fetchLanguageBtn;
@property (weak, nonatomic) IBOutlet UILabel *lbSetPassword;
@property (weak, nonatomic) IBOutlet UILabel *lbSelectMode;
@property (weak, nonatomic) IBOutlet UILabel *lbTableSelection;
@property (weak, nonatomic) IBOutlet UILabel *lbRequestForWaiter;
@property (weak, nonatomic) IBOutlet UILabel *lbRequestForBill;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
@property (weak, nonatomic) IBOutlet UILabel *lbTableSelectionNotice;

@end

@implementation SettingsController {
    SELECT_MODE selectModeValue;
    TABLE_SELECTION tableSelectionValue;
    UIAlertController *alertController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupView];
}

- (void)loadLocalizable {
    [super loadLocalizable];
    
    self.lbTitle.text = @"SC12_044".localizedString;
    self.lbPleaseEnterIP.text = @"SC12_045".localizedString;
    self.lbSelectLanguage.text = @"SC12_046".localizedString;
    self.lbSetPassword.text = @"SC12_047".localizedString;
    self.lbSelectMode.text = @"SC12_048".localizedString;
    self.lbTableSelection.text = @"SC12_049".localizedString;
    self.lbRequestForWaiter.text = @"SC12_050".localizedString;
    self.lbRequestForBill.text = @"SC12_051".localizedString;
    
    [self.fetchLanguageBtn setTitle:@"SC12_053".localizedString forState:UIControlStateNormal];
    self.languageValueLb.text = @"SC12_054".localizedString;
    self.tfNewPassword.placeholder = @"SC12_055".localizedString;
    self.tfConfirmPassword.placeholder = @"SC12_056".localizedString;
    [self.quickServeBtn setTitle:@"SC12_057".localizedString forState:UIControlStateNormal];
    [self.dineinBtn setTitle:@"SC12_058".localizedString forState:UIControlStateNormal];
    [self.fixedBtn setTitle:@"SC12_059".localizedString forState:UIControlStateNormal];
    [self.preOrderBtn setTitle:@"SC12_060".localizedString forState:UIControlStateNormal];
    self.tfTableNo.placeholder = @"SC12_061".localizedString;
    [self.requestForAssistanceView.enabledBtn setTitle:@"SC12_062".localizedString forState:UIControlStateNormal];
    [self.requestForAssistanceView.disabledBtn setTitle:@"SC12_063".localizedString forState:UIControlStateNormal];
    [self.requestForBillView.enabledBtn setTitle:@"SC12_064".localizedString forState:UIControlStateNormal];
    [self.requestForBillView.disabledBtn setTitle:@"SC12_065".localizedString forState:UIControlStateNormal];
    
    [self.saveBtn setTitle:@"SC12_052".localizedString forState:UIControlStateNormal];
}

- (IBAction)backAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)selectModeAction:(id)sender {
    UIButton *button = (UIButton *)sender;
    selectModeValue = button.tag;
    
    switch (button.tag) {
        case Quick_Serve:
            [self.quickServeBtn selected];
            [self.dineinBtn unselected];
            
            [self hiddenTableNo:YES];
            
            [self greyOutTableSelectionButton:YES];
            
            [self.requestForAssistanceView setOn:NO];
            [self.requestForBillView setOn:NO];
            [self.requestForAssistanceView disableView:YES];
            [self.requestForBillView disableView:YES];
            
            break;
            
        default:
            [self.quickServeBtn unselected];
            [self.dineinBtn selected];
            
            if (tableSelectionValue == Fix_ed) {
                [self hiddenTableNo:NO];
            } else {
                [self hiddenTableNo:YES];
            }
            
            [self greyOutTableSelectionButton:NO];
            
            [self.requestForAssistanceView disableView:NO];
            [self.requestForBillView disableView:NO];
            
            break;
    }
}

- (IBAction)selectTableSelectionAction:(id)sender {
    UIButton *button = (UIButton *)sender;
    tableSelectionValue = button.tag;
    
    switch (button.tag) {
        case Fix_ed:
            [self.fixedBtn selected];
            [self.preOrderBtn unselected];
            
            [self hiddenTableNo:NO];
            
            break;
            
        default:
            [self.fixedBtn unselected];
            [self.preOrderBtn selected];
            
            [self hiddenTableNo:YES];
            
            break;
    }
}

- (IBAction)selectLanguageAction:(id)sender {
    NSArray *items = KEY_LANGUAGE_ARR;
    
    [ActionSheetStringPicker showPickerWithTitle:@"Select Language"
                                            rows:items
                                initialSelection:0
                                     doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                         [[NSUserDefaults standardUserDefaults] setObject:items[selectedIndex] forKey:KEY_CURRENT_LANGUAGE];
                                         [[NSUserDefaults standardUserDefaults] synchronize];
                                         
                                         [Util setLanguage:items[0]];
                                         
                                         self.languageValueLb.text = items[0];
                                     }
                                     cancelBlock:^(ActionSheetStringPicker *picker) {
                                         
                                     } origin:sender];
}

- (IBAction)saveAction:(id)sender {
    if (self.tfNewPassword.text.length > 0 || self.tfConfirmPassword.text.length) {
        if (![self.tfNewPassword.text isEqualToString:self.tfConfirmPassword.text]) {
            [Util showAlert:@"Password does not match" vc:self];
            return;
        }
    }
    
    if (selectModeValue == Dine_in && tableSelectionValue == Fix_ed) {
//        NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
//        if ([self.tfTableNo.text rangeOfCharacterFromSet:notDigits].location != NSNotFound) {
//            [Util showAlert:@"Table No must be numeric" vc:self];
//            return;
//        }
//
//        if ([self.tfTableNo.text isEqualToString:@"0"]) {
//            [Util showAlert:@"Table No must be greater than 0" vc:self];
//            return;
//        }
        
        if (self.tfTableNo.text.length == 0 || [self.tfTableNo.text isEqualToString:@"0"]) {
            [Util showAlert:@"Please select table" vc:self];
            return;
        }
    }
    
    SettingModel *setting = [[SettingModel alloc] init];
    setting.serverIP = self.tfIPAddress.text;
    setting.password = self.tfNewPassword.text;
    setting.selectMode = selectModeValue;
    setting.tableSelection = tableSelectionValue;
    setting.tableNo = [self.tfTableNo.text intValue];
    setting.abilityRequestForAssistance = self.requestForAssistanceView.isOn;
    setting.abilityRequestForBill = self.requestForBillView.isOn;
    
    NSString *json = [setting toJSONString];
    [[NSUserDefaults standardUserDefaults] setObject:json forKey:KEY_SAVED_SETTING];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [Util showAlert:@"Save changes successfully" vc:self];
    
    [ShareManager shared].setting = setting;
}

- (void)setupView {
    self.lbRequestForWaiter.adjustsFontSizeToFitWidth = YES;
    self.lbRequestForBill.adjustsFontSizeToFitWidth = YES;
    
    self.requestForAssistanceView.enabledBtn.titleLabel.font = [UIFont fontWithName:KEY_FONT_BOLD size:20];
    self.requestForAssistanceView.disabledBtn.titleLabel.font = [UIFont fontWithName:KEY_FONT_BOLD size:20];
    
    self.requestForBillView.enabledBtn.titleLabel.font = [UIFont fontWithName:KEY_FONT_BOLD size:20];
    self.requestForBillView.disabledBtn.titleLabel.font = [UIFont fontWithName:KEY_FONT_BOLD size:20];
    
    self.quickServeBtn.tag = Quick_Serve;
    self.dineinBtn.tag = Dine_in;
    [self.quickServeBtn selected];
    [self.dineinBtn unselected];
    
    self.fixedBtn.tag = Fix_ed;
    self.preOrderBtn.tag = Pre_order;
    [self.fixedBtn selected];
    [self.preOrderBtn unselected];
    
    self.tfTableNo.delegate = self;
    
    [self getCurrentLanguage];
    
    [self setupData];
}

- (void)setupData {
    SettingModel *setting = [ShareManager shared].setting;
    
    self.tfIPAddress.text = setting.serverIP;
    
    selectModeValue = setting.selectMode;
    switch (setting.selectMode) {
        case Quick_Serve:
            [self.quickServeBtn selected];
            [self.dineinBtn unselected];
            
            [self greyOutTableSelectionButton:YES];
            [self hiddenTableNo:YES];
            
            [self.requestForAssistanceView disableView:YES];
            [self.requestForBillView disableView:YES];
            
            break;
            
        default:
            [self.quickServeBtn unselected];
            [self.dineinBtn selected];
            
            [self greyOutTableSelectionButton:NO];
            [self hiddenTableNo:NO];
            break;
    }
    
    tableSelectionValue = setting.tableSelection;
    switch (setting.tableSelection) {
        case Fix_ed:
            [self.fixedBtn selected];
            [self.preOrderBtn unselected];
            
            [self hiddenTableNo:NO];
            
            break;
            
        default:
            [self.fixedBtn unselected];
            [self.preOrderBtn selected];
            
            [self hiddenTableNo:YES];
            
            break;
    }
    
    if (setting.tableNo > 0) self.tfTableNo.text = [NSString stringWithFormat:@"%d", setting.tableNo];
    [self.requestForAssistanceView setOn:setting.abilityRequestForAssistance];
    [self.requestForBillView setOn:setting.abilityRequestForBill];
}

- (void)hiddenTableNo:(BOOL)isHidden {
    if (isHidden) {
        [self.requestTaleNoContainerView setHidden:YES];
        self.heightTableNoContainerView.constant = 0;
        self.topPaddingTableNoContainerView.constant = 0;
    } else {
        [self.requestTaleNoContainerView setHidden:NO];
        self.heightTableNoContainerView.constant = 50;
        self.topPaddingTableNoContainerView.constant = 10;
    }
}

- (void)greyOutTableSelectionButton:(BOOL)isGrey {
    if (isGrey) {
        [self.lbTableSelectionNotice setHidden:NO];
    } else {
        [self.lbTableSelectionNotice setHidden:YES];
    }
}

- (void)getCurrentLanguage {
    NSArray *items = KEY_LANGUAGE_ARR;
    
    NSString *lang = KEY_LANG_EN;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:KEY_CURRENT_LANGUAGE]) {
        lang = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_CURRENT_LANGUAGE];
    }
    
    int index = (int)[items indexOfObject:lang];
    
    self.languageValueLb.text = items[index];
}

- (void)showTableNoList {
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:TABLE_NO_TABLE_NAME];
    NSArray *tableArr = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    NSMutableArray *items = [NSMutableArray new];
    
    for (NSManagedObject *table in tableArr) {
        [items addObject:[table valueForKey:@"table_no"]];
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

//MARK: UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self showTableNoList];
    return NO;
}

@end

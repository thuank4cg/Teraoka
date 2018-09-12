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

@interface SettingsController ()
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

@end

@implementation SettingsController {
    SELECT_MODE selectModeValue;
    TABLE_SELECTION tableSelectionValue;
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
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[SettingsController class]]) {
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)selectModeAction:(id)sender {
    UIButton *button = (UIButton *)sender;
    selectModeValue = button.tag;
    
    switch (button.tag) {
        case Quick_Serve:
            [self.quickServeBtn selected];
            [self.dineinBtn unselected];
            break;
            
        default:
            [self.quickServeBtn unselected];
            [self.dineinBtn selected];
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
            
            [self.requestTaleNoContainerView setHidden:NO];
            self.heightTableNoContainerView.constant = 50;
            self.topPaddingTableNoContainerView.constant = 10;
            
            break;
            
        default:
            [self.fixedBtn unselected];
            [self.preOrderBtn selected];
            
            [self.requestTaleNoContainerView setHidden:YES];
            self.heightTableNoContainerView.constant = 0;
            self.topPaddingTableNoContainerView.constant = 0;
            
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
    
    NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    if ([self.tfTableNo.text rangeOfCharacterFromSet:notDigits].location != NSNotFound) {
        [Util showAlert:@"Table No must be numeric" vc:self];
        return;
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
    
    json = [[NSUserDefaults standardUserDefaults] stringForKey:KEY_SAVED_SETTING];
    setting = [[SettingModel alloc] initWithString:json error:nil];
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
    
    [self getCurrentLanguage];
    
    [self setupData];
}

- (void)setupData {
    NSString *json = [[NSUserDefaults standardUserDefaults] stringForKey:KEY_SAVED_SETTING];
    SettingModel *setting = [[SettingModel alloc] initWithString:json error:nil];
    
    self.tfIPAddress.text = setting.serverIP;
    
    selectModeValue = setting.selectMode;
    switch (setting.selectMode) {
        case Quick_Serve:
            [self.quickServeBtn selected];
            [self.dineinBtn unselected];
            break;
            
        default:
            [self.quickServeBtn unselected];
            [self.dineinBtn selected];
            break;
    }
    
    tableSelectionValue = setting.tableSelection;
    switch (setting.tableSelection) {
        case Fix_ed:
            [self.fixedBtn selected];
            [self.preOrderBtn unselected];
            
            [self.requestTaleNoContainerView setHidden:NO];
            self.heightTableNoContainerView.constant = 50;
            self.topPaddingTableNoContainerView.constant = 10;
            
            break;
            
        default:
            [self.fixedBtn unselected];
            [self.preOrderBtn selected];
            
            [self.requestTaleNoContainerView setHidden:YES];
            self.heightTableNoContainerView.constant = 0;
            self.topPaddingTableNoContainerView.constant = 0;
            
            break;
    }
    
    self.tfTableNo.text = [NSString stringWithFormat:@"%d", setting.tableNo];
    [self.requestForAssistanceView setOn:setting.abilityRequestForAssistance];
    [self.requestForBillView setOn:setting.abilityRequestForBill];
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

@end

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
            break;
            
        default:
            [self.fixedBtn unselected];
            [self.preOrderBtn selected];
            break;
    }
}

- (IBAction)selectLanguageAction:(id)sender {
//    NSArray *colors = [NSArray arrayWithObjects:@"Red", @"Green", @"Blue", @"Orange", nil];
//    
//    [ActionSheetStringPicker showPickerWithTitle:@"Select Language"
//                                            rows:colors
//                                initialSelection:0
//                                     doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
//                                           
//                                     }
//                                     cancelBlock:^(ActionSheetStringPicker *picker) {
//                                         
//                                     } origin:sender];
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
}

- (void)setupView {
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
            break;
            
        default:
            [self.fixedBtn unselected];
            [self.preOrderBtn selected];
            break;
    }
    
    self.tfTableNo.text = [NSString stringWithFormat:@"%d", setting.tableNo];
    [self.requestForAssistanceView setOn:setting.abilityRequestForAssistance];
    [self.requestForBillView setOn:setting.abilityRequestForBill];
}

@end

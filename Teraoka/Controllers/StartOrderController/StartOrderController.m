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

@interface StartOrderController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet CommonTextfield *tfTableNo;
@property (weak, nonatomic) IBOutlet CommonButton *fixedBtn;
@property (weak, nonatomic) IBOutlet CommonButton *preOrderBtn;

@end

@implementation StartOrderController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupView];
}

- (IBAction)submitAction:(id)sender {
    if (self.tfTableNo.text.length == 0 || [self.tfTableNo.text isEqualToString:@"0"]) {
        [Util showAlert:@"Please select table first." vc:self];
        return;
    }
    
    [ShareManager shared].setting.tableNo = (int)self.tfTableNo.text;
    
    [self doGetContents];
}

- (IBAction)selectModeAction:(id)sender {
    UIButton *button = (UIButton *)sender;
    [ShareManager shared].setting.tableSelection = button.tag;
    
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

- (void)loadLocalizable {
    [super loadLocalizable];
    
    self.tfTableNo.placeholder = @"SC12_061".localizedString;
    
    [self.fixedBtn setTitle:@"SC12_059".localizedString forState:UIControlStateNormal];
    [self.preOrderBtn setTitle:@"SC12_060".localizedString forState:UIControlStateNormal];
}

- (void)setupView {
    self.fixedBtn.tag = Fix_ed;
    self.preOrderBtn.tag = Pre_order;
    
    if ([ShareManager shared].setting.tableSelection == Fix_ed) {
        [self.fixedBtn selected];
        [self.preOrderBtn unselected];
    } else {
        [self.fixedBtn unselected];
        [self.preOrderBtn selected];
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
    NSArray *items = @[@"1", @"2", @"3", @"4", @"5"];
    
    [ActionSheetStringPicker showPickerWithTitle:@"Select Table"
                                            rows:items
                                initialSelection:0
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           self.tfTableNo.text = items[selectedIndex];
                                       }
                                     cancelBlock:^(ActionSheetStringPicker *picker) {
                                         
                                     } origin:self.tfTableNo];
}

@end

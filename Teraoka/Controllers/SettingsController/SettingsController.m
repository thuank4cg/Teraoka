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

@interface SettingsController ()
@property (weak, nonatomic) IBOutlet SwitchCustomView *requestForAssistanceView;
@property (weak, nonatomic) IBOutlet SwitchCustomView *requestForBillView;

@end

@implementation SettingsController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupView];
}

- (void)setupView {
    self.requestForAssistanceView.enabledBtn.titleLabel.font = [UIFont fontWithName:KEY_FONT_BOLD size:22];
    self.requestForAssistanceView.disabledBtn.titleLabel.font = [UIFont fontWithName:KEY_FONT_BOLD size:22];
    
    self.requestForBillView.enabledBtn.titleLabel.font = [UIFont fontWithName:KEY_FONT_BOLD size:22];
    self.requestForBillView.disabledBtn.titleLabel.font = [UIFont fontWithName:KEY_FONT_BOLD size:22];
}

@end

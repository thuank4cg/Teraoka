//
//  EnterPassAccessSettingController.m
//  Teraoka
//
//  Created by Thuan on 8/21/18.
//  Copyright © 2018 ss. All rights reserved.
//

#import "EnterPassAccessSettingController.h"
#import "CommonTextfield.h"
#import "Util.h"
#import "ShareManager.h"

@interface EnterPassAccessSettingController ()

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet CommonTextfield *tfValue;

@end

@implementation EnterPassAccessSettingController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.containerView.clipsToBounds = YES;
    self.containerView.layer.cornerRadius = 5;
    
    self.containerView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.containerView.layer.shadowOffset = CGSizeMake(8.0f, 8.0f);
    self.containerView.layer.shadowOpacity = 0.5;
    self.containerView.layer.shadowRadius = 3.0;
    self.containerView.layer.masksToBounds = NO;
}

- (IBAction)submitAction:(id)sender {
    NSString *pass = @"123456";
    if ([ShareManager shared].setting.password.length > 0) {
        pass = [ShareManager shared].setting.password;
    }
    
    if (![self.tfValue.text isEqualToString:pass]) {
        [Util showAlert:@"Password is incorrect" vc:self];
        return;
    }
    [self.view removeFromSuperview];
    if (self.delegate) {
        [self.delegate didEnterPassSuccess];
    }
}

- (IBAction)backAction:(id)sender {
    [self.view removeFromSuperview];
}

@end
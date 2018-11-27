//
//  EnterLicenseController.m
//  Teraoka
//
//  Created by Thuan on 9/24/18.
//  Copyright © 2018 ss. All rights reserved.
//

#import "EnterLicenseController.h"
#import "SplashController.h"
#import "APIManager.h"
#import "Util.h"
#import <ProgressHUD.h>
#import "APPConstants.h"

@interface EnterLicenseController ()

@property (weak, nonatomic) IBOutlet UITextField *tfLicenseKey;

@end

@implementation EnterLicenseController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupView];
}

- (void)setupView {
    self.tfLicenseKey.clipsToBounds = YES;
    self.tfLicenseKey.layer.borderWidth = 1.0;
    self.tfLicenseKey.layer.borderColor = UIColor.lightGrayColor.CGColor;
    self.tfLicenseKey.layer.cornerRadius = 35;
}

- (IBAction)submitAction:(id)sender {
    if (self.tfLicenseKey.text.length == 0) {
//        [Util showAlert:@"Please enter license key." vc:self];
        [self showSplashScreen];
        return;
    }
    
    [ProgressHUD show:nil Interaction:NO];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[NSNumber numberWithInt:1] forKey:@"licensetype"];
    [params setObject:self.tfLicenseKey.text forKey:@"license"];
    [params setObject:[NSNumber numberWithInt:1] forKey:@"appid"];
//    [params setObject:[[[UIDevice currentDevice] identifierForVendor] UUIDString] forKey:@"uid"];
    
    [[APIManager shared] postRequestSuccess:params success:^(id response) {
        [ProgressHUD dismiss];
        
        [[NSUserDefaults standardUserDefaults] setObject:self.tfLicenseKey.text forKey:KEY_LICENSE_VALID];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self showSplashScreen];
    } failure:^(id failure) {
        [Util showAlert:failure vc:self];
        [ProgressHUD dismiss];
    }];
}

- (void)showSplashScreen {
    SplashController *vc = [[SplashController alloc] initWithNibName:@"SplashController" bundle:nil];
    [self presentViewController:vc animated:YES completion:nil];
}

@end

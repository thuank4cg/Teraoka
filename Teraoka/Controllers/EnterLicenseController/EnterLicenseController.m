//
//  EnterLicenseController.m
//  Teraoka
//
//  Created by Thuan on 9/24/18.
//  Copyright © 2018 ss. All rights reserved.
//

#import "EnterLicenseController.h"
#import "DeliousSelfOrderController.h"
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
        [Util showAlert:@"Please enter license key." vc:self];
        return;
    }
    
    [ProgressHUD show:nil Interaction:NO];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[NSNumber numberWithInt:1] forKey:@"licensetype"];
    [params setObject:self.tfLicenseKey.text forKey:@"license"];
    [params setObject:[NSNumber numberWithInt:3] forKey:@"appid"];
//    [params setObject:[[[UIDevice currentDevice] identifierForVendor] UUIDString] forKey:@"uid"];
    
    [[APIManager shared] tokenVerify:params success:^(id response) {
        [ProgressHUD dismiss];
        
        NSData *data = [response dataUsingEncoding:NSUTF8StringEncoding];
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        [[NSUserDefaults standardUserDefaults] setObject:self.tfLicenseKey.text forKey:KEY_LICENSE_VALID];
        if ([json objectForKey:@"expirydate"]) {
            NSString *expiryDate = [json objectForKey:@"expirydate"];
            [[NSUserDefaults standardUserDefaults] setObject:expiryDate forKey:KEY_LICENSE_EXPIRY_DATE];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self deliousSelfOrder];
    } failure:^(id failure) {
        [Util showAlert:failure vc:self];
        [ProgressHUD dismiss];
    }];
}

- (void)deliousSelfOrder {
    DeliousSelfOrderController *vc = [[DeliousSelfOrderController alloc] initWithNibName:@"DeliousSelfOrderController" bundle:nil];
    [self presentViewController:vc animated:YES completion:nil];
}

@end

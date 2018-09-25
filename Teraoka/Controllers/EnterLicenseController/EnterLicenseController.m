//
//  EnterLicenseController.m
//  Teraoka
//
//  Created by Thuan on 9/24/18.
//  Copyright © 2018 ss. All rights reserved.
//

#import "EnterLicenseController.h"
#import "SplashController.h"

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
    SplashController *vc = [[SplashController alloc] initWithNibName:@"SplashController" bundle:nil];
    [self presentViewController:vc animated:YES completion:nil];
}

@end

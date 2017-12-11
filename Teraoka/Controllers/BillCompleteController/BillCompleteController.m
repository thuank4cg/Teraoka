//
//  BillCompleteController.m
//  Teraoka
//
//  Created by Thuan on 10/18/17.
//  Copyright © 2017 ss. All rights reserved.
//

#import "BillCompleteController.h"
#import "HomeController.h"
#import "ShareManager.h"

@interface BillCompleteController ()

@end

@implementation BillCompleteController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [ShareManager shared].existingOrderArr = nil;
}
- (IBAction)backToHome:(id)sender {
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[HomeController class]]) {
            [self.navigationController popToViewController:vc animated:YES];
            break;
        }
    }
}

@end

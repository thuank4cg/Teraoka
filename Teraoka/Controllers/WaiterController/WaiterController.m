//
//  WaiterController.m
//  Teraoka
//
//  Created by Thuan on 9/17/18.
//  Copyright © 2018 ss. All rights reserved.
//

#import "WaiterController.h"
#import "ShareManager.h"

@interface WaiterController ()

@end

@implementation WaiterController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self sendPOSRequest:CallStaff];
}

- (IBAction)okAction:(id)sender {
    [self.delegate selectedMenuAt:Home];
    [self.view removeFromSuperview];
}

@end

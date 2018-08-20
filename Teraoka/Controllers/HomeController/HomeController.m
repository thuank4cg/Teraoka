//
//  HomeController.m
//  Teraoka
//
//  Created by Thuan on 10/17/17.
//  Copyright © 2017 ss. All rights reserved.
//

#import "HomeController.h"
#import "CategoriesController.h"
#import "ViewExistingOrderController.h"

@interface HomeController ()

@end

@implementation HomeController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)newOrderAction:(id)sender {
    CategoriesController *vc = [[CategoriesController alloc] initWithNibName:@"CategoriesController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)viewOrderAction:(id)sender {
    ViewExistingOrderController *vc = [[ViewExistingOrderController alloc] initWithNibName:@"ViewExistingOrderController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

@end

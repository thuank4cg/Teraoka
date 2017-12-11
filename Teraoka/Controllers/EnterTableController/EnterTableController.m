//
//  EnterTableController.m
//  Teraoka
//
//  Created by Thuan on 10/17/17.
//  Copyright © 2017 ss. All rights reserved.
//

#import "EnterTableController.h"
#import "HomeController.h"

@interface EnterTableController ()

@end

@implementation EnterTableController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)proceedAction:(id)sender {
    HomeController *vc = [[HomeController alloc] initWithNibName:@"HomeController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

@end

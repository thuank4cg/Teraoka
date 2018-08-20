//
//  NewOrderAddedController.m
//  Teraoka
//
//  Created by Thuan on 10/18/17.
//  Copyright © 2017 ss. All rights reserved.
//

#import "NewOrderAddedController.h"
#import "OrderSummaryController.h"
#import "CategoriesController.h"

@interface NewOrderAddedController ()

@property (weak, nonatomic) IBOutlet UIImageView *productImage;
@property (weak, nonatomic) IBOutlet UILabel *lbProductName;

@end

@implementation NewOrderAddedController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.productImage.layer.borderWidth = 1;
    self.productImage.layer.borderColor = [UIColor blackColor].CGColor;
    self.productImage.image = [UIImage imageNamed:self.product.image];
    self.lbProductName.text = self.product.name;
}

- (IBAction)viewOrderSummary:(id)sender {
    OrderSummaryController *vc = [[OrderSummaryController alloc] initWithNibName:@"OrderSummaryController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)orderMore:(id)sender {
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[CategoriesController class]]) {
            [self.navigationController popToViewController:vc animated:YES];
            break;
        }
    }
}

@end

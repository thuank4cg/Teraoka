//
//  BillCompleteController.m
//  Teraoka
//
//  Created by Thuan on 10/18/17.
//  Copyright © 2017 ss. All rights reserved.
//

#import "BillCompleteController.h"
#import "CategoriesController.h"
#import "ShareManager.h"

@interface BillCompleteController ()

@property (weak, nonatomic) IBOutlet UIView *containerView;

@end

@implementation BillCompleteController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [ShareManager shared].existingOrderArr = nil;
    
    self.containerView.clipsToBounds = YES;
    self.containerView.layer.cornerRadius = 5;
    
    self.containerView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.containerView.layer.shadowOffset = CGSizeMake(8.0f, 8.0f);
    self.containerView.layer.shadowOpacity = 0.5;
    self.containerView.layer.shadowRadius = 3.0;
    self.containerView.layer.masksToBounds = NO;
}

- (IBAction)backToHome:(id)sender {
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[CategoriesController class]]) {
            [self.navigationController popToViewController:vc animated:YES];
            break;
        }
    }
}

@end

//
//  OrderConfirmController.m
//  Teraoka
//
//  Created by Thuan on 10/18/17.
//  Copyright © 2017 ss. All rights reserved.
//

#import "OrderConfirmController.h"
#import "ViewExistingOrderController.h"
#import "HomeController.h"
#import "ShareManager.h"
#import "CategoriesController.h"
#import "ViewExistingOrderController.h"
#import "NSString+KeyLanguage.h"

@interface OrderConfirmController ()
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UIButton *okBtn;
@property (weak, nonatomic) IBOutlet UIButton *viewBillBtn;

@end

@implementation OrderConfirmController

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

- (void)loadLocalizable {
    [super loadLocalizable];
    
    self.lbTitle.text = @"SC08_021".localizedString;
    [self.okBtn setTitle:@"SC08_022".localizedString.uppercaseString forState:UIControlStateNormal];
    [self.viewBillBtn setTitle:@"SC08_023".localizedString.uppercaseString forState:UIControlStateNormal];
}

- (IBAction)backTohome:(id)sender {
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[CategoriesController class]]) {
            [self.navigationController popToViewController:vc animated:YES];
            break;
        }
    }
}

- (IBAction)viewBill:(id)sender {
//    UIAlertController * alert = [UIAlertController
//                                 alertControllerWithTitle:nil
//                                 message:@"\"View Bill\" function is not applicable for Demo"
//                                 preferredStyle:UIAlertControllerStyleAlert];
//
//    UIAlertAction* yesButton = [UIAlertAction
//                                actionWithTitle:@"Ok"
//                                style:UIAlertActionStyleDefault
//                                handler:^(UIAlertAction * action) {
//                                    //Handle your yes please button action here
//
//                                }];
//
//    [alert addAction:yesButton];
//    [self presentViewController:alert animated:YES completion:nil];
    
    ViewExistingOrderController *vc = [[ViewExistingOrderController alloc] initWithNibName:@"ViewExistingOrderController" bundle:nil];
    vc.view.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    [self addChildViewController:vc];
    [self.view addSubview:vc.view];
    [vc didMoveToParentViewController:self];

}

@end

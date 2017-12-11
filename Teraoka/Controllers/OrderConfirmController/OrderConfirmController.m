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

@interface OrderConfirmController ()
@property (weak, nonatomic) IBOutlet UIView *containerView;

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
- (IBAction)backTohome:(id)sender {
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[CategoriesController class]]) {
            [self.navigationController popToViewController:vc animated:YES];
            break;
        }
    }
}
- (IBAction)viewExistingOrder:(id)sender {
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:nil
                                 message:@"\"View Bill\" function is not applicable for Demo"
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Ok"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    //Handle your yes please button action here
                                    
                                }];
    
    [alert addAction:yesButton];
    [self presentViewController:alert animated:YES completion:nil];

}

@end

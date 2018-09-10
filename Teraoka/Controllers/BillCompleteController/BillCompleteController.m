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
#import "NSString+KeyLanguage.h"

@interface BillCompleteController ()

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle1;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle2;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;

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

- (void)loadLocalizable {
    [super loadLocalizable];
    
    self.lbTitle1.text = @"SC11_038".localizedString;
    self.lbTitle2.text = @"SC11_039".localizedString;
    [self.backBtn setTitle:@"SC11_040".localizedString forState:UIControlStateNormal];
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

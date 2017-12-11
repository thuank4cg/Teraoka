//
//  IncompleteItemController.m
//  Teraoka
//
//  Created by Thuan on 10/18/17.
//  Copyright © 2017 ss. All rights reserved.
//

#import "IncompleteItemController.h"
#import "CategoriesController.h"

@interface IncompleteItemController ()
@property (weak, nonatomic) IBOutlet UILabel *lbNotice;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@end

@implementation IncompleteItemController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.lbNotice.text = @"You have one incomplete item.\nWill you like to complete item first?";
    
    self.containerView.clipsToBounds = YES;
    self.containerView.layer.cornerRadius = 5;
    
    self.containerView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.containerView.layer.shadowOffset = CGSizeMake(8.0f, 8.0f);
    self.containerView.layer.shadowOpacity = 0.5;
    self.containerView.layer.shadowRadius = 3.0;
    self.containerView.layer.masksToBounds = NO;
}
- (IBAction)yesAction:(id)sender {
    [self onBack:nil];
}
- (IBAction)noAction:(id)sender {
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[CategoriesController class]]) {
            [self.navigationController popToViewController:vc animated:YES];
            break;
        }
    }
}

@end

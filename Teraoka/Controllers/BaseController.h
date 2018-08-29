//
//  BaseController.h
//  Teraoka
//
//  Created by Thuan on 10/17/17.
//  Copyright © 2017 ss. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseController : UIViewController

- (IBAction)onBack:(id)sender;
- (void)sendTransaction;
- (void)getExistingOrder;
- (void)loadLocalizable;

@end

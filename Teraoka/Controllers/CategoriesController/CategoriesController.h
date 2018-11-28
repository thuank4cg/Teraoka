//
//  CategoriesController.h
//  Teraoka
//
//  Created by Thuan on 10/17/17.
//  Copyright © 2017 ss. All rights reserved.
//

#import "BaseController.h"

typedef NS_ENUM(NSInteger, MENU_ITEMS) {
    Home = 0,
    Order,
    Waiter,
    Bill
};

@interface CategoriesController : BaseController
- (void)showOrderCart;
- (void)backDelegate;
- (void)showOutOfStockScreen;
- (void)selectedMenuAt:(int)index;
@end

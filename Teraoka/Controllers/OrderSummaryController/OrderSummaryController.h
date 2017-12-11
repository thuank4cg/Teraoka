//
//  OrderSummaryController.h
//  Teraoka
//
//  Created by Thuan on 10/18/17.
//  Copyright © 2017 ss. All rights reserved.
//

#import "BaseController.h"
#import "CategoriesController.h"

@interface OrderSummaryController : BaseController
@property (nonatomic, weak) CategoriesController *delegate;
@end

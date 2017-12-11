//
//  NewOrderController.h
//  Teraoka
//
//  Created by Thuan on 10/17/17.
//  Copyright © 2017 ss. All rights reserved.
//

#import "BaseController.h"
#import "ProductModel.h"
#import "CategoriesController.h"

@interface NewOrderController : BaseController
@property (nonatomic, strong) ProductModel *product;
@property (nonatomic, weak) CategoriesController *delegate;
@end

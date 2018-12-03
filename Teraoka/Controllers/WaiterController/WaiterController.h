//
//  WaiterController.h
//  Teraoka
//
//  Created by Thuan on 9/17/18.
//  Copyright © 2018 ss. All rights reserved.
//

#import "BaseController.h"
#import "CategoriesController.h"

@interface WaiterController : BaseController

@property (nonatomic, weak) CategoriesController *delegate;

@end

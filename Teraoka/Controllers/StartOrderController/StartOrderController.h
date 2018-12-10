//
//  StartOrderController.h
//  Teraoka
//
//  Created by Thuan on 9/24/18.
//  Copyright © 2018 ss. All rights reserved.
//

#import "BaseController.h"
#import "DeliousSelfOrderController.h"

@interface StartOrderController : BaseController
@property (nonatomic, weak) DeliousSelfOrderController *delegate;
@end

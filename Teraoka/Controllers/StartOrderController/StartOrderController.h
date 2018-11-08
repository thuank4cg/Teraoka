//
//  StartOrderController.h
//  Teraoka
//
//  Created by Thuan on 9/24/18.
//  Copyright © 2018 ss. All rights reserved.
//

#import "BaseController.h"
#import "SplashController.h"

@interface StartOrderController : SplashController
@property (nonatomic, weak) SplashController *delegate;
@end

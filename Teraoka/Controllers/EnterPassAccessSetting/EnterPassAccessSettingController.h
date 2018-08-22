//
//  EnterPassAccessSettingController.h
//  Teraoka
//
//  Created by Thuan on 8/21/18.
//  Copyright © 2018 ss. All rights reserved.
//

#import "BaseController.h"

@protocol EnterPassAccessDelegate <NSObject>
- (void)didEnterPassSuccess;
@end

@interface EnterPassAccessSettingController : BaseController
@property (weak, nonatomic) id<EnterPassAccessDelegate> delegate;
@end

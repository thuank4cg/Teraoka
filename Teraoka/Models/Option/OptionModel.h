//
//  OptionModel.h
//  Teraoka
//
//  Created by Thuan on 9/27/18.
//  Copyright © 2018 ss. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OptionModel : NSObject

@property (nonatomic, assign) int type;
@property (nonatomic, assign) int optionId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) int price;
@property (nonatomic, assign) BOOL isCheck;

@end

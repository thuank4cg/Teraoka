//
//  OptionGroupModel.h
//  Teraoka
//
//  Created by Thuan on 9/27/18.
//  Copyright © 2018 ss. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, OPTION_TYPE) {
    TYPE_CONDIMENT = 100,
    TYPE_SERVING_TIME,
    TYPE_COOKING_INSTRUCTION
};

@interface OptionGroupModel : NSObject

@property (nonatomic, assign) int type;
@property (nonatomic, assign) int groupId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSMutableArray *optionList;

@end

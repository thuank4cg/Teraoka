//
//  ShareManager.h
//  Teraoka
//
//  Created by Thuan on 10/20/17.
//  Copyright © 2017 ss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SettingModel.h"
#import "LanguageModel.h"

@interface ShareManager : NSObject
@property (nonatomic, strong) NSMutableArray *cartArr;
@property (nonatomic, strong) NSMutableArray *existingOrderArr;
@property (nonatomic, strong) NSMutableArray *outOfStockArr;
@property (nonatomic, strong) SettingModel *setting;
@property (nonatomic, strong) NSMutableArray *languages;
+ (ShareManager *)shared;
@end

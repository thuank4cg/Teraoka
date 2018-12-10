//
//  SettingLanguageModel.m
//  Teraoka
//
//  Created by Thuan on 12/7/18.
//  Copyright © 2018 ss. All rights reserved.
//

#import "SettingLanguageModel.h"

@implementation SettingLanguageModel

+(JSONKeyMapper*)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"id": @"ids"}];
}

@end

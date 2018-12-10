//
//  SettingModel.m
//  Teraoka
//
//  Created by Thuan on 8/21/18.
//  Copyright © 2018 ss. All rights reserved.
//

#import "SettingModel.h"

@implementation SettingModel

- (int)getTableNo:(NSString *)tableStr {
    NSArray *components = [tableStr componentsSeparatedByString:@"-"];
    if (components.count > 0) {
        NSString *tableNo = [[components objectAtIndex:0] stringByReplacingOccurrencesOfString:@" " withString:@""];
        return [tableNo intValue];
    }
    return 0;
}

- (NSString *)getTableName:(NSString *)tableStr {
    NSArray *components = [tableStr componentsSeparatedByString:@"-"];
    if (components.count > 1) {
        NSString *tableName = [[components objectAtIndex:1] stringByReplacingOccurrencesOfString:@" " withString:@""];
        return tableName;
    }
    return @"";
}

@end

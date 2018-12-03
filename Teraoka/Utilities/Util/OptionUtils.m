//
//  OptionUtils.m
//  Teraoka
//
//  Created by Thuan on 9/28/18.
//  Copyright © 2018 ss. All rights reserved.
//

#import "OptionUtils.h"
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>
#import "APPConstants.h"
#import "OptionModel.h"

@implementation OptionUtils

+ (OptionUtils *)shared {
    static OptionUtils *_shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [[OptionUtils alloc] init];
    });
    return _shared;
}

@end

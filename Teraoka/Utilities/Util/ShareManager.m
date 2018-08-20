//
//  ShareManager.m
//  Teraoka
//
//  Created by Thuan on 10/20/17.
//  Copyright © 2017 ss. All rights reserved.
//

#import "ShareManager.h"

@implementation ShareManager

+ (ShareManager *)shared {
    static ShareManager *_shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [[ShareManager alloc] init];
    });
    return _shared;
}

- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}

@end

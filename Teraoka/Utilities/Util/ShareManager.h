//
//  ShareManager.h
//  Teraoka
//
//  Created by Thuan on 10/20/17.
//  Copyright © 2017 ss. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShareManager : NSObject
@property (nonatomic, strong) NSMutableArray *cartArr;
@property (nonatomic, strong) NSMutableArray *existingOrderArr;
+ (ShareManager *)shared;
@end

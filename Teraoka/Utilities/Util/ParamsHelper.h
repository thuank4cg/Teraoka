//
//  ParamsHelper.h
//  Teraoka
//
//  Created by Thuan on 12/14/17.
//  Copyright © 2017 ss. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParamsHelper : NSObject
+ (ParamsHelper *)shared;
- (NSMutableData *)collectData;
@end

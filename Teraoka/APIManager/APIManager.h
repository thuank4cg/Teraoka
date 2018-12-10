//
//  APIManager.h
//  Teraoka
//
//  Created by Thuan on 10/4/18.
//  Copyright © 2018 ss. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APIManager : NSObject

+ (APIManager*)shared;
- (void)tokenVerify:(NSDictionary *)params success:(void(^)(id response))success failure:(void(^)(id failure))failure;
- (void)getLanguageList:(NSDictionary *)params success:(void(^)(id response))success failure:(void(^)(id failure))failure;
- (void)getCSVLanguage:(void (^)(NSString *response))success failure:(void (^)(id failure))failure;

@end

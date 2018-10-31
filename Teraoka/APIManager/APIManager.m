//
//  APIManager.m
//  Teraoka
//
//  Created by Thuan on 10/4/18.
//  Copyright © 2018 ss. All rights reserved.
//

#import "APIManager.h"
#import <AFNetworking.h>
#import "ErrorModel.h"

@implementation APIManager

+ (APIManager *)shared {
    static APIManager *_shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [[APIManager alloc] init];
    });
    return _shared;
}

- (void)postRequestSuccess:(NSDictionary *)params success:(void(^)(id response))success failure:(void(^)(id failure))failure {
    NSString *url = @"http://dmc.teraoka.com.sg:8081/v1/token/verify";
    AFHTTPRequestOperationManager *manager    = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    [manager POST:url parameters:params success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        success(nil);
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        ErrorModel *errModel = [[ErrorModel alloc] initWithString:operation.responseString error:nil];
        failure(errModel.detail);
    }];
}

@end

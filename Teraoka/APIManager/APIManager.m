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
#import "APPConstants.h"
#import "SettingModel.h"
#import "ShareManager.h"
#import "SettingLanguageModel.h"

@implementation APIManager

+ (APIManager *)shared {
    static APIManager *_shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [[APIManager alloc] init];
    });
    return _shared;
}

- (void)tokenVerify:(NSDictionary *)params success:(void(^)(id response))success failure:(void(^)(id failure))failure {
    NSString *url = [NSString stringWithFormat:@"%@v1/token/verify", ROOT_API_URL];
    AFHTTPRequestOperationManager *manager    = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    [manager POST:url parameters:params success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        success(nil);
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        ErrorModel *errModel = [[ErrorModel alloc] initWithString:operation.responseString error:nil];
        failure(errModel.detail);
    }];
}

- (void)getLanguageList:(NSDictionary *)params success:(void(^)(id response))success failure:(void(^)(id failure))failure {
    NSString *url = [NSString stringWithFormat:@"%@v1/lang/index", ROOT_API_URL];
    AFHTTPRequestOperationManager *manager    = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    [manager POST:url parameters:params success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSData *data = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        id response = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSArray *languageList = [response objectForKey:@"languagelist"];
        
        SettingModel *setting = [ShareManager shared].setting;
        setting.languageList = [NSMutableArray new];
        
        for (NSDictionary *dict in languageList) {
            SettingLanguageModel *language = [[SettingLanguageModel alloc] initWithDictionary:dict error:nil];
            [setting.languageList addObject:language];
        }
        [ShareManager shared].setting = setting;
        NSString *json = [setting toJSONString];
        [[NSUserDefaults standardUserDefaults] setObject:json forKey:KEY_SAVED_SETTING];
        [[NSUserDefaults standardUserDefaults] synchronize];
        success(nil);
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        ErrorModel *errModel = [[ErrorModel alloc] initWithString:operation.responseString error:nil];
        failure(errModel.detail);
    }];
}

- (void)getCSVLanguage:(void (^)(NSString *response))success failure:(void (^)(id failure))failure {
    NSString *url = [ShareManager shared].setting.language.url;
    if ([url rangeOfString:@"http"].location == NSNotFound) {
        url = [NSString stringWithFormat:@"https://%@", url];
    }
    AFHTTPRequestOperationManager *manager    = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        success(operation.responseString);
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        failure(nil);
    }];
}

@end

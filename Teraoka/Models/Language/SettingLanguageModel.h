//
//  SettingLanguageModel.h
//  Teraoka
//
//  Created by Thuan on 12/7/18.
//  Copyright © 2018 ss. All rights reserved.
//

#import "JSONModel.h"

@protocol SettingLanguageModel
@end

@interface SettingLanguageModel : JSONModel

@property (nonatomic, strong) NSString *ids;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *url;

@end

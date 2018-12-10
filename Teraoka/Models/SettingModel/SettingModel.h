//
//  SettingModel.h
//  Teraoka
//
//  Created by Thuan on 8/21/18.
//  Copyright © 2018 ss. All rights reserved.
//

#import "JSONModel.h"
#import "SettingLanguageModel.h"

typedef NS_ENUM(NSInteger, SELECT_MODE) {
    Quick_Serve = 0,
    Dine_in
};

typedef NS_ENUM(NSInteger, TABLE_SELECTION) {
    Fix_ed = 0,
    Pre_order
};

@interface SettingModel : JSONModel
@property (nonatomic, strong) NSString<Optional> *serverIP;
@property (nonatomic, assign) int tableNo;
@property (nonatomic, assign) NSString<Optional> *tableName;
@property (nonatomic, strong) NSString<Optional> *password;
@property (nonatomic, assign) SELECT_MODE selectMode;
@property (nonatomic, assign) TABLE_SELECTION tableSelection;
@property (nonatomic, assign) BOOL abilityRequestForAssistance;
@property (nonatomic, assign) BOOL abilityRequestForBill;
@property (nonatomic, strong) NSMutableArray<SettingLanguageModel, Optional> *languageList;
@property (nonatomic, strong) SettingLanguageModel<Optional> *language;

- (int)getTableNo:(NSString *)tableStr;
- (NSString *)getTableName:(NSString *)tableStr;

@end

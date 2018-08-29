//
//  SettingModel.h
//  Teraoka
//
//  Created by Thuan on 8/21/18.
//  Copyright © 2018 ss. All rights reserved.
//

#import "JSONModel.h"

typedef NS_ENUM(NSInteger, SELECT_MODE) {
    Quick_Serve = 1,
    Dine_in
};

typedef NS_ENUM(NSInteger, TABLE_SELECTION) {
    Fix_ed = 1,
    Pre_order
};

@interface SettingModel : JSONModel
@property (nonatomic, strong) NSString<Optional> *serverIP;
@property (nonatomic, assign) int tableNo;
@property (nonatomic, strong) NSArray<Optional> *languages;
@property (nonatomic, strong) NSString<Optional> *language;
@property (nonatomic, strong) NSString<Optional> *password;
@property (nonatomic, assign) SELECT_MODE selectMode;
@property (nonatomic, assign) TABLE_SELECTION tableSelection;
@property (nonatomic, assign) BOOL abilityRequestForAssistance;
@property (nonatomic, assign) BOOL abilityRequestForBill;
@end
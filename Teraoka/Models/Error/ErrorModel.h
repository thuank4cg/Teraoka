//
//  ErrorModel.h
//  Teraoka
//
//  Created by Thuan on 10/11/18.
//  Copyright © 2018 ss. All rights reserved.
//

#import "JSONModel.h"

@interface ErrorModel : JSONModel

@property (nonatomic, assign) int error_code;
@property (nonatomic, strong) NSString *detail;

@end

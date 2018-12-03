//
//  CategoryModel.h
//  Teraoka
//
//  Created by Thuan on 10/20/17.
//  Copyright © 2017 ss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>
#import "ProductModel.h"


@interface CategoryModel : NSObject
@property (nonatomic, strong) NSString *category_no;
@property (nonatomic, strong) NSString *category_name;
@property (nonatomic, strong) NSMutableArray *products;
@property (nonatomic, assign) BOOL isSelected;
@end

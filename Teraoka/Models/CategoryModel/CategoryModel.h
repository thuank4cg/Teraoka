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


@interface CategoryModel : JSONModel
@property (nonatomic, strong) NSString<Optional> *ids;
@property (nonatomic, strong) NSString<Optional> *category_name;
@property (nonatomic, strong) NSMutableArray<Optional> *products;
@property (nonatomic, assign) BOOL isSelected;
@end

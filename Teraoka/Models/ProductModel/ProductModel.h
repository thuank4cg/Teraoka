//
//  ProductModel.h
//  Teraoka
//
//  Created by Thuan on 10/20/17.
//  Copyright © 2017 ss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JSONModel.h>

@protocol ProductModel

@end

@interface ProductModel : JSONModel
@property (nonatomic, strong) NSString<Optional> *ids;
@property (nonatomic, strong) NSString<Optional> *image;
@property (nonatomic, strong) NSString<Optional> *name;
@property (nonatomic, strong) NSString<Optional> *price;
@property (nonatomic, strong) NSString<Optional> *priceNumber;
@property (nonatomic, strong) NSString<Optional> *qty;
@property (nonatomic, strong) NSMutableArray *options;
@end

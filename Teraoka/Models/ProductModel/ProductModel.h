//
//  ProductModel.h
//  Teraoka
//
//  Created by Thuan on 10/20/17.
//  Copyright © 2017 ss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>

@protocol ProductModel

@end

@interface ProductModel : JSONModel

@property (nonatomic, strong) NSString<Optional> *productNo;
@property (nonatomic, strong) NSString<Optional> *image;
@property (nonatomic, strong) NSString<Optional> *name;
@property (nonatomic, strong) NSString<Optional> *price;
@property (nonatomic, strong) NSString<Optional> *priceNumber;
@property (nonatomic, strong) NSString<Optional> *originalPrice;
@property (nonatomic, strong) NSString<Optional> *qty;
@property (nonatomic, strong) NSString<Optional> *qtyAvailable;
@property (nonatomic, strong) NSMutableArray *options;
@property (nonatomic, assign) int optionSource;
@property (nonatomic, assign) int optionSourceNo;
@property (nonatomic, assign) int servingSource;
@property (nonatomic, assign) int servingSourceNo;
@property (nonatomic, assign) int commentSource;
@property (nonatomic, assign) int commentSourceNo;

- (NSMutableArray *)getOptionGroupList;

@end

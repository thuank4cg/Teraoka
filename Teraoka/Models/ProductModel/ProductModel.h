//
//  ProductModel.h
//  Teraoka
//
//  Created by Thuan on 10/20/17.
//  Copyright © 2017 ss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>

typedef NS_ENUM(NSInteger, DELIVER_STATUS) {
    None = 0,
    Pending,
    Delivered
};

@protocol ProductModel

@end

@interface ProductModel : NSObject

@property (nonatomic, strong) NSString *productNo;
@property (nonatomic, strong) NSString *image;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *price;
@property (nonatomic, strong) NSString *priceNumber;
@property (nonatomic, strong) NSString *originalPrice;
@property (nonatomic, strong) NSString *qty;
@property (nonatomic, strong) NSString *qtyAvailable;
@property (nonatomic, strong) NSMutableArray *options;
@property (nonatomic, assign) int optionSource;
@property (nonatomic, assign) int optionSourceNo;
@property (nonatomic, assign) int servingSource;
@property (nonatomic, assign) int servingSourceNo;
@property (nonatomic, assign) int commentSource;
@property (nonatomic, assign) int commentSourceNo;
@property (nonatomic, assign) DELIVER_STATUS deliverStatus;
@property (nonatomic, assign) BOOL isChild;
@property (nonatomic, assign) float rate;
@property (nonatomic, assign) int tax_no;
@property (nonatomic, assign) BOOL isFixedSet;

- (float)getTaxPrice;
- (NSMutableArray *)getOptionGroupList;
- (NSMutableArray *)getSelectionGroupList;
- (NSString *)getImageName:(NSArray *)directoryImageContents;
- (float)getRate:(NSArray *)taxList;

@end

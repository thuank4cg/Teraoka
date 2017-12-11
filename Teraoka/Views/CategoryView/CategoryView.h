//
//  CategoryView.h
//  Teraoka
//
//  Created by Thuan on 11/15/17.
//  Copyright © 2017 ss. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^ChooseCategory)(int index);
@interface CategoryView : UIView
@property (nonatomic, assign) int categoryIndex;
@property (nonatomic, copy) ChooseCategory chooseCategory;
- (void)setupData:(NSMutableArray *)cateArr;
@end

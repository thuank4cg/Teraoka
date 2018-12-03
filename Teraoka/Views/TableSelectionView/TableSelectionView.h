//
//  TableSelectionView.h
//  Teraoka
//
//  Created by Thuan on 11/14/18.
//  Copyright © 2018 ss. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TableSelectionViewDelegate <NSObject>
- (void)didSelectItem:(NSString *)tableNo;
@end

@interface TableSelectionView : UIView

@property (nonatomic, weak) id<TableSelectionViewDelegate> delegate;
- (void)setupData:(NSArray *)items;

@end

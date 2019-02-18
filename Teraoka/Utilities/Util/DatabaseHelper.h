//
//  DatabaseHelper.h
//  Teraoka
//
//  Created by Thuan on 9/28/18.
//  Copyright © 2018 ss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OptionSetModel.h"
#import "OptionGroupHeaderModel.h"
#import "ServingSetModel.h"
#import "ServingGroupHeaderModel.h"
#import "CommentSetModel.h"
#import "CommentGroupHeaderModel.h"
#import "SelectionHeaderModel.h"

@interface DatabaseHelper : NSObject
+ (DatabaseHelper *)shared;
- (OptionSetModel *)getOptionSet:(int)option_set_no;
- (OptionGroupHeaderModel *)getOptionGroupHeader:(int)option_group_no;
- (NSMutableArray *)getAllPluByOptionGroup:(int)option_group_no;
- (ServingSetModel *)getServingSet:(int)serving_set_no;
- (ServingGroupHeaderModel *)getServingGroupHeader:(int)serving_group_no;
- (NSMutableArray *)getAllServingByServingGroup:(int)serving_group_no;
- (CommentSetModel *)getCommentSet:(int)comment_set_no;
- (CommentGroupHeaderModel *)getCommentGroupHeader:(int)comment_group_no;
- (NSMutableArray *)getAllCommentByCommentgGroup:(int)comment_group_no;
- (SelectionHeaderModel *)getSelectionHeader:(int)selection_no;
- (NSMutableArray *)getAllChildPlus:(int)plu_no childs:(NSArray *)childPlus;
- (NSMutableArray *)getChildPluFromMealSet:(int)plu_no;
- (NSMutableArray *)getSelectionNoFromSelectionGroup:(int)child_plu_no;
@end

//
//  ProductModel.m
//  Teraoka
//
//  Created by Thuan on 10/20/17.
//  Copyright © 2017 ss. All rights reserved.
//

#import "ProductModel.h"
#import "OptionSetModel.h"
#import "DatabaseHelper.h"
#import "OptionGroupModel.h"
#import "ServingSetModel.h"
#import "CommentSetModel.h"
#import "APPConstants.h"

@implementation ProductModel

- (NSString *)getImageName:(NSArray *)directoryImageContents {
    NSString *prefixImageName = [NSString stringWithFormat:@"plu%@", self.productNo];
    NSString *fullImageName = @"";
    
    for (NSString *content in directoryImageContents) {
        NSArray *contents = [content componentsSeparatedByString:@"."];
        if (contents.count > 0) {
            NSString *prefix = [contents objectAtIndex:0];
            if ([prefix isEqualToString:prefixImageName]) {
                fullImageName = content;
                break;
            }
        }
    }
    
    return [NSString stringWithFormat:@"%@%@/%@", DOCUMENT_DIRECTORY_ROOT, PLU_IMAGE_DIRECTORY_PATH, fullImageName];
}

- (NSMutableArray *)getSelectionGroupList {
    NSMutableArray *optionGroupList = [NSMutableArray new];
    NSMutableArray *selectionArr = [NSMutableArray new];
    
    NSArray *childPlus = [[DatabaseHelper shared] getChildPluFromMealSet:[self.productNo intValue]];
    if (childPlus.count > 0) {
        
        for (NSString *child_plu_no in childPlus) {
            NSArray *selectionNos = [[DatabaseHelper shared] getSelectionNoFromSelectionGroup:[child_plu_no intValue]];
            
            for (NSString *selectionNo in selectionNos) {
                if (![selectionArr containsObject:selectionNo]) {
                    [selectionArr addObject:selectionNo];
                }
            }
        }
    }
    
    for (NSString *selectionNo in selectionArr) {
        OptionGroupModel *optionGroup = [self getSelectionGroup:[selectionNo intValue]];
        if (optionGroup) [optionGroupList addObject:optionGroup];
    }
    
    return optionGroupList;
}

- (NSMutableArray *)getOptionGroupList {
    NSMutableArray *optionGroupList = [NSMutableArray new];
    
    //CONDIMENTS
    if (self.optionSource > 0) {
        OptionSetModel *optionSet = [[DatabaseHelper shared] getOptionSet:self.optionSourceNo];
        
        if (optionSet.optionGroupNo1 > 0) {
            OptionGroupModel *optionGroup = [self getOptionGroupCondiments:optionSet.optionGroupNo1];
            [optionGroupList addObject:optionGroup];
        }
        
        if (optionSet.optionGroupNo2 > 0) {
            OptionGroupModel *optionGroup = [self getOptionGroupCondiments:optionSet.optionGroupNo2];
            [optionGroupList addObject:optionGroup];
        }
        
        if (optionSet.optionGroupNo3 > 0) {
            OptionGroupModel *optionGroup = [self getOptionGroupCondiments:optionSet.optionGroupNo3];
            [optionGroupList addObject:optionGroup];
        }
        
        if (optionSet.optionGroupNo4 > 0) {
            OptionGroupModel *optionGroup = [self getOptionGroupCondiments:optionSet.optionGroupNo4];
            [optionGroupList addObject:optionGroup];
        }
        
        if (optionSet.optionGroupNo5 > 0) {
            OptionGroupModel *optionGroup = [self getOptionGroupCondiments:optionSet.optionGroupNo5];
            [optionGroupList addObject:optionGroup];
        }
    } else if (self.optionSourceNo > 0) {
        OptionGroupModel *optionGroup = [self getOptionGroupCondiments:self.optionSourceNo];
        [optionGroupList addObject:optionGroup];
    }
    
    //COOKING INSTRUCTION
    if (self.commentSource > 0) {
        CommentSetModel *commentSet = [[DatabaseHelper shared] getCommentSet:self.commentSourceNo];
        
        if (commentSet.commentGroupNo1 > 0) {
            OptionGroupModel *optionGroup = [self getOptionGroupCookingInstruction:commentSet.commentGroupNo1];
            [optionGroupList addObject:optionGroup];
        }
        
        if (commentSet.commentGroupNo2 > 0) {
            OptionGroupModel *optionGroup = [self getOptionGroupCookingInstruction:commentSet.commentGroupNo2];
            [optionGroupList addObject:optionGroup];
        }
        
        if (commentSet.commentGroupNo3 > 0) {
            OptionGroupModel *optionGroup = [self getOptionGroupCookingInstruction:commentSet.commentGroupNo3];
            [optionGroupList addObject:optionGroup];
        }
        
        if (commentSet.commentGroupNo4 > 0) {
            OptionGroupModel *optionGroup = [self getOptionGroupCookingInstruction:commentSet.commentGroupNo4];
            [optionGroupList addObject:optionGroup];
        }
        
        if (commentSet.commentGroupNo5 > 0) {
            OptionGroupModel *optionGroup = [self getOptionGroupCookingInstruction:commentSet.commentGroupNo5];
            [optionGroupList addObject:optionGroup];
        }
    } else if (self.commentSourceNo > 0) {
        OptionGroupModel *optionGroup = [self getOptionGroupCookingInstruction:self.commentSourceNo];
        [optionGroupList addObject:optionGroup];
    }
    
    //SERVING TIME
    if (self.servingSource > 0) {
        ServingSetModel *servingSet = [[DatabaseHelper shared] getServingSet:self.servingSourceNo];
        
        if (servingSet.servingGroupNo1 > 0) {
            OptionGroupModel *optionGroup = [self getOptionGroupServingTiming:servingSet.servingGroupNo1];
            [optionGroupList addObject:optionGroup];
        }
        
        if (servingSet.servingGroupNo2 > 0) {
            OptionGroupModel *optionGroup = [self getOptionGroupServingTiming:servingSet.servingGroupNo2];
            [optionGroupList addObject:optionGroup];
        }
        
        if (servingSet.servingGroupNo3 > 0) {
            OptionGroupModel *optionGroup = [self getOptionGroupServingTiming:servingSet.servingGroupNo3];
            [optionGroupList addObject:optionGroup];
        }
        
        if (servingSet.servingGroupNo4 > 0) {
            OptionGroupModel *optionGroup = [self getOptionGroupServingTiming:servingSet.servingGroupNo4];
            [optionGroupList addObject:optionGroup];
        }
        
        if (servingSet.servingGroupNo5 > 0) {
            OptionGroupModel *optionGroup = [self getOptionGroupServingTiming:servingSet.servingGroupNo5];
            [optionGroupList addObject:optionGroup];
        }
    } else if (self.servingSourceNo > 0) {
        OptionGroupModel *optionGroup = [self getOptionGroupServingTiming:self.servingSourceNo];
        [optionGroupList addObject:optionGroup];
    }
    
    return optionGroupList;
}

- (OptionGroupModel *)getOptionGroupCondiments:(int)option_group_no {
    OptionGroupHeaderModel *optionHeader = [[DatabaseHelper shared] getOptionGroupHeader:option_group_no];
    
    OptionGroupModel *optionGroup = [[OptionGroupModel alloc] init];
    optionGroup.name = optionHeader.optionGroupName;
    optionGroup.groupId = optionHeader.optionGroupNo;
    optionGroup.type = TYPE_CONDIMENT;
    optionGroup.optionList = [[DatabaseHelper shared] getAllPluByOptionGroup:optionHeader.optionGroupNo];
    
    return optionGroup;
}

- (OptionGroupModel *)getOptionGroupServingTiming:(int)serving_group_no {
    ServingGroupHeaderModel *servingHeader = [[DatabaseHelper shared] getServingGroupHeader:serving_group_no];
    
    OptionGroupModel *optionGroup = [[OptionGroupModel alloc] init];
    optionGroup.name = servingHeader.descName;
    optionGroup.groupId = servingHeader.servingGroupNo;
    optionGroup.type = TYPE_SERVING_TIME;
    optionGroup.optionList = [[DatabaseHelper shared] getAllServingByServingGroup:servingHeader.servingGroupNo];
    
    return optionGroup;
}

- (OptionGroupModel *)getOptionGroupCookingInstruction:(int)comment_group_no {
    CommentGroupHeaderModel *commentHeader = [[DatabaseHelper shared] getCommentGroupHeader:comment_group_no];
    
    OptionGroupModel *optionGroup = [[OptionGroupModel alloc] init];
    optionGroup.name = commentHeader.commentGroupName;
    optionGroup.groupId = commentHeader.commentGroupNo;
    optionGroup.type = TYPE_COOKING_INSTRUCTION;
    optionGroup.optionList = [[DatabaseHelper shared] getAllCommentByCommentgGroup:comment_group_no];
    
    return optionGroup;
}

- (OptionGroupModel *)getSelectionGroup:(int)plu_no {
    SelectionHeaderModel *selectionHeader = [[DatabaseHelper shared] getSelectionHeader:plu_no];
    
    if (!selectionHeader.selectionName) return nil;
    
    OptionGroupModel *optionGroup = [[OptionGroupModel alloc] init];
    optionGroup.name = selectionHeader.selectionName;
    optionGroup.groupId = selectionHeader.selectionNo;
    optionGroup.optionList = [[DatabaseHelper shared] getAllChildPlus:plu_no];
    
    return optionGroup;
}

@end

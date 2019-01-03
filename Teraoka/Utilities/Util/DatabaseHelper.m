//
//  DatabaseHelper.m
//  Teraoka
//
//  Created by Thuan on 9/28/18.
//  Copyright © 2018 ss. All rights reserved.
//

#import "DatabaseHelper.h"
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>
#import "APPConstants.h"
#import "OptionModel.h"
#import "OptionGroupModel.h"

@implementation DatabaseHelper

+ (DatabaseHelper *)shared {
    static DatabaseHelper *_shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [[DatabaseHelper alloc] init];
    });
    return _shared;
}

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (OptionSetModel *)getOptionSet:(int)option_set_no {
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:OPTION_SET_TABLE_NAME];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"option_set_no == %d", option_set_no]];
    NSArray *optionArr = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    OptionSetModel *model = [[OptionSetModel alloc] init];
    
    for (NSManagedObject *option in optionArr) {
        model.optionSetNo = [[option valueForKey:@"option_set_no"] intValue];
        model.optionGroupNo1 = [[option valueForKey:@"option_group_no1"] intValue];
        model.optionGroupNo2 = [[option valueForKey:@"option_group_no2"] intValue];
        model.optionGroupNo3 = [[option valueForKey:@"option_group_no3"] intValue];
        model.optionGroupNo4 = [[option valueForKey:@"option_group_no4"] intValue];
        model.optionGroupNo5 = [[option valueForKey:@"option_group_no5"] intValue];
    }

    return model;
}

- (OptionGroupHeaderModel *)getOptionGroupHeader:(int)option_group_no {
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:OPTION_GROUP_HEADER_TABLE_NAME];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"option_group_no == %d", option_group_no]];
    NSArray *optionHeaderArr = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    OptionGroupHeaderModel *model = [[OptionGroupHeaderModel alloc] init];
    
    for (NSManagedObject *option in optionHeaderArr) {
        model.optionGroupNo = [[option valueForKey:@"option_group_no"] intValue];;
        model.optionGroupName = [option valueForKey:@"option_group_name"];
    }
    
    return model;
}

- (NSMutableArray *)getAllPluByOptionGroup:(int)option_group_no {
    NSMutableArray *optionList = [NSMutableArray new];
    
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:OPTION_GROUP_TABLE_NAME];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"option_group_no == %d", option_group_no]];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"sorting_no" ascending:YES];
    [fetchRequest setSortDescriptors:@[sort]];
    NSArray *optionGroupArr = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    NSMutableArray *pluNos = [NSMutableArray new];
    for (NSManagedObject *group in optionGroupArr) {
        [pluNos addObject:[group valueForKey:@"plu_no"]];
    }
    
    if (pluNos.count == 0) {
        return optionList;
    }
    
    fetchRequest = [[NSFetchRequest alloc] initWithEntityName:PLU_TABLE_NAME];
    NSArray *pluArr = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    for (NSString *no in pluNos) {
        for (NSManagedObject *plu in pluArr) {
            NSString *pluNo = [plu valueForKey:@"plu_no"];
            if ([no isEqualToString:pluNo]) {
                OptionModel *option = [[OptionModel alloc] init];
                option.optionId = [pluNo intValue];
                option.name = [plu valueForKey:@"item_name"];
                option.type = TYPE_CONDIMENT;
                option.price = [[plu valueForKey:@"price"] intValue];
                [optionList addObject:option];
                break;
            }
        }
    }
    
    return optionList;
}

- (ServingSetModel *)getServingSet:(int)serving_set_no {
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:SERVING_SET_TABLE_NAME];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"serving_set_no == %d", serving_set_no]];
    NSArray *servingArr = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    ServingSetModel *model = [[ServingSetModel alloc] init];
    
    for (NSManagedObject *serving in servingArr) {
        model.servingSetNo = [[serving valueForKey:@"serving_set_no"] intValue];
        model.servingGroupNo1 = [[serving valueForKey:@"serving_group_no1"] intValue];
        model.servingGroupNo2 = [[serving valueForKey:@"serving_group_no2"] intValue];
        model.servingGroupNo3 = [[serving valueForKey:@"serving_group_no3"] intValue];
        model.servingGroupNo4 = [[serving valueForKey:@"serving_group_no4"] intValue];
        model.servingGroupNo5 = [[serving valueForKey:@"serving_group_no5"] intValue];
    }
    
    return model;
}

- (ServingGroupHeaderModel *)getServingGroupHeader:(int)serving_group_no {
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:SERVING_GROUP_HEADER_TABLE_NAME];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"serving_group_no == %d", serving_group_no]];
    NSArray *servingHeaderArr = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    ServingGroupHeaderModel *model = [[ServingGroupHeaderModel alloc] init];
    
    for (NSManagedObject *serving in servingHeaderArr) {
        model.servingGroupNo = [[serving valueForKey:@"serving_group_no"] intValue];;
        model.descName = [serving valueForKey:@"desc_name"];
    }
    
    return model;
}

- (NSMutableArray *)getAllServingByServingGroup:(int)serving_group_no {
    NSMutableArray *optionList = [NSMutableArray new];
    
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:SERVING_GROUP_TABLE_NAME];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"serving_group_no == %d", serving_group_no]];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"sorting_no" ascending:YES];
    [fetchRequest setSortDescriptors:@[sort]];
    NSArray *servingGroupArr = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    NSMutableArray *servingTimingNos = [NSMutableArray new];
    for (NSManagedObject *group in servingGroupArr) {
        [servingTimingNos addObject:[group valueForKey:@"serving_timing_no"]];
    }
    
    if (servingTimingNos.count == 0) {
        return optionList;
    }
    
    fetchRequest = [[NSFetchRequest alloc] initWithEntityName:SERVING_TIMING_TABLE_NAME];
    NSArray *servingTimingArr = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    for (NSString *no in servingTimingNos) {
        for (NSManagedObject *serving in servingTimingArr) {
            NSString *servingTimingNo = [serving valueForKey:@"serving_timing_no"];
            if ([no isEqualToString:servingTimingNo]) {
                OptionModel *option = [[OptionModel alloc] init];
                option.optionId = [servingTimingNo intValue];
                option.name = [serving valueForKey:@"desc_name"];
                option.type = TYPE_SERVING_TIME;
                [optionList addObject:option];
                break;
            }
        }
    }
    
    return optionList;
}

- (CommentSetModel *)getCommentSet:(int)comment_set_no {
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:COMMENT_SET_TABLE_NAME];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"comment_set_no == %d", comment_set_no]];
    NSArray *commentArr = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    CommentSetModel *model = [[CommentSetModel alloc] init];
    
    for (NSManagedObject *comment in commentArr) {
        model.commentSetNo = [[comment valueForKey:@"comment_set_no"] intValue];
        model.commentGroupNo1 = [[comment valueForKey:@"comment_group_no1"] intValue];
        model.commentGroupNo2 = [[comment valueForKey:@"comment_group_no2"] intValue];
        model.commentGroupNo3 = [[comment valueForKey:@"comment_group_no3"] intValue];
        model.commentGroupNo4 = [[comment valueForKey:@"comment_group_no4"] intValue];
        model.commentGroupNo5 = [[comment valueForKey:@"comment_group_no5"] intValue];
    }
    
    return model;
}

- (CommentGroupHeaderModel *)getCommentGroupHeader:(int)comment_group_no {
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:COMMENT_GROUP_HEADER_TABLE_NAME];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"comment_group_no == %d", comment_group_no]];
    NSArray *commentHeaderArr = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    CommentGroupHeaderModel *model = [[CommentGroupHeaderModel alloc] init];
    
    for (NSManagedObject *comment in commentHeaderArr) {
        model.commentGroupName = [comment valueForKey:@"comment_group_name"];
        model.commentGroupNo = [[comment valueForKey:@"comment_group_no"] intValue];
    }
    
    return model;
}

- (NSMutableArray *)getAllCommentByCommentgGroup:(int)comment_group_no {
    NSMutableArray *optionList = [NSMutableArray new];
    
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:COMMENT_GROUP_TABLE_NAME];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"comment_group_no == %d", comment_group_no]];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"sorting_no" ascending:YES];
    [fetchRequest setSortDescriptors:@[sort]];
    NSArray *commentGroupArr = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    NSMutableArray *commentNos = [NSMutableArray new];
    for (NSManagedObject *group in commentGroupArr) {
        [commentNos addObject:[group valueForKey:@"comment_no"]];
    }
    
    if (commentNos.count == 0) {
        return optionList;
    }
    
    fetchRequest = [[NSFetchRequest alloc] initWithEntityName:COMMENT_TABLE_NAME];
    NSArray *commentArr = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    for (NSString *no in commentNos) {
        for (NSManagedObject *comment in commentArr) {
            NSString *commentNo = [comment valueForKey:@"comment_no"];
            if ([no isEqualToString:commentNo]) {
                OptionModel *option = [[OptionModel alloc] init];
                option.optionId = [commentNo intValue];
                option.name = [comment valueForKey:@"comment_name"];
                option.type = TYPE_COOKING_INSTRUCTION;
                [optionList addObject:option];
                break;
            }
        }
    }
    
    return optionList;
}


@end

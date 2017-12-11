//
//  BaseTableViewCell.m
//  ParentalKit
//
//  Created by Steve on 10/21/15.
//  Copyright © 2015 Bluecube. All rights reserved.
//

#import "UIView+Nib.h"

@implementation UIView (Nib)

+ (NSString *)nibName {
    return NSStringFromClass(self);
}

+ (UINib *)nib {
    return [UINib nibWithNibName:[self nibName] bundle:nil];
}

@end

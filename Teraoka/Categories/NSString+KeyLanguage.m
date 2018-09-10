//
//  NSString+KeyLanguage.m
//  Teraoka
//
//  Created by Thuan on 9/10/18.
//  Copyright © 2018 ss. All rights reserved.
//

#import "NSString+KeyLanguage.h"
#import "ShareManager.h"

@implementation NSString (KeyLanguage)

- (NSString *)localizedString {
    if ([ShareManager shared].languages.count > 0) {
        for (LanguageModel *language in [ShareManager shared].languages) {
            if ([language.key isEqualToString:self]) {
                return language.value;
            }
        }
    }
    return self;
}

@end

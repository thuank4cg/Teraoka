//
//  CommonTextfield.m
//  Teraoka
//
//  Created by Thuan on 8/20/18.
//  Copyright © 2018 ss. All rights reserved.
//

#import "CommonTextfield.h"

@implementation CommonTextfield

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initation];
    }
    return self;
}
- (id)initWithCoder:(NSCoder*)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self initation];
    }
    return self;
}

- (void)initation {
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 50)];
    self.leftView = paddingView;
    self.leftViewMode = UITextFieldViewModeAlways;
}

@end

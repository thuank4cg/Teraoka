//
//  ButtonCustom.m
//  Teraoka
//
//  Created by Thuan on 10/17/17.
//  Copyright © 2017 ss. All rights reserved.
//

#import "ButtonCustom.h"
#import "UIColor+HexString.h"

@implementation ButtonCustom

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
    self.layer.borderColor = [UIColor clearColor].CGColor;
    self.layer.cornerRadius = 10;
    self.self.backgroundColor = [UIColor colorWithHexString:@"60d836"];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

@end

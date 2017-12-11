//
//  TextfieldCustom.m
//  Teraoka
//
//  Created by Thuan on 10/17/17.
//  Copyright © 2017 ss. All rights reserved.
//

#import "TextfieldCustom.h"

@implementation TextfieldCustom

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
    self.layer.borderColor = [UIColor blackColor].CGColor;
    self.layer.borderWidth = 1;
//    self.layer.cornerRadius = 10;
}

@end

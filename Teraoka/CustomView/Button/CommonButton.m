//
//  CommonButton.m
//  Teraoka
//
//  Created by Thuan on 8/20/18.
//  Copyright © 2018 ss. All rights reserved.
//

#import "CommonButton.h"
#import "UIColor+HexString.h"

@implementation CommonButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.clipsToBounds = YES;
    self.layer.cornerRadius = self.frame.size.height/2;
    [self selected];
}

- (void)selected {
    self.backgroundColor = [UIColor colorWithHexString:@"38bea5"];
    self.layer.borderColor = [[UIColor clearColor] CGColor];
    self.layer.borderWidth = 0;
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (void)unselected {
    self.backgroundColor = [UIColor whiteColor];
    self.layer.borderColor = [[UIColor colorWithHexString:@"38bea5"] CGColor];
    self.layer.borderWidth = 1;
    [self setTitleColor:[UIColor colorWithHexString:@"38bea5"] forState:UIControlStateNormal];
}

@end

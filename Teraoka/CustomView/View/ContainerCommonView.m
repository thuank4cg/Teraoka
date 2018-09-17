//
//  ContainerCommonView.m
//  Teraoka
//
//  Created by Thuan on 9/17/18.
//  Copyright © 2018 ss. All rights reserved.
//

#import "ContainerCommonView.h"

@implementation ContainerCommonView

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
    self.layer.cornerRadius = 5;
    
    self.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.layer.shadowOffset = CGSizeMake(8.0f, 8.0f);
    self.layer.shadowOpacity = 0.5;
    self.layer.shadowRadius = 3.0;
    self.layer.masksToBounds = NO;
}

@end

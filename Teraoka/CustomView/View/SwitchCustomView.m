//
//  SwitchCustomView.m
//  Teraoka
//
//  Created by Thuan on 8/20/18.
//  Copyright © 2018 ss. All rights reserved.
//

#import "SwitchCustomView.h"
#import <Masonry.h>
#import "UIColor+HexString.h"

@interface SwitchCustomView()
@property (nonatomic, assign) BOOL isOn;
@end

@implementation SwitchCustomView

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
    self.enabledBtn = [[UIButton alloc] init];
    self.disabledBtn = [[UIButton alloc] init];
    
    [self.enabledBtn setTitle:@"Enabled" forState:UIControlStateNormal];
    [self.disabledBtn setTitle:@"Disabled" forState:UIControlStateNormal];
    
    self.clipsToBounds = YES;
    self.layer.cornerRadius = self.frame.size.height/2;
    self.layer.borderWidth = 1;
    self.layer.borderColor = [[UIColor clearColor] CGColor];
    self.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:self.enabledBtn];
    [self addSubview:self.disabledBtn];
    
    self.enabledBtn.layer.cornerRadius = (self.frame.size.height - 2)/2;
    self.disabledBtn.layer.cornerRadius = (self.frame.size.height - 2)/2;
    
    [self.enabledBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.leading.equalTo(self.enabledBtn.superview);
        make.trailing.equalTo(self.disabledBtn.mas_leading);
        make.width.equalTo(self.disabledBtn.mas_width);
    }];
    
    [self.disabledBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.trailing.equalTo(self.disabledBtn.superview);
        make.leading.equalTo(self.enabledBtn.mas_trailing);
        make.width.equalTo(self.enabledBtn.mas_width);
    }];
    
    [self turnOn];
    
    [self.enabledBtn addTarget:self action:@selector(turnOn) forControlEvents:UIControlEventTouchUpInside];
    [self.disabledBtn addTarget:self action:@selector(turnOff) forControlEvents:UIControlEventTouchUpInside];
}

- (void)turnOn {
    if (self.isOn) return;
    self.isOn = YES;
    self.layer.borderColor = [[UIColor colorWithHexString:@"38bea5"] CGColor];
    self.enabledBtn.backgroundColor = [UIColor colorWithHexString:@"38bea5"];
    [self.enabledBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.disabledBtn.backgroundColor = [UIColor clearColor];
    [self.disabledBtn setTitleColor:[UIColor colorWithHexString:@"b2b2b2"] forState:UIControlStateNormal];
}

- (void)turnOff {
    if (!self.isOn) return;
    self.isOn = NO;
    self.layer.borderColor = [[UIColor colorWithHexString:@"b2b2b2"] CGColor];
    self.enabledBtn.backgroundColor = [UIColor clearColor];
    [self.enabledBtn setTitleColor:[UIColor colorWithHexString:@"b2b2b2"] forState:UIControlStateNormal];
    self.disabledBtn.backgroundColor = [UIColor colorWithHexString:@"b2b2b2"];
    [self.disabledBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

@end

//
//  SwitchCustomView.h
//  Teraoka
//
//  Created by Thuan on 8/20/18.
//  Copyright © 2018 ss. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SwitchCustomView : UIView
@property (nonatomic, strong) UIButton *enabledBtn;
@property (nonatomic, strong) UIButton *disabledBtn;
- (BOOL)isOn;
- (void)setOn:(BOOL)isOn;
@end

//
//  BaseImageView.m
//  KJBannerViewDemo
//
//  Created by 杨科军 on 2021/2/19.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo

#import "BaseImageView.h"

@implementation BaseImageView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 20)];
        [self addSubview:label];
        label.text = @"测试子类控件";
        label.center = self.center;
        label.font = [UIFont boldSystemFontOfSize:20];
        label.textColor = UIColor.redColor;
        label.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

@end

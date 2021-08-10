//
//  UIView+KJWebImage.h
//  KJBannerViewDemo
//
//  Created by 杨科军 on 2021/1/28.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo
//  网图显示扩展

#import <UIKit/UIKit.h>
#import "KJBannerWebImageHandle.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIView (KJWebImage)

/// 显示网络图片（目前支持设置UIImageView，UIButton，UIView三种）
/// @param url 图片链接
/// @param handle 设置参数回调
- (void)kj_setImageWithURL:(NSURL *)url handle:(void(^)(id<KJBannerWebImageHandle>handle))handle;

@end

NS_ASSUME_NONNULL_END

//
//  UIImageView+KJWebImage.h
//  KJBannerViewDemo
//
//  Created by 杨科军 on 2021/1/22.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo

#import <UIKit/UIKit.h>
#import "KJBannerViewType.h"
#import "KJBannerViewDownloader.h"
NS_ASSUME_NONNULL_BEGIN
@interface UIImageView (KJWebImage)
/// 显示网络图片，
- (void)kj_setImageWithURL:(NSURL*)url;
/// 显示网络图片，带占位图
- (void)kj_setImageWithURL:(NSURL*)url placeholder:(UIImage * _Nullable)placeholder;
/// 显示网络图片，返回图片资源
- (void)kj_setImageWithURL:(NSURL*)url placeholder:(UIImage*)placeholder completed:(KJWebImageCompleted)completed;
/// 显示网络图片，带下载进度
- (void)kj_setImageWithURL:(NSURL*)url placeholder:(UIImage*)placeholder completed:(KJWebImageCompleted)completed progress:(KJLoadProgressBlock)progress;

#pragma mark - 非动态图
/// 非动态图显示网络图片，裁剪图片
- (void)kj_setImageWithURL:(NSURL*)url placeholder:(UIImage*)placeholder scale:(BOOL)scale completed:(void(^)(UIImage *scaleImage, UIImage *originalImage))completed;

@end

NS_ASSUME_NONNULL_END

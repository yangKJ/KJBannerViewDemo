//
//  KJBannerWebImageHandle.h
//  KJBannerViewDemo
//
//  Created by 杨科军 on 2021/1/26.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "KJBannerViewType.h"
#import "KJBannerViewDownloader.h"
#import "KJBannerViewLoadManager.h"
#import "KJBannerViewCacheManager.h"
NS_ASSUME_NONNULL_BEGIN
/// 图片下载完成回调
typedef void (^_Nullable KJWebImageCompleted)(KJBannerImageType imageType,
                                              UIImage * _Nullable image,
                                              NSData * _Nullable data,
                                              NSError * _Nullable error);
@protocol KJBannerWebImageHandle <NSObject>
@optional;
#pragma mark - common
/// 占位图
@property(nonatomic,strong)UIImage *bannerPlaceholder;
/// 图片下载完成回调
@property(nonatomic,copy,readwrite)KJWebImageCompleted bannerCompleted;
/// 下载进度回调
@property(nonatomic,copy,readwrite)KJLoadProgressBlock bannerProgress;
/// 是否缓存数据至本地，默认开启
@property(nonatomic,assign)bool cacheDatas;
/// 是否等比裁剪图片，默认关闭
@property(nonatomic,assign)bool cropScale;
/// 是否使用预渲染图像，默认开启（动态图暂不支持预渲染处理）
@property(nonatomic,assign)bool preRendering;
/// 获取原始图回调，裁剪开启才有效果
@property(nonatomic,copy,readwrite)void(^kCropScaleImage)(UIImage * originalImgae, UIImage * scaleImage);

#pragma mark - button
/// 按钮状态
@property(nonatomic,assign)UIControlState bannerButtonState;

#pragma mark - view
/// 图片填充方式
@property(nonatomic,copy)CALayerContentsGravity bannerViewContentsGravity;

@end

NS_ASSUME_NONNULL_END

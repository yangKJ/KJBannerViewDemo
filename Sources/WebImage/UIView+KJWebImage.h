//
//  UIView+KJWebImage.h
//  KJBannerViewDemo
//
//  Created by 杨科军 on 2021/1/28.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo
//  网图显示扩展

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "KJNetworkManager.h"

NS_ASSUME_NONNULL_BEGIN
/// 图片类型
typedef NS_ENUM(NSInteger, KJWebImageType) {
    KJWebImageTypeUnknown = 0, /// 未知
    KJWebImageTypeJpeg    = 1, /// jpg
    KJWebImageTypePng     = 2, /// png
    KJWebImageTypeGIF     = 3, /// gif
    KJWebImageTypeTiff    = 4, /// tiff
    KJWebImageTypeWebp    = 5, /// webp
};
@protocol KJWebImageDelegate;
typedef void(^_Nullable KJWebImageProvider)(id<KJWebImageDelegate> provider);

/// 网图显示扩展
@interface UIView (KJWebImage)

/// 显示网络图片（目前支持设置UIImageView，UIButton，UIView三种）
/// @param url 图片链接
/// @param provider 设置参数回调
- (void)kj_setImageWithURL:(NSURL *)url provider:(KJWebImageProvider)provider;

@end

/// 图片下载完成回调
typedef void (^_Nullable KJWebImageCompleted)(KJWebImageType imageType,
                                              UIImage * _Nullable image,
                                              NSData * _Nullable data,
                                              NSError * _Nullable error);
typedef void(^_Nullable KJWebScaleImageBlock)(UIImage * originalImgae, UIImage * scaleImage);
@protocol KJWebImageDelegate <NSObject>
@optional;

#pragma mark - common

/// 图片下载完成回调
@property (nonatomic, copy, readwrite) KJWebImageCompleted webCompleted;
/// 下载进度回调
@property (nonatomic, copy, readwrite) KJLoadProgressBlock webProgressBlock;
/// 获取原始图回调，裁剪开启才有效果
@property (nonatomic, copy, readwrite) KJWebScaleImageBlock webScaleImageBlock;
/// 占位图
@property (nonatomic, strong) UIImage *webPlaceholder;
/// 是否缓存数据至本地，默认开启
@property (nonatomic, assign) bool webCacheDatas;
/// 是否等比裁剪图片，默认关闭
@property (nonatomic, assign) bool webCropScale;
/// 是否使用预渲染图像，默认开启（动态图暂不支持预渲染处理）
@property (nonatomic, assign) bool webPreRendering;

#pragma mark - button

/// 按钮状态
@property (nonatomic, assign) UIControlState webButtonState;

#pragma mark - view

/// 图片填充方式
@property (nonatomic, copy) CALayerContentsGravity webContentsGravity;

@end


NS_ASSUME_NONNULL_END

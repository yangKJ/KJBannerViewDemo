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
#import "KJBannerViewCacheManager.h"
#import "UIImage+KJBannerGIF.h"
@protocol KJBannerWebImageHandle <NSObject>
@optional;
#pragma mark - common
/// 占位图
@property(nonatomic,strong)UIImage *placeholder;
/// 图片下载完成回调
@property(nonatomic,copy,readwrite)KJWebImageCompleted completed;
/// 下载进度回调
@property(nonatomic,copy,readwrite)KJLoadProgressBlock progress;
/// 图片地址链接类型，默认 KJBannerImageURLTypeCommon
@property(nonatomic,assign)KJBannerImageURLType URLType;
/// 是否缓存数据至本地，默认开启
@property(nonatomic,assign)bool cacheDatas;
/// 是否等比裁剪图片，默认关闭
@property(nonatomic,assign)bool cropScale;
/// 获取原始图回调，裁剪开启才有效果
@property(nonatomic,copy,readwrite)void(^kCropScaleImage)(UIImage * originalImgae, UIImage * scaleImage);

#pragma mark - button
/// 按钮状态
@property(nonatomic,assign)UIControlState buttonState;

@end

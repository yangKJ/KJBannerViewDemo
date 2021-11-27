//
//  KJBannerViewFunc.h
//  KJBannerViewDemo
//
//  Created by 杨科军 on 2020/12/7.
//  Copyright © 2020 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo
//  简单函数

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 弱引用
#define __banner_weakself __weak __typeof(self) weakself = self
#define __banner_strongself __strong __typeof(self) strongself = weakself

@interface KJBannerViewFunc : NSObject

/// 子线程
extern void kGCD_banner_async(dispatch_block_t _Nonnull block);

/// 主线程
extern void kGCD_banner_main(dispatch_block_t _Nonnull block);

/// 延时执行
extern void kGCD_banner_after_main(NSTimeInterval delayInSeconds, dispatch_block_t _Nonnull block);

/// 异步绘制圆角，生成蒙版图片
/// 原理就是绘制一个镂空图片盖在上面，所以这种只适用于纯色背景
/// @param radius 圆角半径
/// @param kAsyncDrawImage 蒙版图片回调
/// @param corners 圆角位置，支持特定方位圆角处理
/// @param view 需要覆盖视图
extern void kBannerAsyncCornerRadius(CGFloat radius,
                                     void(^kAsyncDrawImage)(UIImage * image),
                                     UIRectCorner corners, UIView * view);

/// 判断是网络图片还是本地
extern bool kBannerImageURLStringLocality(NSString * _Nonnull urlString);

/// 异步播放动态图
/// @param data 数据源
/// @param kPlayImage 播放图片回调
extern void kBannerAsyncPlayGIFImage(NSData * data, void(^kPlayImage)(UIImage * image));

/// MD5加密
extern NSString * kBannerMD5String(NSString * string);

/// 获取本地GIF资源
extern NSData * kBannerLocalityGIFData(NSString * string);

@end

NS_ASSUME_NONNULL_END

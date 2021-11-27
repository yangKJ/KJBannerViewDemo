//
//  KJBannerViewPreRendered.h
//  KJBannerViewDemo
//
//  Created by 杨科军 on 2020/12/7.
//  Copyright © 2020 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo
//  预渲染管理器

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KJBannerViewPreRendered : NSObject

/// 预渲染图片
/// @param url 图片地址
/// @param withBlock 缓存图片回调
- (void)preRenderedImageWithUrl:(NSString *)url withBlock:(void(^)(UIImage * image))withBlock;

/// 读取缓存区图片资源
/// @param url 图片地址
- (nullable UIImage *)readCacheImageWithUrl:(NSString *)url;

/// 清除缓存区图片资源
- (void)clearCacheImages;

@end

NS_ASSUME_NONNULL_END

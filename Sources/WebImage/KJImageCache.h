//
//  KJImageCache.h
//  KJBannerViewDemo
//
//  Created by 杨科军 on 2020/12/7.
//  Copyright © 2020 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo
//  缓存工具

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define KJBannerLoadImages [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/KJLoadImages"]

/// 图片资源缓存工具
@interface KJImageCache : NSObject
/// 最大缓存，默认50mb
@property (nonatomic, assign, class) NSUInteger maxCache;
/// 是否允许写入Cache，默认为YES
@property (nonatomic, assign, class) BOOL allowCache;
/// 先从缓存读取，若没有则读取本地文件
+ (nullable UIImage *)readCacheImageWithKey:(NSString *)key;
/// 先从缓存读取，若没有则读取本地文件并写入缓存
+ (void)readImageWithKey:(NSString *)key completion:(void(^)(UIImage *image))completion;
/// 将图片写入缓存和存储到本地
+ (void)storeImage:(UIImage *)image Key:(NSString *)key;
/// 链接名转换成MD5
+ (NSString *)MD5String:(NSString *)key;

@end


//********************* 动态图缓存相关 *********************
@interface KJImageCache (KJBannerGIF)
/// 动态图本地获取
+ (nullable NSData *)readGIFImageWithKey:(NSString *)key;
/// 将动态图写入本地
+ (void)storeGIFData:(NSData *)data Key:(NSString *)key;

@end

//********************* 缓存大小相关 *********************
@interface KJImageCache (KJBannerCache)
/// 清理掉缓存和本地文件
+ (BOOL)kj_clearLocalityImageAndCache;
/// 获取图片本地文件总大小
+ (int64_t)kj_getLocalityImageCacheSize;

@end


NS_ASSUME_NONNULL_END

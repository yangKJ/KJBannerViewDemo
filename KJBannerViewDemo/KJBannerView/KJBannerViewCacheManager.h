//
//  KJBannerViewCacheManager.h
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
@interface KJBannerViewCacheManager : NSObject
/// 最大缓存，默认50mb
@property(nonatomic,assign,class)NSUInteger maxCache;
/// 是否允许写入Cache，默认为YES
@property(nonatomic,assign,class)BOOL allowCache;
/// MD5加密
+ (NSString*)kj_bannerMD5WithString:(NSString*)string;
/// 先从缓存读取，若没有则读取本地文件
+ (UIImage*)kj_getImageWithKey:(NSString*)key;
/// 先从缓存读取，若没有则读取本地文件并写入缓存
+ (void)kj_getImageWithKey:(NSString*)key completion:(void(^)(UIImage*image))completion;
/// 将图片写入缓存和存储到本地
+ (void)kj_storeImage:(UIImage*)image Key:(NSString*)key;

@end

//********************* 动态图缓存相关 *********************
@interface KJBannerViewCacheManager (KJBannerGIF)
/// 动态图本地获取
+ (NSData*)kj_getGIFImageWithKey:(NSString*)key;
/// 将动态图写入本地
+ (void)kj_storeGIFData:(NSData*)data Key:(NSString*)key;

@end

//********************* 缓存大小相关 *********************
@interface KJBannerViewCacheManager (KJBannerCache)
/// 清理掉缓存和本地文件
+ (BOOL)kj_clearLocalityImageAndCache;
/// 获取图片本地文件总大小
+ (int64_t)kj_getLocalityImageCacheSize;

@end


NS_ASSUME_NONNULL_END

//
//  KJAutoPurgingImageCache.h
//  KJBannerViewDemo
//
//  Created by 杨科军 on 2021/2/19.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo
//  定时清理指定时间段以前图片资源缓存

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 清理时间周期
typedef NS_ENUM(NSInteger, KJAutoPurginCacheType) {
    KJAutoPurginCacheTypeOneDay,  //1天
    KJAutoPurginCacheTypeThreeDay,//3天
    KJAutoPurginCacheTypeOneWeek, //1周
    KJAutoPurginCacheTypeOneMonth,//1月
    KJAutoPurginCacheTypeOneYear, //1年
    KJAutoPurginCacheTypeAll,     //清理全部
};
extern NSString * kBannerTimingUserDefaultsKey;

/// 定时清理指定时间段以前图片资源缓存
@interface KJAutoPurgingCache : NSObject

/// 该方法需要在程序最开始位置执行，可以是Appdelegate或首页控制器里面
/// @param open 开启清理功能，只有开启过该方法才会存储时间
/// @param type 清除指定时间以前的数据
+ (void)autoPurgingCache:(BOOL)open timingTimeType:(KJAutoPurginCacheType)type;

/// 自动清理大于多少的数据源，TODO
/// @param maxBytes 最大存储数据，单位kb
+ (void)autoPurgingMaxBytes:(NSInteger)maxBytes;

@end

NS_ASSUME_NONNULL_END

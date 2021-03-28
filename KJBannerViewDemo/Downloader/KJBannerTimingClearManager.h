//
//  KJBannerTimingClearManager.h
//  KJBannerViewDemo
//
//  Created by 杨科军 on 2021/2/19.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo
//  定时清理指定时间段以前图片资源缓存

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
//清理时间周期
typedef NS_ENUM(NSInteger, KJBannerViewTimingTimeType) {
    KJBannerViewTimingTimeTypeOneDay,  //1天
    KJBannerViewTimingTimeTypeThreeDay,//3天
    KJBannerViewTimingTimeTypeOneWeek, //1周
    KJBannerViewTimingTimeTypeOneMonth,//1月
    KJBannerViewTimingTimeTypeOneYear, //1年
    KJBannerViewTimingTimeTypeAll,     //清理全部
};
extern NSString *kBannerTimingUserDefaultsKey;
@interface KJBannerTimingClearManager : NSObject
/* 该方法需要在程序最开始位置执行，可以是Appdelegate或首页控制器里面 */
/* 只有开启过该方法才会存储时间 */
/* 开启清理功能，清除时间以前的数据 */
+ (void)kj_openTimingCrearCached:(BOOL)crear TimingTimeType:(KJBannerViewTimingTimeType)type;

/* 自动清理大于多少的数据源，单位kb */
+ (void)kj_autoClearCachedMaxBytes:(NSInteger)maxBytes;

/* ****************** 内部使用 *********/
@property(nonatomic,assign,class,readonly)BOOL openTiming;

@end

NS_ASSUME_NONNULL_END

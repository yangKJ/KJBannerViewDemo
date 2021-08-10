//
//  KJBannerTimingClearManager.m
//  KJBannerViewDemo
//
//  Created by 杨科军 on 2021/2/19.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo

#import "KJBannerTimingClearManager.h"
#import "KJBannerViewType.h"
#import "KJBannerViewCacheManager.h"

NSString *kBannerTimingUserDefaultsKey = @"kBannerTimingUserDefaultsKey";

@implementation KJBannerTimingClearManager

static BOOL _openTiming = NO;
+ (BOOL)openTiming{
    return _openTiming;
}
/* 开启清理功能，清除时间以前的数据 */
+ (void)kj_openTimingCrearCached:(BOOL)crear timingTimeType:(KJBannerViewTimingTimeType)type{
    _openTiming = crear;
    if (crear == NO) return;
    kGCD_banner_async(^{
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        if (type == KJBannerViewTimingTimeTypeAll) {
            [KJBannerViewCacheManager kj_clearLocalityImageAndCache];
            [userDefaults setObject:nil forKey:kBannerTimingUserDefaultsKey];
            [userDefaults synchronize];
            return;
        }
        NSDictionary * before = [userDefaults dictionaryForKey:kBannerTimingUserDefaultsKey];
        if (before == nil) return;
        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:before];
        NSInteger time = (NSInteger)NSDate.date.timeIntervalSince1970;
        switch (type) {
            case KJBannerViewTimingTimeTypeOneDay:
                time -= 24 * 60 * 60;
                break;
            case KJBannerViewTimingTimeTypeThreeDay:
                time -= 24 * 60 * 60 * 3;
                break;
            case KJBannerViewTimingTimeTypeOneWeek:
                time -= 24 * 60 * 60 * 7;
                break;
            case KJBannerViewTimingTimeTypeOneMonth:
                time -= 24 * 60 * 60 * 30;
                break;
            case KJBannerViewTimingTimeTypeOneYear:
                time -= 24 * 60 * 60 * 365;
                break;
            default:
                break;
        }
        NSArray * keys = dict.allKeys;
        [self kj_sortDescriptorWithArray:&keys key:@"self"];
        NSInteger index;
        if ([keys.lastObject integerValue] <= time) {
            index = 0;
        } else {
            index = [self kj_searchKeys:keys timingTime:time];
            if (index == 0 && [keys[0] integerValue] <= time) {
                NSString * key = [NSString stringWithFormat:@"%@",keys[0]];
                if ([self kj_removePath:[dict valueForKey:key]]) {
                    [dict removeObjectForKey:key];
                }
                [userDefaults setObject:dict forKey:kBannerTimingUserDefaultsKey];
                [userDefaults synchronize];
                return;
            }
            index = keys.count - index;
        }
        for (NSInteger i = index; i < keys.count; i++) {
            NSString * key = [NSString stringWithFormat:@"%@",keys[i]];
            if ([self kj_removePath:[dict valueForKey:key]]) {
                [dict removeObjectForKey:key];
            }
        }
        [userDefaults setObject:dict forKey:kBannerTimingUserDefaultsKey];
        [userDefaults synchronize];
    });
}
/* 自动清理大于多少的数据源 */
+ (void)kj_autoClearCachedMaxBytes:(NSInteger)maxBytes{
    //TODO:
}

#pragma mark - private
/// 升序排列
+ (void)kj_sortDescriptorWithArray:(NSArray **)array key:(NSString *)key{
    @autoreleasepool {
        NSSortDescriptor * des = [NSSortDescriptor sortDescriptorWithKey:key ascending:YES];
        NSMutableArray * temp = [NSMutableArray arrayWithArray:*array];
        [temp sortUsingDescriptors:@[des]];
        * array = [temp mutableCopy];
    }
}

/// 谓词匹配查找index
+ (NSInteger)kj_searchKeys:(NSArray *)keys timingTime:(NSInteger)time{
    NSString * string = [NSString stringWithFormat:@"SELF LIKE '%ld'", time];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:string];
    return [[keys filteredArrayUsingPredicate:predicate].firstObject integerValue];
}

/// 删除路径文件
+ (BOOL)kj_removePath:(NSString *)path{
    NSString *directoryPath = [KJBannerLoadImages stringByAppendingPathComponent:path];
    if ([[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:nil]) {
        return [[NSFileManager defaultManager] removeItemAtPath:directoryPath error:nil];
    }
    return YES;
}

@end

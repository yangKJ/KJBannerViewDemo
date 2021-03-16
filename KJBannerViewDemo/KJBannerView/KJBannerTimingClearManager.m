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
+ (void)kj_openTimingCrearCached:(BOOL)crear TimingTimeType:(KJBannerViewTimingTimeType)type{
    _openTiming = crear;
    if (crear == NO) return;
    kGCD_banner_async(^{
        if (type == KJBannerViewTimingTimeTypeAll) {
            [KJBannerViewCacheManager kj_clearLocalityImageAndCache];
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kBannerTimingUserDefaultsKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            return;
        }
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:kBannerTimingUserDefaultsKey]];
        if (dict == nil) return;
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
        NSMutableArray *keys = [NSMutableArray arrayWithArray:dict.allKeys];
        [self kj_quickSortArrary:keys leftIndex:0 rightIndex:keys.count-1];
        NSInteger index;
        if ([keys.lastObject integerValue] <= time) {
            index = 0;
        }else{
            index = [self kj_binarySearchKeys:keys TimingTime:time];
            if (index == 0 && [keys[0] integerValue] <= time) {
                NSString *key = [NSString stringWithFormat:@"%@",keys[0]];
                if ([self kj_removePath:[dict valueForKey:key]]) {
                    [dict removeObjectForKey:key];
                }
                [[NSUserDefaults standardUserDefaults] setObject:dict forKey:kBannerTimingUserDefaultsKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
                return;
            }
            index = keys.count - index;
        }
        for (NSInteger i = index; i<keys.count; i++) {
            NSString *key = [NSString stringWithFormat:@"%@",keys[i]];
            if ([self kj_removePath:[dict valueForKey:key]]) {
                [dict removeObjectForKey:key];
            }
        }
        [[NSUserDefaults standardUserDefaults] setObject:dict forKey:kBannerTimingUserDefaultsKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    });
}
/* 自动清理大于多少的数据源 */
+ (void)kj_autoClearCachedMaxBytes:(NSInteger)maxBytes{
    //TODO:
}

#pragma mark - private
/// 快速排序
+ (void)kj_quickSortArrary:(NSMutableArray*)array leftIndex:(NSInteger)leftIndex rightIndex:(NSInteger)rightIndex{
    if (leftIndex > rightIndex) return;
    NSInteger i = leftIndex;
    NSInteger j = rightIndex;
    NSInteger key = [array[i] integerValue];
    while (i < j) {
        while (i < j && key <= [array[j] integerValue]) {
            j--;
        }
        array[i] = array[j];
        while (i < j && key >= [array[i] integerValue]) {
            i++;
        }
        array[j] = array[i];
    }
    array[i] = @(key);
    //前面排序
    [self kj_quickSortArrary:array leftIndex:leftIndex rightIndex:i - 1];
    //后面排序
    [self kj_quickSortArrary:array leftIndex:i + 1 rightIndex:rightIndex];
}
/// 二分查找，找到当前index
+ (NSInteger)kj_binarySearchKeys:(NSArray*)keys TimingTime:(NSInteger)time{
    NSInteger mid = 0;
    NSInteger frist = 0;
    NSInteger last = keys.count - 1;
    while (frist<=last) {
        mid = (frist+last)>>1;
        if (time > [keys[mid] integerValue]) {
            frist = mid+1;
        }else if (time < [keys[mid] integerValue]) {
            last = mid-1;
        }else{
            break;
        }
    }
    return mid;
}
/// 删除路径文件
+ (BOOL)kj_removePath:(NSString*)path{
    NSString *directoryPath = [KJBannerLoadImages stringByAppendingPathComponent:path];
    if ([[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:nil]) {
        return [[NSFileManager defaultManager] removeItemAtPath:directoryPath error:nil];
    }
    return YES;
}

@end

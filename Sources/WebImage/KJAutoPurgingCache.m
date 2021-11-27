//
//  KJAutoPurgingImageCache.m
//  KJBannerViewDemo
//
//  Created by 杨科军 on 2021/2/19.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo

#import "KJAutoPurgingCache.h"
#import "KJImageCache.h"

NSString * kBannerTimingUserDefaultsKey = @"kBannerTimingUserDefaultsKey";

@implementation KJAutoPurgingCache

static BOOL _openTiming = NO;
+ (BOOL)openTiming{
    return _openTiming;
}
/* 开启清理功能，清除时间以前的数据 */
+ (void)autoPurgingCache:(BOOL)open timingTimeType:(KJAutoPurginCacheType)type{
    _openTiming = open;
    if (open == NO) return;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        if (type == KJAutoPurginCacheTypeAll) {
            [KJImageCache kj_clearLocalityImageAndCache];
            [userDefaults setObject:nil forKey:kBannerTimingUserDefaultsKey];
            [userDefaults synchronize];
            return;
        }
        NSDictionary * before = [userDefaults dictionaryForKey:kBannerTimingUserDefaultsKey];
        if (before == nil) return;
        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:before];
        NSInteger time = (NSInteger)NSDate.date.timeIntervalSince1970;
        switch (type) {
            case KJAutoPurginCacheTypeOneDay:
                time -= 24 * 60 * 60;
                break;
            case KJAutoPurginCacheTypeThreeDay:
                time -= 24 * 60 * 60 * 3;
                break;
            case KJAutoPurginCacheTypeOneWeek:
                time -= 24 * 60 * 60 * 7;
                break;
            case KJAutoPurginCacheTypeOneMonth:
                time -= 24 * 60 * 60 * 30;
                break;
            case KJAutoPurginCacheTypeOneYear:
                time -= 24 * 60 * 60 * 365;
                break;
            default:
                break;
        }
        NSArray * keys = dict.allKeys;
        keys = [self kj_sortDescriptorWithArray:keys key:@"self"];
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
+ (void)autoPurgingMaxBytes:(NSInteger)maxBytes{
    //TODO:
}

#pragma mark - private

/// 升序排列
+ (NSArray *)kj_sortDescriptorWithArray:(NSArray *)array key:(NSString *)key{
    NSSortDescriptor * des = [NSSortDescriptor sortDescriptorWithKey:key ascending:YES];
    NSMutableArray * temp = [NSMutableArray arrayWithArray:array];
    [temp sortUsingDescriptors:@[des]];
    return [temp mutableCopy];
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

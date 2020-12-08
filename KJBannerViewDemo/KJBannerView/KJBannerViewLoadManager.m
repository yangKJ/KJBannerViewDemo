//
//  KJBannerViewLoadManager.m
//  KJBannerViewDemo
//
//  Created by 杨科军 on 2020/12/7.
//  Copyright © 2020 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo

#import "KJBannerViewLoadManager.h"

@interface KJBannerViewLoadManager ()
@property(nonatomic,strong,class)NSMutableDictionary *dict;/// 失败次数
@property(nonatomic,copy,readwrite)KJLoadProgressBlock progressblock;
@end

@implementation KJBannerViewLoadManager
static KJBannerViewLoadManager *manager = nil;
/// 带缓存机制的下载图片
+ (void)kj_loadImageWithURL:(NSString*)url complete:(void(^)(UIImage *image))complete{
    [self kj_loadImageWithURL:url complete:complete progress:nil];
}
+ (void)kj_loadImageWithURL:(NSString*)url complete:(void(^)(UIImage *image))complete progress:(KJLoadProgressBlock)progress{
    [KJBannerViewCacheManager kj_getImageWithKey:url completion:^(UIImage * _Nonnull image) {
        if (image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (complete) complete(image);
            });
        }else{
            if ([self kj_failureNumsForKey:url] >= self.kMaxLoadNum) {
                if (complete) complete(nil);
                return;
            }
            KJBannerViewDownloader *downloader = [[KJBannerViewDownloader alloc] init];
            __block void (^kAnalysis)(NSData *data, NSError *error) = ^(NSData *data, NSError *error){
                UIImage *image = nil;
                if (error) {
                    [self kj_cacheFailureForKey:url];
                    [self kj_loadImageWithURL:url complete:complete progress:progress];
                    return;
                }else{
                    image = [UIImage imageWithData:data];
                    if (image) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (complete) complete(image);
                        });
                        [KJBannerViewCacheManager kj_storeImage:image Key:url];
                        [self.dict removeAllObjects];
                        return;
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (complete) complete(image);
                });
            };
            if (progress) {
                [downloader kj_startDownloadImageWithURL:[NSURL URLWithString:url] Progress:^(KJBannerDownloadProgress * _Nonnull downloadProgress) {
                    progress(downloadProgress);
                } Complete:^(NSData * _Nullable data, NSError * _Nullable error) {
                    kAnalysis(data, error);
                }];
            }else{
                [downloader kj_startDownloadImageWithURL:[NSURL URLWithString:url] Progress:nil Complete:^(NSData *data, NSError *error) {
                    kAnalysis(data, error);
                }];
            }
        }
    }];
}
/// 下载数据，未使用缓存机制
+ (NSData*)kj_downloadDataWithURL:(NSString*)url progress:(KJLoadProgressBlock)progress{
    @synchronized (self) {
        if (manager == nil) manager = [self new];
    }
    manager.progressblock = progress;
    return [manager kj_recursionDataWithURL:[NSURL URLWithString:url]];
}
/// 递归拿到Data
- (NSData*)kj_recursionDataWithURL:(NSURL*)URL{
    NSInteger count = [KJBannerViewLoadManager kj_failureNumsForKey:URL.absoluteString];
    if (count >= KJBannerViewLoadManager.kMaxLoadNum) {
        return nil;
    }
    NSData * (^kGetData)(NSURL*URL) = ^NSData *(NSURL*URL){
        if (URL == nil) return nil;
        __block NSData *__data = nil;
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        dispatch_group_async(dispatch_group_create(), queue, ^{
            KJBannerViewDownloader *downloader = [[KJBannerViewDownloader alloc] init];
            [downloader kj_startDownloadImageWithURL:URL Progress:^(KJBannerDownloadProgress * _Nonnull downloadProgress) {
                if (manager.progressblock) {
                    manager.progressblock(downloadProgress);
                }
            } Complete:^(NSData *data, NSError *error) {
                if (error) {
                    [KJBannerViewLoadManager kj_cacheFailureForKey:URL.absoluteString];
                }
                __data = data;
                dispatch_semaphore_signal(semaphore);
            }];
        });
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        return __data;
    };
    NSData *data = kGetData(URL);
    if (data) {
        [KJBannerViewLoadManager.dict removeAllObjects];
        return data;
    }else{
        return [self kj_recursionDataWithURL:URL];
    }
}
#pragma mark - private
/// 失败次数
+ (NSUInteger)kj_failureNumsForKey:(NSString*)key{
    key = [KJBannerViewCacheManager kj_bannerMD5WithString:key];
    NSNumber *failes = [self.dict objectForKey:key];
    return (failes && [failes respondsToSelector:@selector(integerValue)]) ? failes.integerValue : 0;
}
/// 缓存失败
+ (void)kj_cacheFailureForKey:(NSString*)key{
    key = [KJBannerViewCacheManager kj_bannerMD5WithString:key];
    NSNumber *failes = [self.dict objectForKey:key];
    NSUInteger nums = 0;
    if (failes && [failes respondsToSelector:@selector(integerValue)]) {
        nums = [failes integerValue];
    }
    nums++;
    [self.dict setObject:@(nums) forKey:key];
}

#pragma mark - lazy
static NSMutableDictionary *_dict = nil;
+ (NSMutableDictionary*)dict{
    if (_dict == nil) {
        _dict = [NSMutableDictionary dictionary];
    }
    return _dict;
}
+ (void)setDict:(NSMutableDictionary*)dict{
    _dict = dict;
}
static NSInteger _kMaxLoadNum = 2;
+ (NSInteger)kMaxLoadNum{
    return _kMaxLoadNum;
}
+ (void)setKMaxLoadNum:(NSInteger)kMaxLoadNum{
    _kMaxLoadNum = kMaxLoadNum;
}

@end

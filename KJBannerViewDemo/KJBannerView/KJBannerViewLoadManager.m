//
//  KJBannerViewLoadManager.m
//  KJBannerViewDemo
//
//  Created by 杨科军 on 2020/12/7.
//  Copyright © 2020 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo

#import "KJBannerViewLoadManager.h"

@interface KJBannerViewLoadManager ()
@property(nonatomic,strong,class)NSMutableDictionary *dict;
@end

@implementation KJBannerViewLoadManager
static KJBannerViewLoadManager *manager = nil;
/// 带缓存机制的下载图片
+ (void)kj_loadImageWithURL:(NSString*)url complete:(void(^)(UIImage *image))complete{
    [self kj_loadImageWithURL:url complete:complete progress:nil];
}
+ (void)kj_loadImageWithURL:(NSString*)url complete:(void(^)(UIImage *image))complete progress:(KJLoadProgressBlock)progress{
    void (^kGetNetworkingImage)(void) = ^{
        if ([self kj_failureNumsForKey:url] >= self.kMaxLoadNum) {
            if (complete) complete(nil);
            return;
        }
        void (^kAnalysis)(NSData *data, NSError *error) = ^(NSData *data, NSError *error){
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
                    [self kj_resetFailureDictForKey:url];
                    return;
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (complete) complete(image);
            });
        };
        KJBannerViewDownloader *downloader = [[KJBannerViewDownloader alloc] init];
        if (progress) {
            [downloader kj_startDownloadImageWithURL:[NSURL URLWithString:url] Progress:^(KJBannerDownloadProgress * downloadProgress) {
                progress(downloadProgress);
            } Complete:^(NSData * _Nullable data, NSError * _Nullable error) {
                kAnalysis(data, error);
            }];
        }else{
            [downloader kj_startDownloadImageWithURL:[NSURL URLWithString:url] Progress:nil Complete:^(NSData *data, NSError *error) {
                kAnalysis(data, error);
            }];
        }
    };
    if (self.useAsync) {
        [KJBannerViewCacheManager kj_getImageWithKey:url completion:^(UIImage * _Nonnull image) {
            if (image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (complete) complete(image);
                });
            }else{
                kGetNetworkingImage();
            }
        }];
    }else{
        UIImage *image = [KJBannerViewCacheManager kj_getImageWithKey:url];
        if (image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (complete) complete(image);
            });
        }else{
            kGetNetworkingImage();
        }
    }
}
/// 下载数据，未使用缓存机制
+ (NSData*)kj_downloadDataWithURL:(NSString*)url progress:(KJLoadProgressBlock)progress{
    @synchronized (self) {
        if (manager == nil) manager = [self new];
    }
    return [manager kj_recursionDataWithURL:[NSURL URLWithString:url] progress:progress];
}
/// 递归拿到DATA
- (NSData*)kj_recursionDataWithURL:(NSURL*)URL progress:(KJLoadProgressBlock)progress{
    NSInteger count = [KJBannerViewLoadManager kj_failureNumsForKey:URL.absoluteString];
    if (count >= KJBannerViewLoadManager.kMaxLoadNum) {
        return nil;
    }
    NSData *resultData = ({
        if (URL == nil) return nil;
        __block NSData *__data = nil;
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        dispatch_group_async(dispatch_group_create(), queue, ^{
            [[KJBannerViewDownloader new] kj_startDownloadImageWithURL:URL Progress:^(KJBannerDownloadProgress * _Nonnull downloadProgress) {
                if (progress) {
                    progress(downloadProgress);
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
        __data;
    });
    if (resultData) {
        [KJBannerViewLoadManager kj_resetFailureDictForKey:URL.absoluteString];
        return resultData;
    }else{
        return [self kj_recursionDataWithURL:URL progress:progress];
    }
}
#pragma mark - private
/// 重置失败次数
+ (void)kj_resetFailureDictForKey:(NSString*)key{
    key = [KJBannerViewCacheManager kj_bannerMD5WithString:key];
    [self.dict setObject:@(0) forKey:key];
}
/// 失败次数
+ (NSUInteger)kj_failureNumsForKey:(NSString*)key{
    key = [KJBannerViewCacheManager kj_bannerMD5WithString:key];
    NSNumber *number = [self.dict objectForKey:key];
    return (number && [number respondsToSelector:@selector(integerValue)]) ? number.integerValue : 0;
}
/// 缓存失败
+ (void)kj_cacheFailureForKey:(NSString*)key{
    key = [KJBannerViewCacheManager kj_bannerMD5WithString:key];
    NSNumber *number = [self.dict objectForKey:key];
    NSUInteger index = 0;
    if (number && [number respondsToSelector:@selector(integerValue)]) {
        index = [number integerValue];
    }
    index++;
    [self.dict setObject:@(index) forKey:key];
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
static BOOL _useAsync = NO;
+ (BOOL)useAsync{
    return _useAsync;
}
+ (void)setUseAsync:(BOOL)useAsync{
    _useAsync = useAsync;
}

@end

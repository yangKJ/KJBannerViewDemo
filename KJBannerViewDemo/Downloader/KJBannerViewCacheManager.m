//
//  KJBannerViewCacheManager.m
//  KJBannerViewDemo
//
//  Created by 杨科军 on 2020/12/7.
//  Copyright © 2020 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo

#import "KJBannerViewCacheManager.h"
#import <CommonCrypto/CommonDigest.h>
#import "KJBannerTimingClearManager.h"
#import <objc/message.h>

@interface KJBannerViewCacheManager()
@property(nonatomic,strong,class)NSCache *cache;
@end

@implementation KJBannerViewCacheManager
/// MD5加密
+ (NSString*)kj_bannerMD5WithString:(NSString*)string{
    const char *original_str = [string UTF8String];
    unsigned char digist[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str, (uint)strlen(original_str), digist);
    NSMutableString *outPutStr = [NSMutableString stringWithCapacity:10];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [outPutStr appendFormat:@"%02X", digist[i]];
    }
    return [outPutStr lowercaseString];
}
/// 先从缓存读取，若没有则读取本地文件
+ (UIImage*)kj_getImageWithKey:(NSString*)key{
    if (key == nil || key.length == 0) return nil;
    NSString *subpath = [self kj_bannerMD5WithString:key];
    UIImage *image = [self.cache objectForKey:subpath];
    if (image == nil) {
        NSString *path = [KJBannerLoadImages stringByAppendingPathComponent:subpath];
        image = [UIImage imageWithContentsOfFile:path];
    }
    return image;
}
/// 先从缓存读取，若没有则读取本地文件并写入缓存
+ (void)kj_getImageWithKey:(NSString*)key completion:(void(^)(UIImage *image))completion{
    if (key == nil || key.length == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{        
            if (completion) completion(nil);
        });
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *subpath = [self kj_bannerMD5WithString:key];
        UIImage *image = [self.cache objectForKey:subpath];
        if (image == nil) {
            NSString *path = [KJBannerLoadImages stringByAppendingPathComponent:subpath];
            image = [UIImage imageWithContentsOfFile:path];
            if (image && self.allowCache) {
                [self kj_config];
                NSUInteger cost = kImageCacheSize(image);
                [self.cache setObject:image forKey:subpath cost:cost];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion(image);
        });
    });
}
/// 将图片写入缓存和存储到本地
+ (void)kj_storeImage:(UIImage*)image Key:(NSString*)key{
    if (image == nil || key == nil || key.length == 0) return;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *subpath = [self kj_bannerMD5WithString:key];
        [self kj_saveExtensionPath:subpath];
        if (self.allowCache) {
            [self kj_config];
            NSUInteger cost = kImageCacheSize(image);
            [self.cache setObject:image forKey:subpath cost:cost];
        }
        NSString *directoryPath = KJBannerLoadImages;
        if (![[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:nil]) {
            NSError *error = nil;
            BOOL ok = [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:&error];
            if (ok && error == nil){}else return;
        }
        @autoreleasepool {
            NSString *path = [directoryPath stringByAppendingPathComponent:subpath];
            NSData *data = UIImagePNGRepresentation(image);
            [[NSFileManager defaultManager] createFileAtPath:path contents:data attributes:nil];
        }
    });
}
#pragma mark - private
static KJBannerViewCacheManager *manager = nil;
+ (KJBannerViewCacheManager*)kj_config{
    @synchronized (self) {
        if (manager == nil) {
            manager = [[super allocWithZone:NULL] init];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kj_clearCaches) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        }
    }
    return manager;
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}
- (void)kj_clearCaches{
    [KJBannerViewCacheManager.cache removeAllObjects];
}
static inline NSUInteger kImageCacheSize(UIImage *image){
  return image.size.height * image.size.width * image.scale * image.scale;
}
//存储扩展
+ (void)kj_saveExtensionPath:(NSString*)subpath{
    if (KJBannerTimingClearManager.openTiming) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:kBannerTimingUserDefaultsKey]];
        [dict setObject:subpath forKey:[NSString stringWithFormat:@"%f",NSDate.date.timeIntervalSince1970]];
        [[NSUserDefaults standardUserDefaults] setObject:dict forKey:kBannerTimingUserDefaultsKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark - lazy
static NSCache *_cache = nil;
+ (NSCache*)cache{
    if (_cache == nil) {
        _cache = [[NSCache alloc] init];
    }
    return _cache;
}
+ (void)setCache:(NSCache*)cache{
    _cache = cache;
}
static BOOL _allowCache = YES;
+ (BOOL)allowCache{
    return _allowCache;
}
+ (void)setAllowCache:(BOOL)allowCache{
    _allowCache = allowCache;
}
static NSUInteger _maxCache = 50;
+ (NSUInteger)maxCache{
    return _maxCache;
}
+ (void)setMaxCache:(NSUInteger)maxCache{
    _maxCache = maxCache;
    self.cache.totalCostLimit = _maxCache * 1024 * 1024;
}

@end
@implementation KJBannerViewCacheManager (KJBannerGIF)
+ (NSData*)kj_getGIFImageWithKey:(NSString*)key{
    if (key == nil || key.length == 0) return nil;
    return [NSData dataWithContentsOfFile:[KJBannerLoadImages stringByAppendingPathComponent:[self kj_bannerMD5WithString:key]]];
}
/// 将动态图写入存储到本地
+ (void)kj_storeGIFData:(NSData*)data Key:(NSString*)key{
    if (data == nil || key == nil || data.length == 0) return;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *subpath = [self kj_bannerMD5WithString:key];
        SEL sel = NSSelectorFromString(@"kj_saveExtensionPath:");
        if ([self respondsToSelector:sel]) {
            ((void(*)(id, SEL, NSString*))(void*)objc_msgSend)((id)self, sel, subpath);
        }
        NSString *directoryPath = KJBannerLoadImages;
        if (![[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:nil]) {
            NSError *error = nil;
            BOOL isOK = [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:&error];
            if (isOK && error == nil){}else return;
        }
        @autoreleasepool {
            NSString *path = [directoryPath stringByAppendingPathComponent:subpath];
            [[NSFileManager defaultManager] createFileAtPath:path contents:data attributes:nil];
        }
    });
}

@end
@implementation KJBannerViewCacheManager (KJBannerCache)
/// 清理掉缓存和本地文件
+ (BOOL)kj_clearLocalityImageAndCache{
    [self.cache removeAllObjects];
    NSString *directoryPath = KJBannerLoadImages;
    if ([[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:nil]) {
        return [[NSFileManager defaultManager] removeItemAtPath:directoryPath error:nil];
    }
    return YES;
}
/// 获取图片本地文件总大小
+ (int64_t)kj_getLocalityImageCacheSize{
    BOOL isDir = NO;
    int64_t total = 0;
    NSString *directoryPath = KJBannerLoadImages;
    if ([[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:&isDir]) {
        if (isDir) {
            NSError *error = nil;
            NSArray *array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:&error];
            if (error == nil) {
                for (NSString *subpath in array) {
                    NSString *path = [directoryPath stringByAppendingPathComponent:subpath];
                    NSDictionary *dict = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
                    if (error == nil) total += [dict[NSFileSize] unsignedIntegerValue];
                }
            }
        }
    }
    return total;
}
@end

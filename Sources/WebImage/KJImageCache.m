//
//  KJImageCache.m
//  KJBannerViewDemo
//
//  Created by 杨科军 on 2020/12/7.
//  Copyright © 2020 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo

#import "KJImageCache.h"
#import <objc/message.h>
#import <CommonCrypto/CommonDigest.h>
#import "KJAutoPurgingCache.h"

@interface KJImageCache()

@property(nonatomic,strong,class)NSCache *cache;

@end

@implementation KJImageCache

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
/// 先从缓存读取，若没有则读取本地文件
+ (nullable UIImage *)readCacheImageWithKey:(NSString *)key{
    if (key == nil || key.length == 0) return nil;
    NSString *subpath = [KJImageCache MD5String:key];
    UIImage *image = [self.cache objectForKey:subpath];
    if (image == nil) {
        NSString *path = [KJBannerLoadImages stringByAppendingPathComponent:subpath];
        image = [UIImage imageWithContentsOfFile:path];
    }
    return image;
}
/// 先从缓存读取，若没有则读取本地文件并写入缓存
+ (void)readImageWithKey:(NSString *)key completion:(void(^)(UIImage *image))completion{
    if (key == nil || key.length == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{        
            if (completion) completion(nil);
        });
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *subpath = [KJImageCache MD5String:key];
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
+ (void)storeImage:(UIImage *)image Key:(NSString *)key{
    if (image == nil || key == nil || key.length == 0) return;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *subpath = [KJImageCache MD5String:key];
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

/// 链接名转换成MD5
+ (NSString *)MD5String:(NSString *)key{
    const char * original = [key UTF8String];
    unsigned char digist[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original, (uint)strlen(original), digist);
    NSMutableString *resultString = [NSMutableString stringWithCapacity:10];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
    [resultString appendFormat:@"%02X", digist[i]];
    return [resultString lowercaseString];
}

#pragma mark - private

static KJImageCache *manager = nil;
+ (KJImageCache *)kj_config{
    @synchronized (self) {
        if (manager == nil) {
            manager = [[super allocWithZone:NULL] init];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(kj_clearCaches)
                                                         name:UIApplicationDidReceiveMemoryWarningNotification
                                                       object:nil];
        }
    }
    return manager;
}
- (void)kj_clearCaches{
    [KJImageCache.cache removeAllObjects];
}
static inline NSUInteger kImageCacheSize(UIImage * image){
  return image.size.height * image.size.width * image.scale * image.scale;
}
//存储扩展
+ (void)kj_saveExtensionPath:(NSString *)subpath{
    bool openTiming = [[KJAutoPurgingCache valueForKey:@"openTiming"] boolValue];
    if (openTiming) {
        NSDictionary *defaults = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kBannerTimingUserDefaultsKey];
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:defaults];
        [dict setObject:subpath forKey:[NSString stringWithFormat:@"%f",NSDate.date.timeIntervalSince1970]];
        [[NSUserDefaults standardUserDefaults] setObject:dict forKey:kBannerTimingUserDefaultsKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark - lazy

static NSCache *_cache = nil;
+ (NSCache *)cache{
    if (_cache == nil) {
        _cache = [[NSCache alloc] init];
    }
    return _cache;
}
+ (void)setCache:(NSCache *)cache{
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

@implementation KJImageCache (KJBannerGIF)
+ (nullable NSData *)readGIFImageWithKey:(NSString *)key{
    if (key == nil || key.length == 0) return nil;
    NSString *path = [KJBannerLoadImages stringByAppendingPathComponent:[KJImageCache MD5String:key]];
    return [NSData dataWithContentsOfFile:path];
}
/// 将动态图写入存储到本地
+ (void)storeGIFData:(NSData *)data Key:(NSString *)key{
    if (data == nil || key == nil || data.length == 0) return;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *subpath = [KJImageCache MD5String:key];
        SEL sel = NSSelectorFromString(@"kj_saveExtensionPath:");
        if ([self respondsToSelector:sel]) {
            ((void(*)(id, SEL, NSString*))(void*)objc_msgSend)((id)self, sel, subpath);
        }
        NSString *directoryPath = KJBannerLoadImages;
        if (![[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:nil]) {
            NSError *error = nil;
            BOOL isOK = [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath
                                                  withIntermediateDirectories:YES attributes:nil error:&error];
            if (isOK && error == nil) { } else return;
        }
        @autoreleasepool {
            NSString *path = [directoryPath stringByAppendingPathComponent:subpath];
            [[NSFileManager defaultManager] createFileAtPath:path contents:data attributes:nil];
        }
    });
}

@end

@implementation KJImageCache (KJBannerCache)

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
    NSString * directoryPath = KJBannerLoadImages;
    if ([[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:&isDir]) {
        if (isDir == NO) return total;
        NSError *error = nil;
        NSArray *array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:&error];
        if (error) return total;
        for (NSString * subpath in array) {
            NSString *path = [directoryPath stringByAppendingPathComponent:subpath];
            NSDictionary *dict = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
            if (error == nil) total += [dict[NSFileSize] unsignedIntegerValue];
        }
    }
    return total;
}

@end

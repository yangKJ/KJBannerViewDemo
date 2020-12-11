//
//  KJBannerViewCacheManager+KJBannerGIF.m
//  KJBannerViewDemo
//
//  Created by 杨科军 on 2020/12/9.
//  Copyright © 2020 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo

#import "KJBannerViewCacheManager+KJBannerGIF.h"

@implementation KJBannerViewCacheManager (KJBannerGIF)
+ (NSData*)kj_getGIFImageWithKey:(NSString*)key{
    if (key == nil || key.length == 0) return nil;
    NSString *subpath = [self kj_bannerMD5WithString:key];
    return [NSData dataWithContentsOfFile:[KJBannerLoadImages stringByAppendingPathComponent:subpath]];
}
/// 将动态图写入存储到本地
+ (void)kj_storeGIFData:(NSData*)data Key:(NSString*)key{
    if (data == nil || key == nil || data.length == 0) return;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *subpath = [self kj_bannerMD5WithString:key];
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

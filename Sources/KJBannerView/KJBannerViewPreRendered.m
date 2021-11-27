//
//  KJBannerViewPreRendered.m
//  KJBannerViewDemo
//
//  Created by 杨科军 on 2020/12/7.
//  Copyright © 2020 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo

#import "KJBannerViewPreRendered.h"
#import "KJBannerViewFunc.h"

#if __has_include("KJBannerViewDownloader.h")
#import "KJBannerViewDownloader.h"
#endif

@interface KJBannerViewPreRendered ()

@property (nonatomic,strong) NSMutableDictionary * imageDict;
@property (nonatomic,strong) dispatch_queue_t synchronizationQueue;

@end

@implementation KJBannerViewPreRendered

- (instancetype)init{
    if (self = [super init]) {
        self.imageDict = [NSMutableDictionary dictionary];
        self.synchronizationQueue = dispatch_queue_create("banner.queue.PreRendered", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

/// 预渲染图片
/// @param url 图片地址
/// @param withBlock 缓存图片回调
- (void)preRenderedImageWithUrl:(NSString *)url withBlock:(void(^)(UIImage *))withBlock{
    if (url == nil || url.length == 0) {
        withBlock ? withBlock(nil) : nil;
        return;
    }
    dispatch_barrier_async(self.synchronizationQueue, ^{
        NSString * key = kBannerMD5String(url);
        UIImage * cacheImage = self.imageDict[key];
        if (cacheImage) {
            withBlock ? withBlock(cacheImage) : nil;
            return;
        }
        __banner_weakself;
        if (!kBannerImageURLStringLocality(url)) {
#if __has_include("KJBannerViewDownloader.h")
            KJNetworkDownloader * __autoreleasing downloader = [[KJNetworkDownloader alloc] init];
            [downloader kj_startDownloadImageWithURL:[NSURL URLWithString:url] progress:nil
                                            complete:^(NSData * data, NSError * error) {
                if (error == nil && data && data.length) {
                    if (kBannerImageContentType(data) == KJBannerImageTypeGif) {
                        __banner_strongself;
                        kBannerAsyncPlayGIFImage(data, ^(UIImage * _Nonnull image) {
                            [strongself saveImage:image key:key isGIF:YES];
                            withBlock ? withBlock(image) : nil;
                        });
                    } else {
                        UIImage * image = [UIImage imageWithData:data];
                        if (image) {
                            [weakself saveImage:image key:key isGIF:NO];
                            withBlock ? withBlock(image) : nil;
                        }
                    }
                }
            }];
#endif
        } else {
            NSData * data = kBannerLocalityGIFData(url);
            if (data && data.length) {
                kBannerAsyncPlayGIFImage(data, ^(UIImage * _Nonnull image) {
                    [weakself saveImage:image key:key isGIF:YES];
                    withBlock ? withBlock(image) : nil;
                });
            } else {
                UIImage * image = [UIImage imageNamed:url];
                [self saveImage:image key:key isGIF:NO];
                withBlock ? withBlock(image) : nil;
            }
        }
    });
}

/// 读取缓存区图片资源
/// @param url 图片地址
- (nullable UIImage *)readCacheImageWithUrl:(NSString *)url{
    if (url == nil || url.length == 0) {
        return nil;
    }
    __block UIImage * cacheImage = nil;
    dispatch_sync(self.synchronizationQueue, ^{
        cacheImage = self.imageDict[kBannerMD5String(url)];
    });
    return cacheImage;
}

/// 清除缓存区图片资源
- (void)clearCacheImages{
    @synchronized (self.imageDict) {
        [self.imageDict removeAllObjects];
    }
}

#pragma mark - private method

/// 存储图片资源至缓存区
- (void)saveImage:(nullable UIImage *)image key:(NSString *)key isGIF:(BOOL)GIF{
    if (image == nil) return;
    if (GIF == NO) {
        UIGraphicsBeginImageContextWithOptions(image.size, YES, 0);
        [image drawInRect:(CGRect){CGPointZero, image.size}];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    [self.imageDict setValue:image forKey:key];
}

@end

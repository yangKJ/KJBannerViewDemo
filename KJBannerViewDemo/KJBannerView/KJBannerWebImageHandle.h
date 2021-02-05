//
//  KJBannerWebImageHandle.h
//  KJBannerViewDemo
//
//  Created by 杨科军 on 2021/1/26.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "KJBannerViewType.h"
#import "KJBannerViewDownloader.h"
#import "KJBannerViewCacheManager.h"
NS_ASSUME_NONNULL_BEGIN
@protocol KJBannerWebImageHandle <NSObject>
@optional;
#pragma mark - common
/// 占位图
@property(nonatomic,strong)UIImage *placeholder;
/// 图片下载完成回调
@property(nonatomic,copy,readwrite)KJWebImageCompleted completed;
/// 下载进度回调
@property(nonatomic,copy,readwrite)KJLoadProgressBlock progress;
/// 是否缓存数据至本地，默认开启
@property(nonatomic,assign)bool cacheDatas;
/// 是否等比裁剪图片，默认关闭
@property(nonatomic,assign)bool cropScale;
/// 获取原始图回调，裁剪开启才有效果
@property(nonatomic,copy,readwrite)void(^kCropScaleImage)(UIImage * originalImgae, UIImage * scaleImage);

#pragma mark - button
/// 按钮状态
@property(nonatomic,assign)UIControlState buttonState;

#pragma mark - view
/// 图片填充方式
@property(nonatomic,copy)CALayerContentsGravity viewContentsGravity;

@end

//************ 公共方法 *************
/// 播放图片
NS_INLINE UIImage * kBannerPlayImage(NSData * data, CGSize size, id<KJBannerWebImageHandle> _Nullable han){
    if (data == nil) return nil;
    CGImageSourceRef imageSource = CGImageSourceCreateWithData(CFBridgingRetain(data), nil);
    size_t imageCount = CGImageSourceGetCount(imageSource);
    UIImage *animatedImage;
    if (imageCount <= 1) {
        animatedImage = [[UIImage alloc] initWithData:data];
        if (han.cropScale) {
            UIImage * scaleImage = kBannerCropImage(animatedImage, size);
            animatedImage = scaleImage;
            if (han.kCropScaleImage) han.kCropScaleImage(animatedImage, scaleImage);
        }
    }else{
        NSMutableArray *scaleImages = [NSMutableArray arrayWithCapacity:imageCount];
        NSMutableArray *originalImages = [NSMutableArray arrayWithCapacity:imageCount];
        NSTimeInterval time = 0;
        for (int i = 0; i<imageCount; i++) {
            CGImageRef cgImage = CGImageSourceCreateImageAtIndex(imageSource, i, nil);
            UIImage *originalImage = [UIImage imageWithCGImage:cgImage];
            if (han.cropScale) {
                UIImage * scaleImage = kBannerCropImage(originalImage, size);
                originalImage = scaleImage;
                if (han.kCropScaleImage) [originalImages addObject:originalImage];
            }
            [scaleImages addObject:originalImage];
            CGImageRelease(cgImage);
            CFDictionaryRef const properties = CGImageSourceCopyPropertiesAtIndex(imageSource, i, NULL);
            CFDictionaryRef const gifProperties = CFDictionaryGetValue(properties, kCGImagePropertyGIFDictionary);
            NSNumber *duration = (__bridge id)CFDictionaryGetValue(gifProperties, kCGImagePropertyGIFUnclampedDelayTime);
            if (duration == NULL || [duration doubleValue] == 0) {
                duration = (__bridge id)CFDictionaryGetValue(gifProperties, kCGImagePropertyGIFDelayTime);
            }
            CFRelease(properties);
            CFRelease(gifProperties);
            time += duration.doubleValue;
        }
        animatedImage = [UIImage animatedImageWithImages:scaleImages duration:time];
        if (han.cropScale && han.kCropScaleImage) {
            UIImage *originalImage = [UIImage animatedImageWithImages:originalImages duration:time];
            han.kCropScaleImage(originalImage, animatedImage);
        }
    }
    CFRelease(imageSource);
    return animatedImage;
}
/// 异步播放动态图
NS_INLINE void kBannerAsyncPlayImage(void(^xxblock)(UIImage * _Nullable image), NSData * data){
    if (xxblock) {
        if (data == nil) xxblock(nil);
        kGCD_banner_async(^{
            CGImageSourceRef imageSource = CGImageSourceCreateWithData(CFBridgingRetain(data), nil);
            size_t imageCount = CGImageSourceGetCount(imageSource);
            if (imageCount <= 1) {
                kGCD_banner_main(^{xxblock([[UIImage alloc] initWithData:data]);});
            }else{
                NSMutableArray *scaleImages = [NSMutableArray arrayWithCapacity:imageCount];
                NSTimeInterval time = 0;
                for (int i = 0; i<imageCount; i++) {
                    CGImageRef cgImage = CGImageSourceCreateImageAtIndex(imageSource, i, nil);
                    UIImage *originalImage = [UIImage imageWithCGImage:cgImage];
                    [scaleImages addObject:originalImage];
                    CGImageRelease(cgImage);
                    CFDictionaryRef const properties = CGImageSourceCopyPropertiesAtIndex(imageSource, i, NULL);
                    CFDictionaryRef const gifProperties = CFDictionaryGetValue(properties, kCGImagePropertyGIFDictionary);
                    NSNumber *duration = (__bridge id)CFDictionaryGetValue(gifProperties, kCGImagePropertyGIFUnclampedDelayTime);
                    if (duration == NULL || [duration doubleValue] == 0) {
                        duration = (__bridge id)CFDictionaryGetValue(gifProperties, kCGImagePropertyGIFDelayTime);
                    }
                    CFRelease(properties);
                    CFRelease(gifProperties);
                    time += duration.doubleValue;
                }
                kGCD_banner_main(^{xxblock([UIImage animatedImageWithImages:scaleImages duration:time]);});
            }
            CFRelease(imageSource);
        });
    }
}
/// 获取图片
NS_INLINE UIImage * kBannerWebImageSetImage(NSData * data, CGSize size, id<KJBannerWebImageHandle> han){
    UIImage *image = kBannerPlayImage(data, size, han);
    kGCD_banner_main(^{
        if (han.completed) {
            han.completed(kBannerContentType(data), image, data, nil);
        }
    });
    return image;
}
/// 下载图片
NS_INLINE void kBannerWebImageDownloader(NSURL * url, CGSize size, id<KJBannerWebImageHandle> han, void(^imageblock)(UIImage *image)){
    void (^kDownloaderAnalysis)(NSData *__data) = ^(NSData *__data){
        if (__data == nil) return;
        if (imageblock) {
            imageblock(kBannerWebImageSetImage(__data, size, han));
        }
        if (han.cacheDatas) {
            [KJBannerViewCacheManager kj_storeGIFData:__data Key:url.absoluteString];
        }
    };
    KJBannerViewDownloader *downloader = [KJBannerViewDownloader new];
    if (han.progress) {
        [downloader kj_startDownloadImageWithURL:url Progress:^(KJBannerDownloadProgress * downloadProgress) {
            han.progress(downloadProgress);
        } Complete:^(NSData * _Nullable data, NSError * _Nullable error) {
            if (error) {
                if (han.completed) han.completed(KJBannerImageTypeUnknown, nil, nil, error);
            }else{
                kDownloaderAnalysis(data);
            }
        }];
    }else{
        [downloader kj_startDownloadImageWithURL:url Progress:nil Complete:^(NSData * data, NSError * error) {
            if (error) {
                if (han.completed) han.completed(KJBannerImageTypeUnknown, nil, nil, error);
            }else{
                kDownloaderAnalysis(data);
            }
        }];
    }
}

/// 公共关联区域
#define banner_common_method \
- (UIImage *)placeholder{\
    return objc_getAssociatedObject(self, _cmd);\
}\
- (void)setPlaceholder:(UIImage *)placeholder{\
    objc_setAssociatedObject(self, @selector(placeholder), placeholder, OBJC_ASSOCIATION_RETAIN_NONATOMIC);\
}\
- (KJWebImageCompleted)completed{\
    return objc_getAssociatedObject(self, _cmd);\
}\
- (void)setCompleted:(KJWebImageCompleted)completed{\
    objc_setAssociatedObject(self, @selector(completed), completed, OBJC_ASSOCIATION_RETAIN_NONATOMIC);\
}\
- (KJLoadProgressBlock)progress{\
    return objc_getAssociatedObject(self, _cmd);\
}\
- (void)setProgress:(KJLoadProgressBlock)progress{\
    objc_setAssociatedObject(self, @selector(progress), progress, OBJC_ASSOCIATION_RETAIN_NONATOMIC);\
}\
- (bool)cacheDatas{\
    return [objc_getAssociatedObject(self, _cmd) intValue];\
}\
- (void)setCacheDatas:(bool)cacheDatas{\
    objc_setAssociatedObject(self, @selector(cacheDatas), @(cacheDatas), OBJC_ASSOCIATION_ASSIGN);\
}\
- (bool)cropScale{\
    return [objc_getAssociatedObject(self, _cmd) intValue];\
}\
- (void)setCropScale:(bool)cropScale{\
    objc_setAssociatedObject(self, @selector(cropScale), @(cropScale), OBJC_ASSOCIATION_ASSIGN);\
}\
- (void (^)(UIImage *, UIImage *))kCropScaleImage{\
    return objc_getAssociatedObject(self, _cmd);\
}\
- (void)setKCropScaleImage:(void (^)(UIImage *, UIImage *))kCropScaleImage{\
    objc_setAssociatedObject(self, @selector(kCropScaleImage), kCropScaleImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);\
}\


NS_ASSUME_NONNULL_END

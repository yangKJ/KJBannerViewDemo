//
//  UIView+KJWebImage.m
//  KJBannerViewDemo
//
//  Created by 杨科军 on 2021/1/28.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo

#import "UIView+KJWebImage.h"
#import <objc/runtime.h>
#import "KJBannerViewCacheManager.h"
#import "KJBannerViewFunc.h"

@interface UIView()<KJBannerWebImageHandle>

@end

@implementation UIView (KJWebImage)

- (void)kj_setImageWithURL:(NSURL *)url handle:(void(^)(id<KJBannerWebImageHandle>))handle{
    if (url == nil) return;
    self.bannerCacheDatas = true;
    self.bannerPreRendering = true;
    if (handle) handle(self);
    id<KJBannerWebImageHandle> han = (id<KJBannerWebImageHandle>)self;
    if ([self isKindOfClass:[UIImageView class]]) {
        [self kj_setImageViewImageWithURL:url handle:han];
    } else if ([self isKindOfClass:[UIButton class]]) {
        [self kj_setButtonImageWithURL:url handle:han];
    } else if ([self isKindOfClass:[UIView class]]) {
        [self kj_setViewImageContentsWithURL:url handle:han];
    }
}

#pragma mark - UIImageView

- (void)kj_setImageViewImageWithURL:(NSURL *)url handle:(id<KJBannerWebImageHandle>)han{
    UIImageView *imageView = (UIImageView *)self;
    CGSize size = imageView.frame.size;
    if (han.bannerPlaceholder) imageView.image = han.bannerPlaceholder;
    kGCD_banner_async(^{
        NSData *data = [KJBannerViewCacheManager kj_getGIFImageWithKey:url.absoluteString];
        if (data) {
            kBannerWebImageSetImage(^(UIImage *image) {
                imageView.image = image;
            }, data, size, han);
        } else {
            kBannerWebImageDownloader(url, size, han, ^(UIImage * _Nonnull image) {
                kGCD_banner_main(^{ imageView.image = image;});
            });
        }
    });
}

#pragma mark - UIButton

- (UIControlState)bannerButtonState{
    return (UIControlState)[objc_getAssociatedObject(self, _cmd) intValue];
}
- (void)setBannerButtonState:(UIControlState)bannerButtonState{
    objc_setAssociatedObject(self, @selector(bannerButtonState), @(bannerButtonState), OBJC_ASSOCIATION_ASSIGN);
}
- (void)kj_setButtonImageWithURL:(NSURL *)url handle:(id<KJBannerWebImageHandle>)han{
    UIButton *button = (UIButton *)self;
    CGSize size = button.imageView.frame.size;
    if (han.bannerPlaceholder) [button setImage:han.bannerPlaceholder forState:han.bannerButtonState];
    kGCD_banner_async(^{
        NSData *data = [KJBannerViewCacheManager kj_getGIFImageWithKey:url.absoluteString];
        if (data) {
            kBannerWebImageSetImage(^(UIImage *image) {
                [button setImage:image forState:han.bannerButtonState?:UIControlStateNormal];
            }, data, size, han);
        } else {
            kBannerWebImageDownloader(url, size, han, ^(UIImage * _Nonnull image) {
                kGCD_banner_main(^{
                    [button setImage:image forState:han.bannerButtonState?:UIControlStateNormal];
                });
            });
        }
    });
}

#pragma mark - UIView

- (CALayerContentsGravity)bannerViewContentsGravity{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setBannerViewContentsGravity:(CALayerContentsGravity)bannerViewContentsGravity{
    objc_setAssociatedObject(self, @selector(bannerViewContentsGravity), bannerViewContentsGravity, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (void)kj_setViewImageContentsWithURL:(NSURL *)url handle:(id<KJBannerWebImageHandle>)han{
    __weak __typeof(self) weakself = self;
    CGSize size = self.frame.size;
    kGCD_banner_async(^{
        NSData *data = [KJBannerViewCacheManager kj_getGIFImageWithKey:url.absoluteString];
        if (data) {
            kBannerWebImageSetImage(^(UIImage *image) {
                CALayer *layer = [weakself kj_setLayerImageContents:image?:han.bannerPlaceholder];
                layer.contentsGravity = han.bannerViewContentsGravity?:kCAGravityResize;
            }, data, size, han);
        } else {
            kBannerWebImageDownloader(url, size, han, ^(UIImage * _Nonnull image) {
                kGCD_banner_main(^{
                    CALayer *layer = [weakself kj_setLayerImageContents:image?:han.bannerPlaceholder];
                    layer.contentsGravity = han.bannerViewContentsGravity?:kCAGravityResize;
                });
            });
        }
    });
}
/// 设置Layer上面的内容，默认充满的填充方式
- (CALayer*)kj_setLayerImageContents:(UIImage *)image{
    CALayer * imageLayer = [CALayer layer];
    imageLayer.bounds = self.bounds;
    imageLayer.position = CGPointMake(self.bounds.size.width*.5, self.bounds.size.height*.5);
    imageLayer.contents = (id)image.CGImage;
    [self.layer addSublayer:imageLayer];
    return imageLayer;
}

#pragma mark - function

/// 播放图片
/// @param data 数据源
/// @param size 尺寸
/// @param han 参数
NS_INLINE UIImage * kBannerPlayImage(NSData * data, CGSize size, id<KJBannerWebImageHandle> han){
    if (data == nil || data.length == 0) return nil;
    CGImageSourceRef imageSource = CGImageSourceCreateWithData(CFBridgingRetain(data), nil);
    size_t imageCount = CGImageSourceGetCount(imageSource);
    UIImage *animatedImage;
    if (imageCount == 1) {
        animatedImage = [[UIImage alloc] initWithData:data];
        if (han.bannerCropScale) {
            UIImage * scaleImage = kBannerEqualRatioCropImage(animatedImage, size);
            animatedImage = scaleImage;
            if (han.kBannerCropScaleImage) han.kBannerCropScaleImage(animatedImage, scaleImage);
        }
    } else {
        NSMutableArray *scaleImages = [NSMutableArray arrayWithCapacity:imageCount];
        NSMutableArray *originalImages = [NSMutableArray arrayWithCapacity:imageCount];
        NSTimeInterval time = 0;
        for (int i = 0; i < imageCount; i++) {
            CGImageRef cgImage = CGImageSourceCreateImageAtIndex(imageSource, i, nil);
            UIImage *originalImage = [UIImage imageWithCGImage:cgImage];
            if (han.bannerCropScale) {
                UIImage * scaleImage = kBannerEqualRatioCropImage(originalImage, size);
                originalImage = scaleImage;
                if (han.kBannerCropScaleImage) [originalImages addObject:originalImage];
            }
            [scaleImages addObject:originalImage];
            CGImageRelease(cgImage);
            CFDictionaryRef const properties = CGImageSourceCopyPropertiesAtIndex(imageSource, i, NULL);
            CFDictionaryRef const GIFPros = CFDictionaryGetValue(properties, kCGImagePropertyGIFDictionary);
            NSNumber *duration = (__bridge id)CFDictionaryGetValue(GIFPros, kCGImagePropertyGIFUnclampedDelayTime);
            if (duration == NULL || [duration doubleValue] == 0) {
                duration = (__bridge id)CFDictionaryGetValue(GIFPros, kCGImagePropertyGIFDelayTime);
            }
            CFRelease(properties);
            time += duration.doubleValue;
        }
        animatedImage = [UIImage animatedImageWithImages:scaleImages duration:time];
        if (han.bannerCropScale && han.kBannerCropScaleImage) {
            UIImage *originalImage = [UIImage animatedImageWithImages:originalImages duration:time];
            han.kBannerCropScaleImage(originalImage, animatedImage);
        }
    }
    CFRelease(imageSource);
    return animatedImage;
}
/// 获取图片
NS_INLINE void kBannerWebImageSetImage(void(^imageblock)(UIImage * image),
                                       NSData * data, CGSize size,
                                       id<KJBannerWebImageHandle> han){
    kGCD_banner_async(^{
        UIImage *image = kBannerPlayImage(data, size, han);
        KJBannerImageType type = kBannerImageContentType(data);
        if (han.bannerPreRendering && type != KJBannerImageTypeGif) {
            UIGraphicsBeginImageContextWithOptions(image.size, YES, 0);
            [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        kGCD_banner_main(^{
            imageblock ? imageblock(image) : nil;
            if (han.bannerCompleted) {
                han.bannerCompleted(type, image, data, nil);
            }
        });
    });
}
/// 下载图片
NS_INLINE void kBannerWebImageDownloader(NSURL * url, CGSize size,
                                         id<KJBannerWebImageHandle> han,
                                         void(^imageblock)(UIImage *image)){
    void (^kDownloaderAnalysis)(NSData *) = ^(NSData * __data){
        if (__data == nil) return;
        kBannerWebImageSetImage(imageblock, __data, size, han);
        if (han.bannerCacheDatas) {
            [KJBannerViewCacheManager kj_storeGIFData:__data Key:url.absoluteString];
        }
    };
    KJBannerViewDownloader *downloader = [[KJBannerViewDownloader alloc] init];
    if (han.bannerProgress) {
        [downloader kj_startDownloadImageWithURL:url progress:^(KJBannerDownloadProgress * __progress) {
            han.bannerProgress(__progress);
        } complete:^(NSData * _Nullable data, NSError * _Nullable error) {
            if (error) {
                if (han.bannerCompleted) {
                    han.bannerCompleted(KJBannerImageTypeUnknown, nil, nil, error);
                }
            } else {
                kDownloaderAnalysis(data);
            }
        }];
    } else {
        [downloader kj_startDownloadImageWithURL:url progress:nil complete:^(NSData * data, NSError * error) {
            if (error) {
                if (han.bannerCompleted) {
                    han.bannerCompleted(KJBannerImageTypeUnknown, nil, nil, error);
                }
            } else {
                kDownloaderAnalysis(data);
            }
        }];
    }
}

#pragma maek - Associated

- (UIImage *)bannerPlaceholder{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setBannerPlaceholder:(UIImage *)bannerPlaceholder{
    objc_setAssociatedObject(self, @selector(bannerPlaceholder), bannerPlaceholder, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (KJWebImageCompleted)bannerCompleted{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setBannerCompleted:(KJWebImageCompleted)bannerCompleted{
    objc_setAssociatedObject(self, @selector(bannerCompleted), bannerCompleted, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (KJLoadProgressBlock)bannerProgress{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setBannerProgress:(KJLoadProgressBlock)bannerProgress{
    objc_setAssociatedObject(self, @selector(bannerProgress), bannerProgress, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (void (^)(UIImage *, UIImage *))kBannerCropScaleImage{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setKBannerCropScaleImage:(void (^)(UIImage *, UIImage *))kBannerCropScaleImage{
    objc_setAssociatedObject(self, @selector(kBannerCropScaleImage), kBannerCropScaleImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (bool)bannerCacheDatas{
    return [objc_getAssociatedObject(self, _cmd) intValue];
}
- (void)setBannerCacheDatas:(bool)bannerCacheDatas{
    objc_setAssociatedObject(self, @selector(bannerCacheDatas), @(bannerCacheDatas), OBJC_ASSOCIATION_ASSIGN);
}
- (bool)bannerCropScale{
    return [objc_getAssociatedObject(self, _cmd) intValue];
}
- (void)setBannerCropScale:(bool)bannerCropScale{
    objc_setAssociatedObject(self, @selector(bannerCropScale), @(bannerCropScale), OBJC_ASSOCIATION_ASSIGN);
}
- (bool)bannerPreRendering{
    return [objc_getAssociatedObject(self, _cmd) intValue];
}
- (void)setBannerPreRendering:(bool)bannerPreRendering{
    objc_setAssociatedObject(self, @selector(bannerPreRendering), @(bannerPreRendering), OBJC_ASSOCIATION_ASSIGN);
}

@end

//
//  UIView+KJWebImage.m
//  KJBannerViewDemo
//
//  Created by 杨科军 on 2021/1/28.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo

#import "UIView+KJWebImage.h"

@interface UIView()<KJBannerWebImageHandle>

@end

@implementation UIView (KJWebImage)

- (void)kj_setImageWithURL:(NSURL *)url handle:(void(^)(id<KJBannerWebImageHandle>handle))handle{
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
    UIButton *button = (UIButton*)self;
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
    __banner_weakself;
    CGSize size = weakself.frame.size;
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

/// 预渲染图片
/// @param data 数据源
/// @param size 尺寸
/// @param han 参数
NS_INLINE void kBannerPreRendering(void(^imageblock)(UIImage *image), NSData * data, CGSize size, id<KJBannerWebImageHandle> _Nullable han){
    kGCD_banner_async(^{
        CGImageRef cgImage = [UIImage imageWithData:data].CGImage;
        CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(cgImage) & kCGBitmapAlphaInfoMask;
        
        BOOL hasAlpha = NO;
        if (alphaInfo == kCGImageAlphaPremultipliedLast ||
            alphaInfo == kCGImageAlphaPremultipliedFirst ||
            alphaInfo == kCGImageAlphaLast ||
            alphaInfo == kCGImageAlphaFirst) {
            hasAlpha = YES;
        }
        
        CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Host;
        bitmapInfo |= hasAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst;
        
        size_t width  = han.bannerCropScale ? size.width : CGImageGetWidth(cgImage);
        size_t height = han.bannerCropScale ? size.height : CGImageGetHeight(cgImage);
        
        CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 0, CGColorSpaceCreateDeviceRGB(), bitmapInfo);
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), cgImage);
        cgImage = CGBitmapContextCreateImage(context);
        
        UIImage * image = [UIImage imageWithCGImage:cgImage];
        CGContextRelease(context);
        CGImageRelease(cgImage);
        
        imageblock(image);
    });
}

/// 播放图片
/// @param data 数据源
/// @param size 尺寸
/// @param han 参数
NS_INLINE UIImage * kBannerPlayImage(NSData * data, CGSize size, id<KJBannerWebImageHandle> _Nullable han){
    if (data == nil || data.length == 0) return nil;
    CGImageSourceRef imageSource = CGImageSourceCreateWithData(CFBridgingRetain(data), nil);
    size_t imageCount = CGImageSourceGetCount(imageSource);
    UIImage *animatedImage;
    if (imageCount == 1) {
        animatedImage = [[UIImage alloc] initWithData:data];
        if (han.bannerCropScale) {
            UIImage * scaleImage = kBannerCropImage(animatedImage, size);
            animatedImage = scaleImage;
            if (han.kBannerCropScaleImage) han.kBannerCropScaleImage(animatedImage, scaleImage);
        }
    } else {
        NSMutableArray *scaleImages = [NSMutableArray arrayWithCapacity:imageCount];
        NSMutableArray *originalImages = [NSMutableArray arrayWithCapacity:imageCount];
        NSTimeInterval time = 0;
        for (int i = 0; i<imageCount; i++) {
            CGImageRef cgImage = CGImageSourceCreateImageAtIndex(imageSource, i, nil);
            UIImage *originalImage = [UIImage imageWithCGImage:cgImage];
            if (han.bannerCropScale) {
                UIImage * scaleImage = kBannerCropImage(originalImage, size);
                originalImage = scaleImage;
                if (han.kBannerCropScaleImage) [originalImages addObject:originalImage];
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
NS_INLINE void kBannerWebImageSetImage(void(^imageblock)(UIImage *image), NSData * data, CGSize size, id<KJBannerWebImageHandle> han){
    kGCD_banner_async(^{
        UIImage *image = kBannerPlayImage(data, size, han);
        KJBannerImageType type = kBannerContentType(data);
        if (han.bannerPreRendering && type != KJBannerImageTypeGif) {
            UIGraphicsBeginImageContextWithOptions(image.size, YES, 0);
            [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        kGCD_banner_main(^{
            if (imageblock) {
                imageblock(image);
            }
            if (han.bannerCompleted) {
                han.bannerCompleted(type, image, data, nil);
            }
        });
    });
}
/// 下载图片
NS_INLINE void kBannerWebImageDownloader(NSURL * url, CGSize size, id<KJBannerWebImageHandle> han, void(^imageblock)(UIImage *image)){
    void (^kDownloaderAnalysis)(NSData *__data) = ^(NSData *__data){
        if (__data == nil) return;
        kBannerWebImageSetImage(imageblock, __data, size, han);
        if (han.bannerCacheDatas) {
            [KJBannerViewCacheManager kj_storeGIFData:__data Key:url.absoluteString];
        }
    };
    KJBannerViewDownloader *downloader = [KJBannerViewDownloader new];
    if (han.bannerProgress) {
        [downloader kj_startDownloadImageWithURL:url progress:^(KJBannerDownloadProgress * downloadProgress) {
            han.bannerProgress(downloadProgress);
        } complete:^(NSData * _Nullable data, NSError * _Nullable error) {
            if (error) {
                if (han.bannerCompleted) han.bannerCompleted(KJBannerImageTypeUnknown, nil, nil, error);
            } else {
                kDownloaderAnalysis(data);
            }
        }];
    } else {
        [downloader kj_startDownloadImageWithURL:url progress:nil complete:^(NSData * data, NSError * error) {
            if (error) {
                if (han.bannerCompleted) han.bannerCompleted(KJBannerImageTypeUnknown, nil, nil, error);
            } else {
                kDownloaderAnalysis(data);
            }
        }];
    }
}
/// 根据DATA判断图片类型
NS_INLINE KJBannerImageType kBannerContentType(NSData * _Nonnull data){
    uint8_t c;
    [data getBytes:&c length:1];
    switch (c) {
        case 0xFF:
            return KJBannerImageTypeJpeg;
        case 0x89:
            return KJBannerImageTypePng;
        case 0x47:
            return KJBannerImageTypeGif;
        case 0x49:
        case 0x4D:
            return KJBannerImageTypeTiff;
        case 0x52:
            if ([data length] < 12) return KJBannerImageTypeUnknown;
            NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, 12)]
                                                         encoding:NSASCIIStringEncoding];
            if ([testString hasPrefix:@"RIFF"] && [testString hasSuffix:@"WEBP"]) return KJBannerImageTypeWebp;
            return KJBannerImageTypeUnknown;
    }
    return KJBannerImageTypeUnknown;
}
/// 等比改变图片尺寸
NS_INLINE UIImage * _Nullable kBannerCropImage(UIImage * _Nonnull image, CGSize size){
    CGFloat scale = UIScreen.mainScreen.scale;
    float imgHeight = image.size.height;
    float imgWidth  = image.size.width;
    float maxHeight = size.width * scale;
    float maxWidth = size.height * scale;
    if (imgHeight <= maxHeight && imgWidth <= maxWidth) return image;
    float imgRatio = imgWidth/imgHeight;
    float maxRatio = maxWidth/maxHeight;
    if (imgHeight > maxHeight || imgWidth > maxWidth) {
        if (imgRatio < maxRatio) {
            imgRatio = maxHeight / imgHeight;
            imgWidth = imgRatio * imgWidth;
            imgHeight = maxHeight;
        } else if (imgRatio > maxRatio) {
            imgRatio = maxWidth / imgWidth;
            imgWidth = maxWidth;
            imgHeight = imgRatio * imgHeight;
        } else {
            imgWidth = maxWidth;
            imgHeight = maxHeight;
        }
    }
    CGRect rect = CGRectMake(0.0, 0.0, imgWidth, imgHeight);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
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

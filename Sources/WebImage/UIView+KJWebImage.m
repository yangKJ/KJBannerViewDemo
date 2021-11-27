//
//  UIView+KJWebImage.m
//  KJBannerViewDemo
//
//  Created by 杨科军 on 2021/1/28.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo

#import "UIView+KJWebImage.h"
#import <objc/runtime.h>
#import "KJImageCache.h"

@interface UIView () <KJWebImageDelegate>

@end

@implementation UIView (KJWebImage)

- (void)kj_setImageWithURL:(NSURL *)url provider:(KJWebImageProvider)provider{
    if (url == nil) return;
    self.webCacheDatas = true;
    self.webPreRendering = true;
    if (provider) provider(self);
    if ([self isKindOfClass:[UIImageView class]]) {
        [self kj_setImageViewImageWithURL:url provider:(id<KJWebImageDelegate>)self];
    } else if ([self isKindOfClass:[UIButton class]]) {
        [self kj_setButtonImageWithURL:url provider:(id<KJWebImageDelegate>)self];
    } else if ([self isKindOfClass:[UIView class]]) {
        [self kj_setViewImageContentsWithURL:url provider:(id<KJWebImageDelegate>)self];
    }
}

#pragma mark - UIImageView

- (void)kj_setImageViewImageWithURL:(NSURL *)url provider:(id<KJWebImageDelegate>)provider{
    UIImageView *imageView = (UIImageView *)self;
    CGSize size = imageView.frame.size;
    if (provider.webPlaceholder) imageView.image = provider.webPlaceholder;
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        NSData *data = [KJImageCache readGIFImageWithKey:url.absoluteString];
        if (data) {
            kBannerWebImageSetImage(^(UIImage *image) {
                imageView.image = image;
            }, data, size, provider);
        } else {
            kBannerWebImageDownloader(url, size, provider, ^(UIImage * _Nonnull image) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    imageView.image = image;
                }];
            });
        }
    }];
}

#pragma mark - UIButton

- (UIControlState)webButtonState{
    return (UIControlState)[objc_getAssociatedObject(self, _cmd) intValue];
}
- (void)setWebButtonState:(UIControlState)webButtonState{
    objc_setAssociatedObject(self, @selector(webButtonState), @(webButtonState), OBJC_ASSOCIATION_ASSIGN);
}
- (void)kj_setButtonImageWithURL:(NSURL *)url provider:(id<KJWebImageDelegate>)provider{
    UIButton *button = (UIButton *)self;
    CGSize size = button.imageView.frame.size;
    if (provider.webPlaceholder) {
        [button setImage:provider.webPlaceholder forState:provider.webButtonState];
    }
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        NSData *data = [KJImageCache readGIFImageWithKey:url.absoluteString];
        if (data) {
            kBannerWebImageSetImage(^(UIImage *image) {
                [button setImage:image forState:provider.webButtonState?:UIControlStateNormal];
            }, data, size, provider);
        } else {
            kBannerWebImageDownloader(url, size, provider, ^(UIImage * _Nonnull image) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [button setImage:image forState:provider.webButtonState?:UIControlStateNormal];
                }];
            });
        }
    }];
}

#pragma mark - UIView

- (CALayerContentsGravity)webContentsGravity{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setWebContentsGravity:(CALayerContentsGravity)webContentsGravity{
    objc_setAssociatedObject(self, @selector(webContentsGravity), webContentsGravity, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (void)kj_setViewImageContentsWithURL:(NSURL *)url provider:(id<KJWebImageDelegate>)provider{
    __weak __typeof(self) weakself = self;
    CGSize size = self.frame.size;
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        NSData *data = [KJImageCache readGIFImageWithKey:url.absoluteString];
        if (data) {
            kBannerWebImageSetImage(^(UIImage *image) {
                CALayer *layer = [weakself kj_setLayerImageContents:image?:provider.webPlaceholder];
                layer.contentsGravity = provider.webContentsGravity?:kCAGravityResize;
            }, data, size, provider);
        } else {
            kBannerWebImageDownloader(url, size, provider, ^(UIImage * _Nonnull image) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    CALayer *layer = [weakself kj_setLayerImageContents:image?:provider.webPlaceholder];
                    layer.contentsGravity = provider.webContentsGravity?:kCAGravityResize;
                }];
            });
        }
    }];
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
/// @param provider 参数
NS_INLINE UIImage * kBannerPlayImage(NSData * data, CGSize size, id<KJWebImageDelegate> provider){
    if (data == nil || data.length == 0) return nil;
    CGImageSourceRef imageSource = CGImageSourceCreateWithData(CFBridgingRetain(data), nil);
    size_t imageCount = CGImageSourceGetCount(imageSource);
    UIImage *animatedImage;
    if (imageCount == 1) {
        animatedImage = [[UIImage alloc] initWithData:data];
        if (provider.webCropScale) {
            UIImage * scaleImage = kBannerEqualRatioCropImage(animatedImage, size);
            animatedImage = scaleImage;
            if (provider.webScaleImageBlock) {
                provider.webScaleImageBlock(animatedImage, scaleImage);
            }
        }
    } else {
        NSMutableArray *scaleImages = [NSMutableArray arrayWithCapacity:imageCount];
        NSMutableArray *originalImages = [NSMutableArray arrayWithCapacity:imageCount];
        NSTimeInterval time = 0;
        for (int i = 0; i < imageCount; i++) {
            CGImageRef cgImage = CGImageSourceCreateImageAtIndex(imageSource, i, nil);
            UIImage *originalImage = [UIImage imageWithCGImage:cgImage];
            if (provider.webCropScale) {
                UIImage * scaleImage = kBannerEqualRatioCropImage(originalImage, size);
                originalImage = scaleImage;
                if (provider.webScaleImageBlock) [originalImages addObject:originalImage];
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
        if (provider.webCropScale && provider.webScaleImageBlock) {
            UIImage *originalImage = [UIImage animatedImageWithImages:originalImages duration:time];
            provider.webScaleImageBlock(originalImage, animatedImage);
        }
    }
    CFRelease(imageSource);
    return animatedImage;
}
/// 获取图片
NS_INLINE void kBannerWebImageSetImage(void(^imageblock)(UIImage * image),
                                       NSData * data, CGSize size,
                                       id<KJWebImageDelegate> provider){
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        UIImage *image = kBannerPlayImage(data, size, provider);
        KJWebImageType type = kBannerImageContentType(data);
        if (provider.webPreRendering && type != KJWebImageTypeGIF) {
            UIGraphicsBeginImageContextWithOptions(image.size, YES, 0);
            [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            imageblock ? imageblock(image) : nil;
            if (provider.webCompleted) {
                provider.webCompleted(type, image, data, nil);
            }
        }];
    }];
}
/// 下载图片
NS_INLINE void kBannerWebImageDownloader(NSURL * url, CGSize size,
                                         id<KJWebImageDelegate> provider,
                                         void(^imageblock)(UIImage *image)){
    void (^kDownloaderAnalysis)(NSData *) = ^(NSData * __data){
        if (__data == nil) return;
        kBannerWebImageSetImage(imageblock, __data, size, provider);
        if (provider.webCacheDatas) {
            [KJImageCache storeGIFData:__data Key:url.absoluteString];
        }
    };
    KJNetworkManager * downloader = [[KJNetworkManager alloc] init];
    if (provider.webProgressBlock) {
        [downloader kj_startDownloadImageWithURL:url progress:^(KJBannerDownloadProgress * __progress) {
            provider.webProgressBlock(__progress);
        } complete:^(NSData * _Nullable data, NSError * _Nullable error) {
            if (error) {
                if (provider.webCompleted) {
                    provider.webCompleted(KJWebImageTypeUnknown, nil, nil, error);
                }
            } else {
                kDownloaderAnalysis(data);
            }
        }];
    } else {
        [downloader kj_startDownloadImageWithURL:url progress:nil complete:^(NSData * data, NSError * error) {
            if (error) {
                if (provider.webCompleted) {
                    provider.webCompleted(KJWebImageTypeUnknown, nil, nil, error);
                }
            } else {
                kDownloaderAnalysis(data);
            }
        }];
    }
}

/// 根据DATA判断图片类型
NS_INLINE KJWebImageType kBannerImageContentType(NSData * _Nonnull data){
    uint8_t c;
    [data getBytes:&c length:1];
    switch (c) {
        case 0xFF:
            return KJWebImageTypeJpeg;
        case 0x89:
            return KJWebImageTypePng;
        case 0x47:
            return KJWebImageTypeGIF;
        case 0x49:
        case 0x4D:
            return KJWebImageTypeTiff;
        case 0x52:
            if ([data length] < 12) return KJWebImageTypeUnknown;
            NSString *string = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, 12)]
                                                     encoding:NSASCIIStringEncoding];
            if ([string hasPrefix:@"RIFF"] && [string hasSuffix:@"WEBP"]) {
                return KJWebImageTypeWebp;
            }
            return KJWebImageTypeUnknown;
    }
    return KJWebImageTypeUnknown;
}

/// 等比改变图片尺寸
NS_INLINE UIImage * _Nullable kBannerEqualRatioCropImage(UIImage * _Nonnull image, CGSize size){
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

- (UIImage *)webPlaceholder{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setWebPlaceholder:(UIImage *)webPlaceholder{
    objc_setAssociatedObject(self, @selector(webPlaceholder), webPlaceholder, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (KJWebImageCompleted)webCompleted{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setWebCompleted:(KJWebImageCompleted)webCompleted{
    objc_setAssociatedObject(self, @selector(webCompleted), webCompleted, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (KJLoadProgressBlock)webProgressBlock{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setWebProgressBlock:(KJLoadProgressBlock)webProgressBlock{
    objc_setAssociatedObject(self, @selector(webProgressBlock), webProgressBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (KJWebScaleImageBlock)webScaleImageBlock{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setWebScaleImageBlock:(KJWebScaleImageBlock)webScaleImageBlock{
    objc_setAssociatedObject(self, @selector(webScaleImageBlock), webScaleImageBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (bool)webCacheDatas{
    return [objc_getAssociatedObject(self, _cmd) intValue];
}
- (void)setWebCacheDatas:(bool)webCacheDatas{
    objc_setAssociatedObject(self, @selector(webCacheDatas), @(webCacheDatas), OBJC_ASSOCIATION_ASSIGN);
}
- (bool)webCropScale{
    return [objc_getAssociatedObject(self, _cmd) intValue];
}
- (void)setWebCropScale:(bool)webCropScale{
    objc_setAssociatedObject(self, @selector(webCropScale), @(webCropScale), OBJC_ASSOCIATION_ASSIGN);
}
- (bool)webPreRendering{
    return [objc_getAssociatedObject(self, _cmd) intValue];
}
- (void)setWebPreRendering:(bool)webPreRendering{
    objc_setAssociatedObject(self, @selector(webPreRendering), @(webPreRendering), OBJC_ASSOCIATION_ASSIGN);
}

@end

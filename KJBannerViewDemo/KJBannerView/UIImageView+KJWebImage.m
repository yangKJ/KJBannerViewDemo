//
//  UIImageView+KJWebImage.m
//  KJBannerViewDemo
//
//  Created by 杨科军 on 2021/1/22.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo

#import "UIImageView+KJWebImage.h"

@implementation UIImageView (KJWebImage)
- (void)kj_config{
    self.URLType = KJBannerImageURLTypeCommon;
    self.cacheDatas = true;
}
- (void)kj_setImageWithURL:(NSURL*)url handle:(void(^)(id<KJBannerWebImageHandle>handle))handle{
    if (url == nil) return;
    [self kj_config];
    if (handle) handle(self);
    __block id<KJBannerWebImageHandle> han = (id<KJBannerWebImageHandle>)self;
    if (han.placeholder) self.image = han.placeholder;
    __banner_weakself;
    kGCD_banner_async(^{
        NSData *data = [KJBannerViewCacheManager kj_getGIFImageWithKey:url.absoluteString];
        if (data) {
            [weakself kj_setImageDatas:data Han:han];
        }else{
            void (^kDownloaderAnalysis)(NSData *__data) = ^(NSData *__data){
                if (__data == nil) return;
                [weakself kj_setImageDatas:__data Han:han];
                if (han.cacheDatas) {
                    [KJBannerViewCacheManager kj_storeGIFData:__data Key:url.absoluteString];
                }
            };
            KJBannerViewDownloader *downloader = [KJBannerViewDownloader new];
            if (han.progress) {
                [downloader kj_startDownloadImageWithURL:url Progress:^(KJBannerDownloadProgress * downloadProgress) {
                    han.progress(downloadProgress);
                } Complete:^(NSData * data, NSError * error) {
                    if ((error || !data) && han.completed) {
                        han.completed(KJBannerImageTypeUnknown,nil,nil);
                    }else{
                        kDownloaderAnalysis(data);
                    }
                }];
            }else{
                [downloader kj_startDownloadImageWithURL:url Progress:nil Complete:^(NSData * data, NSError * error) {
                    if ((error || !data) && han.completed) {
                        han.completed(KJBannerImageTypeUnknown,nil,nil);
                    }else{
                        kDownloaderAnalysis(data);
                    }
                }];
            }
        }
    });
}
- (void)kj_setImageDatas:(NSData*)data Han:(id<KJBannerWebImageHandle>)han{
    __banner_weakself;
    kGCD_banner_main(^{
        KJBannerImageType imageType;
        if (han.URLType == KJBannerImageURLTypeMixture) {
            imageType = kBannerContentType(data);
            if (imageType == KJBannerImageTypeGif) {
                weakself.image = [UIImage kj_bannerGIFImageWithData:data];
            }else{
                [weakself kj_cropImage:[UIImage imageWithData:data] Han:han];
            }
        }else if (han.URLType == KJBannerImageURLTypeCommon) {
            [weakself kj_cropImage:[UIImage imageWithData:data] Han:han];
            imageType = kBannerContentType(data);
        }else if (han.URLType == KJBannerImageURLTypeGif) {
            weakself.image = [UIImage kj_bannerGIFImageWithData:data];
            imageType = KJBannerImageTypeGif;
        }else{
            imageType = KJBannerImageTypeUnknown;
        }
        if (han.completed) {
            han.completed(imageType,weakself.image,data);
        }
    });
}
/// 裁剪图片操作
- (void)kj_cropImage:(UIImage*)image Han:(id<KJBannerWebImageHandle>)han{
    if (han.cropScale) {
        self.image = kCropImage(image, self.frame.size);
        if (han.kCropScaleImage) {
            han.kCropScaleImage(image, self.image);
        }
    }else{
        self.image = image;
    }
}

#pragma maek - KJBannerWebImageHandle
- (UIImage *)placeholder{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setPlaceholder:(UIImage *)placeholder{
    objc_setAssociatedObject(self, @selector(placeholder), placeholder, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (KJWebImageCompleted)completed{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setCompleted:(KJWebImageCompleted)completed{
    objc_setAssociatedObject(self, @selector(completed), completed, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (KJLoadProgressBlock)progress{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setProgress:(KJLoadProgressBlock)progress{
    objc_setAssociatedObject(self, @selector(progress), progress, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (KJBannerImageURLType)URLType{
    return (KJBannerImageURLType)[objc_getAssociatedObject(self, _cmd) intValue];
}
- (void)setURLType:(KJBannerImageURLType)URLType{
    objc_setAssociatedObject(self, @selector(URLType), @(URLType), OBJC_ASSOCIATION_ASSIGN);
}
- (bool)cacheDatas{
    return [objc_getAssociatedObject(self, _cmd) intValue];
}
- (void)setCacheDatas:(bool)cacheDatas{
    objc_setAssociatedObject(self, @selector(cacheDatas), @(cacheDatas), OBJC_ASSOCIATION_ASSIGN);
}
- (bool)cropScale{
    return [objc_getAssociatedObject(self, _cmd) intValue];
}
- (void)setCropScale:(bool)cropScale{
    objc_setAssociatedObject(self, @selector(cropScale), @(cropScale), OBJC_ASSOCIATION_ASSIGN);
}
- (void (^)(UIImage *, UIImage *))kCropScaleImage{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setKCropScaleImage:(void (^)(UIImage *, UIImage *))kCropScaleImage{
    objc_setAssociatedObject(self, @selector(kCropScaleImage), kCropScaleImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

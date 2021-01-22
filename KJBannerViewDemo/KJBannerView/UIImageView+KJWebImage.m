//
//  UIImageView+KJWebImage.m
//  KJBannerViewDemo
//
//  Created by 杨科军 on 2021/1/22.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo

#import "UIImageView+KJWebImage.h"
#import "KJBannerViewCacheManager.h"
#import "UIImage+KJBannerGIF.h"
@implementation UIImageView (KJWebImage)
/// 显示网络图片，
- (void)kj_setImageWithURL:(NSURL*)url{
    [self kj_setImageWithURL:url placeholder:nil];
}
/// 显示网络图片，带占位图
- (void)kj_setImageWithURL:(NSURL*)url placeholder:(UIImage * _Nullable)placeholder{
    [self kj_setImageWithURL:url placeholder:placeholder completed:nil];
}
/// 显示网络图片，返回图片资源
- (void)kj_setImageWithURL:(NSURL*)url placeholder:(UIImage*)placeholder completed:(KJWebImageCompleted)completed{
    [self kj_setImageWithURL:url placeholder:placeholder completed:completed progress:nil];
}
/// 显示网络图片，带下载进度
- (void)kj_setImageWithURL:(NSURL*)url
               placeholder:(UIImage*)placeholder
                 completed:(KJWebImageCompleted)completed
                  progress:(KJLoadProgressBlock)progress{
    if (placeholder) self.image = placeholder;
    if (url == nil) return;
    __banner_weakself;
    kGCD_banner_async(^{
        NSData *data = [KJBannerViewCacheManager kj_getGIFImageWithKey:url.absoluteString];
        if (data) {
            KJBannerImageType imageType = kBannerContentType(data);
            kGCD_banner_main(^{
                if (imageType == KJBannerImageTypeGif) {
                    weakself.image = [UIImage kj_bannerGIFImageWithData:data];
                }else{
                    weakself.image = [UIImage imageWithData:data];
                }
                if (completed) {
                    completed(imageType,weakself.image,data);
                }
            });
        }else{
            void (^kDownloaderAnalysis)(NSData *__data) = ^(NSData *__data){
                if (__data == nil) return;
                KJBannerImageType imageType = kBannerContentType(__data);
                kGCD_banner_main(^{
                    if (imageType == KJBannerImageTypeGif) {
                        weakself.image = [UIImage kj_bannerGIFImageWithData:__data];
                    }else{
                        weakself.image = [UIImage imageWithData:__data];
                    }
                    if (completed) {
                        completed(imageType,weakself.image,__data);
                    }
                });
                [KJBannerViewCacheManager kj_storeGIFData:__data Key:url.absoluteString];
            };
            KJBannerViewDownloader *downloader = [KJBannerViewDownloader new];
            if (progress) {
                [downloader kj_startDownloadImageWithURL:url Progress:^(KJBannerDownloadProgress * _Nonnull downloadProgress) {
                    progress(downloadProgress);
                } Complete:^(NSData * _Nullable data, NSError * _Nullable error) {
                    if ((error || !data) && completed) {
                        completed(KJBannerImageTypeUnknown,nil,nil);
                    }else{
                        kDownloaderAnalysis(data);
                    }
                }];
            }else{
                [downloader kj_startDownloadImageWithURL:url Progress:nil Complete:^(NSData * _Nullable data, NSError * _Nullable error) {
                    if ((error || !data) && completed) {
                        completed(KJBannerImageTypeUnknown,nil,nil);
                    }else{
                        kDownloaderAnalysis(data);
                    }
                }];
            }
        }
    });
}
#pragma mark - 非动态图
/// 非动态图显示网络图片，裁剪图片
- (void)kj_setImageWithURL:(NSURL*)url placeholder:(UIImage*)placeholder scale:(BOOL)scale completed:(void(^)(UIImage *scaleImage, UIImage *originalImage))completed{
    if (placeholder) self.image = placeholder;
    if (url == nil) return;
}

@end

//
//  UIButton+KJWebImage.m
//  KJBannerViewDemo
//
//  Created by 杨科军 on 2021/1/22.
//  Copyright © 2021 杨科军. All rights reserved.
//

#import "UIButton+KJWebImage.h"
#import "KJBannerViewCacheManager.h"
#import "UIImage+KJBannerGIF.h"
@implementation UIButton (KJWebImage)

/// 显示网络图片
- (void)kj_setImageWithURL:(NSURL*)url
               placeholder:(UIImage*)placeholder
                     state:(UIControlState)state
                 completed:(KJWebImageCompleted)completed
                  progress:(KJLoadProgressBlock)progress{
    if (placeholder) [self setImage:placeholder forState:state];
    if (url == nil) return;
    __banner_weakself;
    kGCD_banner_async(^{
        NSData *data = [KJBannerViewCacheManager kj_getGIFImageWithKey:url.absoluteString];
        if (data) {
            KJBannerImageType imageType = kBannerContentType(data);
            kGCD_banner_main(^{
                UIImage *image;
                if (imageType == KJBannerImageTypeGif) {
                    image = [UIImage kj_bannerGIFImageWithData:data];
                }else{
                    image = [UIImage imageWithData:data];
                }
                [weakself setImage:image forState:state];
                if (completed) {
                    completed(imageType,image,data);
                }
            });
        }else{
            void (^kDownloaderAnalysis)(NSData *__data) = ^(NSData *__data){
                if (__data == nil) return;
                KJBannerImageType imageType = kBannerContentType(__data);
                kGCD_banner_main(^{
                    UIImage *image;
                    if (imageType == KJBannerImageTypeGif) {
                        image = [UIImage kj_bannerGIFImageWithData:__data];
                    }else{
                        image = [UIImage imageWithData:__data];
                    }
                    [weakself setImage:image forState:state];
                    if (completed) {
                        completed(imageType,image,__data);
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

@end

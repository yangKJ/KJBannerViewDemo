//
//  UIImageView+KJWebImage.m
//  KJBannerViewDemo
//
//  Created by 杨科军 on 2021/1/22.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo

#import "UIImageView+KJWebImage.h"
@interface UIImageView()<KJBannerWebImageHandle>
@end
@implementation UIImageView (KJWebImage)
#pragma maek - Associated
banner_common_method

- (void)kj_config{
    self.cacheDatas = true;
}
- (void)kj_setImageWithURL:(NSURL*)url handle:(void(^)(id<KJBannerWebImageHandle>handle))handle{
    if (url == nil) return;
    [self kj_config];
    if (handle) handle(self);
    __block id<KJBannerWebImageHandle> han = (id<KJBannerWebImageHandle>)self;
    __block CGSize size = self.frame.size;
    if (han.placeholder) self.image = han.placeholder;
    __banner_weakself;
    kGCD_banner_async(^{
        NSData *data = [KJBannerViewCacheManager kj_getGIFImageWithKey:url.absoluteString];
        if (data) {
            kGCD_banner_main(^{
                weakself.image = kBannerWebImageSetImage(data, size, han);
            });
        }else{
            kBannerWebImageDownloader(url, size, han, ^(UIImage * _Nonnull image) {
                kGCD_banner_main(^{ weakself.image = image;});
            });
        }
    });
}

@end

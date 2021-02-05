//
//  UIButton+KJWebImage.m
//  KJBannerViewDemo
//
//  Created by 杨科军 on 2021/1/22.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo

#import "UIButton+KJWebImage.h"
@interface UIButton()<KJBannerWebImageHandle>
@end
@implementation UIButton (KJWebImage)
#pragma maek - Associated
banner_common_method
- (UIControlState)buttonState{
    return (UIControlState)[objc_getAssociatedObject(self, _cmd) intValue];
}
- (void)setButtonState:(UIControlState)buttonState{
    objc_setAssociatedObject(self, @selector(buttonState), @(buttonState), OBJC_ASSOCIATION_ASSIGN);
}
- (void)kj_config{
    self.cacheDatas = true;
    self.buttonState = UIControlStateNormal;
}
- (void)kj_setImageWithURL:(NSURL*)url handle:(void(^)(id<KJBannerWebImageHandle>handle))handle{
    if (url == nil) return;
    [self kj_config];
    if (handle) handle(self);
    __block id<KJBannerWebImageHandle> han = (id<KJBannerWebImageHandle>)self;
    __block CGSize size = self.imageView.frame.size;
    if (han.placeholder) [self setImage:han.placeholder forState:han.buttonState];
    __banner_weakself;
    kGCD_banner_async(^{
        NSData *data = [KJBannerViewCacheManager kj_getGIFImageWithKey:url.absoluteString];
        if (data) {
            kGCD_banner_main(^{
                [weakself setImage:kBannerWebImageSetImage(data, size, han) forState:han.buttonState];
            });
        }else{
            kBannerWebImageDownloader(url, size, han, ^(UIImage * _Nonnull image) {
                kGCD_banner_main(^{
                    [weakself setImage:image forState:han.buttonState];
                });
            });
        }
    });
}

@end

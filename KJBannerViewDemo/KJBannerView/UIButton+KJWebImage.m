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
- (void)kj_config{
    self.URLType = KJBannerImageURLTypeCommon;
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

#pragma maek - KJBannerWebImageHandle
- (UIControlState)buttonState{
    return (UIControlState)[objc_getAssociatedObject(self, _cmd) intValue];
}
- (void)setButtonState:(UIControlState)buttonState{
    objc_setAssociatedObject(self, @selector(buttonState), @(buttonState), OBJC_ASSOCIATION_ASSIGN);
}

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

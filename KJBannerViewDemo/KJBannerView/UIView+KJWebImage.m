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
#pragma maek - Associated
banner_common_method
- (CALayerContentsGravity)viewContentsGravity{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setViewContentsGravity:(CALayerContentsGravity)viewContentsGravity{
    objc_setAssociatedObject(self, @selector(viewContentsGravity), viewContentsGravity, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (void)kj_config{
    self.cacheDatas = true;
    self.viewContentsGravity = kCAGravityResize;
}
- (void)kj_setViewImageContentsWithURL:(NSURL*)url handle:(void(^)(id<KJBannerWebImageHandle>handle))handle{
    if (url == nil) return;
    [self kj_config];
    if (handle) handle(self);
    __block id<KJBannerWebImageHandle> han = (id<KJBannerWebImageHandle>)self;
    __block CGSize size = self.frame.size;
    __banner_weakself;
    kGCD_banner_async(^{
        NSData *data = [KJBannerViewCacheManager kj_getGIFImageWithKey:url.absoluteString];
        if (data) {
            kGCD_banner_main(^{
                UIImage *image = kBannerWebImageSetImage(data, size, han);
                CALayer *layer = [weakself kj_setLayerImageContents:image?:han.placeholder];
                layer.contentsGravity = han.viewContentsGravity;
            });
        }else{
            kBannerWebImageDownloader(url, size, han, ^(UIImage * _Nonnull image) {
                kGCD_banner_main(^{
                    CALayer *layer = [weakself kj_setLayerImageContents:image?:han.placeholder];
                    layer.contentsGravity = han.viewContentsGravity;
                });
            });
        }
    });
}
/// 设置Layer上面的内容，默认充满的填充方式
- (CALayer*)kj_setLayerImageContents:(UIImage*)image{
    CALayer * imageLayer = [CALayer layer];
    imageLayer.bounds = self.bounds;
    imageLayer.position = CGPointMake(self.bounds.size.width*.5, self.bounds.size.height*.5);
    imageLayer.contents = (id)image.CGImage;
    [self.layer addSublayer:imageLayer];
    return imageLayer;
}

@end

//
//  KJBannerViewCell.m
//  KJBannerView
//
//  Created by 杨科军 on 2018/2/27.
//  Copyright © 2018年 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo

#import "KJBannerViewCell.h"
#import "KJBannerViewFunc.h"

#if __has_include("UIView+KJWebImage.h")
#import "UIView+KJWebImage.h"
#endif

@interface KJBannerViewCell(){
    char _divisor;
}
@property (nonatomic,strong) UIImageView *bannerImageView;
@property (nonatomic,copy,readwrite) void(^withBlock)(UIImage *);

/// 占位图
@property (nonatomic,strong) UIImage *placeholderImage;
/// 定制特定方位圆角
@property (nonatomic,assign) UIRectCorner bannerCornerRadius;
/// 图片显示方式
@property (nonatomic,assign) UIViewContentMode bannerContentMode;
/// 圆角
@property (nonatomic,assign) CGFloat bannerRadius;
/// 是否裁剪
@property (nonatomic,assign) BOOL bannerScale;
/// 如果背景不是纯色，请设置为yes
@property (nonatomic,assign) BOOL bannerNoPureBack;
/// 是否预渲染图片处理，默认yes
@property (nonatomic,assign) BOOL bannerPreRendering;

@end

@implementation KJBannerViewCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.layer.contentsScale = [UIScreen mainScreen].scale;
        self.layer.drawsAsynchronously = YES;
        _divisor = 0b00000000;
    }
    return self;
}

/// 下载图片，并渲染到Cell上显示
- (void)kj_bannerImageView{
#if __has_include("UIView+KJWebImage.h")
    __banner_weakself;
    NSURL * url = [NSURL URLWithString:self.imageURLString];
    [self.bannerImageView kj_setImageWithURL:url handle:^(id<KJBannerWebImageHandle>handle) {
        handle.bannerPlaceholder = weakself.placeholderImage;
        handle.bannerCropScale = weakself.bannerScale;
        handle.bannerPreRendering = weakself.bannerPreRendering;
        handle.bannerCompleted = ^(KJBannerImageType type, UIImage *image, NSData *data, NSError *err) {
            __banner_strongself;
            if (image && type != KJBannerImageTypeUnknown) {
                strongself.withBlock ? strongself.withBlock(image) : nil;
            }
        };
    }];
#endif
}

/// 绘制图片
/// @param bannerImage 缓存区图片资源
/// @param withBlock 绘制图片回调
- (void)drawBannerImage:(UIImage *)bannerImage withBlock:(void(^)(UIImage *))withBlock{
    if (bannerImage) {
        self.bannerImageView.image = bannerImage;
        return;
    }
    if (self.imageURLString == nil || [self.imageURLString isEqualToString:@""]) {
        self.bannerImageView.image = self.placeholderImage;
        return;
    }
    if (kBannerImageURLStringLocality(self.imageURLString)) {
        NSData * data = kBannerLocalityGIFData(self.imageURLString);
        if (data) {
            kBannerAsyncPlayGIFImage(data, ^(UIImage * _Nonnull image) {
                if (image) {
                    self.bannerImageView.image = image;
                    withBlock ? withBlock(image) : nil;
                }
            });
        } else if (self.bannerPreRendering) {// 预渲染处理
            kGCD_banner_async(^{
                UIImage *image = [UIImage imageNamed:self.imageURLString];
                if (image == nil) return;
                UIGraphicsBeginImageContextWithOptions(image.size, YES, 0);
                [image drawInRect:(CGRect){CGPointZero, image.size}];
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                kGCD_banner_main(^{
                    self.bannerImageView.image = image;
                    withBlock ? withBlock(image) : nil;
                });
            });
        } else {
            UIImage *image = [UIImage imageNamed:self.imageURLString];
            if (image) {
                self.bannerImageView.image = image;
                withBlock ? withBlock(image) : nil;
            }
        }
    } else {// 停止时刻加载网络图片
        self.withBlock = withBlock;
        self.bannerImageView.image = self.placeholderImage;
        [self performSelector:@selector(kj_bannerImageView) withObject:nil
                   afterDelay:0.0 inModes:@[NSDefaultRunLoopMode]];
    }
}

#pragma mark - setter/getter

- (BOOL)bannerScale{
    return !!(_divisor & 1);
}
- (void)setBannerScale:(BOOL)bannerScale{
    if (bannerScale) {
        _divisor |= 1;
    }else{
        _divisor &= 0;
    }
}
- (BOOL)bannerNoPureBack{
    return !!(_divisor & 2);
}
- (void)setBannerNoPureBack:(BOOL)bannerNoPureBack{
    if (bannerNoPureBack) {
        _divisor |=  (1<<1);
    }else{
        _divisor &= ~(1<<1);
    }
}
- (BOOL)bannerPreRendering{
    return !!(_divisor & 4);
}
- (void)setBannerPreRendering:(BOOL)bannerPreRendering{
    if (bannerPreRendering) {
        _divisor |=  (1<<2);
    }else{
        _divisor &= ~(1<<2);
    }
}

#pragma mark - lazy

- (UIImageView *)bannerImageView{
    if (_bannerImageView == nil) {
        _bannerImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _bannerImageView.contentMode = self.bannerContentMode;
        _bannerImageView.image = self.placeholderImage;
        [self addSubview:_bannerImageView];
        if (self.bannerRadius > 0) {
            CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
            shapeLayer.frame = self.bounds;
            [_bannerImageView.layer addSublayer:shapeLayer];
            if (self.bannerNoPureBack) {
                UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                                cornerRadius:self.bannerRadius];
                shapeLayer.path = path.CGPath;
                _bannerImageView.layer.mask = shapeLayer;
            } else {
                _bannerImageView.clipsToBounds = YES;
                kBannerAsyncCornerRadius(self.bannerRadius, ^(UIImage *image) {
                    shapeLayer.contents = (id)image.CGImage;
                }, self.bannerCornerRadius, _bannerImageView);
            }
        }
    }
    return _bannerImageView;
}

@end

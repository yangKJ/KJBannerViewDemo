//
//  KJBannerViewCell.m
//  KJBannerView
//
//  Created by 杨科军 on 2018/2/27.
//  Copyright © 2018年 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo

#import "KJBannerViewCell.h"
#if __has_include("UIView+KJWebImage.h")
#import "UIView+KJWebImage.h"
#endif

@interface KJBannerViewCell(){
    char _divisor;
}
@property (nonatomic,strong) UIImageView *bannerImageView;
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
- (void)setItemView:(UIView*)itemView{
    if (_itemView) [_itemView removeFromSuperview];
    _itemView = itemView;
    [self addSubview:itemView];
}
- (void)setBannerDatas:(KJBannerDatas*)info{
    _bannerDatas = info;
#if __has_include("UIView+KJWebImage.h")
    if (info.bannerImage) {
        self.bannerImageView.image = info.bannerImage;
    }else{
        if (kBannerLocality(info.bannerURLString)) {
            NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:info.bannerURLString ofType:@"gif"]];
            if (data == nil) {
                data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:info.bannerURLString ofType:@"GIF"]];
            }
            if (data) {
                __banner_weakself;
                kBannerAsyncPlayImage(^(UIImage * _Nullable image) {
                    weakself.bannerImageView.image = info.bannerImage = image?:weakself.bannerPlaceholder;
                }, data);
            }else{
                if (self.bannerPreRendering) {
                    __banner_weakself;
                    kGCD_banner_async(^{
                        UIImage *image = [UIImage imageNamed:info.bannerURLString]?:weakself.bannerPlaceholder;
                        UIGraphicsBeginImageContextWithOptions(image.size, YES, 0);
                        [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
                        image = UIGraphicsGetImageFromCurrentImageContext();
                        UIGraphicsEndImageContext();
                        info.bannerImage = image;
                        kGCD_banner_main(^{
                            weakself.bannerImageView.image = image;
                        });
                    });
                }else{
                    self.bannerImageView.image = info.bannerImage = [UIImage imageNamed:info.bannerURLString]?:self.bannerPlaceholder;
                }
            }
        }else{
            [self performSelector:@selector(kj_bannerImageView) withObject:nil afterDelay:0.0 inModes:@[NSDefaultRunLoopMode]];
        }
    }
#endif
}
#if __has_include("UIView+KJWebImage.h")
/// 下载图片，并渲染到cell上显示
- (void)kj_bannerImageView{
    __banner_weakself;
    [self.bannerImageView kj_setImageWithURL:[NSURL URLWithString:self.bannerDatas.bannerURLString] handle:^(id<KJBannerWebImageHandle>handle) {
        handle.bannerPlaceholder = weakself.bannerPlaceholder;
        handle.cropScale = weakself.bannerScale;
        handle.preRendering = weakself.bannerPreRendering;
        handle.bannerCompleted = ^(KJBannerImageType imageType, UIImage * image, NSData * data, NSError * error) {
            weakself.bannerDatas.bannerImage = image;
        };
    }];
}
/// 判断是网络图片还是本地
NS_INLINE bool kBannerLocality(NSString * _Nonnull urlString){
    return ([urlString hasPrefix:@"http://"] || [urlString hasPrefix:@"https://"]) ? false : true;
}
/// 异步播放动态图
NS_INLINE void kBannerAsyncPlayImage(void(^xxblock)(UIImage * _Nullable image), NSData * data){
    if (xxblock) {
        if (data == nil) xxblock(nil);
        kGCD_banner_async(^{
            CGImageSourceRef imageSource = CGImageSourceCreateWithData(CFBridgingRetain(data), nil);
            size_t imageCount = CGImageSourceGetCount(imageSource);
            UIImage *image;
            if (imageCount <= 1) {
                image = [UIImage imageWithData:data];
            }else{
                NSMutableArray *scaleImages = [NSMutableArray arrayWithCapacity:imageCount];
                NSTimeInterval time = 0;
                for (int i = 0; i<imageCount; i++) {
                    CGImageRef cgImage = CGImageSourceCreateImageAtIndex(imageSource, i, nil);
                    UIImage *originalImage = [UIImage imageWithCGImage:cgImage];
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
                image = [UIImage animatedImageWithImages:scaleImages duration:time];
            }
            kGCD_banner_main(^{
                xxblock(image);
            });
            CFRelease(imageSource);
        });
    }
}
#endif

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
- (UIImageView*)bannerImageView{
    if (_bannerImageView == nil) {
        _bannerImageView = [[UIImageView alloc]initWithFrame:self.bounds];
        _bannerImageView.contentMode = self.bannerContentMode;
        _bannerImageView.image = self.bannerPlaceholder;
        [self addSubview:_bannerImageView];
        if (self.bannerRadius > 0) {
            CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
            shapeLayer.frame = self.bounds;
            [_bannerImageView.layer addSublayer:shapeLayer];
            if (self.bannerNoPureBack) {
                shapeLayer.path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.bannerRadius].CGPath;
                _bannerImageView.layer.mask = shapeLayer;
            }else{
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
@implementation KJBannerDatas

@end

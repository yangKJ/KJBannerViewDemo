//
//  KJBannerViewCell.m
//  KJBannerView
//
//  Created by 杨科军 on 2018/2/27.
//  Copyright © 2018年 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo

#import "KJBannerViewCell.h"
#import "KJBannerView.h"

#if __has_include("KJWebImageHeader.h")
#import "KJWebImageHeader.h"
#endif

@interface KJBannerViewCell (){
    char _divisor;
}
@property (nonatomic,strong) KJBannerView *bannerView;
@property (nonatomic,strong) UIImageView *bannerImageView;
@property (nonatomic,strong) UIImage *placeholderImage;
@property (nonatomic,strong) NSString *imageURLString;

@end

@implementation KJBannerViewCell

- (void)setupInit{
    _divisor = 0b00000000;
    self.bannerNoPureBack = YES;
    self.bannerContentMode = UIViewContentModeScaleToFill;
    self.bannerCornerRadius = UIRectCornerAllCorners;
    self.bannerRadiusColor = self.superview.backgroundColor;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.layer.contentsScale = [UIScreen mainScreen].scale;
        self.layer.drawsAsynchronously = YES;
        [self setupInit];
    }
    return self;
}

/// 🎷 是否使用本库提供的图片加载，支持动态GIF网图混合使用
/// 经过预渲染和暂存在缓存区处理，性能方面更优
/// 前提条件，必须引入网络加载模块 pod 'KJBannerView/Downloader'
/// @param imageURLString 图片链接地址，支持动态GIF和网图、本地图等等
/// @param mineLoadImage 是否使用本库提供的图片加载
- (void)setupImageURLString:(NSString *)imageURLString mineLoadImage:(BOOL)mineLoadImage{
    UIImage *image = [UIImage imageNamed:@"KJBannerView.bundle/KJBannerPlaceholderImage.png"];
    [self setupImageURLString:imageURLString placeholderImage:image mineLoadImage:mineLoadImage];
}

- (void)setupImageURLString:(NSString *)imageURLString
           placeholderImage:(UIImage *)placeholderImage
              mineLoadImage:(BOOL)mineLoadImage{
    if (imageURLString == nil || imageURLString.length == 0) {
        return;
    }
    self.imageURLString = imageURLString;
    self.placeholderImage = placeholderImage;
    if (self.bannerImageView.image == nil) {    
        self.bannerImageView.image = self.placeholderImage;
    }
    if (mineLoadImage) {
        [self drawBannerImageWithURLString:imageURLString];
    }
}

/// 绘制图片
- (void)drawBannerImageWithURLString:(NSString *)urlString{
    UIImage *cacheImage = [self.bannerView.cacheImages valueForKey:urlString];
    if (cacheImage) {
        self.bannerImageView.image = cacheImage;
        return;
    }
    // 本地图
    if (kBannerImageURLStringLocality(urlString)) {
        NSData * data = kBannerLocalityGIFData(urlString);
        if (data) {
            __weak __typeof(self) weakself = self;
            kBannerAsyncPlayGIFImage(data, ^(UIImage * _Nonnull image) {
                weakself.bannerImageView.image = image;
                [weakself.bannerView.cacheImages setValue:image forKey:urlString];
            });
        } else {
            UIImage *image = [UIImage imageNamed:urlString];
            if (image) {
                self.bannerImageView.image = image;
                [self.bannerView.cacheImages setValue:image forKey:urlString];
            }
        }
        return;
    }
    // 停止时刻加载网络图片
    [self performSelector:@selector(kj_bannerImageView)
               withObject:nil
               afterDelay:0.0
                  inModes:@[NSDefaultRunLoopMode]];
}

/// 下载图片，并渲染到Cell上显示
- (void)kj_bannerImageView{
    #if __has_include("KJWebImageHeader.h")
    __weak __typeof(self) weakself = self;
    NSURL * imageURL = [NSURL URLWithString:self.imageURLString];
    [self.bannerImageView kj_setImageWithURL:imageURL provider:^(id<KJWebImageDelegate> delegate) {
        delegate.webPlaceholder = weakself.placeholderImage;
        delegate.webCropScale = weakself.bannerScale;
        __strong __typeof(self) strongself = weakself;
        delegate.webCompleted = ^(KJWebImageType imageType, UIImage *image, NSData *data, NSError *error) {
            if (image) {
                [strongself.bannerView.cacheImages setValue:image forKey:strongself.imageURLString];
            }
        };
    }];
    #endif
}

#pragma mark - private method

/// 判断是网络图片还是本地
NS_INLINE bool kBannerImageURLStringLocality(NSString * _Nonnull urlString){
    return ([urlString hasPrefix:@"http://"] || [urlString hasPrefix:@"https://"]) ? false : true;
}

/// 获取本地GIF资源
NS_INLINE NSData * kBannerLocalityGIFData(NSString * string){
    NSString *name = [[NSBundle mainBundle] pathForResource:string ofType:@"gif"];
    NSData *data = [NSData dataWithContentsOfFile:name];
    if (data == nil) {
        name = [[NSBundle mainBundle] pathForResource:string ofType:@"GIF"];
        data = [NSData dataWithContentsOfFile:name];
    }
    return data;
}

/// 异步播放动态图
/// @param data 数据源
/// @param callback 播放图片回调
NS_INLINE void kBannerAsyncPlayGIFImage(NSData * data, void(^callback)(UIImage *)){
    if (callback == nil || data == nil) return;
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        CGImageSourceRef imageSource = CGImageSourceCreateWithData(CFBridgingRetain(data), nil);
        size_t imageCount = CGImageSourceGetCount(imageSource);
        UIImage *image;
        if (imageCount <= 1) {
            image = [UIImage imageWithData:data];
        } else {
            NSMutableArray *scaleImages = [NSMutableArray arrayWithCapacity:imageCount];
            NSTimeInterval time = 0;
            for (int i = 0; i < imageCount; i++) {
                CGImageRef cgImage = CGImageSourceCreateImageAtIndex(imageSource, i, nil);
                UIImage *originalImage = [UIImage imageWithCGImage:cgImage];
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
            image = [UIImage animatedImageWithImages:scaleImages duration:time];
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            callback(image);
        }];
        CFRelease(imageSource);
    }];
}

/// 异步绘制圆角，
/// 原理就是绘制一个镂空图片盖在上面，所以这种只适用于纯色背景
/// @param radius 圆角半径
/// @param callback 蒙版图片回调
/// @param corners 圆角位置，支持特定方位圆角处理
/// @param view 需要覆盖视图
NS_INLINE void kBannerAsyncCornerRadius(CGFloat radius,
                                        void(^callback)(UIImage * image),
                                        UIRectCorner corners, UIView * view){
    if (callback == nil) return;
    UIColor * backgroundColor = UIColor.whiteColor;
    if (view.backgroundColor) {
        backgroundColor = view.backgroundColor;
    } else if (view.superview.backgroundColor) {
        backgroundColor = view.superview.backgroundColor;
    }
    CGRect bounds = view.bounds;
    CGFloat scale = [UIScreen mainScreen].scale;
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        UIGraphicsBeginImageContextWithOptions(bounds.size, NO, scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:bounds];
        UIBezierPath *radiusPath = [UIBezierPath bezierPathWithRoundedRect:bounds
                                                         byRoundingCorners:corners
                                                               cornerRadii:CGSizeMake(radius, radius)];
        UIBezierPath *cornerPath = [radiusPath bezierPathByReversingPath];
        [path appendPath:cornerPath];
        CGContextAddPath(context, path.CGPath);
        [backgroundColor set];
        CGContextFillPath(context);
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            callback(image);
        }];
    }];
}

#pragma mark - setter/getter

- (BOOL)bannerScale{
    return !!(_divisor & 1);
}
- (void)setBannerScale:(BOOL)bannerScale{
    if (bannerScale) {
        _divisor |= 1;
    } else {
        _divisor &= 0;
    }
}
- (BOOL)bannerNoPureBack{
    return !!(_divisor & 2);
}
- (void)setBannerNoPureBack:(BOOL)bannerNoPureBack{
    if (bannerNoPureBack) {
        _divisor |=  (1<<1);
    } else {
        _divisor &= ~(1<<1);
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
                kBannerAsyncCornerRadius(self.bannerRadius, ^(UIImage * image) {
                    shapeLayer.contents = (id)image.CGImage;
                }, self.bannerCornerRadius, _bannerImageView);
            }
        }
    }
    return _bannerImageView;
}

@end

//
//  KJLoadImageView.m
//  iSchool
//
//  Created by 杨科军 on 2018/12/22.
//  Copyright © 2018 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo

#import "KJLoadImageView.h"
#import "UIImage+KJBannerGIF.h"
#import "KJBannerViewLoadManager.h"
#import "KJBannerViewCacheManager+KJBannerGIF.h"
@implementation KJLoadImageView
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self configureLayout];
    }
    return self;
}
/// 清理掉本地缓存
+ (void)kj_clearImagesCache{
    [KJBannerViewCacheManager kj_clearLocalityImageAndCache];
}
/// 获取图片缓存的占用的总大小
+ (int64_t)kj_imagesCacheSize{
    return [KJBannerViewCacheManager kj_getLocalityImageCacheSize];
}
#pragma mark - 网图
/// 设置网图
- (void)kj_setImageWithURLString:(NSString*)url Placeholder:(UIImage*)placeholderImage{
    return [self kj_setImageWithURLString:url Placeholder:placeholderImage Completion:nil];
}
- (void)kj_setImageWithURLString:(NSString*)url Placeholder:(UIImage*)placeholderImage Completion:(void(^)(UIImage *image))completion{
    self.image = placeholderImage;
    if (url == nil || url.length == 0 || [url isEqualToString:@""]) {
        return;
    }
    KJBannerViewLoadManager.kMaxLoadNum = self.kj_failedTimes;
    __weak typeof(self) weakself = self;
    [KJBannerViewLoadManager kj_loadImageWithURL:url complete:^(UIImage * _Nullable image) {
        if (image) {
            if (weakself.kj_isScale) {
                CGFloat scale = UIScreen.mainScreen.scale;
                CGSize size = CGSizeMake(weakself.frame.size.width * scale, weakself.frame.size.height * scale);
                image = [weakself kj_cropImage:image Size:size];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([image isKindOfClass:[UIImage class]]) {                
                    weakself.image = image;
                }
            });
        }
        if (completion) {
            completion(image);
        }
    }];
}

#pragma mark - 动态图
/// 动态图显示下载
- (void)kj_setGIFImageWithURLString:(NSString*)url Placeholder:(UIImage*)placeholderImage Completion:(void(^_Nullable)(UIImage*image))completion{
    self.image = placeholderImage;
    if (url == nil || url.length == 0 || [url isEqualToString:@""]) {
        return;
    }
    __weak typeof(self) weakself = self;
    NSData *data = [KJBannerViewCacheManager kj_getGIFImageWithKey:url];
    if (data) {
        UIImage *image = [UIImage kj_bannerGIFImageWithData:data];
        weakself.image = image;
        if (completion) completion(image);
    }else{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *image = [UIImage kj_bannerGIFImageWithURL:[NSURL URLWithString:url]];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (image) weakself.image = image;
                if (completion) completion(image);
            });
        });
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
            if (data) [KJBannerViewCacheManager kj_storeGIFData:data Key:url];
        });
    }
}

#pragma mark - private
/// 初始化
- (void)configureLayout{
    self.contentMode = UIViewContentModeScaleToFill;
    self.kj_failedTimes = 2;
    self.kj_isScale = NO;
}
/// 等比改变图片尺寸
- (UIImage*)kj_cropImage:(UIImage*)image Size:(CGSize)size{
    float scale = image.size.width/image.size.height;
    CGRect rect = CGRectZero;
    if (scale > size.width/size.height){
        rect.origin.x = (image.size.width - image.size.height * size.width/size.height)/2;
        rect.size.width  = image.size.height * size.width/size.height;
        rect.size.height = image.size.height;
    }else{
        rect.origin.y = (image.size.height - image.size.width/size.width * size.height)/2;
        rect.size.width  = image.size.width;
        rect.size.height = image.size.width/size.width * size.height;
    }
    CGImageRef imageRef   = CGImageCreateWithImageInRect(image.CGImage, rect);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return croppedImage;
}

@end


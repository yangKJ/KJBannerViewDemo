//
//  KJBannerViewFunc.m
//  KJBannerViewDemo
//
//  Created by 杨科军 on 2020/12/7.
//  Copyright © 2020 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo

#import "KJBannerViewFunc.h"
#import <CommonCrypto/CommonDigest.h>

@implementation KJBannerViewFunc

#pragma mark - simple method

/// 子线程
void kGCD_banner_async(dispatch_block_t _Nonnull block) {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL),
               dispatch_queue_get_label(queue)) == 0) {
        block();
    } else {
        dispatch_async(queue, block);
    }
}
/// 主线程
void kGCD_banner_main(dispatch_block_t _Nonnull block) {
    dispatch_queue_t queue = dispatch_get_main_queue();
    if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL),
               dispatch_queue_get_label(queue)) == 0) {
        block();
    } else {
        if ([[NSThread currentThread] isMainThread]) {
            dispatch_async(queue, block);
        } else {
            dispatch_sync(queue, block);
        }
    }
}

/// 延时执行
void kGCD_banner_after_main(NSTimeInterval delayInSeconds, dispatch_block_t _Nonnull block) {
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(time, dispatch_get_main_queue(), block);
}

/// 异步绘制圆角，
/// 原理就是绘制一个镂空图片盖在上面，所以这种只适用于纯色背景
/// @param radius 圆角半径
/// @param kAsyncDrawImage 蒙版图片回调
/// @param corners 圆角位置，支持特定方位圆角处理
/// @param view 需要覆盖视图
void kBannerAsyncCornerRadius(CGFloat radius,
                              void(^kAsyncDrawImage)(UIImage * image),
                              UIRectCorner corners, UIView * view){
    if (kAsyncDrawImage == nil) {
        return;
    }
    UIColor * backgroundColor = UIColor.whiteColor;;
    if (view.backgroundColor) {
        backgroundColor = view.backgroundColor;
    } else if (view.superview.backgroundColor) {
        backgroundColor = view.superview.backgroundColor;
    }
    CGRect bounds = view.bounds;
    CGFloat scale = [UIScreen mainScreen].scale;
    kGCD_banner_async(^{
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
        kGCD_banner_main(^{
            kAsyncDrawImage(image);
        });
        UIGraphicsEndImageContext();
    });
}
/// 判断是网络图片还是本地
bool kBannerImageURLStringLocality(NSString * _Nonnull urlString){
    return ([urlString hasPrefix:@"http://"] || [urlString hasPrefix:@"https://"]) ? false : true;
}
/// 异步播放动态图
/// @param data 数据源
/// @param kPlayImage 播放图片回调
void kBannerAsyncPlayGIFImage(NSData * data, void(^kPlayImage)(UIImage *)){
    if (kPlayImage == nil) return;
    if (data == nil) kPlayImage(nil);
    kGCD_banner_async(^{
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
        kGCD_banner_main(^{
            kPlayImage(image);
        });
        CFRelease(imageSource);
    });
}

/// MD5加密
NSString * kBannerMD5String(NSString * string){
    const char * original = [string UTF8String];
    unsigned char digist[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original, (uint)strlen(original), digist);
    NSMutableString *resultString = [NSMutableString stringWithCapacity:10];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
    [resultString appendFormat:@"%02X", digist[i]];
    return [resultString lowercaseString];
}

/// 获取本地GIF资源
NSData * kBannerLocalityGIFData(NSString * string){
    NSString *name = [[NSBundle mainBundle] pathForResource:string ofType:@"gif"];
    NSData *data = [NSData dataWithContentsOfFile:name];
    if (data == nil) {
        name = [[NSBundle mainBundle] pathForResource:string ofType:@"GIF"];
        data = [NSData dataWithContentsOfFile:name];
    }
    return data;
}

@end

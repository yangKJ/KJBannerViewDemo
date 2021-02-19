//
//  KJBannerWebImageHandle.h
//  KJBannerViewDemo
//
//  Created by 杨科军 on 2021/1/26.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "KJBannerViewType.h"
#import "KJBannerViewDownloader.h"
#import "KJBannerViewCacheManager.h"
NS_ASSUME_NONNULL_BEGIN
/// 图片下载完成回调
typedef void (^_Nullable KJWebImageCompleted)(KJBannerImageType imageType, UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error);
@protocol KJBannerWebImageHandle <NSObject>
@optional;
#pragma mark - common
/// 占位图
@property(nonatomic,strong)UIImage *placeholder;
/// 图片下载完成回调
@property(nonatomic,copy,readwrite)KJWebImageCompleted completed;
/// 下载进度回调
@property(nonatomic,copy,readwrite)KJLoadProgressBlock progress;
/// 是否缓存数据至本地，默认开启
@property(nonatomic,assign)bool cacheDatas;
/// 是否等比裁剪图片，默认关闭
@property(nonatomic,assign)bool cropScale;
/// 获取原始图回调，裁剪开启才有效果
@property(nonatomic,copy,readwrite)void(^kCropScaleImage)(UIImage * originalImgae, UIImage * scaleImage);

#pragma mark - button
/// 按钮状态
@property(nonatomic,assign)UIControlState buttonState;

#pragma mark - view
/// 图片填充方式
@property(nonatomic,copy)CALayerContentsGravity viewContentsGravity;

@end
//************ 公共方法 *************
/// 异步播放动态图
NS_INLINE void kBannerAsyncPlayImage(void(^xxblock)(UIImage * _Nullable image), NSData * data){
    if (xxblock) {
        if (data == nil) xxblock(nil);
        kGCD_banner_async(^{
            CGImageSourceRef imageSource = CGImageSourceCreateWithData(CFBridgingRetain(data), nil);
            size_t imageCount = CGImageSourceGetCount(imageSource);
            if (imageCount <= 1) {
                kGCD_banner_main(^{xxblock([[UIImage alloc] initWithData:data]);});
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
                    CFRelease(gifProperties);
                    time += duration.doubleValue;
                }
                kGCD_banner_main(^{xxblock([UIImage animatedImageWithImages:scaleImages duration:time]);});
            }
            CFRelease(imageSource);
        });
    }
}

NS_ASSUME_NONNULL_END

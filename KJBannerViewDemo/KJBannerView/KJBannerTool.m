//
//  KJBannerTool.m
//  KJBannerViewDemo
//
//  Created by 杨科军 on 2019/7/30.
//  Copyright © 2019 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo

#import "KJBannerTool.h"

@implementation KJBannerTool
/// 判断该字符串是不是一个有效的URL
+ (BOOL)kj_bannerValidUrl:(NSString*)url{
    NSString *regex = @"[a-zA-z]+://[^\\s]*";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [urlTest evaluateWithObject:url];
}
/// 判断是网络图片还是本地
+ (BOOL)kj_bannerImageWithImageUrl:(NSString*)url{
    return ([url hasPrefix:@"http"] || [url hasPrefix:@"https"]) ? NO : YES;
}
/// 根据图片名判断是否是动态图
+ (BOOL)kj_bannerIsGifImageWithImageName:(NSString*)imageName{
    NSString *ext = imageName.pathExtension.lowercaseString;
    return ([ext isEqualToString:@"gif"]) ? YES : NO;
}
/// 根据图片地址判断是否为动态图
+ (BOOL)kj_bannerIsGifWithURL:(id)url{
    if (![url isKindOfClass:[NSURL class]]) {
        url = [NSURL URLWithString:url];
    }
    NSData *data = [NSData dataWithContentsOfURL:url];
    return [self contentTypeWithImageData:data] == KJBannerImageTypeGif ? YES : NO;
}
/// 根据DATA判断图片类型
+ (KJBannerImageType)contentTypeWithImageData:(NSData*)data{
    uint8_t c;
    [data getBytes:&c length:1];
    switch (c) {
        case 0xFF:
            return KJBannerImageTypeJpeg;
        case 0x89:
            return KJBannerImageTypePng;
        case 0x47:
            return KJBannerImageTypeGif;
        case 0x49:
        case 0x4D:
            return KJBannerImageTypeTiff;
        case 0x52:
            if ([data length] < 12) return KJBannerImageTypeUnknown;
            NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, 12)] encoding:NSASCIIStringEncoding];
            if ([testString hasPrefix:@"RIFF"] && [testString hasSuffix:@"WEBP"]) return KJBannerImageTypeWebp;
            return KJBannerImageTypeUnknown;
    }
    return KJBannerImageTypeUnknown;
}
/// 播放网络Gif
+ (NSTimeInterval)kj_bannerPlayGifWithImageView:(UIImageView*)imageView URL:(id)url{
    if (![url isKindOfClass:[NSURL class]]) url = [NSURL URLWithString:url];
    NSData *data = [NSData dataWithContentsOfURL:url];
    CGImageSourceRef imageSource = CGImageSourceCreateWithData(CFBridgingRetain(data), nil);
    size_t imageCount = CGImageSourceGetCount(imageSource);
    NSMutableArray *images = [NSMutableArray array];
    NSTimeInterval totalDuration = 0;
    for (int i = 0; i<imageCount; i++) {
        CGImageRef cgImage = CGImageSourceCreateImageAtIndex(imageSource, i, nil);
        UIImage *image = [UIImage imageWithCGImage:cgImage];
        [images addObject:image];
        NSDictionary *properties = (__bridge_transfer NSDictionary*)CGImageSourceCopyPropertiesAtIndex(imageSource, i, nil);
        NSDictionary *gifDict = [properties objectForKey:(__bridge NSString *)kCGImagePropertyGIFDictionary];
        NSNumber *frameDuration = [gifDict objectForKey:(__bridge NSString *)kCGImagePropertyGIFDelayTime];
        totalDuration += frameDuration.doubleValue;
    }
    imageView.animationImages = images;
    imageView.animationDuration = totalDuration;
    imageView.animationRepeatCount = 0;
    [imageView startAnimating];
    return totalDuration;
}
// 获取网络GIF图
+ (UIImage*)kj_bannerGetImageWithURL:(id)url{
    if (![url isKindOfClass:[NSURL class]]) url = [NSURL URLWithString:url];
    NSData *data = [NSData dataWithContentsOfURL:url];
    CGImageSourceRef imageSource = CGImageSourceCreateWithData(CFBridgingRetain(data), nil);
    size_t imageCount = CGImageSourceGetCount(imageSource);
    UIImage *animatedImage;
    if (imageCount <= 1) {
        animatedImage = [[UIImage alloc] initWithData:data];
    }else{
        NSMutableArray *images = [NSMutableArray array];
        NSTimeInterval totalDuration = 0;
        CGImageRef cgImage = NULL;
        for (int i = 0; i<imageCount; i++) {
            cgImage = CGImageSourceCreateImageAtIndex(imageSource,i,nil);
            [images addObject:[UIImage imageWithCGImage:cgImage]];
            NSDictionary *properties = (__bridge_transfer NSDictionary*)CGImageSourceCopyPropertiesAtIndex(imageSource, i, nil);
            NSDictionary *gifDict = [properties objectForKey:(__bridge NSString *)kCGImagePropertyGIFDictionary];
            NSNumber *frameDuration = [gifDict objectForKey:(__bridge NSString *)kCGImagePropertyGIFDelayTime];
            totalDuration += frameDuration.doubleValue;
        }
        animatedImage = [UIImage animatedImageWithImages:images duration:totalDuration];
        CGImageRelease(cgImage);
        images = nil;
    }
    CFRelease(imageSource);
    return animatedImage;
}
/// 保存gif在本地
+ (void)kj_bannerSaveWithImage:(UIImage*)image URL:(id)url{
    NSString *directoryPath = KJBannerLoadImages;
    if (![[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:nil]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) return;
    }
    if ([url isKindOfClass:[NSURL class]]) url = [url absoluteString];
    NSString *name = [KJBannerViewCacheManager kj_bannerMD5WithString:url];
    NSString *path = [directoryPath stringByAppendingPathComponent:name];
    NSData *data = UIImagePNGRepresentation(image);
    if (data) [[NSFileManager defaultManager] createFileAtPath:path contents:data attributes:nil];
}
/// 从 File 当中获取Gif文件
+ (UIImage*)kj_bannerGetImageInFileWithURL:(id)url{
    if ([url isKindOfClass:[NSURL class]]) url = [url absoluteString];
    NSString *directoryPath = KJBannerLoadImages;
    NSString *name = [KJBannerViewCacheManager kj_bannerMD5WithString:url];
    NSString *path = [directoryPath stringByAppendingPathComponent:name];
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:path];
    NSData *fileData = [handle readDataToEndOfFile];
    [handle closeFile];
    return [[UIImage alloc]initWithData:fileData];
}

@end


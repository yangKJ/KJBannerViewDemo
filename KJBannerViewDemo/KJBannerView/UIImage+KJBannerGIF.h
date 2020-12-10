//
//  UIImage+KJBannerGIF.h
//  KJBannerViewDemo
//
//  Created by 杨科军 on 2020/11/12.
//  Copyright © 2020 杨科军. All rights reserved.
//  动态图播放

#import <UIKit/UIKit.h>
#import <ImageIO/ImageIO.h>
NS_ASSUME_NONNULL_BEGIN

@interface UIImage (KJBannerGIF)
/// 本地动图
+ (UIImage*)kj_bannerGIFImageWithData:(NSData*)data;
/// 网络动图
+ (UIImage*)kj_bannerGIFImageWithURL:(NSURL*)URL;

@end

NS_ASSUME_NONNULL_END

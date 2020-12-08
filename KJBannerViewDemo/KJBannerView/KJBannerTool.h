//
//  KJBannerTool.h
//  KJBannerViewDemo
//
//  Created by 杨科军 on 2019/7/30.
//  Copyright © 2019 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UIImage+KJBannerGIF.h"
#import "NSTimer+KJSolve.h"
#import "KJBannerViewType.h"
#import "KJBannerViewCacheManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface KJBannerDatasInfo : NSObject
@property (nonatomic,strong) UIImage *image;
@property (nonatomic,strong) NSString *imageUrl;
@property (nonatomic,assign) KJBannerImageInfoType type;
@property (nonatomic,assign) KJBannerViewImageType superType;
@end

@interface KJBannerTool : NSObject
/// 判断该字符串是不是有效的URL
+ (BOOL)kj_bannerValidUrl:(NSString*)url;
/// 根据图片名判断是否为动态图
+ (BOOL)kj_bannerIsGifImageWithImageName:(NSString*)imageName;
/// 根据图片URL判断是否为动态图
+ (BOOL)kj_bannerIsGifWithURL:(id)url;
/// 判断图片类型
+ (KJBannerImageType)contentTypeWithImageData:(NSData*)data;
/// 判断是网络图片还是本地
+ (BOOL)kj_bannerImageWithImageUrl:(NSString*)imageUrl;
/// 播放网络动态图
+ (NSTimeInterval)kj_bannerPlayGifWithImageView:(UIImageView*)imageView URL:(id)url;
/// 获取网络动态图
+ (UIImage*)kj_bannerGetImageWithURL:(id)url;

@end

NS_ASSUME_NONNULL_END

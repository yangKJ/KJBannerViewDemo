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

NS_ASSUME_NONNULL_BEGIN
#define KJBannerLoadImages [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/KJLoadImages"];
typedef NS_ENUM(NSInteger, KJBannerImageType) {
    KJBannerImageTypeUnknown = 0, /// 未知
    KJBannerImageTypeJpeg    = 1, /// jpg
    KJBannerImageTypePng     = 2, /// png
    KJBannerImageTypeGif     = 3, /// gif
    KJBannerImageTypeTiff    = 4, /// tiff
    KJBannerImageTypeWebp    = 5, /// webp
};
/// 图片的几种类型
typedef NS_ENUM(NSInteger, KJBannerImageInfoType) {
    KJBannerImageInfoTypeLocality, /// 本地图片
    KJBannerImageInfoTypeNetIamge, /// 网络图片
    KJBannerImageInfoTypeGIFImage, /// 网络动态图
};
/// 滚动方法
typedef NS_ENUM(NSInteger, KJBannerViewRollDirectionType) {
    KJBannerViewRollDirectionTypeRightToLeft = 0, /// 默认，从右往左
    KJBannerViewRollDirectionTypeLeftToRight,     /// 从左往右
};
/// 图片的几种类型
typedef NS_ENUM(NSInteger, KJBannerViewImageType) {
    KJBannerViewImageTypeMix = 0,  /// 混合，本地图片、网络图片、网络动态图
    KJBannerViewImageTypeGIFAndNet,/// 网络动态图和网络图片混合
    KJBannerViewImageTypeLocality, /// 本地图片
    KJBannerViewImageTypeNetIamge, /// 网络图片
    KJBannerViewImageTypeGIFImage, /// 网络动态图
};
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

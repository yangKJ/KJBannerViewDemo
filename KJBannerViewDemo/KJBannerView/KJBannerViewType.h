//
//  KJBannerViewType.h
//  KJBannerViewDemo
//
//  Created by 杨科军 on 2020/12/7.
//  Copyright © 2020 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo
//  枚举文件夹

#ifndef KJBannerViewType_h
#define KJBannerViewType_h

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

#endif /* KJBannerViewType_h */

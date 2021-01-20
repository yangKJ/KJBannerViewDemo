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
/// 滚动方法
typedef NS_ENUM(NSInteger, KJBannerViewRollDirectionType) {
    KJBannerViewRollDirectionTypeRightToLeft, /// 默认，从右往左
    KJBannerViewRollDirectionTypeLeftToRight, /// 从左往右
    KJBannerViewRollDirectionTypeBottomToTop, /// 从下往上
    KJBannerViewRollDirectionTypeTopToBottom, /// 从上往下
};
/// 数据源类型
typedef NS_ENUM(NSInteger, KJBannerViewImageType) {
    KJBannerViewImageTypeMix = 0,  /// 混合，本地图片、网络图片、网络动态图、本地动态图
    KJBannerViewImageTypeLocality, /// 本地图片和本地动态图
    KJBannerViewImageTypeGIFAndNet,/// 网络动态图和网络图片混合
    KJBannerViewImageTypeNetIamge, /// 网络图片
    KJBannerViewImageTypeGIFImage, /// 网络动态图
};
/// 图片的几种类型
typedef NS_ENUM(NSInteger, KJBannerImageInfoType) {
    KJBannerImageInfoTypeLocality = 0,/// 本地图片
    KJBannerImageInfoTypeLocalityGIF, /// 本地动态图
    KJBannerImageInfoTypeNetIamge, /// 网络图片
    KJBannerImageInfoTypeGIFImage, /// 网络动态图
};

NS_INLINE void kGCD_banner_async(dispatch_block_t block) {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(queue)) == 0) {
        block();
    }else{
        dispatch_async(queue, block);
    }
}
NS_INLINE void kGCD_banner_main(dispatch_block_t block) {
    dispatch_queue_t queue = dispatch_get_main_queue();
    if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(queue)) == 0) {
        block();
    }else{
        if ([[NSThread currentThread] isMainThread]) {
            dispatch_async(queue, block);
        }else{
            dispatch_sync(queue, block);
        }
    }
}

#endif /* KJBannerViewType_h */

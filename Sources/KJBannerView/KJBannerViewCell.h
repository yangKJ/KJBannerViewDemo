//
//  KJBannerViewCell.h
//  KJBannerView
//
//  Created by 杨科军 on 2018/2/27.
//  Copyright © 2018年 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo

#import <UIKit/UIKit.h>

@interface KJBannerViewCell : UICollectionViewCell

/// 如果背景不是纯色并且需要切圆角，请设置为yes
@property (nonatomic,assign) BOOL bannerNoPureBack;
/// 是否裁剪，默认NO
@property (nonatomic,assign) BOOL bannerScale;
/// 是否预渲染图片处理，默认yes
@property (nonatomic,assign) BOOL bannerPreRendering;
/// 切圆角，默认为0px
@property (nonatomic,assign) CGFloat bannerRadius;
/// 轮播图片的ContentMode，默认为 UIViewContentModeScaleToFill
@property (nonatomic,assign) UIViewContentMode bannerContentMode;
/// 定制特定方位圆角，默认四个位置
@property (nonatomic,assign) UIRectCorner bannerCornerRadius;
/// 圆角背景颜色，默认KJBannerView背景色
@property (nonatomic,strong) UIColor *bannerRadiusColor;

/// 图片显示控件
@property (nonatomic, strong, readonly) UIImageView *bannerImageView;

/// 图片链接地址，支持动态GIF和网图、本地图等等
@property (nonatomic, strong) NSString * imageURLString;

/// 🎷 是否使用本库提供的图片加载，支持动态GIF网图混合使用
/// 经过预渲染和暂存在缓存区处理，性能方面更优
/// 前提条件，必须引入网络加载模块 pod 'KJBannerView/Downloader'
@property (nonatomic, assign) BOOL useMineLoadImage;

@end

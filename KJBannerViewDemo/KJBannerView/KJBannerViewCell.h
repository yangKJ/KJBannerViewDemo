//
//  KJBannerViewCell.h
//  KJBannerView
//
//  Created by 杨科军 on 2018/2/27.
//  Copyright © 2018年 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo

#import <UIKit/UIKit.h>

@interface KJBannerViewCell : UICollectionViewCell

/// 图片显示控件
@property (nonatomic, strong, readonly) UIImageView *bannerImageView;

/// 图片链接地址，支持动态GIF和网图、本地图等等
@property (nonatomic, strong) NSString * imageURLString;

/// 下一个图片链接地址，用于预加载
@property (nonatomic, strong) NSString * nextImageURLString;

/// 🎷 是否使用本库提供的图片加载，支持动态GIF网图混合使用
/// 经过预渲染和暂存在缓存区处理，性能方面更优
/// 前提条件，必须引入网络加载模块 pod 'KJBannerView/Downloader'
@property (nonatomic, assign) BOOL useMineLoadImage;

@end

//
//  KJBannerViewCell.h
//  KJBannerView
//
//  Created by 杨科军 on 2018/2/27.
//  Copyright © 2018年 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo

#import <UIKit/UIKit.h>
@interface KJBannerDatas : NSObject
@property (nonatomic,strong) UIImage *bannerImage;
@property (nonatomic,strong) NSString *bannerURLString;
@end
@interface KJBannerViewCell : UICollectionViewCell
/// 数据模型，用于自定义 itemClass 样式传递数据
@property (nonatomic,strong) NSObject *model;
/// 使用 KJBannerViewDataSource 方式时候使用
@property (nonatomic,strong) UIView *itemView;

/// 图片显示方式
@property (nonatomic,assign) UIViewContentMode bannerContentMode;
/// 圆角
@property (nonatomic,assign) CGFloat bannerRadius;
/// 是否裁剪
@property (nonatomic,assign) BOOL bannerScale;
/// 自带数据模型
@property (nonatomic,strong) KJBannerDatas *bannerDatas;
/// 占位图
@property (nonatomic,strong) UIImage *bannerPlaceholder;
/// 图片显示控件
@property (nonatomic,strong,readonly) UIImageView *bannerImageView;

@end

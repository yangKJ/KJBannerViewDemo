//
//  KJBannerViewProtocol.h
//  KJBannerViewDemo
//
//  Created by 杨科军 on 2020/3/3.
//  Copyright © 2020 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo
//  委托协议相关

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class KJBannerView;
@class KJBannerViewCell;
@protocol KJBannerViewDelegate <NSObject>
@optional

/// 点击图片回调
/// @param banner 轮播图
/// @param index 点击的图片
- (void)kj_BannerView:(KJBannerView *)banner SelectIndex:(NSInteger)index;

/// 滚动时候回调
/// @param banner 轮播图
/// @param index 滚动时刻当前图片
/// @return 是否隐藏自带的分页控件
- (BOOL)kj_BannerView:(KJBannerView *)banner CurrentIndex:(NSInteger)index;

/// 滚动调用
/// @param banner 轮播图
- (void)kj_BannerViewDidScroll:(KJBannerView *)banner;

@end

@protocol KJBannerViewDataSource <NSObject>

/// 数据源
/// @param banner 轮播图
/// @return 返回轮播图数据源
- (NSArray *)kj_setDatasBannerView:(KJBannerView *)banner;

@optional

/// 定制样式，如无必须需求，请不要使用这种自定义创建方式，内部我做了很多性能优化处理
/// @param banner 轮播图
/// @param size 尺寸
/// @param index 当前的index
/// @return 返回需添加的视图
- (__kindof UIView *)kj_BannerView:(KJBannerView *)banner
                          ItemSize:(CGSize)size
                             Index:(NSInteger)index;

@end

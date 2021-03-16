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
- (void)kj_BannerView:(KJBannerView *)banner SelectIndex:(NSInteger)index;
/// 滚动时候回调，是否隐藏自带的PageControl
- (BOOL)kj_BannerView:(KJBannerView *)banner CurrentIndex:(NSInteger)index;
/// 滚动调用
- (void)kj_BannerViewDidScroll:(KJBannerView *)banner;

@end

@protocol KJBannerViewDataSource <NSObject>
/// 数据源
- (NSArray *)kj_setDatasBannerView:(KJBannerView *)banner;
/// 定制样式
- (__kindof UIView *)kj_BannerView:(KJBannerView *)banner ItemSize:(CGSize)size Index:(NSInteger)index;

@optional
/* ****************************************** 黄金分割线 ******************************************/
/// 定制不同的控件，该方式已废弃
- (UIView*)kj_BannerView:(KJBannerView*)banner BannerViewCell:(KJBannerViewCell*)bannercell ImageDatas:(NSArray*)imageDatas Index:(NSInteger)index DEPRECATED_MSG_ATTRIBUTE("Please use dataSource [kj_BannerView:ItemSize:Index:]");

@end

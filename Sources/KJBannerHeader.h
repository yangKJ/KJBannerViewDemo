//
//  KJBannerHeader.h
//  KJBannerViewDemo
//
//  Created by 杨科军 on 2018/12/23.
//  Copyright © 2018 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo

#ifndef KJBannerHeader_h
#define KJBannerHeader_h

#import "KJBannerView.h" // 轮播Banner
#import "KJPageControl.h" // 分页控件
#import "KJBannerViewTimer.h" // GCD计时器

// 显示网络图片（目前支持设置UIImageView，UIButton，UIView三种）
#if __has_include(<KJBannerView/KJWebImageHeader.h>)
#import <KJBannerView/KJWebImageHeader.h>
#elif __has_include("KJWebImageHeader.h")
#import "KJWebImageHeader.h"
#else
#endif

#endif /* KJBannerHeader_h */

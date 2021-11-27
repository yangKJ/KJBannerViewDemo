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
#import "KJBannerViewFunc.h" // 简单函数

// 显示网络图片（目前支持设置UIImageView，UIButton，UIView三种）
#if __has_include(<KJBannerView/KJWebImageHeader.h>)
#import <KJBannerView/KJWebImageHeader.h>
#elif __has_include("KJWebImageHeader.h")
#import "KJWebImageHeader.h"
#else
#endif

#endif /* KJBannerHeader_h */
/*
*********************************************************************************
*
*⭐️⭐️⭐️ ----- 本人其他库 ----- ⭐️⭐️⭐️
*
扩展库 - Button图文混排、点击事件封装、扩大点击域、点赞粒子效果，
手势封装、圆角渐变、渐变色滑块等，
图片压缩加工处理、滤镜渲染、泛洪算法、识别网址超链接等等
图片处理封装，霍夫矫正，特征提取，形态学处理，滤镜处理等等
pod 'KJEmitterView'
pod 'KJEmitterView/Foundation'
pod 'KJEmitterView/Language' # 多语言模块
pod 'KJEmitterView/Opencv' # Opencv封装使用
pod 'KJEmitterView/LeetCode'

播放器 - 动态切换内核，支持边下边播的播放器方案
* 支持音/视频播放，midi文件播放，直播流媒体播放
* 支持视频边下边播，把播放器播放过的数据流缓存到本地
* 支持断点续载续播，下次直接优先从缓冲读取播放
* 支持缓存管理，清除时间段缓存
* 支持试看，自动跳过片头
* 支持记录上次播放时间，等等等
pod 'KJPlayer' # 播放器功能区
pod 'KJPlayer/AVPlayer' # AVPlayer内核播放器
pod 'KJPlayer/AVDownloader' # AVPlayer附加边播边下边存分支
pod 'KJPlayer/MIDI' # midi内核
pod 'KJPlayer/IJKPlayer' # ijkplayer内核

轮播图 - 支持继承自定义样式 自带网络加载和缓存
pod 'KJBannerView'  # 轮播图，网络图片加载 支持网络GIF和网络图片和本地图片混合轮播

加载Loading - 多种样式供选择 HUD控件封装
pod 'KJLoading' # 加载控件

菜单控件 - 下拉控件 选择控件
pod 'KJMenuView' # 菜单控件

异常处理库 - 包含基本的防崩溃处理
pod 'KJExceptionDemo'

Github地址：https://github.com/yangKJ
简书地址：https://www.jianshu.com/u/c84c00476ab6
博客地址：https://blog.csdn.net/qq_34534179
掘金地址：https://juejin.cn/user/1987535102554472/posts
邮箱地址：ykj310@126.com

* 如果觉得好用,希望您能Star支持,你的 ⭐️ 是我持续更新的动力!
*
*********************************************************************************
*/

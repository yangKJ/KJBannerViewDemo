//
//  KJBannerView.h
//  KJBannerView
//
//  Created by 杨科军 on 2018/2/27.
//  Copyright © 2018年 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo
//  轮播图

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 滚动方法
typedef NS_ENUM(NSInteger, KJBannerViewRollDirectionType) {
    KJBannerViewRollDirectionTypeRightToLeft, /// 默认，从右往左
    KJBannerViewRollDirectionTypeLeftToRight, /// 从左往右
    KJBannerViewRollDirectionTypeBottomToTop, /// 从下往上
    KJBannerViewRollDirectionTypeTopToBottom, /// 从上往下
};
@class KJPageControl;
@class KJBannerViewCell;
@class KJBannerViewFlowLayout;
@protocol KJBannerViewDelegate,KJBannerViewDataSource;
IB_DESIGNABLE
@interface KJBannerView : UIView
/// 代理方法
@property (nonatomic,weak) id<KJBannerViewDelegate> delegate;
@property (nonatomic,weak) id<KJBannerViewDataSource> dataSource;

//************************ API ************************
/// 是否缩放，默认no
@property (nonatomic,assign) IBInspectable BOOL isZoom;
/// 是否无线循环，默认yes
@property (nonatomic,assign) IBInspectable BOOL infiniteLoop;
/// 是否自动滑动，默认yes
@property (nonatomic,assign) IBInspectable BOOL autoScroll;
/// 是否显示分页控件，默认yes
@property (nonatomic,assign) IBInspectable BOOL showPageControl;
/// 自动滚动间隔时间，默认2s
@property (nonatomic,assign) IBInspectable CGFloat autoTime;
/// Cell宽度，默认控件宽度
@property (nonatomic,assign) IBInspectable CGFloat itemWidth;
/// Cell间距，默认0px
@property (nonatomic,assign) IBInspectable CGFloat itemSpace;
/// 占位图，用于网络未加载到图片时
@property (nonatomic,strong) UIImage *placeholderImage;
/// 滚动方向，默认从右到左
@property (nonatomic,assign) KJBannerViewRollDirectionType rollType;
/// 当前位置
@property (nonatomic,assign,readonly) NSInteger currentIndex;
/// 分页控制器
@property (nonatomic,strong,readonly) KJPageControl *pageControl;
/// 布局信息
@property (nonatomic,strong,readonly) KJBannerViewFlowLayout *layout;

/// 注册一个类，用于创建 `UICollectionViewCell`
/// @param clazz 类
/// @param identifier 标识符
- (void)registerClass:(Class)clazz forCellWithReuseIdentifier:(NSString *)identifier;

/// 注册一个类，用于创建 `UICollectionViewCell`
/// @param nib UINib
/// @param identifier 标识符
- (void)registerNib:(UINib *)nib forCellWithReuseIdentifier:(NSString *)identifier;

/// 创建 `UICollectionViewCell`
/// @param identifier 标识符
/// @param index 下标
- (__kindof KJBannerViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier
                                                             forIndex:(NSInteger)index;
/// 刷新
- (void)reloadData;

/// 滚动到指定位置
/// @param index 指定位置
/// @param animated 是否执行动画
- (void)scrollToItemAtIndex:(NSInteger)index animated:(BOOL)animated;

/// 暂停计时器滚动处理，备注：在viewDidDisappear当中实现
- (void)kj_pauseTimer;

/// 继续计时器滚动，备注：在viewDidAppear当中实现
- (void)kj_repauseTimer;

/// 使用Masonry自动布局，请在设置布局之后调用该方法
- (void)kj_useMasonry;

@end

/// 委托协议代理
@protocol KJBannerViewDataSource <NSObject>

/// 数据源
/// @param banner 轮播图
/// @return 返回轮播图数据源
- (NSInteger)kj_numberOfItemsInBannerView:(KJBannerView *)banner;

/// 定制专有样式
/// @param banner 轮播图
/// @param index 索引
/// @return 返回定制样式Cell
- (__kindof KJBannerViewCell *)kj_bannerView:(KJBannerView *)banner
                          cellForItemAtIndex:(NSInteger)index;

@optional

/// 预渲染下一个Cell图片内容
/// @param banner 轮播图
/// @param index 下一个对应索引
/// @return 返回预渲染图片链接地址
- (nullable NSString *)kj_bannerView:(KJBannerView *)banner
     nextPreRenderedImageItemAtIndex:(NSInteger)index;

/// 返回预渲染图片
/// @param banner 轮播图
/// @param image 预渲染图片
- (void)kj_bannerView:(KJBannerView *)banner preRenderedImage:(UIImage *)image;

@end

@protocol KJBannerViewDelegate <NSObject>

@optional

/// 点击图片响应
/// @param banner 轮播图
/// @param index 索引
- (void)kj_bannerView:(KJBannerView *)banner didSelectItemAtIndex:(NSInteger)index;

/// 轮播滚动时刻响应
/// @param banner 轮播图
/// @param index 索引
- (void)kj_bannerView:(KJBannerView *)banner loopScrolledItemAtIndex:(NSInteger)index;

/// 滚动调用
/// @param banner 轮播图
- (void)kj_bannerViewDidScroll:(KJBannerView *)banner;

@end

NS_ASSUME_NONNULL_END

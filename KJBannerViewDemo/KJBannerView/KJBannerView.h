//
//  KJBannerView.h
//  KJBannerView
//
//  Created by 杨科军 on 2018/2/27.
//  Copyright © 2018年 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo
//  轮播图

#import <UIKit/UIKit.h>
#import "KJBannerViewType.h"
#import "KJBannerViewProtocol.h"
#import "KJPageView.h"
#import "KJBannerViewFlowLayout.h"
NS_ASSUME_NONNULL_BEGIN
IB_DESIGNABLE
@interface KJBannerView : UIView
/// 代理方法
@property (nonatomic,weak) id<KJBannerViewDelegate> delegate;
@property (nonatomic,weak) id<KJBannerViewDataSource> dataSource;
/// 暂停计时器滚动处理，备注：在viewDidDisappear当中实现
- (void)kj_pauseTimer;
/// 继续计时器滚动，备注：在viewDidAppear当中实现
- (void)kj_repauseTimer;
/// 滚动到指定位置，备注：需要在设置数据源之后调用
- (void)kj_makeScrollToIndex:(NSInteger)index;
/// 使用Masonry自动布局，请在设置布局之后调用该方法
- (void)kj_useMasonry;
/// 设置完数据之后，请刷新
- (void)kj_reloadBannerViewDatas;

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
/// cell宽度，左右宽度
@property (nonatomic,assign) IBInspectable CGFloat itemWidth;
/// cell间距，默认为0
@property (nonatomic,assign) IBInspectable CGFloat itemSpace;
/// 滚动方向，默认从右到左
@property (nonatomic,assign) KJBannerViewRollDirectionType rollType;
/// 分页控制器
@property (nonatomic,strong,readonly) KJPageView *pageControl;
/// 当前位置
@property (nonatomic,assign,readonly) NSInteger currentIndex;
/// 布局信息
@property (nonatomic,strong,readonly) KJBannerViewFlowLayout *layout;

//************************ 废弃属性方法 *****************************/
/// 支持自定义Cell，自定义Cell需继承自 KJBannerViewCell，和委托的自定义方式互斥
/// 备注：性能上面这种自定义方式其实优于委托的自定义方式，只是这种方式要创建继承于KJBannerViewCell的Cell，略显麻烦
@property (nonatomic,strong) Class itemClass DEPRECATED_MSG_ATTRIBUTE("Please use dataSource [kj_BannerView:ItemSize:Index:]");
/// 数据源
@property (nonatomic,strong) NSArray *imageDatas DEPRECATED_MSG_ATTRIBUTE("Please use dataSource [kj_setDatasBannerView:]");

@end

//******************** 自带KJBannerViewCell可设置属性 ********************
//备注：必须引入网络加载模块 pod 'KJBannerView/Downloader'
@interface KJBannerView (KJBannerViewCell)
/// 如果背景不是纯色并且需要切圆角，请设置为yes
@property (nonatomic,assign) BOOL bannerNoPureBack;
/// 是否裁剪，默认yes
@property (nonatomic,assign) BOOL bannerScale;
/// 是否预渲染图片处理，默认yes
@property (nonatomic,assign) BOOL bannerPreRendering;
/// 切圆角，默认为0px
@property (nonatomic,assign) CGFloat bannerRadius;
/// 占位图，用于网络未加载到图片时
@property (nonatomic,strong) UIImage *placeholderImage;
/// 轮播图片的ContentMode，默认为 UIViewContentModeScaleToFill
@property (nonatomic,assign) UIViewContentMode bannerContentMode;
/// 定制特定方位圆角，默认四个位置
@property (nonatomic,assign) UIRectCorner bannerCornerRadius;

@end

@interface KJBannerView (KJBannerBlock)
/// 点击回调
@property (nonatomic,readwrite,copy) void(^kSelectBlock)(KJBannerView *banner, NSInteger idx);
/// 滚动回调
@property (nonatomic,readwrite,copy) void(^kScrollBlock)(KJBannerView *banner, NSInteger idx);

@end
NS_ASSUME_NONNULL_END

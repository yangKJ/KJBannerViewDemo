# KJBannerView

<p align="left">
<img src="https://upload-images.jianshu.io/upload_images/1933747-82138031f05852ab.gif?imageMogr2/auto-orient/strip" width="" hspace="1px">
</p>

### 功能介绍
KJBannerView 是一款轮播Banner，支持动态图和网图混播  
1. 缩放无限自动循环滚动  √    
2. 支持四种方向滚动，从左往右、从右往左、从上往下、从下往上  √  
3. 自定义继承，定制不同样式，详情使用请见Demo  √  
4. 支持网络动态图和网络图片和本地图片混合轮播  √  
5. 支持在Storyboard和Xib中创建并配置其属性  √  
6. 提供多种分页控件PageControl显示  √  
7. 自带缓存加载，内部封装网图下载缓存工具  √  
8. 清理指定时间段以前的图片资源数据  √  

----------------------------------------

### 使用方法
```
pod 'KJBannerView' # 轮播图 
pod 'KJBannerView/Downloader' # 网络加载板块
```

### API & Property
```
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
/// 自动滚动间隔时间，默认2s
@property (nonatomic,assign) IBInspectable CGFloat autoTime;
/// 是否无线循环，默认yes
@property (nonatomic,assign) IBInspectable BOOL infiniteLoop;
/// 是否自动滑动，默认yes
@property (nonatomic,assign) IBInspectable BOOL autoScroll;
/// 是否缩放，默认不缩放
@property (nonatomic,assign) IBInspectable BOOL isZoom;
/// cell宽度，左右宽度
@property (nonatomic,assign) IBInspectable CGFloat itemWidth;
/// cell间距，默认为0
@property (nonatomic,assign) IBInspectable CGFloat itemSpace;
/// 是否显示分页控件，默认yes
@property (nonatomic,assign) IBInspectable BOOL showPageControl;
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
/// 切圆角，默认为0px
@property (nonatomic,assign) CGFloat bannerRadius;
/// 占位图，用于网络未加载到图片时
@property (nonatomic,strong) UIImage *placeholderImage;
/// 轮播图片的ContentMode，默认为 UIViewContentModeScaleToFill
@property (nonatomic,assign) UIViewContentMode bannerContentMode;
/// 定制特定方位圆角，默认四个位置
@property (nonatomic,assign) UIRectCorner bannerCornerRadius;
/// 是否裁剪，默认yes
@property (nonatomic,assign) BOOL bannerScale;
/// 是否预渲染图片处理，默认yes
@property (nonatomic,assign) BOOL bannerPreRendering;

@end

@interface KJBannerView (KJBannerBlock)
/// 点击回调
@property (nonatomic,readwrite,copy) void(^kSelectBlock)(KJBannerView *banner, NSInteger idx);
/// 滚动回调
@property (nonatomic,readwrite,copy) void(^kScrollBlock)(KJBannerView *banner, NSInteger idx);

@end
NS_ASSUME_NONNULL_END
```

### KJBannerView类介绍
| Class | 功能区 |
| :--- | :--- |
| KJBannerView | 轮播图主控件 |
| KJPageView | 自定义分页控件 |
| KJBannerViewFlowLayout | Cell缩放管理 |
| KJBannerViewCell | 基类，自定义需继承该Cell |
| KJBannerViewType | 枚举文件夹 |
| KJBannerViewProtocol | 委托协议相关 |
| NSTimer+KJSolve | 计时器分类 |
| UIImage+KJBannerGIF | 动态图分类 |
| KJBannerViewCacheManager | 缓存工具 |
| KJBannerViewDownloader | 网络请求工具 |
| KJBannerViewLoadManager | 网图下载工具 |
| KJBannerWebImageHandle | 网图和动态图下载显示协议 |
| UIView+KJWebImage | 显示网络图片（目前支持设置UIImageView，UIButton，UIView三种） |

#### 支持Xib快捷设置属性
![Xib](https://upload-images.jianshu.io/upload_images/1933747-0c4b715868e47746.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/666)

### 效果图
![轮播图](https://upload-images.jianshu.io/upload_images/1933747-2e51515ae91af6d4.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/666)

#### 下载测试效果图，图片采用信号量方式获取
![IMG_0145.PNG](https://upload-images.jianshu.io/upload_images/1933747-ea228edad91a2dcd.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/666)


#### <a id="打赏作者"></a>打赏作者
<!--user:用户名 repo:仓库名字 type:star count:数量-->
* 如果你觉得有帮助，还请为我 <iframe
style="margin-left: 2px; margin-bottom:-5px;"
frameborder="0" scrolling="0" width="100px" height="20px"
src="https://ghbtns.com/github-btn.html?user=yangKJ&repo=KJBannerViewDemo&type=star&count=true" ></iframe>   
* 如果在使用过程中遇到Bug，希望你能Issues，我会及时修复  
* 大家有什么需要添加的功能，也可以给我留言，有空我将补充完善  
* 谢谢大家的支持 - -！  

#### 联系方式 ** [Github地址](https://github.com/yangKJ) | [简书地址](https://www.jianshu.com/u/c84c00476ab6) | [博客地址](https://blog.csdn.net/qq_34534179) | [掘金地址](https://juejin.cn/user/1987535102554472/posts)

[![谢谢老板](https://upload-images.jianshu.io/upload_images/1933747-879572df848f758a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)](https://github.com/yangKJ/KJBannerViewDemo)

#### 救救孩子吧，谢谢各位老板～～～～

## <a id="更新日志"></a>[更新日志](https://github.com/yangKJ/KJBannerViewDemo/blob/master/CHANGELOG.md)

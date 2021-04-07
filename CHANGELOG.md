# <a id="功能介绍"></a>功能介绍
KJBannerView 是一款轮播Banner，支持gif和url混播，自带图片下载和缓存    
1. 缩放无限自动循环滚动  √    
2. 支持四种方向滚动，从左往右、从右往左、从上往下、从下往上  √  
3. 自定义继承，定制不同样式，详情使用请见Demo  √  
4. 支持网络动态图和网络图片和本地图片混合轮播  √  
5. 支持在Storyboard和Xib中创建并配置其属性  √  
6. 提供多种分页控件PageControl显示  √  
7. 自带缓存加载，内部封装网图下载缓存工具  √  
8. 清理指定时间段以前的图片资源数据  √  

> 备注：快捷打开浏览器命令，command + shift + 鼠标左键

# 版本更新日志
### [版本2.1.6](https://github.com/yangKJ/KJBannerViewDemo/tree/2.1.6)
- 解决一条数据点击不响应问题
- 优化一下，规范代码

### [版本2.1.3](https://github.com/yangKJ/KJBannerViewDemo/tree/2.1.3)
- 抽离网络加载部分，pod 'KJBannerView/Downloader'
- 新增网络加载部分预渲染图片处理 `bannerPreRendering`

### [版本2.1.2](https://github.com/yangKJ/KJBannerViewDemo/tree/2.1.2)
- 更高效的圆角切割，避免离屏渲染
- 更换计时器，替换为异步GCD计时器
- 新增定制特定方位圆角字段
- 修复字段重名情况

### [版本2.1.0](https://github.com/yangKJ/KJBannerViewDemo/tree/2.1.0)
- 更换动态图处理播放控件，移除数据源类型
- 修改为异步播放本地动态图
- 去除原先的 UIImageView+KJWebImage、UIButton+KJWebImage
- 合并网图加载分类 UIView+KJWebImage
- 新增 KJBannerTimingClearManager 清理指定时间段以前的图片资源数据

### [版本2.0.11](https://github.com/yangKJ/KJBannerViewDemo/tree/2.0.11)
- 简练代码逻辑，整理修改重复代码
- 新增 UIView+KJWebImage 显示View内容图片

### [版本2.0.10](https://github.com/yangKJ/KJBannerViewDemo/tree/2.0.10)
- 修改网图显示，新增 KJBannerWebImageHandle 关联
- 性能优化，完善逻辑处理

### [版本2.0.9](https://github.com/yangKJ/KJBannerViewDemo/tree/2.0.9)
- 移除不再使用数据，优化逻辑操作
- 新增 UIImageView+KJWebImage 图片显示处理

### [版本2.0.8](https://github.com/yangKJ/KJBannerViewDemo/tree/2.0.8)
- 解决偶尔出现 Thread 1: EXC_ARITHMETIC (code=EXC_I386_DIV, subcode=0x0)
- 修复首次加载不出现问题，优化性能

### [版本2.0.7](https://github.com/yangKJ/KJBannerViewDemo/tree/2.0.7)
- KJPageView 新增显示位置属性 displayType 和 距离边界间隙 space
- 完善自定义控件方式 itemClass

### [版本2.0.6](https://github.com/yangKJ/KJBannerViewDemo/tree/2.0.6)
- 属性 rollType 新增从上往下和从下往上两种滚动方向
- 新增属性 showPageControl 是否显示分页控件
- 适配Masonry布局，请调用方法 kj_useMasonry

### [版本2.0.5](https://github.com/yangKJ/KJBannerViewDemo/tree/2.0.5)
- KJPageView 优化修改选中

### [版本2.0.4](https://github.com/yangKJ/KJBannerViewDemo/tree/2.0.4)
- KJBannerViewLoadManager 新增是否开启异步字段 `useAsync`
- 新增 KJBannerViewCacheManager+KJBannerGIF 动态图缓存相关 

### [版本2.0.3](https://github.com/yangKJ/KJBannerViewDemo/tree/2.0.3)
- 新增本地动态图播放
- KJBannerView 新增是否需要动态图缓存字段 `openGIFCache`

### [版本2.0.1](https://github.com/yangKJ/KJBannerViewDemo/tree/2.0.1)
- 优化自带第一条数据不显示问题
- 优化卡顿问题
- KJBannerView 修改xib属性字段名

### [版本2.0.0](https://github.com/yangKJ/KJBannerViewDemo/tree/2.0.0)
- 重写网络请求板块，
- 封装网络请求工具：KJBannerViewDownloader
- 缓存工具：KJBannerViewCacheManager
- 网图下载工具：KJBannerViewLoadManager

### [版本1.3.8](https://github.com/yangKJ/KJBannerViewDemo/tree/1.3.8)
- 新增委托方法 `kj_BannerViewDidScroll:`

### [版本1.3.7](https://github.com/yangKJ/KJBannerViewDemo/tree/1.3.7)
- 新增动态图分类，替换原先的动态图播放方式
- 去掉单例，优化数据的获取方式
- 解决数据源为空的处理

### [版本1.3.6](https://github.com/yangKJ/KJBannerViewDemo/tree/1.3.6)
- KJPageView 新增属性 margin 用于方块之间微微调整
- KJPageView 新增属性 dotwidth和dotheight 用于方块尺寸调整
- KJPageView 优化解决不居中问题

### [版本1.3.5](https://github.com/yangKJ/KJBannerViewDemo/tree/1.3.5)
- 独立委托协议类KJBannerViewProtocol，归类代码更加简洁
- 新增滚动回调 `kScrollBlock`

### [版本1.3.4](https://github.com/yangKJ/KJBannerViewDemo/tree/1.3.4)
- 解决只有一张图片显示异常问题
- 多线程处理gif数据，再次提升效率

### [版本1.3.3](https://github.com/yangKJ/KJBannerViewDemo/tree/1.3.3)
- 优化图片下载速率，解决卡顿问题
- 修改`kj_BannerView:BannerViewCell:ImageDatas:Index:`委托方法，解决Memory疯涨问题

### [版本1.3.2](https://github.com/yangKJ/KJBannerViewDemo/tree/1.3.2)
- 新增 NSTimer+KJSolve 解决计时器循环引用

### [版本1.3.0](https://github.com/yangKJ/KJBannerViewDemo/tree/1.3.0)
- 新增KJBannerViewDataSource委托，更方便的自定义方式 不需要再继承 KJBannerViewCell
- `kj_BannerView:BannerViewCell:ImageDatas:Index:`此方法和 `itemClass` 互斥
- Banner支持在Storyboard和Xib中创建并配置其属性
- 新增裁剪网络图片从而提高效率 bannerScale

### [版本1.2.6](https://github.com/yangKJ/KJBannerViewDemo/tree/1.2.6)
- KJPageView 新增大小点类型 PageControlStyleSizeDot
- 优化修改网友提出的卡顿问题
- 移出 KJBannerViewCell 当中的判断处理，从而提高效率

### [版本1.2.5](https://github.com/yangKJ/KJBannerViewDemo/tree/1.2.5)
- 新增委托方法 `kj_BannerView:CurrentIndex:` 滚动时候回调 可是否隐藏自带的PageControl
- 优化性能，修复重复创建PageControl

### [版本1.2.4](https://github.com/yangKJ/KJBannerViewDemo/tree/1.2.4)
- 新增本地和网络图片混合，自带判断方式，去掉以前的本地判断方式
- 新增Gif图显示，支持本地图片、网络图片、网络GIF图片混合显示
- KJBannerViewImageType 控制图片的显示类型

### [版本1.2.2](https://github.com/yangKJ/KJBannerViewDemo/tree/1.2.2)
- 修改pageControl样式颜色的修改方式，从而提高效率

### [版本1.2.1](https://github.com/yangKJ/KJBannerViewDemo/tree/1.2.1)
- 再次优化，提高性能
- 新增自带Cell显示本地图片 `isLocalityImage`

### [版本1.2.0](https://github.com/yangKJ/KJBannerViewDemo/tree/1.2.0)
- KJPageView 支持3种样式（圆形，长方形，正方形）
- 重新整理，从而提高轮播图性能
- 自带Cell新增默认占位图，一条数据时隐藏KJPageControl

### [版本1.1.1](https://github.com/yangKJ/KJBannerViewDemo/tree/1.1.1)
- 新增支持Swift宏
- 新增Block代理点击事件 KJBannerViewBlock
- 新增设置滚动方向属性 `rollType`

### [版本1.1.0](https://github.com/yangKJ/KJBannerViewDemo/tree/1.1.0)
- 新增支持自定义Cell
- 继承KJBannerViewCell，然后在model设置数据

### 版本1.0.2
- 新增 KJBannerView 轮播图 - banner支持缩放
- 自带图片下载和缓存相关功能，无三方依赖、轻量级组件

# <a id="作者信息"></a>作者信息
### [Github地址](https://github.com/yangKJ) | [简书地址](https://www.jianshu.com/u/c84c00476ab6) | [博客地址](https://blog.csdn.net/qq_34534179) | [掘金地址](https://juejin.cn/user/1987535102554472/posts)

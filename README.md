# KJBannerView

<p align="left">
<img src="https://upload-images.jianshu.io/upload_images/1933747-82138031f05852ab.gif?imageMogr2/auto-orient/strip" width="280" hspace="1px">
</p>

### 功能介绍
KJBannerView 是一款轮播Banner，支持网络GIF和网络图片和本地图片混合轮播  

- [x] 缩放无限自动循环滚动  √    
- [x] 预加载渲染处理，缓存区缓存图片资源处理  √    
- [x] 支持四种方向滚动，从左往右、从右往左、从上往下、从下往上  √  
- [x] 自定义继承，定制不同样式，详情使用请见Demo  √  
- [x] 支持网络动态图和网络图片和本地图片混合轮播  √  
- [x] 支持在Storyboard和Xib中创建并配置其属性  √  
- [x] 提供多种分页控件PageControl显示  √  
- [x] 自带缓存加载，内部封装网图下载缓存工具  √  
- [x] 清理指定时间段以前的图片资源数据  √  

----

### KJBannerView类介绍
| Class | 功能区 |
| :--- | :--- |
| KJBannerView | 轮播图主控件 |
| KJBannerViewCell | 基类，自定义需继承该Cell |
| KJBannerViewFlowLayout | Cell缩放管理 |
| KJBannerViewFunc | 简单函数 |
| KJBannerViewTimer | 计时器 |
| KJPageView | 自定义分页控件 |
| KJBannerViewPreRendered | 预渲染管理器 |

### Downloader类介绍
| Class | 功能区 |
| :--- | :--- |
| KJAutoPurgingImageCache | 定时清理缓存工具 |
| KJImageCache | 缓存工具 |
| KJNetworkManager | 网络请求工具 |
| KJWebImageDownloader | 网图下载工具 |
| UIView+KJWebImage | 显示网络图片（目前支持设置UIImageView，UIButton，UIView三种） |

#### 支持Xib快捷设置属性
![Xib](https://upload-images.jianshu.io/upload_images/1933747-0c4b715868e47746.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/666)

### 效果图
![轮播图](https://upload-images.jianshu.io/upload_images/1933747-2e51515ae91af6d4.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/666)

- 下载测试效果图，图片采用信号量方式获取
![IMG_0145.PNG](https://upload-images.jianshu.io/upload_images/1933747-ea228edad91a2dcd.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/666)

### CocoaPods Install
```
pod 'KJBannerView' # 轮播图 
pod 'KJBannerView/Downloader' # 网络加载板块
```

### 关于作者
- 🎷 **邮箱地址：[ykj310@126.com](ykj310@126.com) 🎷**
- 🎸 **GitHub地址：[yangKJ](https://github.com/yangKJ) 🎸**
- 🎺 **掘金地址：[茶底世界之下](https://juejin.cn/user/1987535102554472/posts) 🎺**
- 🚴🏻 **简书地址：[77___](https://www.jianshu.com/u/c84c00476ab6) 🚴🏻**

----

> <font color=red>**觉得有帮助的老哥们，请帮忙点个星 ⭐..**</font>

**救救孩子吧，谢谢各位老板。**

🥺

-----

# KJBannerView

<p align="left">
<img src="https://upload-images.jianshu.io/upload_images/1933747-f7fbb91e9088f39e.gif?imageMogr2/auto-orient/strip" width="" hspace="1px">
</p>

#### <a id="功能介绍"></a>功能介绍
KJBannerView 是一款轮播Banner，支持gif和url混播，自带图片下载和缓存    
1、无任何第三方依赖、自带缓存加载  ☑️  
2、缩放无限循环滚动  ☑️    
3、支持四种方向滚动，从左往右、从右往左、从上往下、从下往上  ☑️  
4、自定义继承 KJBannerViewCell、定制特定样式  ☑️  
5、支持每种Cell都定制不同的样式，详情使用请见Demo  ☑️  
6、支持网络动态图GIF和网络图片和本地图片混合轮播  ☑️  
7、支持在Storyboard和Xib中创建并配置其属性  ☑️  
8、提供多种Pagecontrol显示  ☑️  
9、内部封装网图下载缓存工具  ☑️  

----------------------------------------
### 框架整体介绍
* [功能介绍](#功能介绍)
* [更新日志](#更新日志)
* [KJBannerView 功能区](#KJBannerView)
* [效果图](#效果图)
* [打赏作者 &radic;](#打赏作者)

#### <a id="使用方法(支持cocoapods/carthage安装)"></a>Pod使用方法
```
pod 'KJBannerView' # 轮播图 
```

## <a id="更新日志"></a>[更新日志](https://github.com/yangKJ/KJBannerViewDemo/blob/master/CHANGELOG.md)

#### <a id="KJBannerView"></a>KJBannerView
- KJPageControl：自定义三种PageControl  长方形、正方形、圆形
- KJBannerViewFlowLayout：Cell缩放管理
- KJBannerViewCell：基类Cell，自定义的Cell需继承该Cell
- KJBannerDatasInfo：自带BannerViewCell数据模型
- KJLoadImageView：图片下载工具类
- KJBannerTool：工具方法
- KJBannerViewCacheManager：缓存工具
- KJBannerViewDownloader：网络请求工具
- KJBannerViewLoadManager：网图下载工具

#### 支持Xib快捷设置属性
![Xib](https://upload-images.jianshu.io/upload_images/1933747-0c4b715868e47746.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/666)

#### <a id="效果图"></a>效果图
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


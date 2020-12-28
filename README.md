# KJBannerView

<p align="left">
<img src="https://upload-images.jianshu.io/upload_images/1933747-f7fbb91e9088f39e.gif?imageMogr2/auto-orient/strip" width="" hspace="1px">
</p>

#### <a id="功能介绍"></a>功能介绍
KJBannerView 是一款轮播Banner，自带图片下载和缓存    
1、无任何第三方依赖、自带缓存加载  ☑️  
2、缩放无限循环滚动  ☑️  
3、自定义继承 KJBannerViewCell、定制特定样式  ☑️  
4、支持每种Cell都定制不同的样式，详情使用请见Demo  ☑️   
5、支持网络动态图GIF和网络图片和本地图片混合轮播  ☑️  
6、支持在Storyboard和Xib中创建并配置其属性  ☑️  
7、提供多种Pagecontrol显示  ☑️  
8、内部封装网图下载缓存工具  ☑️

----------------------------------------
### 框架整体介绍
* [功能介绍](#功能介绍)
* [作者信息](#作者信息)
* [更新日志](#更新日志)
* [KJBannerView 功能区](#KJBannerView)
* [效果图](#效果图)
* [打赏作者 &radic;](#打赏作者)

#### <a id="作者信息"></a>作者信息
> Github地址：https://github.com/yangKJ  
> 简书地址：https://www.jianshu.com/u/c84c00476ab6  
> 博客地址：https://blog.csdn.net/qq_34534179  
> 掘金地址：https://juejin.cn/user/1987535102554472/posts

#### <a id="作者其他库"></a>作者其他Pod库
```
/*
*********************************************************************************
*
*⭐️⭐️⭐️ ----- 本人其他库 ----- ⭐️⭐️⭐️
*
粒子效果、自定义控件、自定义选中控件
pod 'KJEmitterView'
pod 'KJEmitterView/Control' # 自定义控件
 
扩展库 - Button图文混排、点击事件封装、扩大点击域、点赞粒子效果，
手势封装、圆角渐变、倒影、投影、内阴影、内外发光、渐变色滑块等，
图片压缩加工处理、滤镜渲染、泛洪算法、识别网址超链接等等
pod 'KJExtensionHandler'
pod 'KJExtensionHandler/Foundation'
pod 'KJExtensionHandler/Language' # 多语言模块

基类库 - 封装整理常用，采用链式处理，提炼独立工具
pod 'KJBaseHandler'
pod 'KJBaseHandler/Tool' # 工具相关
pod 'KJBaseHandler/Router' # 路由相关

播放器 - KJPlayer是一款视频播放器，AVPlayer的封装，继承UIView
视频可以边下边播，把播放器播放过的数据流缓存到本地，下次直接从缓冲读取播放
pod 'KJPlayer' # 播放器功能区
pod 'KJPlayer/KJPlayerView' # 自带展示界面

轮播图 - 支持缩放 多种pagecontrol 支持继承自定义样式 自带网络加载和缓存
pod 'KJBannerView'  # 轮播图，网络图片加载 支持网络GIF和网络图片和本地图片混合轮播

加载Loading - 多种样式供选择 HUD控件封装
pod 'KJLoading' # 加载控件

菜单控件 - 下拉控件 选择控件
pod 'KJMenuView' # 菜单控件

工具库 - 推送工具、网络下载工具、识别网页图片工具等
pod 'KJWorkbox' # 系统工具
pod 'KJWorkbox/CommonBox'

异常处理库 - 包含基本的防崩溃处理（数组，字典，字符串）
pod 'KJExceptionDemo'

* 如果觉得好用,希望您能Star支持,你的 ⭐️ 是我持续更新的动力!
*
*********************************************************************************
*/
```

#### <a id="使用方法(支持cocoapods/carthage安装)"></a>Pod使用方法
```
pod 'KJBannerView' # 轮播图 
```

# <a id="更新日志"></a>[更新日志](https://github.com/yangKJ/KJBannerViewDemo/blob/master/CHANGELOG.md)

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

#### <a id="温馨提示"></a>温馨提示
#####1、使用第三方库Xcode报错  
Cannot synthesize weak property because the current deployment target does not support weak references  
可在`Podfile`文件底下加入下面的代码，'8.0'是对应的部署目标（deployment target） 删除库重新Pod  
不支持用weak修饰属性，而weak在使用ARC管理引用计数项目中才可使用  
遍历每个develop target，将target支持版本统一设成一个支持ARC的版本

```
##################加入代码##################
# 使用第三方库xcode报错Cannot synthesize weak property because the current deployment target does not support weak references
post_install do |installer|
installer.pods_project.targets.each do |target|
target.build_configurations.each do |config|
config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '8.0'
end
end
end
##################加入代码##################
```
#####2、若搜索不到库
- 方案1：可执行pod repo update
- 方案2：使用 rm ~/Library/Caches/CocoaPods/search_index.json 移除本地索引然后再执行安装
- 方案3：更新一下 CocoaPods 版本

----------------------------------------

#### <a id="打赏作者"></a>打赏作者
<!--user:用户名 repo:仓库名字 type:star count:数量-->
* 如果你觉得有帮助，还请为我 <iframe
style="margin-left: 2px; margin-bottom:-5px;"
frameborder="0" scrolling="0" width="100px" height="20px"
src="https://ghbtns.com/github-btn.html?user=yangKJ&repo=KJBannerViewDemo&type=star&count=true" ></iframe>   
* 如果在使用过程中遇到Bug，希望你能Issues，我会及时修复  
* 大家有什么需要添加的功能，也可以给我留言，有空我将补充完善  
* 谢谢大家的支持 - -！  

[![谢谢老板](https://upload-images.jianshu.io/upload_images/1933747-879572df848f758a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)](https://github.com/yangKJ/KJBannerViewDemo)

#### 救救孩子吧，谢谢各位老板～～～～


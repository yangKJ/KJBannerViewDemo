Pod::Spec.new do |s|
  s.name         = "KJBannerView"
  s.version      = "2.0.9"
  s.summary      = "KJBannerView是一款自带图片下载和缓存轮播Banner，支持动态图和网图混合显示"
  s.homepage     = "https://github.com/yangKJ/KJBannerViewDemo"
  s.license      = "MIT"
  s.license      = {:type => "MIT", :file => "LICENSE"}
  s.license      = "Copyright (c) 2018 yangkejun"
  s.author       = {"77" => "ykj310@126.com"}
  s.platform     = :ios
  s.source       = {:git => "https://github.com/yangKJ/KJBannerViewDemo.git", :tag => "#{s.version}"}
  s.social_media_url = 'https://www.jianshu.com/u/c84c00476ab6'
  s.requires_arc = true
  
  s.default_subspec  = 'KJBannerView'
  s.ios.source_files = 'KJBannerViewDemo/KJBannerHeader.h' 

  s.subspec 'KJBannerView' do |ss|
    ss.source_files = "KJBannerViewDemo/KJBannerView/*.{h,m}"
    ss.resources = "KJBannerViewDemo/KJBannerView/*.{bundle}","CHANGELOG.md"
    ss.frameworks = 'Foundation','UIKit'
  end

end



Pod::Spec.new do |s|
  s.name         = "KJBannerView"
  s.version      = "2.1.3"
  s.summary      = "KJBannerView是一款自带图片下载和缓存轮播Banner，支持动态图和网图混合显示"
  s.homepage     = "https://github.com/yangKJ/KJBannerViewDemo"
  s.description  = 'https://github.com/yangKJ/KJBannerViewDemo/blob/master/README.md'
  s.license      = "MIT"
  s.license      = {:type => "MIT", :file => "LICENSE"}
  s.license      = "Copyright (c) 2018 yangkejun"
  s.author       = {"77" => "ykj310@126.com"}
  s.platform     = :ios
  s.source       = {:git => "https://github.com/yangKJ/KJBannerViewDemo.git", :tag => "#{s.version}"}
  s.social_media_url = 'https://www.jianshu.com/p/47b29be42a49'
  s.requires_arc = true
  
  s.default_subspec  = 'KJBannerView'
  s.ios.source_files = 'KJBannerViewDemo/KJBannerHeader.h' 

  s.subspec 'KJBannerView' do |ss|
    ss.source_files = "KJBannerViewDemo/KJBannerView/*.{h,m}"
    ss.resources = "KJBannerViewDemo/KJBannerView/*.{bundle}","CHANGELOG.md"
  end
  
  s.subspec 'Downloader' do |dd|
    dd.source_files = "KJBannerViewDemo/Downloader/*.{h,m}"
  end

  s.frameworks = 'Foundation','UIKit'
  
end

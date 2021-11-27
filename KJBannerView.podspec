Pod::Spec.new do |s|
  s.name         = "KJBannerView"
  s.version      = "3.0.1"
  s.summary      = "KJBannerView是一款自带图片下载和缓存轮播Banner，支持动态图和网图混合显示"
  s.homepage     = "https://github.com/yangKJ/KJBannerViewDemo"
  s.description  = 'https://github.com/yangKJ/KJBannerViewDemo/blob/master/README.md'
  s.license      = "MIT"
  s.license      = {:type => "MIT", :file => "LICENSE"}
  s.license      = "Copyright (c) 2018 yangkejun"
  s.author       = {"77" => "ykj310@126.com"}
  s.source       = {:git => "https://github.com/yangKJ/KJBannerViewDemo.git", :tag => "#{s.version}"}
  s.platform     = :ios
  s.social_media_url = 'https://www.jianshu.com/p/47b29be42a49'
  s.requires_arc = true
  
  s.ios.deployment_target = '9.0'
  s.ios.pod_target_xcconfig = { 'PRODUCT_BUNDLE_IDENTIFIER' => 'com.yangkejun.KJBannerViewDemo' }
  
  s.default_subspec  = 'BannerView'
  s.ios.source_files = 'Sources/KJBannerHeader.h'

  s.subspec 'BannerView' do |ss|
    ss.source_files = "Sources/KJBannerView/*.{h,m}","Sources/PageControl/*.{h,m}"
    ss.resources = "Sources/KJBannerView/*.{bundle}"
  end
  
  s.subspec 'Downloader' do |ss|
    ss.source_files = "Sources/WebImage/*.{h,m}"
  end
  
end

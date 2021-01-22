//
//  ViewController.m
//  KJBannerViewDemo
//
//  Created by 杨科军 on 2018/12/22.
//  Copyright © 2018 杨科军. All rights reserved.
//
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

Github地址：https://github.com/yangKJ
简书地址：https://www.jianshu.com/u/c84c00476ab6
博客地址：https://blog.csdn.net/qq_34534179
掘金地址：https://juejin.cn/user/1987535102554472/posts
 
* 如果觉得好用,希望您能Star支持,你的 ⭐️ 是我持续更新的动力!
*
*********************************************************************************
*/
#import "ViewController.h"
#import "KJBannerHeader.h"
#import "KJCollectionViewCell.h"
#import "KJBannerModel.h"
#import "KJTestViewController.h"
#import <Masonry/Masonry.h>
#import "UIImageView+KJWebImage.h"

#define gif @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1564463770360&di=c93e799328198337ed68c61381bcd0be&imgtype=0&src=http%3A%2F%2Fimg.mp.itc.cn%2Fupload%2F20170714%2F1eed483f1874437990ad84c50ecfc82a_th.jpg"
#define gif2 @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1579085817466&di=0c1cba2b5dba938cd33ea7d053b1493a&imgtype=0&src=http%3A%2F%2Fww2.sinaimg.cn%2Flarge%2F85cc5ccbgy1ffngbkq2c9g20b206k78d.jpg"

#define tu1 @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1579082232413&di=2775dc6e781e712d518bf1cf7a1e675e&imgtype=0&src=http%3A%2F%2Fimg3.doubanio.com%2Fview%2Fnote%2Fl%2Fpublic%2Fp41813904.jpg"
#define tu2 @"http://photos.tuchong.com/285606/f/4374153.jpg"

@interface ViewController ()<KJBannerViewDelegate,KJBannerViewDataSource>
@property (weak, nonatomic) IBOutlet KJBannerView *banner;
@property (weak, nonatomic) IBOutlet KJBannerView *banner3;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UISwitch *Switch;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (nonatomic,strong) UILabel *label1,*label2;
@property (nonatomic,strong) KJBannerView *banner2;
@property (nonatomic,strong) NSArray *temp;
@end

@implementation ViewController

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.banner kj_repauseTimer];
    [self.banner2 kj_repauseTimer];
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.banner kj_pauseTimer];
    [self.banner2 kj_pauseTimer];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _setDatas];
    [self setXib];
    [self setMasonry];
    [self setText];
    [self setUI];
}

- (void)setUI{
    [self.button addTarget:self action:@selector(clearAction) forControlEvents:(UIControlEventTouchUpInside)];
    [self.Switch addTarget:self action:@selector(qiehuanAction:) forControlEvents:(UIControlEventValueChanged)];
    self.label.text = [NSString stringWithFormat:@"缓存大小：%.02f MB",[KJBannerViewCacheManager kj_getLocalityImageCacheSize] / 1024 / 1024.0];
}
- (void)setText{
    self.banner3.showPageControl = NO;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    self.banner3.itemClass = [KJCollectionViewCell class];
#pragma clang diagnostic pop
    self.banner3.rollType = KJBannerViewRollDirectionTypeBottomToTop;
    self.banner3.imageDatas = @[@"测试文本滚动",@"觉得好用请给我点个星",@"有什么问题也可以联系我",@"邮箱: ykj310@126.com"];
}
- (void)setMasonry{
    self.banner2 = [[KJBannerView alloc]init];
    self.banner2.autoTime = 2;
    self.banner2.isZoom = YES;
    self.banner2.itemSpace = -10;
    self.banner2.itemWidth = 280;
    self.banner2.delegate = self;
    self.banner2.dataSource = self;
    self.banner2.imageType = KJBannerViewImageTypeMix;
    self.banner2.pageControl.pageType = PageControlStyleSizeDot;
    self.banner2.pageControl.displayType = KJPageControlDisplayTypeRight;
    self.banner2.pageControl.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.5];
    [self.backView addSubview:self.banner2];
    [self.banner2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.mas_equalTo(0);
    }];
    [self.banner2 kj_useMasonry];
    self.banner2.imageDatas = self.temp;
}
- (void)setXib{
    self.banner.delegate = self;
    self.banner.pageControl.pageType = PageControlStyleRectangle;
    self.banner.pageControl.selectColor = UIColor.greenColor;
    self.banner.pageControl.dotwidth = 20;
    self.banner.pageControl.dotheight = 2;
    self.banner.pageControl.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.5];
    self.banner.pageControl.displayType = KJPageControlDisplayTypeLeft;
    self.banner.imageType = KJBannerViewImageTypeMix;
    self.banner.bannerScale = YES;
    self.banner.rollType = KJBannerViewRollDirectionTypeBottomToTop;
    self.banner.bannerContentMode = UIViewContentModeScaleAspectFill;
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    self.banner.imageDatas = @[tu2,gif2,@"IMG_0139",@"tu3",gif];
    [self.banner kj_makeScrollToIndex:2];
    NSLog(@"banner_time: %f", CFAbsoluteTimeGetCurrent() - start);
}
- (void)_setDatas{
    NSArray *images = @[@"http://photos.tuchong.com/285606/f/4374153.jpg",@"IMG_4931",tu1];
    NSMutableArray *arr = [NSMutableArray array];
    for (int i=0; i<images.count; i++) {
        KJBannerModel *model = [[KJBannerModel alloc]init];
        model.customImageUrl = images[i];
        model.customTitle = [NSString stringWithFormat:@"图片名称:%d",i];
        [arr addObject:model];
    }
    self.temp = arr;
}
- (void)qiehuanAction:(UISwitch*)sender{
    if (sender.on) {
        self.banner2.imageDatas = self.temp;
    }else{
        self.banner2.imageDatas = @[];
    }
}
- (void)clearAction{
    [KJBannerViewCacheManager kj_clearLocalityImageAndCache];
    self.label.text = [NSString stringWithFormat:@"缓存大小：%.02f MB",[KJBannerViewCacheManager kj_getLocalityImageCacheSize] / 1024 / 1024.0];
}
- (IBAction)pauseRoll:(UIButton *)sender {
    [self.banner kj_pauseTimer];
    [self.banner2 kj_pauseTimer];
    [self.banner3 kj_pauseTimer];
}
- (IBAction)repauseRoll:(UIButton *)sender {
    [self.banner kj_repauseTimer];
    [self.banner2 kj_repauseTimer];
    [self.banner3 kj_repauseTimer];
}

#pragma mark - KJBannerViewDelegate
//点击图片的代理
- (void)kj_BannerView:(KJBannerView *)banner SelectIndex:(NSInteger)index{
    KJTestViewController *vc = [KJTestViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}
- (BOOL)kj_BannerView:(KJBannerView *)banner CurrentIndex:(NSInteger)index{
    self.label.text = [NSString stringWithFormat:@"缓存大小：%.02f MB",[KJBannerViewCacheManager kj_getLocalityImageCacheSize] / 1024 / 1024.0];
    if (banner == self.banner2) return NO;
    return NO;
}
- (void)kj_BannerViewDidScroll:(KJBannerView*)banner{
    
}

#pragma mark - KJBannerViewDataSource
- (UIView*)kj_BannerView:(KJBannerView*)banner BannerViewCell:(KJBannerViewCell*)bannercell ImageDatas:(NSArray*)imageDatas Index:(NSInteger)index{
    KJBannerModel *model = imageDatas[index];
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:bannercell.contentView.bounds];
    [imageView kj_setImageWithURL:[NSURL URLWithString:model.customImageUrl] placeholder:[UIImage imageNamed:@"tu3"]];
//    [imageView kj_setImageWithURLString:model.customImageUrl Placeholder:[UIImage imageNamed:@"tu3"]];
    if (index == 0) {
        CGRect rect = {0, 0, 100, 20};
        UILabel *label = [[UILabel alloc]initWithFrame:rect];
        [imageView addSubview:label];
        label.text = @"定制不同的控件";
        label.frame = CGRectMake(0, 0, bannercell.contentView.frame.size.width, 40);
        label.font = [UIFont boldSystemFontOfSize:35];
        label.textColor = UIColor.greenColor;
        label.textAlignment = NSTextAlignmentCenter;
    }
    return imageView;
}

@end

//
//  ViewController.m
//  KJBannerViewDemo
//
//  Created by 杨科军 on 2018/12/22.
//  Copyright © 2018 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo
#import "ViewController.h"
#import "KJBannerHeader.h"
#import "KJCollectionViewCell.h"
#import "KJBannerModel.h"
#import "KJTestViewController.h"
#import <Masonry/Masonry.h>
#import "BaseImageView.h"
#import "UIView+KJWebImage.h"

#define gif @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1564463770360&di=c93e799328198337ed68c61381bcd0be&imgtype=0&src=http%3A%2F%2Fimg.mp.itc.cn%2Fupload%2F20170714%2F1eed483f1874437990ad84c50ecfc82a_th.jpg"

#define tu1 @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1579082232413&di=2775dc6e781e712d518bf1cf7a1e675e&imgtype=0&src=http%3A%2F%2Fimg3.doubanio.com%2Fview%2Fnote%2Fl%2Fpublic%2Fp41813904.jpg"
#define tu2 @"http://photos.tuchong.com/285606/f/4374153.jpg"
#define tu3 @"https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fgss0.baidu.com%2F-4o3dSag_xI4khGko9WTAnF6hhy%2Fzhidao%2Fpic%2Fitem%2Ff636afc379310a558f3f592dbb4543a9832610cb.jpg&refer=http%3A%2F%2Fgss0.baidu.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1614246801&t=096f32d80f2f04110b4bddde27f2165e"
#define tu4 @"https://tfile.melinked.com/2021/01/5c071de1-b7e9-4bf4-a1f7-a2f35eff9ed6.jpg"

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
    [self setUI];
    [self setText];
    [self setXib];
    [self setMasonry];
   
    //清除三天前缓存的数据
    [KJBannerTimingClearManager kj_openTimingCrearCached:YES TimingTimeType:(KJBannerViewTimingTimeTypeThreeDay)];
    
    BOOL isPhoneX = ({
        BOOL isPhoneX = NO;
        if (@available(iOS 13.0, *)) {
            isPhoneX = [UIApplication sharedApplication].windows.firstObject.safeAreaInsets.bottom > 0.0;
        }else if (@available(iOS 11.0, *)) {
            isPhoneX = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0;
        }
        (isPhoneX);
    });
    UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
    button.frame = CGRectMake(10, self.view.frame.size.height-100-(isPhoneX ? 34.0f : 0.0f), self.view.frame.size.width-20, 100);
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:@"大家觉得好用还请点个星，遇见什么问题也可issues，持续更新ing.." attributes:@{
        NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle),
        NSForegroundColorAttributeName:UIColor.redColor}];
    [button setAttributedTitle:attrStr forState:(UIControlStateNormal)];
    button.titleLabel.numberOfLines = 0;
    button.titleLabel.textAlignment = 1;
    [button addTarget:self action:@selector(kj_button) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:button];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(30, button.frame.origin.y - 50, 300, 20)];
    self.label1 = label;
    label.textColor = UIColor.blueColor;
    label.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:label];
    
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(30, CGRectGetMaxY(label.frame) + 10, 300, 20)];
    self.label2 = label2;
    label2.textColor = UIColor.blueColor;
    label2.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:label2];
    
    [self kj_bannerCreateAsyncTimer:YES Task:^{
        kGCD_banner_main(^{
            self.label.text = [NSString stringWithFormat:@"缓存大小：%.02f MB",[KJBannerViewCacheManager kj_getLocalityImageCacheSize]/1024/1024.0];
            self.label1.text = [NSString stringWithFormat:@"当前设备可用内存：%.02f MB",[KJBannerModel availableMemory]];
            self.label2.text = [NSString stringWithFormat:@"当前任务所占用内存：%.02f MB",[KJBannerModel usedMemory]/2.];
        });
    } start:0 interval:.5 repeats:YES];
}
- (void)kj_button{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/yangKJ/KJBannerViewDemo"]];
#pragma clang diagnostic pop
}
- (void)setUI{
    [self.button addTarget:self action:@selector(clearAction) forControlEvents:(UIControlEventTouchUpInside)];
    [self.Switch addTarget:self action:@selector(qiehuanAction:) forControlEvents:(UIControlEventValueChanged)];
}
- (void)setText{
    self.banner3.showPageControl = NO;
    self.banner3.rollType = KJBannerViewRollDirectionTypeBottomToTop;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    self.banner3.itemClass = [KJCollectionViewCell class];
    self.banner3.imageDatas = @[@"测试文本滚动",@"觉得好用请给我点个星",@"有什么问题也可以联系我",@"邮箱: ykj310@126.com"];
#pragma clang diagnostic pop
}
- (void)setXib{
    self.banner.delegate = self;
    self.banner.pageControl.pageType = PageControlStyleRectangle;
    self.banner.pageControl.selectColor = UIColor.greenColor;
    self.banner.pageControl.dotwidth = 20;
    self.banner.pageControl.dotheight = 2;
    self.banner.pageControl.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.5];
    self.banner.pageControl.displayType = KJPageControlDisplayTypeLeft;
    self.banner.rollType = KJBannerViewRollDirectionTypeBottomToTop;
    self.banner.bannerContentMode = UIViewContentModeScaleAspectFill;
    self.banner.bannerCornerRadius = UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight;
//    self.banner.bannerNoPureBack = YES;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    self.banner.imageDatas = @[@"IMG_0139",tu2,gif,@"tu3"];
#pragma clang diagnostic pop
    [self.banner kj_makeScrollToIndex:1];
}
- (void)setMasonry{
    self.banner2 = [[KJBannerView alloc]init];
    self.banner2.autoTime = 2;
    self.banner2.isZoom = YES;
    self.banner2.itemSpace = -10;
    self.banner2.itemWidth = 280;
    self.banner2.delegate = self;
    self.banner2.dataSource = self;
    self.banner2.pageControl.pageType = PageControlStyleSizeDot;
    self.banner2.pageControl.displayType = KJPageControlDisplayTypeRight;
    self.banner2.pageControl.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.5];
    [self.backView addSubview:self.banner2];
    [self.banner2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.mas_equalTo(0);
    }];
    [self.banner2 kj_useMasonry];
    [self.banner2 kj_makeScrollToIndex:1];
}
//模拟多网络加载
- (void)_setDatas{
    __banner_weakself;
    NSMutableArray *arr = [NSMutableArray array];
    dispatch_group_t dispatchGroup = dispatch_group_create();
    dispatch_group_enter(dispatchGroup);
    dispatch_group_async(dispatchGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [weakself kj_bannerAfterTask:^{
            NSArray *images = @[tu3,tu2,tu1];
            for (int i = 0; i<images.count; i++) {
                KJBannerModel *model = [[KJBannerModel alloc]init];
                model.customImageUrl = images[i];
                model.customTitle = [NSString stringWithFormat:@"A线程图片名称:%d",i];
                NSLog(@"----%@",model.customTitle);
                [arr addObject:model];
            }
            dispatch_group_leave(dispatchGroup);
        } time:1. Asyne:YES];
    });
    dispatch_group_enter(dispatchGroup);
    dispatch_group_async(dispatchGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [weakself kj_bannerAfterTask:^{
            NSArray *images = @[tu2,tu2,tu2];
            for (int i = 0; i<images.count; i++) {
                KJBannerModel *model = [[KJBannerModel alloc]init];
                model.customImageUrl = images[i];
                model.customTitle = @"B线程图片地址";
                [arr addObject:model];
                NSLog(@"----%@",model.customTitle);
            }
            dispatch_group_leave(dispatchGroup);
        } time:.5 Asyne:YES];
    });
    dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), ^(){
        weakself.temp = arr;
        [weakself.banner2 kj_reloadBannerViewDatas];
    });
}
- (void)qiehuanAction:(UISwitch*)sender{
    if (sender.on) {
        [self _setDatas];
    }else{
        self.temp = @[];
    }
    [self.banner2 kj_reloadBannerViewDatas];
}
- (void)clearAction{
    [KJBannerViewCacheManager kj_clearLocalityImageAndCache];
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
/// 数据源
- (NSArray *)kj_setDatasBannerView:(KJBannerView *)banner{
    return self.temp;
}
- (__kindof UIView *)kj_BannerView:(KJBannerView *)banner ItemSize:(CGSize)size Index:(NSInteger)index{
    KJBannerModel *model = self.temp[index];
    BaseImageView *imageView = [[BaseImageView alloc]initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    if (model.customImage) {
        imageView.image = model.customImage;
    }else{
        [imageView kj_setImageWithURL:[NSURL URLWithString:model.customImageUrl] handle:^(id<KJBannerWebImageHandle> _Nonnull handle) {
            handle.bannerPlaceholder = [UIImage imageNamed:@"tu3"];
            handle.cropScale = YES;
            handle.bannerCompleted = ^(KJBannerImageType imageType, UIImage * image, NSData * data, NSError * error) {
                model.customImage = image;
            };
        }];
    }
    // 异步绘制圆角，支持特定方位圆角处理，原理就是绘制一个镂空图片盖在上面，所以这种只适用于纯色背景
    imageView.backgroundColor = self.backView.backgroundColor;
    UIImageView *ciview = [[UIImageView alloc]initWithFrame:imageView.bounds];
    [imageView addSubview:ciview];
    kBannerAsyncCornerRadius(size.height/4, ^(UIImage * _Nonnull image) {
        ciview.image = image;
    }, UIRectCornerAllCorners, ciview);
    if (index == 0) {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, size.width, 40)];
        [imageView addSubview:label];
        label.text = @"定制不同的控件";
        label.font = [UIFont boldSystemFontOfSize:35];
        label.textColor = UIColor.greenColor;
        label.textAlignment = NSTextAlignmentCenter;
    }else{
        CGRect rect = {0, size.height - 50, size.width, 20};
        UILabel *label = [[UILabel alloc]initWithFrame:rect];
        [imageView addSubview:label];
        label.text = model.customTitle;
        label.font = [UIFont boldSystemFontOfSize:20];
        label.textColor = UIColor.greenColor;
        label.textAlignment = NSTextAlignmentCenter;
    }
    return imageView;
}

@end

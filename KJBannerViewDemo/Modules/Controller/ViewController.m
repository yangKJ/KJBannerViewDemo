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
#import "DownloadViewController.h"
#import "KJViewModel.h"
#import "Masonry.h"

@interface ViewController ()<KJBannerViewDelegate,KJBannerViewDataSource>
@property (weak, nonatomic) IBOutlet KJBannerView *banner;
@property (weak, nonatomic) IBOutlet KJBannerView *banner3;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UISwitch *Switch;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (nonatomic,strong) KJBannerView *banner2;
@property (nonatomic,strong) NSArray *datas;
@property (nonatomic,strong) NSArray *banner3Datas;
@property (nonatomic,strong) KJViewModel *viewModel;

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
    
    [self setupUI];
    [self setText];
    [self setXib];
    [self setMasonry];
    
    [self _bingViewModel];
}

- (void)setupUI{
    BOOL isPhoneX = ({
        BOOL isPhoneX = NO;
        if (@available(iOS 13.0, *)) {
            isPhoneX = [UIApplication sharedApplication].windows.firstObject.safeAreaInsets.bottom > 0.0;
        }else if (@available(iOS 11.0, *)) {
            isPhoneX = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0;
        }
        (isPhoneX);
    });
    [self.button addTarget:self action:@selector(clearAction) forControlEvents:(UIControlEventTouchUpInside)];
    [self.Switch addTarget:self action:@selector(qiehuanAction:) forControlEvents:(UIControlEventValueChanged)];
    UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
    button.frame = CGRectMake(10, self.view.frame.size.height-100-(isPhoneX ? 34.0f : 0.0f), self.view.frame.size.width-20, 100);
    NSDictionary *attributes = @{
        NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle),
        NSForegroundColorAttributeName:UIColor.redColor
    };
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc]
                                          initWithString:@"大家觉得好用还请点个星，遇见什么问题也可issues，持续更新ing.."
                                          attributes:attributes];
    [button setAttributedTitle:attrStr forState:(UIControlStateNormal)];
    button.titleLabel.numberOfLines = 0;
    button.titleLabel.textAlignment = 1;
    [button addTarget:self action:@selector(kj_button) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:button];
    self.Switch.on = NO;
}

- (void)setText{
    self.banner3.dataSource = self;
    self.banner3.showPageControl = NO;
    self.banner3.rollType = KJBannerViewRollDirectionTypeBottomToTop;
    [self.banner3 registerClass:[KJCollectionViewCell class] forCellWithReuseIdentifier:@"banner3"];
    self.banner3Datas = @[
        @"测试文本滚动",
        @"觉得好用请给我点个星",
        @"有什么问题也可以联系我",
        @"邮箱: ykj310@126.com"
    ];
    [self.banner3 reloadData];
}
- (void)setXib{
    self.banner.delegate = self;
    self.banner.dataSource = self;
    self.banner.pageControl.pageType = PageControlStyleRectangle;
    self.banner.pageControl.selectColor = UIColor.greenColor;
    self.banner.pageControl.dotwidth = 20;
    self.banner.pageControl.dotheight = 2;
    self.banner.pageControl.displayType = KJPageControlDisplayTypeLeft;
    self.banner.pageControl.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.5];
    self.banner.rollType = KJBannerViewRollDirectionTypeBottomToTop;
    [self.banner registerClass:[KJBannerViewCell class] forCellWithReuseIdentifier:@"KJBannerViewCell"];
    
    self.datas = @[
        @"IMG_Guitar_52",
        @"IMG_0139",
        @"http://photos.tuchong.com/285606/f/4374153.jpg",
        @"https://up.54fcnr.com/pic_source/f7/1f/5d/f71f5d3cbf13f1f0f7da798aa8ddb4f9.gif",
    ];
    [self.banner reloadData];
}
- (void)setMasonry{
    [self.backView addSubview:self.banner2];
    [self.banner2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.backView);
    }];
    [self.banner2 kj_useMasonry];
}

#pragma mark - setDatas

- (void)_bingViewModel{
    self.viewModel = [[KJViewModel alloc] init];
    [self.viewModel refresh:^(NSArray * _Nonnull datas) {
        [self.banner2 reloadData];
    } haveDatas:NO];
    self.label.text = [NSString stringWithFormat:@"缓存大小：%.02f MB", [KJViewModel cacheSize]];
}

#pragma mark - action

- (void)kj_button{
    NSURL * url = [NSURL URLWithString:@"https://github.com/yangKJ/KJBannerViewDemo"];
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}

- (void)qiehuanAction:(UISwitch *)sender{
    [self.viewModel refresh:^(NSArray * _Nonnull datas) {
        [self.banner2 reloadData];
    } haveDatas:sender.on];
}
- (void)clearAction{
    [KJViewModel clearCache];
    self.label.text = [NSString stringWithFormat:@"缓存大小：%.02f MB", [KJViewModel cacheSize]];
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

- (void)kj_bannerView:(KJBannerView *)banner didSelectItemAtIndex:(NSInteger)index{
    DownloadViewController *vc = [DownloadViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)kj_bannerView:(KJBannerView *)banner loopScrolledItemAtIndex:(NSInteger)index{

}

#pragma mark - KJBannerViewDataSource

- (NSInteger)kj_numberOfItemsInBannerView:(KJBannerView *)banner {
    if (banner == self.banner) {
        return self.datas.count;
    } else if (banner == self.banner2) {
        return self.viewModel.datas.count;
    }
    return self.banner3Datas.count;
}

- (__kindof KJBannerViewCell *)kj_bannerView:(KJBannerView *)banner cellForItemAtIndex:(NSInteger)index {
    if (banner == self.banner) {
        KJBannerViewCell *cell = [banner dequeueReusableCellWithReuseIdentifier:@"KJBannerViewCell" forIndex:index];
        cell.bannerContentMode = UIViewContentModeScaleAspectFill;
        cell.bannerCornerRadius = UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight;
        cell.bannerNoPureBack = YES;
        cell.bannerRadius = 50;
        cell.imageURLString = self.datas[index];
        cell.useMineLoadImage = YES;
        return cell;
    } else if (banner == self.banner2) {
        KJBannerViewCell *cell = [banner dequeueReusableCellWithReuseIdentifier:@"banner2" forIndex:index];
        KJBannerModel *model = self.viewModel.datas[index];
        cell.imageURLString = model.customImageUrl;
        cell.useMineLoadImage = YES;
        cell.bannerRadius = 20;
        cell.bannerNoPureBack = YES;
        cell.bannerRadiusColor = self.backView.backgroundColor;
        return cell;
    }
    KJCollectionViewCell *cell = [banner dequeueReusableCellWithReuseIdentifier:@"banner3" forIndex:index];
    cell.title = self.banner3Datas[index];
    return cell;
}

- (nullable NSString *)kj_bannerView:(KJBannerView *)banner nextPreRenderedImageItemAtIndex:(NSInteger)index{
    if (banner == self.banner) {
        return self.datas[index];
    } else {
        return nil;
    }
}

- (void)kj_bannerView:(KJBannerView *)banner preRenderedImage:(UIImage *)image{
    
}

#pragma mark - lazy

- (KJBannerView *)banner2{
    if (!_banner2) {
        _banner2 = [[KJBannerView alloc] init];
        _banner2.delegate = self;
        _banner2.dataSource = self;
        _banner2.autoTime = 3;
        _banner2.isZoom = YES;
        _banner2.itemSpace = -10;
        CGSize size = CGSizeApplyAffineTransform(self.backView.frame.size, CGAffineTransformMakeScale(.7, .7));
        _banner2.itemWidth = size.width;
        _banner2.pageControl.pageType = PageControlStyleSizeDot;
        _banner2.pageControl.displayType = KJPageControlDisplayTypeRight;
        _banner2.pageControl.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.5];
        [_banner2 registerClass:[KJBannerViewCell class] forCellWithReuseIdentifier:@"banner2"];
    }
    return _banner2;
}

@end

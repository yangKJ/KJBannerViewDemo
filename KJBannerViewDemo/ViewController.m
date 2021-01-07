//
//  ViewController.m
//  KJBannerViewDemo
//
//  Created by 杨科军 on 2018/12/22.
//  Copyright © 2018 杨科军. All rights reserved.
//

#import "ViewController.h"
#import "KJBannerHeader.h"
#import "KJCollectionViewCell.h"
#import "KJBannerModel.h"
#import "KJTestViewController.h"
#import "KJLoadImageView.h"
#import "NSTimer+KJSolve.h"
#import "KJPageView.h"
#import <Masonry/Masonry.h>

#define gif @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1564463770360&di=c93e799328198337ed68c61381bcd0be&imgtype=0&src=http%3A%2F%2Fimg.mp.itc.cn%2Fupload%2F20170714%2F1eed483f1874437990ad84c50ecfc82a_th.jpg"
#define gif2 @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1579085817466&di=0c1cba2b5dba938cd33ea7d053b1493a&imgtype=0&src=http%3A%2F%2Fww2.sinaimg.cn%2Flarge%2F85cc5ccbgy1ffngbkq2c9g20b206k78d.jpg"

#define tu1 @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1579082232413&di=2775dc6e781e712d518bf1cf7a1e675e&imgtype=0&src=http%3A%2F%2Fimg3.doubanio.com%2Fview%2Fnote%2Fl%2Fpublic%2Fp41813904.jpg"
#define tu2 @"http://photos.tuchong.com/285606/f/4374153.jpg"

@interface ViewController ()<KJBannerViewDelegate,KJBannerViewDataSource>
@property (weak, nonatomic) IBOutlet KJBannerView *banner;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UISwitch *Switch;
@property (nonatomic,strong) KJBannerView *banner2;
@property (nonatomic,strong) NSArray *temp;
@property (nonatomic,strong) UILabel *label1,*label2;
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
    [self setUI];
    [self setTimer];
}

- (void)setUI{
    [self.button addTarget:self action:@selector(clearAction) forControlEvents:(UIControlEventTouchUpInside)];
    [self.Switch addTarget:self action:@selector(qiehuanAction:) forControlEvents:(UIControlEventValueChanged)];
    
    int64_t num = [KJLoadImageView kj_imagesCacheSize];
    self.label.text = [NSString stringWithFormat:@"缓存大小：%.02f MB",num / 1024 / 1024.0];
    
    CGFloat w = self.view.frame.size.width;
    CGFloat h = self.label.frame.origin.y + self.label.frame.size.height + 100;
    self.label1 = [[UILabel alloc]initWithFrame:CGRectMake(20, h + 30, w-40, 20)];
    self.label1.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:self.label1];
    
    self.label2 = [[UILabel alloc]initWithFrame:CGRectMake(20, h + 30 + 30, w-40, 20)];
    self.label2.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:self.label2];
    
    self.label1.text  = [NSString stringWithFormat:@"当前设备可用内存：%.2f MB",[KJTestViewController availableMemory]];
    self.label2.text = [NSString stringWithFormat:@"当前任务所占用内存：%.2f MB",[KJTestViewController usedMemory]];
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
    self.banner.imageType = KJBannerViewImageTypeMix;
    self.banner.bannerScale = YES;
    self.banner.rollType = KJBannerViewRollDirectionTypeBottomToTop;
    self.banner.bannerContentMode = UIViewContentModeScaleAspectFill;
    self.banner.imageDatas = @[tu2,gif2,@"IMG_0139",@"tu3"];
    [self.banner kj_makeScrollToIndex:1];
}
- (void)_setDatas{
    NSArray *images = @[@"http://photos.tuchong.com/285606/f/4374153.jpg",tu1,@"IMG_4931",tu1];
    NSMutableArray *arr = [NSMutableArray array];
    for (int i=0; i<images.count; i++) {
        KJBannerModel *model = [[KJBannerModel alloc]init];
        model.customImageUrl = images[i];
        model.customTitle = [NSString stringWithFormat:@"图片名称:%d",i];
        [arr addObject:model];
    }
    self.temp = arr;
}
- (void)setTimer{
    __weak typeof(self) weakself = self;
    NSTimer *timer = [NSTimer kj_bannerScheduledTimerWithTimeInterval:1.0 Repeats:YES Block:^(NSTimer *timer) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakself.label.text  = [NSString stringWithFormat:@"缓存大小：%.02f MB",[KJLoadImageView kj_imagesCacheSize] / 1024 / 1024.0];
            weakself.label1.text = [NSString stringWithFormat:@"当前设备可用内存：%.2f MB",[KJTestViewController availableMemory]];
            weakself.label2.text = [NSString stringWithFormat:@"当前任务所占用内存：%.2f MB",[KJTestViewController usedMemory]];
        });
    }];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}
- (void)qiehuanAction:(UISwitch*)sender{
    if (sender.on) {
        self.banner2.imageDatas = self.temp;
    }else{
        self.banner2.imageDatas = @[];
    }
}
- (void)clearAction{
    [KJLoadImageView kj_clearImagesCache];
}
- (IBAction)pauseRoll:(UIButton *)sender {
    [self.banner kj_pauseTimer];
    [self.banner2 kj_pauseTimer];
}
- (IBAction)repauseRoll:(UIButton *)sender {
    [self.banner kj_repauseTimer];
    [self.banner2 kj_repauseTimer];
}

#pragma mark - KJBannerViewDelegate
//点击图片的代理
- (void)kj_BannerView:(KJBannerView *)banner SelectIndex:(NSInteger)index{
    KJTestViewController *vc = [KJTestViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}
- (BOOL)kj_BannerView:(KJBannerView *)banner CurrentIndex:(NSInteger)index{
    if (banner == self.banner2) return NO;
    return NO;
}
- (void)kj_BannerViewDidScroll:(KJBannerView*)banner{
    
}

#pragma mark - KJBannerViewDataSource
- (UIView*)kj_BannerView:(KJBannerView*)banner BannerViewCell:(KJBannerViewCell*)bannercell ImageDatas:(NSArray*)imageDatas Index:(NSInteger)index{
    KJBannerModel *model = imageDatas[index];
    CGRect rect = {0, 0, 100, 20};
    UILabel *label = [[UILabel alloc]initWithFrame:rect];
    if (index == 0) {
        label.text = @"定制不同的控件";
        label.frame = CGRectMake(0, 0, bannercell.contentView.frame.size.width, 40);
        label.font = [UIFont boldSystemFontOfSize:35];
        label.textColor = UIColor.greenColor;
        label.textAlignment = NSTextAlignmentCenter;
    }
    KJLoadImageView *imageView = [[KJLoadImageView alloc]initWithFrame:bannercell.contentView.bounds];
    imageView.kj_isScale = YES;
    [imageView kj_setImageWithURLString:model.customImageUrl Placeholder:[UIImage imageNamed:@"tu3"]];
    [imageView addSubview:label];
    return imageView;
}

@end
